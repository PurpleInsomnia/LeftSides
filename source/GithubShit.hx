package;

import flixel.util.FlxTimer;
import haxe.Json;
import sys.io.File;

typedef GithubFile = {
    var doodlesLink:String;
    var doodlesDescLink:String;
    var dlcHOFLink:String;
    var communityLink:String;
    var comicsLink:String;
}

class GithubShit
{
    public static var GF:GithubFile = null;
    public static function load(callback:Void->Void)
    {
        GF = Json.parse(File.getContent("assets/data/githubLinks.json"));
        callback();
    }
}