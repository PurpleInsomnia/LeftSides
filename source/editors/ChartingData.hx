package editors;

import flixel.FlxG;

typedef ChartingMetaData = {
    var waveforms:Array<Bool>;
    var muteInst:Bool;
    var muteVocals:Bool;
    var playSoundBf:Bool;
    var playSoundDad:Bool;
    var playSoundGf:Bool;
}

class ChartingData
{
    public static var data:ChartingMetaData = null;

    public static function saveChartingPrefs()
    {
        FlxG.save.data.chartingData = data;
        
        FlxG.save.flush();
    }

    public static function loadChartingPrefs()
    {
        if (FlxG.save.data.chartingData != null)
        {
            data = FlxG.save.data.chartingData;
        }
        else
        {
            data = {
                waveforms: [false, false, false, false],
                muteInst: false,
                muteVocals: false,
                playSoundBf: false,
                playSoundDad: false,
                playSoundGf: false
            }
        }
    }
}