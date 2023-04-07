package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSubState;
import haxe.Json;
import haxe.format.JsonParser;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import openfl.utils.Assets;
import FunkinLua;

using StringTools;

class DialogueCharacter extends FlxSprite
{
	private static var IDLE_SUFFIX:String = '-IDLE';
	public static var DEFAULT_CHARACTER:String = 'bf';
	public static var DEFAULT_SCALE:Float = 0.7;

	public var startingPos:Float = 0; //For center characters, it works as the starting Y, for everything else it works as starting X
	public var isGhost:Bool = false; //For the editor
	public var curCharacter:String = 'bf';
	public var daAnim:String = "default";

	public static var curBox:String = 'speech_bubble';

	public static function resetVariables() 
	{
		curBox = 'speech_bubble';
	}

	public function new(x:Float = 0, y:Float = 0, character:String = null)
	{
		super(x, y);

		if(character == null) character = DEFAULT_CHARACTER;
		this.curCharacter = character;

		reloadCharacter(character);
		reloadExpression();
	}

	public function reloadExpression()
	{
		// fixes the stuff with having multiple fucking portraits in the files.
		var prefix:String = curCharacter;
		switch (prefix)
		{
			case "ben":
				prefix = "benN";
			case "tess":
				prefix = "tessN";
			case "bf":
				prefix = "ben";
			case "gf":
				prefix = "tess";
		}
		if (FileSystem.exists(Paths.preloadFunny("side-stories/images/ports/" + prefix + "/" + daAnim + ".png")))
		{
			loadGraphic(Paths.preloadFunny("side-stories/images/ports/" + prefix + "/" + daAnim + ".png"));
			return;
		}
		if (FileSystem.exists(Paths.dialogue("ports/" + curCharacter + "/" + daAnim + ".png")))
		{
			loadGraphic(Paths.dialogue("ports/" + curCharacter + "/" + daAnim + ".png"));
			return;
		}
		if (FileSystem.exists(Paths.preloadFunny("shared/images/dialogue/" + curCharacter + ".png")))
		{
			loadGraphic(Paths.preloadFunny("shared/images/dialogue/" + curCharacter + ".png"), true, 413, 249);
			switch(curCharacter)
			{
				case "dmitri":
					animation.add("default", [0], 1, true);
					animation.add("death-stare", [1], 1, true);
					animation.add("cry", [2], 1, true);
				case "spookeez":
					animation.add("skid-default", [1], 1, true);
					animation.add("skid-bruh", [0], 1, true);
					animation.add("skid-point", [2], 1, true);
					animation.add("skid-sad", [3], 1, true);
					animation.add("pump-default", [4], 1, true);
					animation.add("pump-point", [5], 1, true);
					animation.add("pump-undertale", [6], 1, true);
					animation.add("pump-worried", [7], 1, true);
				case "matto":
					animation.add("default", [2], 1, true);
					animation.add("angry", [1], 1, true);
					animation.add("happy", [0], 1, true);
				case "bb":
					animation.add("walt", [2], 1, true);
					animation.add("walt two", [3], 1, true);
					animation.add("walt three", [4], 1, true);
					animation.add("jesse", [0], 1, true);
					animation.add("jesse two", [1], 1, true);
			}
			animation.play(daAnim, true);
			return;
		}
	}

	public function reloadCharacter(character:String) 
	{
		curCharacter = character;
	}

	public function playAnim(animName:String = null, ?playIdle:Bool = false) 
	{
		daAnim = animName;
		reloadExpression();
	}

	public function portExists(port:String)
	{
		var prefix:String = port;
		switch (prefix)
		{
			case "ben":
				prefix = "benN";
			case "tess":
				prefix = "tessN";
			case "bf":
				prefix = "ben";
			case "gf":
				prefix = "tess";
		}
		if (FileSystem.exists(Paths.preloadFunny("side-stories/images/ports/" + prefix + "/")))
		{
			return true;
		}
		if (FileSystem.exists(Paths.preloadFunny("dialogue/ports/" + port + "/")))
		{
			return true;
		}
		if (FileSystem.exists(Paths.preloadFunny("shared/images/dialogue/" + port + ".png")))
		{
			return true;
		}
		return false;
	}

	public function checkExpression(swag:String)
	{
		var prefix:String = curCharacter;
		switch (prefix)
		{
			case "ben":
				prefix = "benN";
			case "tess":
				prefix = "tessN";
			case "bf":
				prefix = "ben";
			case "gf":
				prefix = "tess";
		}
		if (FileSystem.exists(Paths.preloadFunny("side-stories/images/ports/" + prefix + "/" + daAnim + ".png")))
		{
			return true;
		}
		if (FileSystem.exists(Paths.dialogue("ports/" + curCharacter + "/" + daAnim + ".png")))
		{
			return true;
		}
		if (FileSystem.exists(Paths.preloadFunny("shared/images/dialogue/" + curCharacter + ".png")))
		{
			return true;
		}
		return false;
	}
}