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
}
