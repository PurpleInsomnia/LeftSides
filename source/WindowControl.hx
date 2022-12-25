package;

import flixel.FlxG;
import lime.app.Application;

class WindowControl
{
    public static function rePosWindow()
    {
        var display = Application.current.window.display.currentMode;

        Application.current.window.x = Std.int((display.width / 2) - Application.current.window.width / 2);
        Application.current.window.y = Std.int((display.height / 2) - Application.current.window.height / 2); 
    }
}