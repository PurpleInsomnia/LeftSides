package arcade;

import flixel.FlxG;
import flixel.FlxSprite;
import Paths;
import flixel.FlxBasic;

class UnlockedDoor extends FlxSprite
{
	public var roomNum:Int = 0;

	override public function new(x:Int, y:Int, roomThing:Int = 0)
	{
		super(x, y);
		loadGraphic(Paths.arcade('images/door.png'));
		roomNum = roomThing;
		// yep thats ALL you need I guess LMFAO
	}
}