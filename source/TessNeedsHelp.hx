package;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.addons.transition.FlxTransitionableState;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import filters.*;

class TessNeedsHelp extends MusicBeatState
{
	var jump:FlxSprite;

	var vcr:VCR;

	override function create()
	{
		FlxTransitionableState.skipNextTransIn = true;
		jump = new FlxSprite().loadGraphic(Paths.image("fault/3"));

		var toAdd:Array<BitmapFilter> = [];
        var tv:TV = new TV();
        var filter1:ShaderFilter = new ShaderFilter(tv.shader);
        vcr = new VCR();
        var filter2:ShaderFilter = new ShaderFilter(vcr.shader);
        toAdd.push(filter1);
        toAdd.push(filter2);
        FlxG.camera.setFilters(toAdd);

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

	override function update(elapsed) 
	{
		vcr.update(elapsed);
		super.update(elapsed);	
	}

	function jumpscare()
	{
		add(jump);
		FlxG.sound.play(Paths.sound("fault/jump"), 1, true);
		MusicBeatState.switchState(new StoryMenuState());
	}
}