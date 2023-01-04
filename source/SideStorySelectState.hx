package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import openfl.display.BlendMode;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef CustomFile = {
	var names:Array<String>;
	var dataFolders:Array<String>;
	var lockedUntil:Array<String>;
	var colours:Array<Array<String>>;
}

class SideStorySelectState extends MusicBeatState
{
	// KEY: Name, icon path, unlocked (0 for false, 1 for true), Colour 1 (top), Colour 2 (bottom), Colour 3 (grid)
	public static var storyList:Array<Array<Dynamic>> = [
		["Halloween", "halloween", 0, "0xFFFF8400", "0xFF000000", "0xFFCFCFCF"],
		["Saturday", "saturday", 0, "0xFF9D00FF", "0xFFFF7E00", "0xFF3F3F3F"],
		["Talking", "talking", 0, "0x7F9D00FF", "0x7FFD00FF", "0xFF7F7F7F"]
	];

	public static var directories:Array<String> = [Paths.mods()];

	public static var toRead:Array<Array<Dynamic>> = [];

	public static var realList:Array<Array<Dynamic>> = [];

	public static var customStories:Array<Array<Dynamic>> = [];

	public static var amountUnlocked:Int = 0;

	public static var curSelected:Int = 0;
	public static var curDirect:String = "";

	public static var canPress:Bool = false;
	public static var noStories:Bool = false;
	// no stories? :(

	public static var camFollow:FlxSprite;
	public static var camX:Array<Float> = [];

	public static var colourSpr:FlxSprite;
	public static var gradient1:FlxSprite;
	public static var gradient2:FlxSprite;

	public static var nameTxt:FlxText;

