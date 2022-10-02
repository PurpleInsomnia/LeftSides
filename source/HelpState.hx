package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class HelpState extends MusicBeatState
{
	var vg:FlxSprite;

	override function create()
	{
		add(new FlxSprite().loadGraphic(Paths.image('help')));

		FlxG.sound.play(Paths.sound('help'));

		vg = new FlxSprite().loadGraphic(Paths.image('helpVG'));
		vg.alpha = 0;
		add(vg);

		FlxTween.tween(vg, {alpha: 1}, 10, {onComplete: function(twn:FlxTween)
		{
			#if desktop
			Sys.exit(0);
			#else
			MusicBeatState.switchState(new options.Extras());
			#end
		}});

		super.create();
	}
}