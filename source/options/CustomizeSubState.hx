package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;
import sys.FileSystem;

using StringTools;

class CustomizeSubState extends BaseOptionsMenu
{
	var fileList:Array<String> = ['Off', 'NOTE_assets', 'funkinNOTE_assets', "purpleinsomniaNOTE_assets"];
	var splashFileList:Array<String> = ["Off", "noteSplashes", "funkinNoteSplashes", "purpleinsomniaNoteSplashes"];
	var strumArray:Array<String> = ['Off', 'Left Sides Notes', "Funkin' Notes", "PurpleInsomnia Notes"];
	var directories:Array<String> = [Paths.mods(), Paths.getPreloadPath()];
	var barArray:Array<String> = ['Default', "Grid", "Sonic Spikes"];
	var ratingArray:Array<String> = ['Default', 'Funkin', "PurpleInsomnia"];

	var strumOption:Option;

	public function new()
	{
		title = 'Custom Settings';
		rpcTitle = 'Custom Settings Menu'; //for Discord Rich Presence

		resetArrays();

		checkMods();
		checkForStrums();
		checkForBars();
		checkForRating();

		strumOption = new Option('Note Skin:',
			"Set a custom note skin for yourself.\nWhen applied however, stuff like " + '"Change UI" (the event)\nand "Arrow Skins" (used in song files) ' + "\nwill not be active",
			'customStrum',
			'string',
			'Off',
		strumArray);

		strumOption.onChange = changeStrum;

		addOption(strumOption);

		var option:Option = new Option('Cinematic Bar Type:',
		"Set a custom texture for the cinematic bars",
		'customBar',
		'string',
		'Default',
		barArray);
		
		addOption(option);

		var option:Option = new Option('Rating Sprite Skin:',
		"Set a custom texture for the rating sprites",
		'customRating',
		'string',
		'Default',
		ratingArray);

		addOption(option);

		changeStrum();

		super();
	}

	function changeStrum()
	{
		if (ClientPrefs.customStrum != "Off")
		{
			CustomStrum.strum = fileList[strumOption.curOption];
			CustomStrum.splash = splashFileList[strumOption.curOption];
		}
		else
		{
			// this is so sad.
			CustomStrum.strum = "";
			CustomStrum.splash = "";
		}
	}

	function resetArrays()
	{
		strumArray = ['Off', 'Left Sides Notes', "Funkin' Notes", "PurpleInsomia Notes"];
		fileList = ['Off', 'NOTE_assets', 'funkinNOTE_assets', "purpleinsomniaNOTE_assets"];
		splashFileList = ["Off", "noteSplashes", "funkinNoteSplashes", "purpleinsomniaNoteSplashes"];
		barArray = ['Default', "Grid", "Sonic Spikes"];
		ratingArray = ['Default', 'Funkin', "PurpleInsomnia"];
		directories = [Paths.mods(), Paths.getPreloadPath()];
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

	function checkForStrums()
	{
		for (i in 0...directories.length)
		{
			if (FileSystem.exists(directories[i] + 'data/skinList.txt'))
			{
				var list:Array<String> = CoolUtil.coolTextFile(directories[i] + 'data/skinList.txt');
				for (i in 0...list.length)
				{
					var split:Array<String> = list[i].split('|');
					strumArray.push(split[0]);
					if (split[1] == null)
					{
						lime.app.Application.current.window.alert('Please specify a file path by adding a "|" after your strum name.\nEXAMPLE: "My Strum|mystrumNOTE_assets|myStrumNoteSplashes"', "Error on strum file (line " + i + ")");
					}
					else
					{
						fileList.push(split[1]);
					}
					if (split[2] == null)
					{
						lime.app.Application.current.window.alert('Please specify a splash skin file path by adding a "|" after your strum file path.\nEXAMPLE: "My Strum|mystrumNOTE_assets|myStrumNoteSplashes"', "Error on strum file (line " + i + ")");
					}
					else
					{
						splashFileList.push(split[2]);
					}
				}
			}
		}
	}

	function checkForBars()
	{
		for (i in 0...directories.length)
		{
			if (FileSystem.exists(directories[i] + 'data/barList.txt'))
			{
				var list:Array<String> = CoolUtil.coolTextFile(directories[i] + 'data/barList.txt');
				for (i in 0...list.length)
				{
					barArray.push(list[i]);
				}
			}
		}
	}

	function checkForRating()
	{
		for (i in 0...directories.length)
		{
			if (FileSystem.exists(directories[i] + 'data/ratingList.txt'))
			{
				var list:Array<String> = CoolUtil.coolTextFile(directories[i] + 'data/ratingList.txt');
				for (i in 0...list.length)
				{
					ratingArray.push(list[i]);
				}
			}
		}
	}
}