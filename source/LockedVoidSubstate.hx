import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.text.FlxText;

using StringTools;

class LockedVoidSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;

	public function new()
	{
		super();

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		var text:FlxText = new FlxText(0, 180, "Complete Week 5 To Unlock!! ", 40);
		text.screenCenter();
		text.scrollFactor.set();
		add(text);

		var otherText:FlxText = new FlxText(0, 0, "Press Enter To Continue", 24);
		otherText.screenCenter(X);
		otherText.scrollFactor.set();
		otherText.y = 720 - otherText.height;
		add(otherText);
	}

	override function update(elapsed:Float)
	{
		if(controls.ACCEPT) {
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		}
		super.update(elapsed);
	}
}