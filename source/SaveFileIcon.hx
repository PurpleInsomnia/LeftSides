package;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class SaveFileIcon extends FlxSprite
{
	// for save file states lmao
	public static var list:Array<String> = ['BEN', 'TESS', 'DAD', 'SPOOKY', 'PICO', 'MOM', 'MONSTER', 'SENPAI', 'WALT', 'JUSTCAM', 'NICO', 'PURPLEINSOMNIA'];
	public var name:String = 'BEN';

	public function new()
	{
		super();
	}

	public function load(icon:String)
	{
		loadGraphic(Paths.image('saveFile/icons/' + icon.toLowerCase()));
		setGraphicSize(150, 150);
		name = icon.toUpperCase();
	}
}