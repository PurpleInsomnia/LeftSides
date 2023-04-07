#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;

import flixel.util.FlxTimer;

class GlobalLua
{
    var lua:State = null;

    var lePlayState:Dynamic = null;

    public static var Function_Continue = 0;
    public static var Function_Stop = 1;

    var gonnaClose:Bool = false;

    public function new(path:String, parent:Dynamic)
    {
        lua = LuaL.newstate();
        LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

        var result:Dynamic = LuaL.dofile(lua, path);
		var resultStr:String = Lua.tostring(lua, result);
		if(resultStr != null && result != 0) {
			lime.app.Application.current.window.alert(resultStr, 'Error on .LUA script!');
			trace('Error on .LUA script! ' + resultStr);
			lua = null;
			return;
		}

        set('Function_Stop', Function_Stop);
		set('Function_Continue', Function_Continue);
        set('luaDebugMode', false);
		set('luaDeprecatedWarnings', true);

        // Some settings, no jokes
		set('downscroll', ClientPrefs.downScroll);
		set('middlescroll', ClientPrefs.middleScroll);
		set('framerate', ClientPrefs.framerate);
		set('ghostTapping', ClientPrefs.ghostTapping);
		set('hideHud', ClientPrefs.hideHud);
		set('hideTime', ClientPrefs.hideTime);
		set('cameraZoomOnBeat', ClientPrefs.camZooms);
		set('flashingLights', ClientPrefs.flashing);
		set('flashing', ClientPrefs.flashing);
		set('noteOffset', ClientPrefs.noteOffset);
		set('lowQuality', ClientPrefs.lowQuality);
		set('jumpscares', ClientPrefs.jumpscares);
		set('shaders', ClientPrefs.shaders);

        Lua_helper.add_callback(lua, "close", function(printMessage:Bool) {
			if(!gonnaClose) {
				new FlxTimer().start(0.1, function(tmr:FlxTimer) {
					stop();
				});
			}
			gonnaClose = true;
		});

        addCallback("trace", function(message:Dynamic)
        {
            trace(message);
        });

        call("onCreate", []);
    }

    public function addCallback(name:String, thingy:Dynamic)
    {
        Lua_helper.add_callback(lua, name, thingy);
    }

    public function luaTrace(text:String, ignoreCheck:Bool = false, deprecated:Bool = false) {
		#if LUA_ALLOWED
		if(ignoreCheck || getBool('luaDebugMode')) {
			if(deprecated && !getBool('luaDeprecatedWarnings')) {
				return;
			}
			lePlayState.addTextToDebug(text);
			trace(text);
		}
		#end
	}
	
	public function call(event:String, args:Array<Dynamic>):Dynamic {
		if(lua == null) {
			return Function_Continue;
		}

		Lua.getglobal(lua, event);

		for (arg in args) {
			Convert.toLua(lua, arg);
		}

		var result:Null<Int> = Lua.pcall(lua, args.length, 1, 0);
		if(result != null && resultIsAllowed(lua, result)) {
			/*var resultStr:String = Lua.tostring(lua, result);
			var error:String = Lua.tostring(lua, -1);
			Lua.pop(lua, 1);*/
			if(Lua.type(lua, -1) == Lua.LUA_TSTRING) {
				var error:String = Lua.tostring(lua, -1);
				Lua.pop(lua, 1);
				if(error == 'attempt to call a nil value') { //Makes it ignore warnings and not break stuff if you didn't put the functions on your lua file
					return Function_Continue;
				}
			}

			var conv:Dynamic = Convert.fromLua(lua, result);
			return conv;
		}
		return Function_Continue;
	}

	function resultIsAllowed(leLua:State, leResult:Null<Int>) { //Makes it ignore warnings
		switch(Lua.type(leLua, leResult)) {
			case Lua.LUA_TNIL | Lua.LUA_TBOOLEAN | Lua.LUA_TNUMBER | Lua.LUA_TSTRING | Lua.LUA_TTABLE:
				return true;
		}
		return false;
	}

	public function set(variable:String, data:Dynamic) {
		if(lua == null) {
			return;
		}

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
	}

	public function getBool(variable:String) {
		var result:String = null;
		Lua.getglobal(lua, variable);
		result = Convert.fromLua(lua, -1);
		Lua.pop(lua, 1);

		if(result == null) {
			return false;
		}

		// YES! FINALLY IT WORKS
		//trace('variable: ' + variable + ', ' + result);
		return (result == 'true');
	}

	public function stop() {
		if(lua == null) {
			return;
		}

		Lua.close(lua);
		lua = null;
	}
}
#end