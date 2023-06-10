package dlc;

#if DISCORD
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import sys.FileSystem;
import openfl.display.BlendMode;
import flixel.math.FlxMath;
import sys.io.File;
import haxe.Json;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxUIInputText;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;

using StringTools;

typedef ModData = 
{
	name:String,
	description:String,
	restart:Bool,
	color:Array<Int>
}

typedef DlcHomeFile =
{
	var mainMenuAsHome:Bool;
}

class DlcMenuState extends MusicBeatState
{
	var modsList:Array<Array<Dynamic>> = [];
	var graphicList:Array<Dynamic> = [];

	var bg:FlxSprite;
	var daIcons:FlxTypedGroup<Dynamic>;
	var daBigIcon:FlxSprite;
	var titleText:FlxText;
	var descText:FlxText;
	var statText:FlxText;
	var white:FlxSprite;

	var camFollow:FlxSprite;
	var camFollower:FlxSprite;

	var curSelected:Int = 0;

	var noMods:Bool = false;

	var canPress:Bool = true;

    var allowedFolders:Array<String> = [];
    var ttc:Array<String> = [];

	var check:Array<String> = [];
	var skipLastCheck:Bool = false;

	private var camGame:FlxCamera;
	private var camOV:FlxCamera;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.setDirectoryFromWeek();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Browsing DLC Packs", null);
		#end

		curSelected = 0;
		canPress = true;

		camFollow = new FlxSprite().makeGraphic(1, 1);
		camFollow.screenCenter();
		add(camFollow);

		camFollower = new FlxSprite().makeGraphic(1, 1);
		camFollower.screenCenter();
		add(camFollower);

		add(new GridBackdrop());

		bg = new FlxSprite().loadGraphic(Paths.image("freeplay/bg"));
		bg.blend = BlendMode.MULTIPLY;
		bg.scrollFactor.set(0, 0);
		add(bg);

