package;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end
import haxe.Json;
import haxe.format.JsonParser;
import Song;

using StringTools;

typedef StageFile = {
	var defaultZoom:Float;
	var isPixelStage:Bool;

	var boyfriend:Array<Dynamic>;
	var girlfriend:Array<Dynamic>;
	var opponent:Array<Dynamic>;

	var cameraSpeed:Float;
	var cameraPositions:PositionData;
}

typedef PositionData = {
	var dad:Array<Float>;
	var bf:Array<Float>;
	var gf:Array<Float>;
}

class StageData {
	public static var forceNextDirectory:String = "";
	public static function loadDirectory(SONG:SwagSong) {
		var stage:String = '';
		if(SONG.stage != null) 
		{
			stage = SONG.stage;
		} 
		else if(SONG.song != null) 
		{
			switch (SONG.song.toLowerCase().replace(' ', '-'))
			{
				case 'spookeez' | 'south' | 'monster':
					stage = 'spooky';
				case 'pico' | 'blammed' | 'philly' | 'philly-nice':
					stage = 'philly';
				case 'milf' | 'satin-panties' | 'high':
					stage = 'limo';
				case 'cocoa' | 'eggnog':
					stage = 'mall';
				case 'winter-horrorland':
					stage = 'mallEvil';
				case 'senpai' | 'roses':
					stage = 'school';
				case 'thorns':
					stage = 'schoolEvil';
				default:
					stage = 'stage';
			}
		} 
		else 
		{
			stage = 'stage';
		}
	}

	public static function getStageFile(stage:String):StageFile {
		var rawJson:String = null;
		var path:String; 
		if (!PlayState.encoreMode)
		{
			path = Paths.getPreloadPath('stages/' + stage + '.json');
		}
		else
		{
			path = Paths.getPreloadPath('stages/encore/' + stage + '.json');
		}

		#if MODS_ALLOWED
		var modPath:String;
		if (!PlayState.encoreMode) 
		{
			modPath = Paths.modFolders('stages/' + stage + '.json');
		}
		else
		{ 
			modPath = Paths.modFolders('stages/encore/' + stage + '.json');
		}

		if(FileSystem.exists(modPath)) 
		{
			rawJson = File.getContent(modPath);
		} 
		else if(FileSystem.exists(path)) 
		{
			rawJson = File.getContent(path);
		}
		#else
		if(Assets.exists(path)) 
		{
			rawJson = Assets.getText(path);
		}
		#end
		else
		{
			return null;
		}
		return cast Json.parse(rawJson);
	}

	public static function getDefaultFile()
	{
		var ret:StageFile = Json.parse(File.getContent("assets/stages/stage.json"));
		return ret;
	}
}