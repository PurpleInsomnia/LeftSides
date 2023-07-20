package;

#if DISCORD
import Discord.DiscordClient;
#end
import GameJolt.GameJoltAPI;
import filters.*;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.addons.text.FlxTypeText;
import flixel.effects.FlxFlicker;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.FlxSound;
import flixel.text.FlxText.FlxTextAlign;
import flixel.text.FlxText.FlxTextBorderStyle;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxCollision;
import flixel.util.FlxDirectionFlags;
import flixel.util.FlxTimer;
import haxe.ds.StringMap;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.ShaderFilter;
import sys.FileSystem;
import sys.io.File;
import trophies.TrophyUtil;
import trophies.TrophiesState;
import trophies.TrophiesState.TrophySelectState;

using StringTools;

class MenuHscript
{

    public static var hscriptVars:StringMap<Dynamic> = new StringMap<Dynamic>();

	public static var parent:Dynamic = null;

    public static function getBlend(blend:String):BlendMode
    {
        switch(blend.toLowerCase().trim()) {
			case 'add': return ADD;
			case 'alpha': return ALPHA;
			case 'darken': return DARKEN;
			case 'difference': return DIFFERENCE;
			case 'erase': return ERASE;
			case 'hardlight': return HARDLIGHT;
			case 'invert': return INVERT;
			case 'layer': return LAYER;
			case 'lighten': return LIGHTEN;
			case 'multiply': return MULTIPLY;
			case 'overlay': return OVERLAY;
			case 'screen': return SCREEN;
			case 'shader': return SHADER;
			case 'subtract': return SUBTRACT;
		}
		return NORMAL;
    }

    public static function callOnScripts(thing:String, arg:Dynamic)
	{
		// lazy way of doin shit LMFAOOOOOOOOOOOOOOOO
        if (MusicBeatState.menuHscripts[0] == null)
        {
			// nothing
        }
		else
		{
			for (i in 0...MusicBeatState.menuHscripts.length)
			{
		    	if (MusicBeatState.menuHscripts[i].exists(thing))
		    	{
			    	if (arg[0] == null)
				    	MusicBeatState.menuHscripts[i].get(thing)();

			    	if (arg.length == 1)
				    	MusicBeatState.menuHscripts[i].get(thing)(arg[0]);

			    	if (arg.length == 2)
				    	MusicBeatState.menuHscripts[i].get(thing)(arg[0], arg[1]);

			    	if (arg.length == 3)
				    	MusicBeatState.menuHscripts[i].get(thing)(arg[0], arg[1], arg[2]);

			    	if (arg.length == 4)
				    	MusicBeatState.menuHscripts[i].get(thing)(arg[0], arg[1], arg[2], arg[3]);

			    	if (arg.length == 5)
				    	MusicBeatState.menuHscripts[i].get(thing)(arg[0], arg[1], arg[2], arg[3], arg[4]);

			    	if (arg.length == 6)
				    	MusicBeatState.menuHscripts[i].get(thing)(arg[0], arg[1], arg[2], arg[3], arg[4], arg[5]);
				}
			}
        }
	}

	public static function setOnScripts(vari:String, val:Dynamic)
	{
        if (MusicBeatState.menuHscripts[0] == null)
        {
            return;
        }
		for (i in 0...MusicBeatState.menuHscripts.length)
		{
			MusicBeatState.menuHscripts[i].set(vari, val);
		}
	}

    public static function theTrace(val:Dynamic)
    {
        trace(val);
    }

	public static function addScript(scriptPath:String)
	{
        @:privateAccess
		MusicBeatState.menuHscripts.push(HscriptManager.load(Paths.preloadFunny("states/" + MusicBeatState.currentStateName + "/" + scriptPath + ".hxs"), hscriptVars));
	}

	public static function removeScript(ind:Int)
	{
		// goofyahh
		var daScript:HscriptScript = MusicBeatState.menuHscripts[ind];
		daScript.dispose();
		MusicBeatState.menuHscripts.remove(daScript);
	}

	public static function screenCenter(obj:FlxObject, ?pl:String = "XY")
	{
		switch(pl.toUpperCase())
		{
			case "X":
				obj.screenCenter(FlxAxes.X);
			case "Y":
				obj.screenCenter(FlxAxes.Y);
			case "XY":
				obj.screenCenter(FlxAxes.XY);
		}
	}

	public static function setCamBgAlpha(camera:FlxCamera, ?alpha:Float = 0)
	{
		camera.bgColor.alpha = 0;
	}

	public static function alignText(text:FlxText, ?place:String = "left")
	{
		switch(place.toLowerCase())
		{
			case "left":
				text.alignment = LEFT;
			case "right":
				text.alignment = RIGHT;
			case "center":
				text.alignment = CENTER;
		}
	}

	// only I can use this HAHAHAHAHAHA!!!
	public static function unlockGameJoltTrophy(id:Int, icon:String)
	{
		GameJoltAPI.getTrophy(id, icon);
	}

    public static function setHscriptVars(parent:Dynamic)
    {
		MenuHscript.parent = parent;

        hscriptVars.set("add", parent.add);
		hscriptVars.set("remove", parent.remove);
		hscriptVars.set("insert", parent.insert);
		hscriptVars.set("lePlayState", parent);

		hscriptVars.set("screenCenter", screenCenter);
		hscriptVars.set("setCamBgAlpha", setCamBgAlpha);
		hscriptVars.set("alignText", alignText);
		hscriptVars.set("unlockGameJoltTrophy", unlockGameJoltTrophy);

        hscriptVars.set("controls", parent.controls);
		hscriptVars.set("openSubState", parent.openSubState);
        hscriptVars.set("getBlend", getBlend);
        hscriptVars.set("trace", theTrace);
		hscriptVars.set("addScript", addScript);
		hscriptVars.set("removeScript", removeScript);

		hscriptVars.set("callOnScripts", callOnScripts);
		hscriptVars.set("setOnScripts", setOnScripts);

        // Some settings, no jokes
		hscriptVars.set('flashingLights', ClientPrefs.flashing);
		hscriptVars.set("antialiasing", ClientPrefs.globalAntialiasing);
		hscriptVars.set('lowQuality', ClientPrefs.lowQuality);

		#if windows
		hscriptVars.set('buildTarget', 'windows');
		#elseif linux
		hscriptVars.set('buildTarget', 'linux');
		#elseif mac
		hscriptVars.set('buildTarget', 'mac');
		#elseif html5
		hscriptVars.set('buildTarget', 'browser');
		#elseif android
		hscriptVars.set('buildTarget', 'android');
		#else
		hscriptVars.set('buildTarget', 'unknown');
		#end
    }

    public static function returnFile(path:String)
    {
        @:privateAccess
        var state:String = MusicBeatState.currentStateName;

        var daPath:String = Paths.preloadFunny("states/" + state + "/" + path + ".hxs");
        setHscriptVars(MusicBeatState.getState());
        return HscriptManager.load(daPath, hscriptVars);
    }
}