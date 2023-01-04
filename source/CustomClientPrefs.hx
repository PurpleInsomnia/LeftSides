package;

class CustomClientPrefs
{
    #if (haxe >= "4.0.0")
    public static var saved:Map<String, Dynamic> = new Map();
    #else
    public static var saved:Map<String, Dynamic> = new Map<String, Dynamic>();
    #end

    public static function save(data:String, val:Dynamic)
    {
        if (saved.exists(Paths.currentModDirectory + data))
        {
            saved.remove(Paths.currentModDirectory + data);
        }
        saved.set(Paths.currentModDirectory + data, val);
        ClientPrefs.saveSettings();
    }

    public static function remove(data:String)
    {
        if (saved.exists(Paths.currentModDirectory + data))
        {
            saved.remove(Paths.currentModDirectory + data);
        }
        ClientPrefs.saveSettings();
    }

    public static function get(data:String):Dynamic
    {
        if (saved.exists(Paths.currentModDirectory + data))
        {
            return saved.get(Paths.currentModDirectory + data);
        }
        return null;
    }
}