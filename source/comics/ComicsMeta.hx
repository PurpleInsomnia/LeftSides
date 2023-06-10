package comics;

import flixel.util.FlxTimer;
import haxe.Json;
import haxe.io.Bytes;
import sys.io.File;
import sys.FileSystem;

typedef ComicsData = {
    var sections:Array<ComicsSection>;
}

typedef ComicsSection = {
    var name:String;
}

class ComicsMeta
{
    public static var data:ComicsData = null;

    public static function loadMetaData()
    {
        #if ALLOW_GITHUB
        var http = new haxe.Http("https://raw.githubusercontent.com/PurpleInsomnia/LeftSidesAPIShit/main/" + GithubShit.GF.comicsLink);

        http.onBytes = function(bytes:Bytes)
        {
            File.saveBytes("comics/data.json", bytes);
            data = Json.parse(File.getContent("comics/data.json"));
        }

        http.onError = function(msg)
        {
            trace(msg);
            if (FileSystem.exists("comics/data.json"))
            {
                data = Json.parse(File.getContent("comics/data.json"));
            }
        }

        http.request();
        #end
    }
}