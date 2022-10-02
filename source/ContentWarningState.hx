package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class ContentWarningState extends MusicBeatState
{
	var warning:FlxText;

	var reasons:Array<String>= [];

	var canPress = false;

	public function new(reasons:Array<String>)
	{
		super();

		this.reasons = [];
		this.reasons = reasons;
		this.reasons.push('(Press ENTER to continue)');
		this.reasons.push('(Press ESC to leave)');
	}

	override function create()
	{
		warning = new FlxText(0, 104, 'WARNING!!\nThis Song/Week/Menu Has\nContent That May Cause Discomfort\nThis Includes:\n', 52);
		warning.setFormat(Paths.font('eras.ttf'), 52, FlxColor.WHITE, CENTER);
		warning.screenCenter(X);
		add(warning);

		for (i in 0...reasons.length)
		{
			var text:FlxText = new FlxText(0, Std.int(104 + warning.height + (36 * i)), reasons[i], 32);
			text.setFormat(Paths.font('eras.ttf'), 32, FlxColor.WHITE, CENTER);
			text.screenCenter(X);
			text.y += 720;
			add(text);
			FlxTween.tween(text, {y: text.y - 720}, 1, {onComplete: function(twn:FlxTween)
			{
				canPress = true;
			}});
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && canPress)
		{
			canPress = false;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			MusicBeatState.switchState(new HealthLossState());
		}
		if (controls.BACK && canPress)
		{
			canPress = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new StoryMenuState());
		}

		super.update(elapsed);
	}
}