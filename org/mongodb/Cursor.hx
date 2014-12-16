package org.mongodb;

import haxe.Int64;

class Cursor<T>
{

	public function new(collection:String)
	{
		this.collection = collection;
		this.finished = false;
		this.documents = new Array();

		checkResponse();
	}

	private inline function checkResponse():Bool
	{
		cursorId = Protocol.response(documents);
		if (documents.length == 0)
		{
			finished = true;
			if (cursorId != null)
			{
				Protocol.killCursors([cursorId]);
			}
			return false;
		}
		else
		{
			return true;
		}
	}

	public function hasNext():Bool
	{
		// we've depleted the cursor
		if (finished) return false;

		if (documents.length > 0)
		{
			return true;
		}
		else
		{
			Protocol.getMore(collection, cursorId);
			if (checkResponse())
			{
				return true;
			}
		}
		return false;
	}

	public function next():T
	{
		return documents.shift();
	}

	public function iterator():Iterator<T>
	{
		return this;
	}

	private var collection:String;
	private var cursorId:Int64;
	private var documents:Array<T>;
	private var finished:Bool;

}
