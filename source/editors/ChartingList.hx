package editors;

import haxe.Json;

typedef ChartingList = {
    var Events:Array<Dynamic>;
    var NoteTypes:Array<String>;
}

class ChartingListUtil
{
    public static var eventStuff:Array<Dynamic> = [];

    public static function loadShit()
    {
        // load chart shit.
		var listFile:ChartingList = Json.parse(Paths.getTextFromFile("data/ChartingLists.json"));
		eventStuff = listFile.Events;
		ChartingState.noteTypeList = listFile.NoteTypes;
    }

    public static function reloadEvents()
    {
        var listFile:ChartingList = Json.parse(Paths.getTextFromFile("data/ChartingLists.json"));
	    eventStuff = listFile.Events; 
    }
}