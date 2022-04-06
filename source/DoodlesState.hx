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
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import openfl.Assets;
import sys.FileSystem;
import flixel.util.FlxTimer;

using StringTools;

class DoodlesState extends MusicBeatState
{
	public static var curSelected:Int = 0;

	var doodleItems:FlxTypedGroup<FlxSprite>;
	var fanArtItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;

	#if (haxe >= "4.0.0")
	public var doodleSprites:Map<String, FlxSprite> = new Map();
	public var fanSprites:Map<String, FlxSprite> = new Map();
	#else
	public var doodleSprites:Map<String, FlxSprite> = new Map<String, Dynamic>();
	public var fanSprites:Map<String, FlxSprite> = new Map<String, Dynamic>();
	#end
	
	var doodleStrings:Array<String> = [];
	var fanArt:Array<String> = [];

	var bg:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var versionShit:FlxText;

	var blackScreen:FlxSprite;

	var fanArtPath:String;
	var fanArtDescPath:String;

	var fanArtDesc:String;

	var isDoodle:Bool = true;
	var isFanArt:Bool = false;

	var descText:FlxText;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		swagShader = new ColorSwap();

		camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxCamera.defaultCameras = [camGame];

		// NO WEIRD SHIT

		fanArtPath = 'mods/doodles/fanArtList.txt';

		fanArtDescPath = 'mods/doodles/fan-art/';

		bg = new FlxSprite().loadGraphic(Paths.image('doodleBg'));
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.shader = swagShader.shader;
		add(bg);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('breakfast'));
		}

		doodleItems = new FlxTypedGroup<FlxSprite>();
		add(doodleItems);

		fanArtItems = new FlxTypedGroup<FlxSprite>();
		add(fanArtItems);

		doodleStrings = CoolUtil.coolTextFile('mods/doodles/doodleList.txt');
		for (i in 0...doodleStrings.length)
		{
			doodleSprites.get(Paths.modsDoodles('doodles/' + doodleStrings[i]));
			Paths.addCustomGraphic(Paths.modsDoodles('doodles/' + doodleStrings[i]));
			var doodleItem:FlxSprite = new FlxSprite().loadGraphic(Paths.modsDoodles('doodles/' + doodleStrings[i]));
			doodleItem.ID = i;
			doodleItem.screenCenter();
			doodleItems.add(doodleItem);
			doodleItem.antialiasing = ClientPrefs.globalAntialiasing;
			doodleItem.visible = false;
			//doodleItem.setGraphicSize(Std.int(doodleItem.width * 0.58));
		}

		if (FileSystem.exists(fanArtPath))
		{
			fanArt = CoolUtil.coolTextFile(fanArtPath);
			for (i in 0...fanArt.length)
			{
				fanSprites.get(Paths.modsDoodles('doodles/' + fanArt[i]));
				Paths.addCustomGraphic(Paths.modsDoodles('doodles/' + fanArt[i]));
				var fanArtImage:FlxSprite = new FlxSprite().loadGraphic(Paths.modsDoodles('fan-art/' + fanArt[i]));
				fanArtImage.screenCenter();
				fanArtImage.ID = i;
				fanArtItems.add(fanArtImage);
				fanArtImage.visible = false;

				/*
				fanArtDesc = CoolUtil.coolTextFile('doodles/fan-art/' fanArt[i] + '.txt');

				if (FileSystem.exists(fanArtDesc))
				{
					descText = new FlxText(12, FlxG.height - 48, 0, fanArtDesc.length, 20);
					descText.scrollFactor.set();
					descText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
					descText.screenCenter(X);
					fanArtItems.add(descText);
				}
				*/
				// code was being poopy. >:(
			}
		}

		fanArtItems.visible = true;

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.alpha = 0;
		add(blackScreen);

		changeItem();

		versionShit = new FlxText(12, FlxG.height - 24, 0, "Press Left or Right To Look At Another Image, Press DOWN to see FAN ART!", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.screenCenter(X);
		add(versionShit);

		super.create();
	}

	var selectedSomethin:Bool = false;

	var swagShader:ColorSwap = null;

	override function update(elapsed:Float)
	{
		swagShader = new ColorSwap();

		swagShader.hue += elapsed * 0.1;

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);

		var daChoice:String = doodleStrings[curSelected];

		if (!selectedSomethin)
		{
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.UI_DOWN_P && isDoodle)
			{
				isDoodle = false;
				FlxG.sound.play(Paths.sound('coolTrans'));

				FlxTween.tween(blackScreen, {alpha: 1}, 0.5);

				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					isFanArt = true;
					fanArtItems.visible = true;
					doodleItems.visible = false;
					FlxTween.tween(blackScreen, {alpha: 0}, 0.5);
					changeItem();
					versionShit.text = "Press Left or Right To Look At Another Image, Press UP to see PurpleInsomnia's doodles!";
					versionShit.screenCenter(X);
				});
			}

			if (controls.UI_UP_P && isFanArt)
			{
				isFanArt = false;
				FlxG.sound.play(Paths.sound('coolTrans'));

				FlxTween.tween(blackScreen, {alpha: 1}, 0.5);

				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					isDoodle = true;
					fanArtItems.visible = false;
					doodleItems.visible = true;
					FlxTween.tween(blackScreen, {alpha: 0}, 0.5);
					versionShit.text = "Press Left or Right To Look At Another Image, Press DOWN to see FAN ART!";
					versionShit.screenCenter(X);
				});
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.music.stop();
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}
		}

		super.update(elapsed);

		doodleItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter();
		});

		fanArtItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter();
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;
		// bg.color = FlxColor.fromHSB(FlxG.random.int(0, 359), FlxG.random.float(0, 0.8), FlxG.random.float(0.3, 1));

		if (curSelected >= doodleItems.length && isDoodle)
			curSelected = 0;
		if (curSelected < 0 && isDoodle)
			curSelected = doodleItems.length - 1;

		if (curSelected >= fanArtItems.length && isFanArt)
			curSelected = 0;
		if (curSelected < 0 && isFanArt)
			curSelected = fanArtItems.length - 1;

		doodleItems.forEach(function(spr:FlxSprite)
		{
			spr.updateHitbox();

			if (spr.ID == curSelected && isDoodle)
			{
				spr.visible = true;
			}
			if (curSelected != spr.ID && isDoodle)
			{
				spr.visible = false;
			}
		});

		fanArtItems.forEach(function(spr:FlxSprite)
		{
			spr.updateHitbox();

			if (spr.ID == curSelected && isFanArt)
			{
				spr.visible = true;
			}
			if (curSelected != spr.ID && isFanArt)
			{
				spr.visible = false;
			}
		});
	}
}
