package;

import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import flixel.graphics.FlxGraphic;
import haxe.ds.StringMap;
import openfl.display.BitmapData;
import lime.utils.AssetManifest;
import flixel.util.FlxTimer;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end

using StringTools;

typedef CompletionData = {
	var songs:String;
	var sRanks:String;
	var sideStories:String;
	var costumes:String;
	var trophies:String;
	var gotten:Int;
	var toGet100:Int;
}

class CoolUtil
{
	// [Difficulty name, Chart file suffix]
	public static var difficultyStuff:Array<Dynamic> = [
		['Easy', '-easy'],
		['Normal', ''],
		['Fucked', '-fucked']
	];

	#if (haxe >= "4.0.0")
	public static var playstateImages:Map<String, FlxGraphic> = new Map();
	#else
	public static var playstateImages:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
	#end

	public static var curSelectedChars:Array<Int> = [0, 0];

	public static function difficultyString():String
	{
		return difficultyStuff[PlayState.storyDifficulty][0].toUpperCase();
	}

	public static function boundTo(value:Float, min:Float, max:Float):Float {
		var newValue:Float = value;
		if(newValue < min) newValue = min;
		else if(newValue > max) newValue = max;
		return newValue;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = [];
		#if sys
		if(FileSystem.exists(path)) daList = File.getContent(path).trim().split('\n');
		#else
		if(Assets.exists(path)) daList = Assets.getText(path).trim().split('\n');
		#end

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function listFromString(string:String):Array<String>
	{
		var daList:Array<String> = [];
		daList = string.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}

	//uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void {
		if(!Assets.cache.hasSound(Paths.sound(sound, library))) {
			FlxG.sound.cache(Paths.sound(sound, library));
		}
	}