	override function create()
	{
		noStories = false;
		amountUnlocked = 0;
		curSelected = 0;
		camX = [];
		realList = [];
		// sorting this shit bc im stupid af.

		directories = [Paths.mods()];
		customStories = [];
		curDirect = "";
		getCustomStories();

		toRead = [storyList[0], storyList[1], storyList[2]];
		if (customStories != [])
		{
			for (i in 0...customStories.length)
			{
				if ((storyList[0][2] != 0 && storyList[1][2] != 0 && storyList[2][2] != 0) || ClientPrefs.devMode)
				{
					toRead.push(customStories[i]);
				}
			}
		}

		FlxG.sound.playMusic(Paths.music("storyTeller"), 1, true);

		camFollow = new FlxSprite().makeGraphic(1, 1, 0xFF000000);
		camFollow.screenCenter();
		add(camFollow);

		FlxG.camera.follow(camFollow, null, 1);

		add(new GridBackdrop());

		colourSpr = new FlxSprite().loadGraphic(Paths.image("sideStories/bg"));
		colourSpr.blend = BlendMode.MULTIPLY;
		colourSpr.scrollFactor.set(0, 0);
		add(colourSpr);

		gradient1 = new FlxSprite().loadGraphic(Paths.image("sideStories/gradient1"));
		gradient1.blend = BlendMode.MULTIPLY;
		gradient1.scrollFactor.set(0, 0);
		add(gradient1);

		gradient2 = new FlxSprite().loadGraphic(Paths.image("sideStories/gradient2"));
		gradient2.blend = BlendMode.MULTIPLY;
		gradient2.scrollFactor.set(0, 0);
		add(gradient2);

		for (i in 0...toRead.length)
		{
			if (toRead[i][2] == 1 || ClientPrefs.devMode)
			{
				realList.push(toRead[i]);
				amountUnlocked += 1;

				var graphic:FlxSprite = new FlxSprite();
				if (toRead[i].length != 7)
				{
					graphic.loadGraphic("assets/side-stories/images/icons/" + toRead[i][1] + ".png");
				}
				else
				{
					var split:Array<String> = toRead[i][6].split("/");
					Paths.currentModDirectory = split[1];
					graphic.loadGraphic(Paths.funnyFlxGraphic("side-stories/images/icons/" + toRead[i][1] + ".png"));
				}
				graphic.screenCenter();
				graphic.y += 25;
				graphic.x += 1280 * i;
				add(graphic);

				camX.push(camFollow.x + (1280 * i));
			}
		}

		trace(amountUnlocked);
		trace("goofy ahh bug");

		canPress = true;

		if (amountUnlocked == 0)
		{
			noStories = true;
			gradient1.visible = false;
			gradient2.visible = false;
			colourSpr.color = 0xFF000000;

			var stupidBitch:FlxText = new FlxText(0, 0, FlxG.width, "You Do Not Have Any\nSide Stories Unlocked Yet.\nComplete Weeks (or songs)\nTo Unlock Them!\n", 48);
			stupidBitch.font = Paths.font("eras.ttf");
			stupidBitch.alignment = CENTER;
			stupidBitch.screenCenter();
			stupidBitch.scrollFactor.set(0, 0);
			add(stupidBitch);

			FlxTween.tween(stupidBitch, {y: stupidBitch.y + 10, alpha: 0.5}, 1, {type: PINGPONG});
		}
		else
		{
			nameTxt = new FlxText(0, 25, FlxG.width, "", 42);
			nameTxt.setFormat(Paths.font("eras.ttf"), 42, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
			nameTxt.screenCenter(X);
			nameTxt.scrollFactor.set(0, 0);
			add(nameTxt);

			changeStory(0);
		}

		trace("goofy ahh bug");

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (canPress)
		{
			if (!noStories)
			{
				if (controls.UI_RIGHT_P)
				{
					FlxG.sound.play(Paths.sound("scrollMenu"));
					changeStory(1);
				}
				if (controls.UI_LEFT_P)
				{
					FlxG.sound.play(Paths.sound("scrollMenu"));
					changeStory(-1);
				}
				if (controls.ACCEPT)
				{
					// nothing yet :|
					var name:String = realList[curSelected][1];
					trace(Paths.getModFile("side-stories/data/" + name + "/dialogue.txt"));
					var file:Array<String> = [];
					if (Paths.currentModDirectory == "")
						file = CoolUtil.coolTextFile("assets/side-stories/data/" + name + "/dialogue.txt");
					else
						file = CoolUtil.coolTextFile(Paths.getModFile("side-stories/data/" + name + "/dialogue.txt"));

					FlxG.sound.music.stop();
					MusicBeatState.switchState(new SideStoryState(file, name, Paths.currentModDirectory));
				}
				nameTxt.screenCenter(X);
			}
			if (controls.BACK)
			{
				canPress = false;
				FlxG.sound.music.stop();
				FlxG.sound.play(Paths.sound("cancelMenu"));
				MusicBeatState.switchState(new MainMenuState());
			}
		}
		super.update(elapsed);
	}

	public static var colourTween1:FlxTween;
	public static var colourTween2:FlxTween;
	public static var colourTween3:FlxTween;
	public static var camTween:FlxTween;
	public static function changeStory(?huh:Int = 0)
	{
		if (colourTween1 != null)
			colourTween1.cancel();
		if (colourTween2 != null)
			colourTween2.cancel();
		if (colourTween3 != null)
			colourTween3.cancel();
		if (camTween != null)
			camTween.cancel();

		curSelected += huh;

		if (curSelected >= realList.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = realList.length - 1;

		colourTween1 = FlxTween.color(gradient1, 0.5, gradient1.color, Std.parseInt(realList[curSelected][3]));
		colourTween2 = FlxTween.color(gradient2, 0.5, gradient2.color, Std.parseInt(realList[curSelected][4]));
		colourTween3 = FlxTween.color(colourSpr, 0.5, colourSpr.color, Std.parseInt(realList[curSelected][5]));
		camTween = FlxTween.tween(camFollow, {x: camX[curSelected]}, 0.5, {ease: FlxEase.sineInOut});

		nameTxt.text = realList[curSelected][0];

		if (customStories != [])
		{
			if (curSelected >= (amountUnlocked - customStories.length))
			{
				var daSplit:Array<String> = realList[curSelected][6].split("/");
				curDirect = daSplit[1];
				Paths.currentModDirectory = daSplit[1];
			}
			else
			{
				curDirect = "";
				Paths.currentModDirectory = "";
			}
		}
	}

	public static function save()
	{
		FlxG.save.data.storyList = storyList;

		FlxG.save.flush();
	}

	public static function load()
	{
		if (FlxG.save.data.storyList != null)
		{
			storyList = FlxG.save.data.storyList;
			if (storyList.length > 3)
			{
				storyList = [
					["Halloween", "halloween", 0, "0xFFFF8400", "0xFF000000", "0xFFCFCFCF"],
					["Saturday", "saturday", 0, "0xFF9D00FF", "0xFFFF7E00", "0xFF3F3F3F"],
					["Talking", "talking", 0, "0x7F9D00FF", "0x7FFD00FF", "0xFF7F7F7F"]
				];
			}
		}
	}

	function getCustomStories()
	{
		checkMods();
		var customFile:CustomFile = null;
		for (i in 0...directories.length)
		{
			if (FileSystem.exists(directories[i] + "side-stories/data/sidestories.json"))
			{
				customFile = Json.parse(File.getContent(directories[i] + "side-stories/data/sidestories.json"));
				for (j in 0...customFile.names.length)
				{
					var toPush:Array<Dynamic> = [customFile.names[j], customFile.dataFolders[j]];
					if (Highscore.getWeekScore(customFile.lockedUntil[j], 1) > 0 || ClientPrefs.devMode)
					{
						toPush.push(1);
					}
					else
					{
						toPush.push(0);
					}
					for (colourthing in customFile.colours[j])
					{
						toPush.push(colourthing);
					}
					toPush.push(directories[i]);
					customStories.push(toPush);
				}
			}
		}
	}

	function checkMods()
	{
		var modsListPath:String = 'modsList.txt';
		var originalLength:Int = directories.length;
		if(FileSystem.exists(modsListPath))
		{
			var stuff:Array<String> = CoolUtil.coolTextFile(modsListPath);
			for (i in 0...stuff.length)
			{
				var splitName:Array<String> = stuff[i].trim().split('|');
				if(splitName[1] == '0') // Disable mod
				{
					// pussy
				}
				else // Sort mod loading order based on modsList.txt file
				{
					var path = haxe.io.Path.join([Paths.mods(), splitName[0]]);
					//trace('trying to push: ' + splitName[0]);
					if (sys.FileSystem.isDirectory(path) && !Paths.ignoreModFolders.exists(splitName[0]) && splitName[1] == '1' && !directories.contains(path))
					{
						directories.push(path + '/');
					}
				}
			}
		}
	}
}