		camGame = new FlxCamera();
		camOV = new FlxCamera();
		camOV.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camOV);
		FlxCamera.defaultCameras = [camGame];

		FlxG.camera.follow(camFollower, null, 1);

		var folders:Array<String> = Paths.getModDirectories();
		if (!FileSystem.exists("modsList.txt"))
		{
			noMods = true;
			skipLastCheck = false;
			File.saveContent("modsList.txt", "");
		}
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			// auto-updates the list incase a new pack is found :)
			check = CoolUtil.coolTextFile("modsList.txt");
			var toSave:Array<String> = [];
			var toRead:Array<String> = [];
			if (check[0] != null)
			{
				for (i in 0...check.length)
				{
					if (check[i].contains("|"))
					{
						toSave.push(check[i]);
					}
					var toSplit:Array<String> = check[i].split("|");
					toRead.push(toSplit[0]);
				}
				var cont:String = "";
				for (folder in folders)
				{
					if (!Paths.ignoreModFolders.exists(folder))
					{
						if (!toRead.contains(Std.string(folder)))
						{
							toSave.push(Std.string(folder) + "|0");
						}
					}
				}
				cont = toSave[0];
				for (i in 1...toSave.length)
				{
					cont += "\n" + toSave[i];
				}
				File.saveContent("modsList.txt", cont);
				check = CoolUtil.coolTextFile("modsList.txt");
			}
			else
			{
				var cont:String = "";
				var toSave:Array<String> = [];
				for (folder in folders)
				{
					if (!Paths.ignoreModFolders.exists(folder))
					{
						noMods = false;
						skipLastCheck = true;
						toSave.push(Std.string(folder) + "|0");
					}
				}
				cont = toSave[0];
				for (i in 1...toSave.length)
				{
					cont += "\n" + toSave[i];
				}
				File.saveContent("modsList.txt", cont);
				check = CoolUtil.coolTextFile("modsList.txt");
			}
		});

		var blackOvrlay:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFF000000);
		blackOvrlay.cameras = [camOV];
		add(blackOvrlay);

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			makeRest();
			FlxTween.tween(blackOvrlay, {alpha: 0}, 0.5);
		});

		super.create();
	}

	function makeRest()
	{
		if (check[0].length < 2 && !skipLastCheck)
		{
			noMods = true;
		}

        var path:String = 'modsList.txt';
		// FIND MOD FOLDERS
		var boolshit = true;
		var checkedFolder:Array<String> = [];
		for (i in 0...check.length)
		{
			var daSplit:Array<String> = check[i].split("|");
			checkedFolder.push(daSplit[0]);
		}
		if (!noMods)
        {
			for (folder in checkedFolder)
			{
				if(!Paths.ignoreModFolders.exists(folder))
				{
					var string:String = 'mods/' + Std.string(folder) + '/' + Std.string(folder) + '.leftSides';
					var list:Array<String> = [];
					if (FileSystem.exists('mods/' + Std.string(folder) + '/' + Std.string(folder) + '.leftSides'))
					{
						list = CoolUtil.coolTextFile(string);
					}
					else
					{
						trace('No .leftSides file found :(');
					}
					if (list[0].contains('LEFTSIDESMODFILE') && list[1].contains('LS' + Std.string(folder) + 'LS') && list[2].contains(Std.string(folder.length * 2)))
					{
						allowedFolders.push(folder);
					}
					else
					{
						trace('.leftSides file has incorrect data :(');
					}
				}
			}
		}

        // Just incase lol.
        Paths.getModFolders();

		if (!noMods)
		{
			FlxG.mouse.visible = true;
			for (i in 0...allowedFolders.length)
			{
				if(!Paths.ignoreModFolders.exists(allowedFolders[i].toLowerCase()))
				{
					var json:ModData;
					var on:Bool = false;

					Paths.currentModDirectory = allowedFolders[i];

					if (FileSystem.exists(Paths.mods(Paths.currentModDirectory + "/icon.png")))
					{
						var loadedIcon:BitmapData;
						var iconToUse:String = Paths.mods(Paths.currentModDirectory + '/icon.png');
						if(FileSystem.exists(iconToUse))
						{
							loadedIcon = BitmapData.fromFile(iconToUse);
							graphicList.push(loadedIcon);
						}
					}
					else
					{
						graphicList.push("assets/images/placeholderBg.png");
					}

					if (FileSystem.exists(Paths.mods(Paths.currentModDirectory + "/pack.json")))
					{
						json = Json.parse(Paths.getTextFromFile("pack.json"));
					}
					else
					{
						json = {
							name: "[DLC NAME]",
							description: "[DESCRIPTION]",
							restart: false,
							color: [255, 255, 255]
						}
					}

					var file:Array<String> = CoolUtil.coolTextFile(path);
					var split:Array<String> = [];
					if (file.length != 0 || file != null)
					{
						for (j in 0...file.length)
						{
							if (file[j].startsWith(allowedFolders[i]))
							{
								split = file[j].split("|");
							}
						}
					}

					if (split[1] == "1")
						on = true;
					else
						on = false;

					var toPush:Array<Dynamic> = [json, on, Paths.currentModDirectory];
					modsList.push(toPush);
				}
			}
			saveFile();

			WeekData.loadTheFirstEnabledMod();

			daIcons = new FlxTypedGroup<Dynamic>();
			add(daIcons);

			for (i in 0...modsList.length)
			{
				var icon:FlxSprite = new FlxSprite().loadGraphic(graphicList[i]);
				icon.x = 175;
				icon.screenCenter(Y);
				icon.y += (160 * i);
				icon.ID = i;
				daIcons.add(icon);
			}

			var bbb:FlxSprite = new FlxSprite(750, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
			bbb.alpha = 0.62;
			bbb.scrollFactor.set(0, 0);
			add(bbb);

			white = new FlxSprite(750, 0).makeGraphic(FlxG.width, 3, 0xFFFFFFFF);
			white.scrollFactor.set(0, 0);
			add(white);

			daBigIcon = new FlxSprite(0, 150).loadGraphic(graphicList[0]);
			daBigIcon.setGraphicSize(300, 300);
			daBigIcon.x = 750 + 175;
			daBigIcon.scrollFactor.set(0, 0);
			add(daBigIcon);

			titleText = new FlxText(775, daBigIcon.y, FlxG.width - 775, modsList[0][0].name, 42);
			titleText.font = Paths.font("vcr.ttf");
			titleText.scrollFactor.set(0, 0);
			titleText.y += daBigIcon.height + (titleText.height + 25);
			add(titleText);

			white.y = (titleText.y + titleText.height) + 5;

			descText = new FlxText(800, white.y + 50, FlxG.width - 800, modsList[0][0].description, 24);
			descText.font = Paths.font("vcr.ttf");
			descText.scrollFactor.set(0, 0);
			add(descText);

			statText = new FlxText(800 + 100, FlxG.height - 75, FlxG.width - 800, "THIS MOD IS\nPROBABLY ON", 24);
			statText.alignment = CENTER;
			statText.font = Paths.font("vcr.ttf");
			statText.scrollFactor.set(0, 0);
			changeStatusText(modsList[0][1]);
			add(statText);

			var moveButton:FlxButton = new FlxButton(800 + 50, FlxG.height - 50, "MOVE MOD TO TOP", movePress);
			moveButton.label.setFormat(Paths.font("vcr.ttf"), 6, FlxColor.BLACK, CENTER);
			moveButton.setGraphicSize(75, 25);
			moveButton.color = FlxColor.GREEN;
			add(moveButton);

			var makeButton:FlxButton = new FlxButton(30, FlxG.height - 50, "MAKE DLC PACK", function()
			{
				canPress = false;
				openSubState(new DlcMakerSubstate());
			});
			makeButton.label.setFormat(Paths.font("vcr.ttf"), 6, FlxColor.BLACK, CENTER);
			makeButton.setGraphicSize(75, 25);
			makeButton.color = FlxColor.GREEN;
			add(makeButton);

			changeSelection(0);
		}
		else
		{
			var noBitches:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("no bitches"));
			noBitches.screenCenter();
			add(noBitches);

			var makeButton:FlxButton = new FlxButton(20, FlxG.height - 50, "MAKE DLC PACK", function()
			{
				canPress = false;
				openSubState(new DlcMakerSubstate());
			});
			makeButton.label.setFormat(Paths.font("vcr.ttf"), 6, FlxColor.BLACK, CENTER);
			makeButton.setGraphicSize(75, 25);
			makeButton.screenCenter(X);
			makeButton.y += 75;
			makeButton.color = FlxColor.GREEN;
			add(makeButton);
		}
	}

	override function update(elapsed:Float)
	{
		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollower.setPosition(FlxMath.lerp(camFollower.x, camFollow.x, lerpVal), FlxMath.lerp(camFollower.y, camFollow.y, lerpVal));

		if (controls.UI_DOWN_P && !noMods && canPress)
		{
			FlxG.sound.play(Paths.sound("scrollMenu"));
			changeSelection(1);
		}
		if (controls.UI_UP_P && !noMods && canPress)
		{
			FlxG.sound.play(Paths.sound("scrollMenu"));
			changeSelection(-1);
		}
		if (controls.ACCEPT && !noMods && canPress)
		{
			FlxG.sound.play(Paths.sound("confirmMenu"));
			if (modsList[curSelected][1])
			{
				modsList[curSelected][1] = false;
			}
			else
			{
				modsList[curSelected][1] = true;
			}
			changeStatusText(modsList[curSelected][1]);
		}
		if (controls.BACK && canPress)
		{
			FlxG.sound.play(Paths.sound("cancelMenu"));
			var restart:Bool = true;
			if (!noMods)
			{
				if (modsList[curSelected][0].restart)
				{
					restart = true;
				}
				else
				{
					restart = false;
				}
			}

			FlxG.mouse.visible = false;

			saveFile();

			var switching:Bool = false;
			if (!noMods)
			{
				var useDirectory:Bool = false;
				for (i in 0...modsList.length)
				{
					if (!useDirectory)
					{
						if (modsList[i][1])
						{
							useDirectory = true;
						}
					}
				}
				if (useDirectory)
				{
					Paths.currentModDirectory = modsList[curSelected][2];
				}
				else
				{
					Paths.currentModDirectory = "";
				}
				if (FileSystem.exists("mods/" + Paths.currentModDirectory + "/home.json"))
				{
					var homeFile:DlcHomeFile = Json.parse(Paths.getTextFromFile("home.json"));
					if (homeFile.mainMenuAsHome)
					{
						switching = true;
						MusicBeatState.switchState(new MainMenuState());
					}
				}
			}

			if (!switching)
			{
				if (restart)
				{
					MusicBeatState.switchState(new TitleScreenState());
				}
				else
				{
					FlxG.sound.music.stop();
					MusicBeatState.switchState(new MainMenuState());
				}
			}
		}
		super.update(elapsed);
	}

	var colourTween:FlxTween;
	function changeSelection(huh:Int)
	{
		if (colourTween != null)
			colourTween.cancel();

		curSelected += huh;

		if (curSelected >= modsList.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = modsList.length - 1;

		camFollow.y = daIcons.members[curSelected].getGraphicMidpoint().y;

		daBigIcon.loadGraphic(graphicList[curSelected]);
		daBigIcon.setGraphicSize(300, 300);
		daBigIcon.updateHitbox();
		daBigIcon.y = 75;
		daBigIcon.x = 750 + 115;

		titleText.text = modsList[curSelected][0].name;
		descText.text = modsList[curSelected][0].description;
		white.y = (titleText.y + titleText.height) + 5;
		descText.y = white.y + 50;

		changeStatusText(modsList[curSelected][1]);

		daIcons.forEach(function(spr:FlxSprite)
		{
			spr.alpha = 0.5;
			if (spr.ID == curSelected)
				spr.alpha = 1;
		});

		var colour:FlxColor = FlxColor.fromRGB(modsList[curSelected][0].color[0], modsList[curSelected][0].color[1], modsList[curSelected][0].color[2]);
		colourTween = FlxTween.color(bg, 0.75, bg.color, colour);
	}

	function changeStatusText(on:Bool)
	{
		if (on)
		{
			statText.color = FlxColor.LIME;
			statText.text = "THIS DLC IS\nON\n";
		}
		else
		{
			statText.color = FlxColor.RED;
			statText.text = "THIS DLC IS\nOFF\n";
		}
	}

	function saveFile()
	{
		var cont:String = "";
		if (modsList[0] == null)
		{
			return;
		}
		for (i in 0...modsList.length)
		{
			if(cont.length > 0) cont += '\n';
			var toAdd:String = "0";
			if (!modsList[i][1])
			{
				toAdd = "0";
			}
			else
			{
				toAdd = "1";
			}
			cont += modsList[i][2] + "|" + toAdd;
		}

		var path:String = "modsList.txt";
		File.saveContent(path, cont);
	}

	function moveToTop(mod:Array<Dynamic>)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"));
		modsList.remove(mod);
		modsList.insert(0, mod);
		saveFile();
		MusicBeatState.switchState(new DlcMenuState());
	}

	function movePress()
	{
		var mod:Array<Dynamic> = modsList[curSelected];
		moveToTop(mod);
	}
}

