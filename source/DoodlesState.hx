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
import flixel.ui.FlxButton;

using StringTools;

class DoodlesState extends MusicBeatState
{
	public static var curSelected:Int = 0;

	var doodleItems:FlxTypedGroup<FlxSprite>;
	var fanArtItems:FlxTypedGroup<FlxSprite>;
	var gfItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	
	var swagShader:ColorSwap = null;

	var doodleStrings:Array<String> = [];
	var fanArt:Array<String> = [];
	var gfVault:Array<String> = [];

	var bg:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var versionShit:FlxText;

	var blackScreen:FlxSprite;
	var white:FlxSprite;

	var fanArtPath:String;
	var fanArtDescPath:String;

	var fanArtDesc:Array<String>;

	var isDoodle:Bool = true;
	var isGf:Bool = false;
	var isFanArt:Bool = false;

	var descText:FlxText;

	var sussyBaka:FlxButton;

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

		FlxG.mouse.visible = true;

		var thing:String = 'mods/doodles/GF_Vault/gf.txt';

		add(new FlxSprite().loadGraphic(Paths.image('doodleBg')));

		trace('sussy baka');

		white = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		white.visible = false;
		add(white);

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

		gfItems = new FlxTypedGroup<FlxSprite>();
		add(gfItems);

		descText = new FlxText(12, FlxG.height - 48, 0, 'penis', 20);
		descText.scrollFactor.set();
		descText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.screenCenter(X);
		add(descText);
		descText.visible = false;

		doodleStrings = CoolUtil.coolTextFile('mods/doodles/doodleList.txt');
		for (i in 0...doodleStrings.length)
		{
			var doodleItem:FlxSprite = new FlxSprite().loadGraphic(Paths.mods('doodles/doodles/' + doodleStrings[i] + '.png'));
			doodleItem.ID = i;
			if (doodleItem.height > 720)
			{
				doodleItem.setGraphicSize(Std.int(doodleItem.width), 720);
			}
			doodleItem.screenCenter();
			doodleItems.add(doodleItem);
			doodleItem.antialiasing = ClientPrefs.globalAntialiasing;
			doodleItem.visible = false;
		}

		if (FileSystem.exists(fanArtPath))
		{
			fanArt = CoolUtil.coolTextFile(fanArtPath);
			for (i in 0...fanArt.length)
			{
				var fanArtImage:FlxSprite = new FlxSprite().loadGraphic(Paths.mods('doodles/fan-art/' + fanArt[i] + '.png'));
				fanArtImage.screenCenter();
				fanArtImage.ID = i;
				fanArtItems.add(fanArtImage);
				fanArtImage.visible = false;
			}
		}

		gfVault = CoolUtil.coolTextFile(thing);
		trace(gfVault);
		for (i in 0...gfVault.length)
		{
			var gfImage:FlxSprite = new FlxSprite().loadGraphic(Paths.mods('doodles/GF_Vault/' + gfVault[i] + '.png'));
			gfImage.screenCenter();
			gfImage.ID = i;
			gfItems.add(gfImage);
			gfImage.visible = false;
		}

		fanArtItems.visible = false;
		gfItems.visible = false;

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.alpha = 0;
		add(blackScreen);

		changeItem();

		versionShit = new FlxText(12, FlxG.height - 24, 0, "Press Left or Right To Look At Another Image, Press DOWN to see FAN ART!", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.screenCenter(X);
		add(versionShit);

		add(new Acheivement(1, "You visited the doodles menu!\n(very swag)", 'artist'));

		sussyBaka = new FlxButton(0, 0, '', pressConcept);
		sussyBaka.loadGraphic(Paths.image('unusedButton'), true, 150, 150);
		sussyBaka.x = Std.int((FlxG.width - 150) - 16);
		sussyBaka.y += 16;
		add(sussyBaka);

		super.create();
	}

	var selectedSomethin:Bool = false;

	var hueOn:Bool = false;
	override function update(elapsed:Float)
	{
		swagShader.hue += elapsed * 0.1;

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);

		var daChoice:String = doodleStrings[curSelected];

		if (curSelected != 0)
		{
			sussyBaka.visible = false;
		}
		else
		{
			sussyBaka.visible = true;
		}

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

			if (FlxG.keys.justPressed.G)
			{
				if (isDoodle)
					isDoodle = false;
				if (isFanArt)
					isFanArt = false;

				isGf = true;
				FlxG.sound.play(Paths.sound('coolTrans'));

				FlxTween.tween(blackScreen, {alpha: 1}, 0.5);

				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					isFanArt = false;
					isDoodle = false;
					fanArtItems.visible = false;
					gfItems.visible = true;
					descText.visible = false;
					doodleItems.visible = false;
					white.visible = true;
					FlxTween.tween(blackScreen, {alpha: 0}, 0.5);
					changeItem();
					versionShit.text = "PurpleInsomnia is down BADDDDDDDDD";
					versionShit.screenCenter(X);
				});
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
					descText.visible = true;
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
				hueOn = false;
				FlxG.sound.play(Paths.sound('coolTrans'));

				FlxTween.tween(blackScreen, {alpha: 1}, 0.5);

				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					isDoodle = true;
					fanArtItems.visible = false;
					descText.visible = false;
					doodleItems.visible = true;
					FlxTween.tween(blackScreen, {alpha: 0}, 0.5);
					versionShit.text = "Press Left or Right To Look At Another Image, Press DOWN to see FAN ART!";
					versionShit.screenCenter(X);
				});
			}

			if (controls.BACK)
			{
				if (!isGf)
				{
					selectedSomethin = true;
					FlxG.sound.music.stop();
					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new MainMenuState());
				}
				else
				{
					isGf = false;

					FlxG.sound.play(Paths.sound('coolTrans'));

					FlxTween.tween(blackScreen, {alpha: 1}, 0.5);

					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						isDoodle = true;
						fanArtItems.visible = false;
						gfItems.visible = false;
						descText.visible = false;
						doodleItems.visible = true;
						white.visible = false;
						FlxTween.tween(blackScreen, {alpha: 0}, 0.5);
						versionShit.text = "Press Left or Right To Look At Another Image, Press DOWN to see FAN ART!";
						versionShit.screenCenter(X);
					});
				}
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

		gfItems.forEach(function(spr:FlxSprite)
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

		if (curSelected >= gfItems.length && isGf)
			curSelected = 0;
		if (curSelected < 0 && isGf)
			curSelected = gfItems.length - 1;

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

		gfItems.forEach(function(spr:FlxSprite)
		{
			spr.updateHitbox();

			if (spr.ID == curSelected && isGf)
			{
				spr.visible = true;
			}
			if (curSelected != spr.ID && isGf)
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
				fanArtDesc = CoolUtil.coolTextFile('mods/doodles/fan-art/' + fanArt[curSelected] + '.txt');
				descText.text = fanArtDesc[0];
				descText.screenCenter(X);
			}
			if (curSelected != spr.ID && isFanArt)
			{
				spr.visible = false;
			}
		});
	}

	function pressConcept()
	{
		FlxG.sound.play(Paths.sound('confirmMenu'));
		MusicBeatState.switchState(new DoodlesConceptState());
	}
}
