package arcade;

import flixel.FlxG;
import flixel.FlxSprite;

class CutsceneItem extends FlxSprite
{
	public var name:String;
	public var otherString:String;

	override public function new(x:Int = 0, y:Int = 0, cutsceneName:String = 'none', otherThing:String = 'none')
	{
		super(x, y);
		

		loadGraphic(Paths.arcade('transparent.png'));
		name = cutsceneName;
		otherString = otherThing;
	}

	public function start(name:String = 'sex', otherThing:String = 'sex2')
	{
		switch(name)
		{
			case 'dialogue':
				ArcadePlayState.startDialogue(otherThing);
		}
	}
}