	public static function browserLoad(site:String) {
		#if linux
		Sys.command('/usr/bin/xdg-open', [site, "&"]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function username()
	{
		var username:String = '**USERNAME**';
		if (ClientPrefs.showUsername)
		{
			#if desktop
			username = Std.string(Sys.environment()["USERNAME"]);
			return username;
			#else
			username = Std.string(Sys.environment()["USER"]);
			return username;
			#end
		}
		else
		{
			return '**USERNAME**';
		}
	}

	public static function swearFilter(text:String)
	{
		var toReturn:String = text;

		var swearWords:Array<String> = ['Fuck', 'Shit', 'Ass', 'Bitch', 'Whore', 'Pussy', 'Dick', 'Wanker', "Damn"];
		var goodWords:Array<String> = ['****', '****', '***', '*****', '*****', '*****', '****', '******', "Darn"];
		// swear filter >:(
		if (ClientPrefs.swearFilter)
		{
			for (i in 0...swearWords.length)
			{
				toReturn.replace(swearWords[i], goodWords[i]);
				toReturn.replace(swearWords[i].toUpperCase(), goodWords[i].toUpperCase());
				toReturn.replace(swearWords[i].toLowerCase(), goodWords[i].toLowerCase());
			}
		}

		return toReturn;
	}

	public static function dominantColor(sprite:flixel.FlxSprite):Int{
		var countByColor:Map<Int, Int> = [];
		for(col in 0...sprite.frameWidth){
			for(row in 0...sprite.frameHeight){
			  var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
			  if(colorOfThisPixel != 0){
				  if(countByColor.exists(colorOfThisPixel)){
				    countByColor[colorOfThisPixel] =  countByColor[colorOfThisPixel] + 1;
				  }else if(countByColor[colorOfThisPixel] != 13520687 - (2*13520687)){
					 countByColor[colorOfThisPixel] = 1;
				  }
			  }
			}
		 }
		var maxCount = 0;
		var maxKey:Int = 0;//after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
			for(key in countByColor.keys()){
			if(countByColor[key] >= maxCount){
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	#if sys
	public static function pcCharacters()
	{
		var folders:Array<String> = ["assets/shared/images/characters/", "assets/images/characters/", "assets/shared/images/characters/encore/", Paths.mods("") + "images/characters/", Paths.mods("") + "images/characters/encore/", Paths.getModFile("") + "images/characters/", Paths.getModFile("") + "images/characters/encore/"];
		for (i in 0...folders.length)
		{
			if (FileSystem.exists(folders[i]))
			{
				var chars:Array<String> = FileSystem.readDirectory(folders[i]);
				// spits files by five in oreder to minimize lag.
				var theL:Array<Array<String>> = [];
				for (i in 0...chars.length)
				{
					if (i % 4 == 0)
					{
						var tp:Array<String> = [chars[i - 4], chars[i - 3], chars[i - 2], chars[i - 1], chars[i]];
						theL.push(tp);
					}
				}
				for (i in 0...theL.length)
				{
					new FlxTimer().start(0.01, function(tmr:FlxTimer)
					{
						for (char in theL[i])
						{
							if (char.endsWith(".png"))
							{
								if (playstateImages.exists(char.replace(".png", "")))
                				{
                    				return;
                				}
                				var newBitmap:BitmapData = BitmapData.fromFile(folders[i] + char);
                				var daNewGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, char.replace(".png", ""));
                				playstateImages.set(char.replace(".png", ""), daNewGraphic);
							}
						}
					});
				}
			}
		}
	}
	#end

	public static function getCompletionStatus(?check:Bool = false)
	{
		var ret:CompletionData = {
			songs: "",
			sRanks: "",
			sideStories: "",
			costumes: "",
			trophies: "",
			gotten: 0,
			toGet100: 0
		}

		var tg1:Int = 0;

		var read:Array<String> = [];
		var exclude:Array<String> = [
			"candy-canes",
			"cycles",
			"guns",
			"los-pollos-raperos",
			"monochrome",
			"nightmare",
			"roses",
			"senpai",
			"smash",
			"test",
			"thorns",
			"triple-trouble"
		];
		for (path in FileSystem.readDirectory("assets/data/"))
		{
			if (FileSystem.isDirectory("assets/data/" + path))
			{
				if (!exclude.contains(path))
				{
					read.push(path);
				}
			}
		}

		var completed:Int = 0;
		for (i in 0...read.length)
		{
			tg1 += 1;
			if (Highscore.getScore(read[i], 1) > 0)
			{
				ret.gotten += 1;
				completed += 1;
			}
			if (read[i] == "tutorial" || read[i] == "bopeebo" || read[i] == "fresh" || read[i] == "dad-battle" || read[i] == "spookeez" || read[i] == "treats-and-tricks" || read[i] == "south" || read[i] == "free-me")
			{
				tg1 += 1;
				if (Highscore.getEncoreScore(read[i], 1) > 0)
				{
					ret.gotten += 1;
					completed += 1;
				}
			}
		}
		// encore songs lol
		var totalSongs:Int = read.length + 8;
		ret.songs = "" + completed + "/" + totalSongs;
		if (completed == totalSongs && check)
		{
			GameJolt.GameJoltAPI.getTrophy(194371, "microphone");
		}


		var ranks:Int = 0;
		var length:Int = 0;
		for (file in FileSystem.readDirectory("assets/weeks/"))
		{
			if (file.endsWith(".json"))
			{
				var ratingNum:Int = Highscore.getWeekRating(file.replace(".json", ""), 1);
				if (ratingNum == 10)
				{
					ret.gotten += 1;
					ranks += 1;
				}
				tg1 += 1;
				length += 1;
			}
		}
		for (file in FileSystem.readDirectory("assets/weeks/encore/"))
		{
			if (file.endsWith(".json"))
			{
				var ratingNum:Int = Highscore.getWeekRating(file.replace(".json", ""), 1);
				if (ratingNum == 10)
				{
					ret.gotten += 1;
					ranks += 1;
				}
				tg1 += 1;
				length += 1;
			}
		}
		ret.sRanks = "" + ranks + "/" + length;
		if (ranks == length && check)
		{
			GameJolt.GameJoltAPI.getTrophy(194372, "s");
		}

		var aass:Int = 0;
		for (i in 0...8)
		{
			tg1 += 1;
			if (ClientPrefs.completedSideStories.get(SideStorySelectState.storyList[i][1]))
			{
				ret.gotten += 1;
				aass += 1;
			}
		}
		ret.sideStories = "" + aass + "/" + SideStorySelectState.storyList.length;
		if (aass == SideStorySelectState.storyList.length && check)
		{
			GameJolt.GameJoltAPI.getTrophy(194363, "side-story");
		}

		var cos:Int = 0;
		var gett:Array<Int> = WardrobeState.getUnlocksAsInt();
		cos = (gett[0] + gett[1]);
		ret.gotten += cos;
		tg1 += gett[2];
		ret.costumes = "" + cos + "/" + gett[2];
		if (cos == gett[2] && check)
		{
			GameJolt.GameJoltAPI.getTrophy(194362, "wardrobe");
		}

		var tr:Int = 0;
		var tra:Int = 0;
		for (i in 0...trophies.TrophyUtil.trophiesData.trophies.length)
		{
			tg1 += 1;
			tra += 1;
			if (trophies.TrophyUtil.trophies.exists(trophies.TrophyUtil.trophiesData.trophies[i].name))
			{
				ret.gotten += 1;
				tr += 1;
			}
		}
		ret.trophies = "" + tr + "/" + (tra - 1);

		ret.toGet100 = tg1;
		if (ClientPrefs.devMode)
		{
			ret.gotten = tg1;
		}

		var per:Int = Std.int((ret.gotten / ret.toGet100) * 100);
		if (per == 100 && check)
		{
			GameJolt.GameJoltAPI.getTrophy(194373, "100");
		}

		return ret;
	}
}