class DlcMakerSubstate extends MusicBeatSubstate
{
	public var input:FlxUIInputText = null;

	public function new()
	{
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bg.scrollFactor.set(0, 0);
		bg.alpha = 0.5;
		add(bg);

		input = new FlxUIInputText(0, 0, Std.int(FlxG.width / 2), '', 28);
		input.scrollFactor.set(0, 0);
		input.screenCenter();
		add(input);

		var text:FlxText = new FlxText(0, 0, 1280, "NAME YOUR NEW PACK:", 28);
		text.font = Paths.font("eras.ttf");
		text.alignment = CENTER;
		text.screenCenter(X);
		text.y = Std.int(input.y - text.height);
		text.scrollFactor.set(0, 0);
		add(text);

		var confirm:FlxButton = new FlxButton(800 + 100, FlxG.height - 50, "CONFIRM", confirmPack);
		confirm.label.setFormat(Paths.font("eras.ttf"), 12, FlxColor.BLACK, CENTER);
		confirm.setGraphicSize(150, 75);
		confirm.screenCenter(X);
		confirm.y = input.y + 80;
		confirm.color = FlxColor.LIME;
		confirm.scrollFactor.set(0, 0);
		add(confirm);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound("cancelMenu"));
			MusicBeatState.resetState();
		}
	}

	function confirmPack()
	{
		var daName:String = input.text;

		var modPack:ModData = {
			name: daName,
			description: "ENTER DESCRIPTION HERE",
			restart: false,
			color: [255, 255, 255]
		}

		var savedPack:String = Json.stringify(modPack, "\t");

		var daLength:Int = Std.int(daName.length * 2);

		var lsFileData:String = "LEFTSIDESMODFILE\nLS" + daName + "LS\n" + daLength;

		FileSystem.createDirectory("mods/" + daName);

		File.saveContent("mods/"+ daName + "/pack.json", savedPack);
		File.saveContent("mods/" + daName + "/" + daName + ".leftSides", lsFileData);

		// Resets the state. Because you should see your results! :)
		MusicBeatState.resetState();
	}
}