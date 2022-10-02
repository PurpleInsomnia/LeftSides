package arcade;

import flixel.FlxG;
import flixel.FlxSprite;
import Paths;
import flixel.FlxBasic;

using StringTools;

class LockedDoor extends FlxSprite
{
	public var message:String;

	override public function new(x:Int, y:Int, textThing:String = 'sex')
	{
		super(x, y);
		loadGraphic(Paths.arcade('images/door.png'));
		message = textThing;
		// yep thats ALL you need I guess LMFAO
	}

	public function displayMessage(thing:String = 'sex')
	{
		ArcadePlayState.startDialogue(thing);
	}
}