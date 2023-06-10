package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import haxe.Json;
import openfl.utils.Assets as OpenFlAssets;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef AnimatedIconData = {
	var defaultFrames:Array<Int>;
	var losingFrames:Array<Int>;
	var winningFrames:Array<Int>;
	var fps:Int;
	var loops:IconLoopData;
}

typedef IconLoopData = {
	var idle:Bool;
	var losing:Bool;
	var winning:Bool;
}

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	private var isOldIcon:Bool = false;
	private var isPlayer:Bool = false;
	public var char:String = '';
	public var curChar:String = "";

	public var animationData:AnimatedIconData = null;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		isOldIcon = (char == 'bf-old');
		this.isPlayer = isPlayer;
		changeIcon(char);
		scrollFactor.set();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}

	public function swapOldIcon() {
		if(isOldIcon = !isOldIcon) changeIcon('bf-old');
		else changeIcon('bf');
	}

	public function changeIcon(char:String) {
		if(this.char != char) {
			var name:String = 'icons/' + char;
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-' + char; //Older versions of psych engine's support
			if(!Paths.fileExists('images/' + name + '.png', IMAGE)) name = 'icons/icon-face'; //Prevents crash from missing icon
			var file:Dynamic = Paths.image(name);

			var dataName:String = "icons/" + char;
			if(!Paths.fileExists("images/" + dataName + ".png", IMAGE)) dataName = "icons/icon-" + char;
			if(!Paths.fileExists("images/" + dataName + ".png", IMAGE)) dataName = "icons/icon-face";
			if (FileSystem.exists(Paths.preloadFunny("images/" + dataName + ".json")))
			{
				animationData = Json.parse(File.getContent(Paths.preloadFunny("images/" + name + ".json")));
				loadGraphic(file, true, 150, 150);
				animation.add("default", animationData.defaultFrames, animationData.fps, animationData.loops.idle, isPlayer);
				animation.add("losing", animationData.losingFrames, animationData.fps, animationData.loops.losing, isPlayer);
				animation.add("winning", animationData.winningFrames, animationData.fps, animationData.loops.winning, isPlayer);
				animation.play("default");
				this.char = char;
				curChar = char.replace("icon-", "");
			}
			else
			{
				animationData = null;
				loadGraphic(file, true, 150, 150);
				animation.add("default", [0], 0, false, isPlayer);
				animation.add("losing", [1], 0, false, isPlayer);
				animation.add("winning", [2], 0, false, isPlayer);
				animation.play("default");
				this.char = char;
				curChar = char.replace("icon-", "");
			}

			antialiasing = ClientPrefs.globalAntialiasing;
			if(char.endsWith('-pixel')) 
			{
				antialiasing = false;
			}
		}
	}

	public function getCharacter():String {
		return char;
	}
}


class IconGlow extends FlxSprite
{
	public function new(character:Character)
	{
		super();
		loadGraphic(Paths.image("icons/glow"));
		color = FlxColor.fromRGB(character.healthColorArray[0], character.healthColorArray[1], character.healthColorArray[2]);
	}

	public function updateProperties(character:Character)
	{
		color = FlxColor.fromRGB(character.healthColorArray[0], character.healthColorArray[1], character.healthColorArray[2]);
	}
}