package;

import flixel.FlxG;
import sys.FileSystem;
import sys.io.File;
import lime.system.System;

class TextFile
{
	public static function newFile(text:String, fileName:String)
	{
		var path:String = System.desktopDirectory + fileName + '.txt';
		File.saveContent(path, text);
		System.openFile(path);
	}
}