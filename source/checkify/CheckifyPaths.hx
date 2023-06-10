package checkify;

import flash.media.Sound;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.display.BitmapData;
import sys.FileSystem;
import sys.io.File;

typedef CheckifyMeta = {
    var name:String;
    var list:Array<String>;
    var artists:Array<String>;
    var filePaths:Array<String>;
    var songType:String;
}

class CheckifyPaths
{
    public static var ignoreDLC:Array<String> = ["ost", "bonus", "encore", "menu", "insts", "insts-encore"];
    public static function loadMeta(name:String)
    {
        if (!ignoreDLC.contains(name))
        {
            if (FileSystem.exists(Paths.getModFile("soundtracks/" + name + "/data.json")))
            {
                var coolFile:CheckifyMeta = Json.parse(File.getContent(Paths.getModFile("soundtracks/" + name + "/data.json")));
                return coolFile;
            }
        }
        var newFile:CheckifyMeta = Json.parse(File.getContent(Paths.getPreloadPath("soundtracks/" + name + "/data.json")));
        return newFile;
    }

    public static function loadSongsFromData(data:CheckifyMeta)
    {
        var ret:Array<Array<Dynamic>> = [];
        switch (data.songType)
        {
            default:
                for (i in 0...data.list.length)
                {
                    var inst:String = Paths.preloadFunny("songs/" + Paths.formatToSongPath(data.list[i]) + "/Inst." + Paths.SOUND_EXT);
                    var vocals:String = Paths.preloadFunny("songs/" + Paths.formatToSongPath(data.list[i]) + "/Voices." + Paths.SOUND_EXT);
                    var artist:String = "";
                    if (data.artists[i] == null)
                    {
                        artist = data.artists[0];
                    }
                    else
                    {
                        artist = data.artists[i];
                    }
                    ret.push([inst, vocals, data.list[i], artist, data.name]);
                }
            case "encore":
                for (i in 0...data.list.length)
                {
                    var inst:String = Paths.preloadFunny("songs/" + Paths.formatToSongPath(data.list[i]) + "/InstEncore." + Paths.SOUND_EXT);
                    var vocals:String = Paths.preloadFunny("songs/" + Paths.formatToSongPath(data.list[i]) + "/VoicesEncore." + Paths.SOUND_EXT);
                    var artist:String = "";
                    if (data.artists[i] == null)
                    {
                        artist = data.artists[0];
                    }
                    else
                    {
                        artist = data.artists[i];
                    }
                    ret.push([inst, vocals, data.list[i], artist, data.name]);
                }
            case "inst":
                for (i in 0...data.list.length)
                {
                    var song:String = Paths.preloadFunny("songs/" + Paths.formatToSongPath(data.list[i]) + "/Inst." + Paths.SOUND_EXT);
                    var artist:String = "";
                    if (data.artists[i] == null)
                    {
                        artist = data.artists[0];
                    }
                    else
                    {
                        artist = data.artists[i];
                    }
                    ret.push([song, null, data.list[i], artist, data.name]);
                }
            case "inst-encore":
                for (i in 0...data.list.length)
                {
                    var song:String = Paths.preloadFunny("songs/" + Paths.formatToSongPath(data.list[i]) + "/InstEncore." + Paths.SOUND_EXT);
                    var artist:String = "";
                    if (data.artists[i] == null)
                    {
                        artist = data.artists[0];
                    }
                    else
                    {
                        artist = data.artists[i];
                    }
                    ret.push([song, null, data.list[i], artist, data.name]);
                }
            case "music":
                for (i in 0...data.list.length)
                {
                    var song:String = null;
                    if (FileSystem.exists(Paths.getSharedMods("music/" + data.filePaths[i] + "." + Paths.SOUND_EXT)))
                    {
                        song = Paths.getSharedMods("music/" + data.filePaths[i] + "." + Paths.SOUND_EXT);
                    }
                    else
                    {
                        song = Paths.preloadFunny("music/" + data.filePaths[i] + "." + Paths.SOUND_EXT);
                    }
                    var artist:String = "";
                    if (data.artists[i] == null)
                    {
                        artist = data.artists[0];
                    }
                    else
                    {
                        artist = data.artists[i];
                    }
                    ret.push([song, null, data.list[i], artist, data.name]);
                }
            case "file":
                for (i in 0...data.list.length)
                {
                    var song:String = Paths.preloadFunny(data.filePaths[i] + "." + Paths.SOUND_EXT);
                    var artist:String = "";
                    if (data.artists[i] == null)
                    {
                        artist = data.artists[0];
                    }
                    else
                    {
                        artist = data.artists[i];
                    }
                    ret.push([song, null, data.list[i], artist, data.name]);
                }
        }

        return ret;
    }

    public static function image(img:String):BitmapData
    {
        var bitmap:BitmapData = null;
        if (FileSystem.exists(Paths.getModFile("soundtracks/assets/images/" + img + ".png")))
        {
            bitmap = BitmapData.fromFile(Paths.getModFile("soundtracks/assets/images/" + img + ".png"));
            return bitmap;
        }
        bitmap = BitmapData.fromFile(Paths.getPreloadPath("soundtracks/assets/images/" + img + ".png"));
        return bitmap;
    }

    public static function getAlbumArt(album:String)
    {
        var bitmap:BitmapData = null;
        if (FileSystem.exists(Paths.getModFile("soundtracks/" + album + "/cover.png")))
        {
            bitmap = BitmapData.fromFile(Paths.getModFile("soundtracks/" + album + "/cover.png"));
            return bitmap;
        }
        bitmap = BitmapData.fromFile(Paths.getPreloadPath("soundtracks/" + album + "/cover.png"));
        return bitmap;
    }
}