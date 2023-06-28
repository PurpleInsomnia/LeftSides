package;

import haxe.Json;
import sys.FileSystem;

typedef PlayStateMetaData = {
	var wardrobeEnabled:Bool;
    var loadingDirectory:String;
    var loadingMusic:String;
    var pauseMusic:String;
    var strumSkins:MetaSkins;
    var ratingPack:String;
    var songInfoType:String;
}

typedef MetaSkins = {
    dad:String,
    bf:String,
    gf:String
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
            loadingMusic: "loading",
            pauseMusic: "breakfast",
            strumSkins: {
                "dad": "",
                "bf": "",
                "gf": ""
            },
            ratingPack: "",
            songInfoType: "default"
        }
        dataFile = metaFile;
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
            loadingMusic: "loading",
            pauseMusic: "breakfast",
            strumSkins: {
                "dad": "",
                "bf": "",
                "gf": ""
            },
            ratingPack: "",
            songInfoType: "default"
        }
        return metaFile;
    }
}