package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import openfl.Assets;
import sys.FileSystem;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;

class DoodlesConceptState extends MusicBeatState
{
	var stuff:Array<String> = [
		'sooubway:image',
		'bficon:image',
		'monsterNotes:image',
		'trickyIcon:image',
		'nightmare:music',
		'pico:music',
		'dad:music'
	];

	var descs:Array<String> = [
		"Concept for Ben and Tess in their Subway Uniforms.\n(Tess SHOULD be wearing her hair in a different way but whatever I guess.)",
		'Unused icon that was going to be used in "High"',
		'Unused "Monster Notes". They would change from regular notes to a mine note',
		"Left Sides Tricky icon concept",
		'Unused instrumental to a song that would take place after "They Go Upstairs"\n(Press Enter To Play)',
		'Unused dialogue theme for Pico\n(Press Enter To Play)',
		'Unused dialogue theme for Daddy Dearest\n(Press Enter To Play)'
	];

	var spriteGroup:FlxTypedGroup<FlxSprite>;
	var text:FlxText;
	var penisMusic:FlxSound = null;
	var camStuff:Array<Float> = [];

	var camFollow:FlxSprite;
	var curSelected:Int = 0;

	var canPress:Bool = true;

	override function create()
	{
		curSelected = 0;
		canPress = true;

		camFollow = new FlxSprite().makeGraphic(1, 1, 0x00FFFFFF);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow, null, 1);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.concepts('images/bg.png'));
		bg.scrollFactor.set(0, 0);
		add(bg);

		var spikes:FlxSprite = new FlxSprite().loadGraphic(Paths.concepts('images/spikes.png'));
		spikes.scrollFactor.set(0, 0);
		add(spikes);
		FlxTween.tween(spikes, {x: -1280}, 5, {type: LOOPING});

		spriteGroup = new FlxTypedGroup<FlxSprite>();
		add(spriteGroup);

		for (i in 0...stuff.length)
		{
			var split:Array<String> = stuff[i].split(':');
			if (split[1] == 'image')
			{
				var sprite:FlxSprite = new FlxSprite().loadGraphic(Paths.concepts('images/' + split[0] + '.png'));
				sprite.screenCenter();
				sprite.x += 1280 * i;
				camStuff.push(camFollow.x + (1280 * i));
				spriteGroup.add(sprite);
			}
			if (split[1] == 'music')
			{
				var sprite:FlxSprite = new FlxSprite().loadGraphic(Paths.concepts('images/soundFile.png'));
				sprite.screenCenter();
				sprite.x += 1280 * i;
				camStuff.push(camFollow.x + (1280 * i));
				spriteGroup.add(sprite);
			}
		}

		var textBG:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 125, 0xFF000000);
		textBG.scrollFactor.set(0, 0);
		textBG.y = FlxG.height - 125;
		add(textBG);

		text = new FlxText(0, textBG.y, FlxG.width, 'BIG SEX', 24);
		text.font = Paths.font('eras.ttf');
		text.scrollFactor.set(0, 0);
		add(text);

		changeSelection();

		super.create();
	}

	override function update(elapsed)
	{
		if (controls.UI_RIGHT_P && canPress)
			changeSelection(1);

		if (controls.UI_LEFT_P && canPress)
			changeSelection(-1);

		if (controls.ACCEPT && canPress)
		{
			var split:Array<String> = stuff[curSelected].split(':');
			if (split[1] == 'music')
			{
				FlxG.sound.music.volume = 0;
				if (penisMusic != null)
				{
					penisMusic.stop();
					penisMusic = null;
				}
				penisMusic = FlxG.sound.load(Paths.concepts('music/' + split[0] + '.ogg'));
				penisMusic.play();
			}
		}

		if (controls.BACK && canPress)
		{
			canPress = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			var split:Array<String> = stuff[curSelected].split(':');
			if (split[1] == 'music')
			{
				FlxG.sound.music.volume = 1;
				if (penisMusic != null)
					penisMusic.stop();
			}
			MusicBeatState.switchState(new DoodlesState());
		}
	}

	function changeSelection(?huh:Int = 0)
	{
		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += huh;

		if (curSelected >= stuff.length)
		{
			curSelected = 0;
		}
		if (curSelected < 0)
		{
			curSelected = stuff.length - 1;
		}

		FlxTween.tween(camFollow, {x: camStuff[curSelected]}, 0.5, {ease: FlxEase.sineOut});

		text.text = descs[curSelected];

		var split:Array<String> = stuff[curSelected].split(':');
		if (split[1] == 'image')
		{
			FlxG.sound.music.volume = 1;
			if (penisMusic != null)
			{
				penisMusic.stop();
				penisMusic = null;
			}
		}
	}
}