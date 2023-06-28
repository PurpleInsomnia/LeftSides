package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import filters.*;

class HelpState extends MusicBeatState
{
	var vg:FlxSprite;

	var vcr:VCR;

	override function create()
	{
		if (ClientPrefs.shaders)
		{
			var toAdd:Array<BitmapFilter> = [];
        	var tv:TV = new TV();
        	var filter1:ShaderFilter = new ShaderFilter(tv.shader);
        	vcr = new VCR();
        	var filter2:ShaderFilter = new ShaderFilter(vcr.shader);
        	toAdd.push(filter1);
        	toAdd.push(filter2);
        	FlxG.camera.setFilters(toAdd);
		}

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
			MusicBeatState.switchState(new MonsterLairState());
			#end
		}});

		super.create();
	}

	override function update(elapsed) 
	{
		if (ClientPrefs.shaders)
		{
			vcr.update(elapsed);
		}
		super.update(elapsed);	
	}
}