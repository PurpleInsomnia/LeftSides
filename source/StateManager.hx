package;

import sys.FileSystem;

class StateManager
{
    // returns true for oncreate bs.
    public static function check(name:String):Bool
    {
        #if desktop
        if (FileSystem.exists(Paths.getModFile("states/" + name + ".hxs")))
        {
            MusicBeatState.switchState(new CustomState(Paths.getModFile("states/" + name + ".hxs")));
            return true;
        }
        #end

        return false;
    }
}