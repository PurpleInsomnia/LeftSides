package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flash.display.BlendMode;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.ui.FlxButton;
import editors.MasterEditorMenu;
import sys.FileSystem;
import arcade.ArcadePlayState;

using StringTools;

class ArcadeState extends MusicBeatState
{
	var games:Array<String> = ['worstDay', 'upset', 'attempt'];
	var colors:Array<FlxColor> = [0xFF5E4128, 0xFF8E1FB6, 0xFFFFA600, 0xFFD84949];

	var gg:FlxTypedGroup<FlxSprite>;

	var curSelected:Int = 0;

	var bg:FlxSprite;

	var canPress:Bool = true;

	override function create()
	{
		bg = new FlxSprite().loadGraphic(Paths.image('arcade/menu/bg'));
		bg.color = colors[curSelected];
		add(bg);

		gg = new FlxTypedGroup<FlxSprite>();
		add(gg);

		canPress = true;

		if (ClientPrefs.week8Done)
		{
			games.push('knuckles');
		}

		FlxG.sound.playMusic(Paths.music('arcade/menu'));

		for (i in 0...games.length)
		{
			var thingy:FlxSprite = new FlxSprite();
			thingy.loadGraphic(Paths.image('arcade/menu/' + games[i]));
			thingy.x = 128;
			thingy.x += 260 * i;
			thingy.ID = i;
			thingy.screenCenter(Y);
			gg.add(thingy);
		}

		startTweens();

		changeSelection();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_RIGHT_P && canPress)
		{
			changeSelection(1);
		}
		if (controls.UI_LEFT_P && canPress)
		{
			changeSelection(-1);
		}
		if (controls.ACCEPT && canPress)
		{
			canPress = false;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			if (games[curSelected] != 'knuckles')
			{
				ArcadePlayState.curStory = games[curSelected];
				ArcadePlayState.curRoom = 0;
				FlxG.sound.music.stop();
				MusicBeatState.switchState(new ArcadePlayState());
			}
			else
			{
				// sex
			}
		}

		super.update(elapsed);
	}

	function changeSelection(bruh:Int = 0)
	{
		curSelected += bruh;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		if (curSelected >= games.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = games.length - 1;

		bg.color = colors[curSelected];

		gg.forEach(function(spr:FlxSprite)
		{
			
			if (spr.ID == curSelected)
			{
				spr.y -= 50;
			}
			else
			{
				spr.screenCenter(Y);
			}
		});
	}

	function startTweens()
	{
		var secs:Array<Float> = [0.33, 0.66, 0.99];

		if (games.contains('knuckles'))
		{
			secs = [0.25, 0.5, 0.75, 1];
		}

		for (i in 0...games.length)
		{
			new FlxTimer().start(secs[i], function(tmr:FlxTimer)
			{
				FlxTween.tween(gg.members[i], {alpha: 0.75}, 0.85, {type: PINGPONG});
			});
		}
	}
}