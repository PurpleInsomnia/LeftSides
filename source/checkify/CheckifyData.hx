package checkify;

import flixel.FlxG;

typedef CheckifyOptions = {
    var loop:Bool;
    var shuffle:Bool;
}

class CheckifyData
{
    public static var data:CheckifyOptions = null;

    public static function save()
    {
        FlxG.save.data.checkifyOptions = data;

        FlxG.save.flush();
    }

    public static function load()
    {
        if (FlxG.save.data.checkifyOptions != null)
        {
            data = FlxG.save.data.checkifyOptions;
        }
        else
        {
            data = {
                loop: true,
                shuffle: false
            }
            save();
        }
    }
}