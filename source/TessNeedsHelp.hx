package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;

class TessNeedsHelp extends MusicBeatState
{
	var jump:FlxSprite;

	override function create()
	{
		FlxTransitionableState.skipNextTransIn = true;
		jump = new FlxSprite().loadGraphic(Paths.image("fault/3"));

		FlxG.sound.play(Paths.sound("fault/amb"), 1, true);

		var spr1:FlxSprite = new FlxSprite().loadGraphic(Paths.image("fault/0"));
		spr1.alpha = 0;
		add(spr1);

		FlxTween.tween(spr1, {alpha: 1}, 3, {onComplete: function(twn:FlxTween)
		{
			var spr2:FlxSprite = new FlxSprite().loadGraphic(Paths.image("fault/1"));
			spr2.alpha = 0;
			add(spr2);
			FlxTween.tween(spr2, {alpha: 1}, 3, {onComplete: function(twn:FlxTween)
			{
				var spr3:FlxSprite = new FlxSprite().loadGraphic(Paths.image("fault/2"));
				spr3.alpha = 0;
				add(spr3);
				FlxTween.tween(spr3, {alpha: 1}, 3, {onComplete: function(twn:FlxTween)
				{
					jumpscare();
				}});
			}});
		}});

		super.create();
	}

	function jumpscare()
	{
		add(jump);
		FlxG.sound.play(Paths.sound("fault/jump"), 1, true);
		MusicBeatState.switchState(new StoryMenuState());
	}
}