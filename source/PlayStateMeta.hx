package;

import haxe.Json;
import sys.FileSystem;

typedef PlayStateMetaData = {
	var wardrobeEnabled:Bool;
    var loadingDirectory:String;
    var pauseMusic:String;
}

class PlayStateMeta
{
    public static var dataFile:PlayStateMetaData = null;

    public static function setFile(song:String)
    {
        if (FileSystem.exists(Paths.preloadFunny("data/" + Paths.formatToSongPath(song) + "/meta.json")))
        {
            var newMeta:PlayStateMetaData = Json.parse(Paths.getTextFromFile("data/" + Paths.formatToSongPath(song) + "/meta.json"));
            dataFile = newMeta;
            return;
        }
        var metaFile:PlayStateMetaData = {
            wardrobeEnabled: true,
            loadingDirectory: "",
            pauseMusic: "breakfast"
        }
        dataFile =  metaFile;
    }

    public static function loadFile(song:String)
    {
        if (FileSystem.exists(Paths.preloadFunny("data/" + Paths.formatToSongPath(song) + "/meta.json")))
        {
            var newMeta:PlayStateMetaData = Json.parse(Paths.getTextFromFile("data/" + Paths.formatToSongPath(song) + "/meta.json"));
            return newMeta;
        }
        var metaFile:PlayStateMetaData = {
            wardrobeEnabled: true,
            loadingDirectory: "",
            pauseMusic: "breakfast"
        }
        return metaFile;
    }
}