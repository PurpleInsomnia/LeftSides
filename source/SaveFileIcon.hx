package;

import flixel.FlxG;
import flixel.FlxSprite;
import sys.FileSystem;

using StringTools;

class SaveFileIcon extends FlxSprite
{
	// for save file states lmao
	#if (haxe >= "4.0.0")
	public static var modDirectoryPaths:Map<String, String> = new Map();
	#else
	public static var modDirectoryPaths:Map<String, String> = new Map(String, String);
	#end
	public static var defaultList:Array<String> = ["BEN", "TESS", "DAD", "SPOOKY", "MONSTER", "BAD-THOUGHTS", "PICO", "MOM", "RON", "SENPAI", "TANKMAN", "WALT", "JESSE", "SAUL", "MATTO", "V", "LUCID", "NUCKLE", "JABBIN", "FINGER", "SONIC", "FORTNITE-BOOTS", "JUSTCAM", "NICO", "PURPLEINSOMNIA"];
	public static var list:Array<String> = ['BEN', 'TESS', 'DAD', 'SPOOKY', 'PICO', 'MOM', 'MONSTER', 'SENPAI', 'WALT', 'JUSTCAM', 'NICO', 'PURPLEINSOMNIA'];
	public var name:String = 'BEN';

	public function new()
	{
		super();
	}

	public function load(icon:String)
	{
		// WE UP WITH THIS DLC LOADING ONG:bangbang:
		var daTrueModDirec:String = Paths.currentModDirectory;
		if (modDirectoryPaths.exists(icon.toUpperCase()))
		{
			Paths.currentModDirectory = modDirectoryPaths.get(icon.toUpperCase());
		}

		loadGraphic(Paths.image('saveFile/icons/' + icon.toLowerCase()));
		setGraphicSize(150, 150);
		name = icon.toUpperCase();

		Paths.currentModDirectory = daTrueModDirec;
	}

	public static function loadList()
	{
		var newList:Array<String> = defaultList;
		#if desktop
		var daModFile:Array<String> = [];
		if (FileSystem.exists("modsList.txt"))
		{
			daModFile = CoolUtil.coolTextFile("modsList.txt");
		}
		else
		{
			list = newList;
			return;
		}
		var modDirecs:Array<String> = [];
		for (i in 0...daModFile.length)
		{
			var spl:Array<String> = daModFile[i].split("|");
			modDirecs.push(spl[0]);
		}
		for (i in 0...modDirecs.length)
		{
			if (FileSystem.exists("mods/" + modDirecs[i] + "/images/saveFile/icons/"))
			{
				for (file in FileSystem.readDirectory("mods/" + modDirecs[i] + "/images/saveFile/icons/"))
				{
					if (file.endsWith(".png"))
					{
						var real:String = file.replace(".png", "");
						if (!newList.contains(real.toUpperCase()))
						{
							if (!modDirectoryPaths.exists(real.toUpperCase()))
							{
								modDirectoryPaths.set(real.toUpperCase(), modDirecs[i]);
							}
							newList.push(real.toUpperCase());
						}
					}	
				}
			}
		}
		#end
		list = newList;
		return;
	}
}