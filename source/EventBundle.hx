package;

import haxe.Json;
import sys.FileSystem;
import sys.io.File;

typedef EventMeta = {
    var events:Array<EventArray>;
}

typedef EventArray = {
    var step:Int;
    var toTrigger:Array<Array<String>>;
}

class EventBundle
{
    public static var data:EventMeta = null;

    public static function loadEventsFromSong(song:String)
    {
        if (!PlayState.encoreMode)
        {
            if (FileSystem.exists(Paths.preloadFunny("data/" + song + "/eventBundle.json")))
            {
                data = Json.parse(File.getContent(Paths.preloadFunny("data/" + song + "/eventBundle.json")));
            }
        }
        else
        {
            if (FileSystem.exists(Paths.preloadFunny("data/" + song + "/eventBundle-encore.json")))
            {
                data = Json.parse(File.getContent(Paths.preloadFunny("data/" + song + "/eventBundle-encore.json")));
            }
        }
    }

    public static function checkForATrigger(step:Int, lePlayState:PlayState)
    {
        if (data == null)
        {
            return;
        }

        for (i in 0...data.events.length)
        {
            if (data.events[i].step == step)
            {
                for (event in data.events[i].toTrigger)
                {
                    lePlayState.triggerEventNote(event[0], event[1], event[2]);
                }
            }
        }
    }
}