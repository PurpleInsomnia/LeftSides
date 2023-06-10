package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import flixel.FlxSprite;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
#end

import flash.media.Sound;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static var VIDEO_EXT = "mp4";

	#if MODS_ALLOWED
	#if (haxe >= "4.0.0")
	public static var ignoreModFolders:Map<String, Bool> = new Map();
	public static var customImagesLoaded:Map<String, Bool> = new Map();
	public static var customDoodlesLoaded:Map<String, Bool> = new Map();
	public static var customSoundsLoaded:Map<String, Sound> = new Map();
	#else
	public static var ignoreModFolders:Map<String, Bool> = new Map<String, Bool>();
	public static var customImagesLoaded:Map<String, Bool> = new Map<String, Bool>();
	public static var customDoodlesLoaded:Map<String, Bool> = new Map<String, Bool>();
	public static var customSoundsLoaded:Map<String, Sound> = new Map<String, Sound>();
	#end
	#end

	public static function destroyLoadedImages(ignoreCheck:Bool = false) {
		#if MODS_ALLOWED
		if(!ignoreCheck && ClientPrefs.imagesPersist) return; //If there's 20+ images loaded, do a cleanup just for preventing a crash

		for (key in customImagesLoaded.keys()) {
			var graphic:FlxGraphic = FlxG.bitmap.get(key);
			if(graphic != null) {
				graphic.bitmap.dispose();
				graphic.destroy();
				FlxG.bitmap.removeByKey(key);
			}
		}
		Paths.customImagesLoaded.clear();
		#end
	}

	static public var currentModDirectory:String = '';
	static public var AssetDirectories:Array<String> = [];
	static var currentLevel:String;
	static public function getModFolders()
	{
		#if MODS_ALLOWED
		ignoreModFolders.set("arcade", true);
		ignoreModFolders.set('characters', true);
		ignoreModFolders.set('custom_events', true);
		ignoreModFolders.set('custom_notetypes', true);
		ignoreModFolders.set('data', true);
		ignoreModFolders.set('songs', true);
		ignoreModFolders.set('music', true);
		ignoreModFolders.set('sounds', true);
		ignoreModFolders.set('doodles', true);
		ignoreModFolders.set('scripts', true);
		ignoreModFolders.set('videos', true);
		ignoreModFolders.set('images', true);
		ignoreModFolders.set('stages', true);
		ignoreModFolders.set('weeks', true);
		ignoreModFolders.set("side-stories", true);
		ignoreModFolders.set("dialogue", true);
		ignoreModFolders.set("quotes", true);
		ignoreModFolders.set("fanart", true);
		ignoreModFolders.set("states", true);
		ignoreModFolders.set("shaders", true);
		ignoreModFolders.set("wardrobe", true);
		ignoreModFolders.set("fonts", true);
		ignoreModFolders.set("soundtracks", true);
		#end
	}

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	public static function getSharedMods(file:String):String
	{
		if (FileSystem.exists(modFolders(file)))
		{
			return modFolders(file);
		}
		return "assets/shared/" + file;
	}

	public static function getPath(file:String, type:AssetType, ?library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline public static function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		var swag:String = "";
		if (FileSystem.exists(modsJson(key)))
		{
			swag = modsJson(key);
		}
		else
		{
			swag = "assets/data/" + key + ".json";
		}
		return swag;
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	static public function video(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsVideo(key);
		if(FileSystem.exists(file)) {
			return file;
		}
		#end
		return 'assets/videos/$key.$VIDEO_EXT';
	}

	static public function sound(key:String, ?library:String):Dynamic
	{
		#if MODS_ALLOWED
		var file:String = modsSounds(key);
		if(FileSystem.exists(file)) {
			if(!customSoundsLoaded.exists(file)) {
				customSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return customSoundsLoaded.get(file);
		}
		#end
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	static public function doodles(key:String, ?library:String):Dynamic
	{
		#if MODS_ALLOWED
		var file:String = modsDoodles(key);
		if(FileSystem.exists(file)) {
			return customDoodlesLoaded.get(file);
		}
		#end
		return getPath('doodles/$key.png', IMAGE, library);
	}

	static public function arcade(key:String):Dynamic
	{
		if (FileSystem.exists(Paths.modFolders("arcade/" + key)))
		{
			if (key.contains("images/"))
			{
				return Paths.getFlxGraphic(Paths.modFolders("arcade/" + key));
			}
			if (key.contains("sounds/") || key.contains("music/"))
			{
				if(!customSoundsLoaded.exists(key)) {
					customSoundsLoaded.set(key, Sound.fromFile(key));
				}
				return customSoundsLoaded.get(key);
			}
			return Paths.modFolders("arcade/" + key);
		}
		return 'assets/arcade/' + key;
	}

	static public function concepts(key:String)
	{
		return 'assets/concepts/' + key;
	}
	
	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String):Dynamic
	{
		#if MODS_ALLOWED
		var file:String = modsMusic(key);
		if(FileSystem.exists(file)) {
			if(!customSoundsLoaded.exists(file)) {
				customSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return customSoundsLoaded.get(file);
		}
		#end
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function unusedSongs(song:String):Any
	{
		return 'unusedSongs/$song.$SOUND_EXT';
	}

	inline static public function voices(song:String, ?ext:String = "ogg", ?fn:String = "Voices"):Any
	{
		var songFin:String = fn;
		var fullExt:String = ext;
		if (fullExt == "ogg")
		{
			fullExt = '$SOUND_EXT';
		}
		#if MODS_ALLOWED
		var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/' + songFin, fullExt));
		if(file != null) {
			return file;
		}
		#end
		return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/' + songFin + "." + fullExt;
	}

	inline static public function voicesEncore(song:String, ?ext:String = "ogg", ?fn:String = "VoicesEncore"):Any
	{
		var toAdd:String = "";
		var fullExt:String = ext;
		if (fullExt == "ogg")
		{
			fullExt = '$SOUND_EXT';
		}
		#if MODS_ALLOWED
		var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/' + fn + toAdd, fullExt));
		if(file != null) {
			return file;
		}
		#end
		return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/' + fn + toAdd + "." + fullExt;
	}

	inline static public function fuckedVoices(song:String):Any
	{
		#if MODS_ALLOWED
		var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/Voices-fucked'));
		if(file != null) {
			return file;
		}
		#end
		return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/Voices-fucked.$SOUND_EXT';
	}

	inline static public function inst(song:String):Any
	{
		var songFin:String = "Inst";
		#if MODS_ALLOWED
		var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/' + songFin));
		if(file != null) {
			return file;
		}
		#end
		return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/' + songFin + '.$SOUND_EXT';
	}

	inline static public function instEncore(song:String):Any
	{
		var toAdd:String = "";
		#if MODS_ALLOWED
		var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/InstEncore' + toAdd));
		if(file != null) {
			return file;
		}
		#end
		return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/InstEncore' + toAdd + '.$SOUND_EXT';
	}

	inline static public function fuckedInst(song:String):Any
	{
		#if MODS_ALLOWED
		var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/Inst-fucked'));
		if(file != null) {
			return file;
		}
		#end
		return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/Inst-fucked.$SOUND_EXT';
	}

	#if MODS_ALLOWED
	inline static private function returnSongFile(file:String):Sound
	{
		if(FileSystem.exists(file)) {
			if(!customSoundsLoaded.exists(file)) {
				customSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return customSoundsLoaded.get(file);
		}
		return null;
	}
	#end

	inline static public function image(key:String, ?library:String):Dynamic
	{
		#if MODS_ALLOWED
		var imageToReturn:FlxGraphic = addCustomGraphic(key);
		if(imageToReturn != null) return imageToReturn;
		#end
		return getPath('images/$key.png', IMAGE, library);
	}
	
	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
	{
		#if sys
		if (!ignoreMods && FileSystem.exists(getModFile(key)))
			return File.getContent(getModFile(key));

		if (FileSystem.exists(getPreloadPath(key)))
			return File.getContent(getPreloadPath(key));

		if (currentLevel != null)
		{
			var levelPath:String = '';
			if(currentLevel != 'shared') {
				levelPath = getLibraryPathForce(key, currentLevel);
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}

			levelPath = getLibraryPathForce(key, 'shared');
			if (FileSystem.exists(levelPath))
				return File.getContent(levelPath);
		}
		#end
		return Assets.getText(getPath(key, TEXT));
	}

	inline static public function font(key:String)
	{
		if (FileSystem.exists(getModFile('fonts/$key')))
		{
			return getModFile('fonts/$key');
		}
		return 'assets/fonts/$key';
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		#if MODS_ALLOWED
		if(FileSystem.exists(mods(currentModDirectory + '/' + key)) || FileSystem.exists(mods(key))) {
			return true;
		}
		#end
		
		if(OpenFlAssets.exists(Paths.getPath(key, type))) {
			return true;
		}
		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = addCustomGraphic(key);
		var xmlExists:Bool = false;
		if(FileSystem.exists(modsXml(key))) {
			xmlExists = true;
		}

		return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)), (xmlExists ? File.getContent(modsXml(key)) : file('images/$key.xml', library)));
		#else
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
		#end
	}

	inline static public function getPrecachedSparrow(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(CoolUtil.playstateImages.get(key), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = addCustomGraphic(key);
		var txtExists:Bool = false;
		if(FileSystem.exists(modsTxt(key))) {
			txtExists = true;
		}

		return FlxAtlasFrames.fromSpriteSheetPacker((imageLoaded != null ? imageLoaded : image(key, library)), (txtExists ? File.getContent(modsTxt(key)) : file('images/$key.txt', library)));
		#else
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
		#end
	}

	inline static public function getPrecacheAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(CoolUtil.playstateImages.get(key), file('images/$key.txt', library));
	}

	inline static public function formatToSongPath(path:String) 
	{
		return path.toLowerCase().replace(' ', '-');
	}

	inline static public function addFlxGraphic(key:String):FlxGraphic {
		var newBitmap:BitmapData = BitmapData.fromFile(image(key));
		if(FileSystem.exists(modsImages(key)))
		{
			if(!customImagesLoaded.exists(key))
			{
				newBitmap = BitmapData.fromFile(modsImages(key));
			}
		}
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
		newGraphic.persist = true;
		FlxG.bitmap.addGraphic(newGraphic);
		customImagesLoaded.set(key, true);
		return FlxG.bitmap.get(key);
	}

	inline static public function funnyFlxGraphic(key:String):FlxGraphic {
		var newBitmap:BitmapData = BitmapData.fromFile(preloadFunny(key));
		if(FileSystem.exists(getModFile(key)))
		{
			if(!customImagesLoaded.exists(key))
			{
				newBitmap = BitmapData.fromFile(getModFile(key));
			}
		}
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
		newGraphic.persist = true;
		FlxG.bitmap.addGraphic(newGraphic);
		customImagesLoaded.set(key, true);
		return FlxG.bitmap.get(key);
	}

	inline static public function getFlxGraphic(key:String):FlxGraphic {
		var newBitmap:BitmapData = BitmapData.fromFile(key);
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
		newGraphic.persist = true;
		FlxG.bitmap.addGraphic(newGraphic);
		customImagesLoaded.set(key, true);
		return FlxG.bitmap.get(key);
	}

	inline static public function quotes(key:String = "")
	{
		if (FileSystem.exists(modFolders("quotes/" + key + ".txt")))
		{
			return modFolders("quotes/" + key + ".txt");
		}
		return "assets/quotes/" + key + ".txt";
	}

	inline static public function gameover(key:String)
	{
		if (FileSystem.exists(modFolders("gameover/" + key)))
		{
			return modFolders("gameover/" + key);
		}
		return "assets/gameover/" + key;
	}

	inline static public function wardrobe(key:String)
	{
		return "assets/wardrobe/" + key;
	}

	inline static public function preloadFunny(key:String)
	{
		if (FileSystem.exists(modFolders(key)))
		{
			return modFolders(key);
		}
		return getPreloadPath(key);
	}

	inline static public function dialogue(key:String)
	{
		if (FileSystem.exists(modFolders("dialogue/" + key)))
		{
			return modFolders("dialogue/" + key);
		}
		return "assets/dialogue/" + key;
	}

	inline static public function shaders(key:String, ?toAdd:String = "frag")
	{
		if (FileSystem.exists(modFolders("shaders/" + key + "." + toAdd)))
		{
			return modFolders("shaders/" + key + "." + toAdd);
		}
		return "assets/shaders/" + key + "." + toAdd;
	}

	inline static public function shop(key:String)
	{
		return "assets/shop/" + key;
	}

	inline static public function archives(key:String)
	{
		return "assets/archives/" + key;
	}
	
	#if MODS_ALLOWED
	static public function addCustomGraphic(key:String):FlxGraphic {
		if(FileSystem.exists(modsImages(key))) 
		{
			if(!customImagesLoaded.exists(key)) {
				var newBitmap:BitmapData = BitmapData.fromFile(modsImages(key));
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
				newGraphic.persist = true;
				FlxG.bitmap.addGraphic(newGraphic);
				customImagesLoaded.set(key, true);
			}
			return FlxG.bitmap.get(key);
		}
		return null;
	}

	inline static public function mods(key:String = '') {
		return 'mods/' + key;
	}

	inline static public function modsJson(key:String) {
		return modFolders('data/' + key + '.json');
	}

	inline static public function modsVideo(key:String) {
		return modFolders('videos/' + key + '.' + VIDEO_EXT);
	}

	inline static public function modsMusic(key:String) {
		return modFolders('music/' + key + '.' + SOUND_EXT);
	}

	inline static public function modsSounds(key:String) {
		return modFolders('sounds/' + key + '.' + SOUND_EXT);
	}

	inline static public function modsSongs(key:String, ?ext:String = "ogg") {
		return modFolders('songs/' + key + '.' + ext);
	}

	inline static public function modsImages(key:String) {
		return modFolders('images/' + key + '.png');
	}

	inline static public function modsDoodles(key:String) {
		return modFolders('doodles/' + key + '.png');
	}

	inline static public function modsXml(key:String) {
		return modFolders('images/' + key + '.xml');
	}

	inline static public function modsTxt(key:String) {
		return modFolders('images/' + key + '.txt');
	}

	inline static public function modsTxtData(key:String) {
		return modFolders('data/' + key + '.txt');
	}

	inline static public function warpInfo(key:String) {
		return modFolders('data/' + key + '.txt');
	}

	inline static public function modsScriptTxt(key:String) {
		return modFolders('scripts/' + key + '.txt');
	}

	inline static public function getModFile(key:String)
	{
		return modFolders(key);
	}

	static public function modFolders(key:String) {
		if(currentModDirectory != null && currentModDirectory.length > 0) {
			var fileToCheck:String = mods(currentModDirectory + '/' + key);
			if(FileSystem.exists(fileToCheck)) {
				return fileToCheck;
			}
		}
		WeekData.getAssetDirectories();
		if (AssetDirectories != [])
		{
			for (i in 0...AssetDirectories.length)
			{
				var fileToCheck:String = mods(AssetDirectories[i] + "/" + key);
				if (FileSystem.exists(fileToCheck))
				{
					return fileToCheck;
				}
			}
		}
		return 'mods/' + key;
	}

	static public function getModDirectories():Array<String> {
		var list:Array<String> = [];
		var modsFolder:String = mods();
		if(FileSystem.exists(modsFolder)) {
			for (folder in FileSystem.readDirectory(modsFolder)) {
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !ignoreModFolders.exists(folder) && !list.contains(folder)) {
					list.push(folder);
				}
			}
		}
		return list;
	}
	#end
}
