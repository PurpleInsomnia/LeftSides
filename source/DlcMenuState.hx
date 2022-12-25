package;

import flixel.FlxG;
import flixel.FlxSprite;
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

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.setDirectoryFromWeek();

		curSelected = 0;
		canPress = true;

		camFollow = new FlxSprite().makeGraphic(1, 1);
		camFollow.screenCenter();
		add(camFollow);

		camFollower = new FlxSprite().makeGraphic(1, 1);
		camFollower.screenCenter();
		add(camFollower);

		FlxG.camera.follow(camFollower, null, 1);

		add(new GridBackdrop());

		bg = new FlxSprite().loadGraphic(Paths.image("freeplay/bg"));
		bg.blend = BlendMode.MULTIPLY;
		bg.scrollFactor.set(0, 0);
		add(bg);

		var check:Array<String> = [];
		if (!FileSystem.exists("modsList.txt"))
		{
			noMods = true;
		}
		else
		{
			check = CoolUtil.coolTextFile("modsList.txt");
		}

		if (check[0].length < 2)
		{
			noMods = true;
		}

        var path:String = 'modsList.txt';
		// FIND MOD FOLDERS
		var boolshit = true;
		if (!noMods)
        {
			for (folder in Paths.getModDirectories())
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

			trace("bruh");

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

			var removeButton:FlxButton = new FlxButton(800, FlxG.height - 50, "REMOVE THIS MOD", removePress);
			removeButton.label.setFormat(Paths.font("vcr.ttf"), 6, FlxColor.BLACK, CENTER);
			removeButton.setGraphicSize(75, 25);
			removeButton.color = FlxColor.RED;
			add(removeButton);

			var moveButton:FlxButton = new FlxButton(800 + 100, FlxG.height - 50, "MOVE MOD TO TOP", movePress);
			moveButton.label.setFormat(Paths.font("vcr.ttf"), 6, FlxColor.BLACK, CENTER);
			moveButton.setGraphicSize(75, 25);
			moveButton.color = FlxColor.GREEN;
			add(moveButton);

			changeSelection(0);
		}
		else
		{
			var noBitches:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("no bitches"));
			noBitches.screenCenter();
			add(noBitches);
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
			var restart:Bool = false;
			if (!noMods)
			{
				if (modsList[0][0].restart)
				{
					restart = true;
				}
			}

			FlxG.mouse.visible = false;

			saveFile();

			if (!noMods)
			{
				Paths.currentModDirectory = modsList[0][2];
			}

			if (restart)
			{
				MusicBeatState.switchState(new TitleScreenState());
			}
			else
			{
				MusicBeatState.switchState(new MainMenuState());
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
		daBigIcon.x = 750 + 175;

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

		var colour:FlxColor = FlxColor.fromRGB(modsList[0][0].color[0], modsList[0][0].color[1], modsList[0][0].color[2]);
		colourTween = FlxTween.color(bg, 0.75, bg.color, colour);
	}

	function changeStatusText(on:Bool)
	{
		if (on)
		{
			statText.color = FlxColor.LIME;
			statText.text = "THIS MOD IS\nON\n";
		}
		else
		{
			statText.color = FlxColor.RED;
			statText.text = "THIS MOD IS\nOFF\n";
		}
	}

	function saveFile()
	{
		var cont:String = "";
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
		FlxG.sound.play(Paths.sound("scollMenu"));
		modsList.remove(mod);
		modsList.insert(0, mod);
		saveFile();
		MusicBeatState.switchState(new DlcMenuState());
	}

	function removeMod(mod:Array<Dynamic>)
	{
		FlxG.sound.play(Paths.sound("cancelMenu"));
		modsList.remove(mod);
		saveFile();
		MusicBeatState.switchState(new DlcMenuState());
	}

	function removePress()
	{
		var mod:Array<Dynamic> = modsList[curSelected];
		removeMod(mod);
	}

	function movePress()
	{
		var mod:Array<Dynamic> = modsList[curSelected];
		moveToTop(mod);
	}
}