package dlc;

import trophies.TrophyUtil.TrophiesData;
import haxe.ds.StringMap;
import haxe.Json;
import trophies.TrophyUtil.*;
import sys.FileSystem;

class DlcTrophies
{
    public static var data:TrophiesData = null;
    #if (haxe >= "4.0.0")
    public static var trophies:Map<String, Bool> = new Map();
    #else
    public static var trophies:Map<String, Bool> = new Map(String, Bool);
    #end

    public static function getTrophies()
    {
        if (FileSystem.exists(Paths.getModFile("trophies/data.json")))
        {
            data = Json.parse(Paths.getTextFromFile("trophies/data.json"));
        }
        else
        {
            data = null;
        }
    }

    public static function getTrophyFromDirectory(direct:String)
    {
        var retData:TrophiesData = null;
        if (FileSystem.exists(Paths.getModFile("trophies/data.json")))
        {
            retData = Json.parse(Paths.getTextFromFile("trophies/data.json"));
        }
        return retData;
    }

    public static function getTrophy(name:String)
    {
        if (trophies.exists(Paths.currentModDirectory + name))
        {
            return true;
        }
        return false;
    }
}