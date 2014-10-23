package org.bsonspec;

import haxe.io.Input;
import haxe.io.Bytes;
import haxe.io.BytesOutput;

// TODO rename to ObjectId for more consistency with mongoDB docs and Haxe convention
class ObjectID
{

	public function new(?input:Input)
	{
		if (input == null)
		{
			// generate a new id
            // Maybe: use big endian encoding, like the mongo client (at least) 
            //        then other clients could use getTimestamp()
			var out:BytesOutput = new BytesOutput();
#if haxe3
			out.writeInt32(Math.floor(Date.now().getTime() / 1000)); // seconds
#else
			out.writeInt32(haxe.Int32.ofInt(Math.floor(Date.now().getTime() / 1000))); // seconds
#end
			out.writeBytes(machine, 0, 3);
			out.writeUInt16(pid);
			out.writeUInt24(sequence++);
			if (sequence > 0xFFFFFF) sequence = 0;
			bytes = out.getBytes();
		}
		else
		{
			bytes = Bytes.alloc(12);
			input.readBytes(bytes, 0, 12);
		}
	}

	public function toString():String
	{
		return 'ObjectID("' + bytes.toHex() + '")';
	}

	public var bytes(default, null):Bytes;
    // TODO locking or atomic increment
	private static var sequence:Int = 0;

	// machine host name
#if (neko || php || cpp)
    // TODO only first 3 chars, to little; change to hash and/or ip
	private static var machine:Bytes = Bytes.ofString(sys.net.Host.localhost());
#else
	private static var machine:Bytes = Bytes.ofString("flash");
#end
    // TODO (sys) on Linux, we can use $PPID, how about on Windows and Mac?
	private static var pid = Std.random(65536);

}
