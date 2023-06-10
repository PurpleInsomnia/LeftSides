package;

import trophies.TrophyUtil;
import trophies.TrophiesState;
import trophies.TrophiesState.TrophySelectState;
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

using StringTools;

class CustomState extends MusicBeatState
{
    var scriptName:String;
	var scriptArray:Array<HscriptScript> = [];

    var hscriptVars:StringMap<Dynamic> = new StringMap<Dynamic>();

    public function new(?name:String = "")
    {
        super();
        scriptName = name;
    }

    override function create()
    {
        #if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

        FlxG.camera.visible = true;

        setHscriptVars();

        scriptArray.push(HscriptManager.load(scriptName, hscriptVars));

        super.create();
    }

	override function closeSubState() 
	{
		callOnScripts("onCloseSubstate", []);
		super.closeSubState();
	}

    override function update(elapsed:Float)
    {
        callOnScripts("onUpdate", [elapsed]);
        super.update(elapsed);
    }

    public function getBlend(blend:String):BlendMode
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

    function callOnScripts(thing:String, arg:Dynamic)
	{
		// lazy way of doin shit LMFAOOOOOOOOOOOOOOOO
		for (i in 0...scriptArray.length)
		{
		    if (scriptArray[i].exists(thing))
		    {
			    if (arg[0] == null)
				    scriptArray[i].get(thing)();

			    if (arg.length == 1)
				    scriptArray[i].get(thing)(arg[0]);

			    if (arg.length == 2)
				    scriptArray[i].get(thing)(arg[0], arg[1]);

			    if (arg.length == 3)
				    scriptArray[i].get(thing)(arg[0], arg[1], arg[2]);

			    if (arg.length == 4)
				    scriptArray[i].get(thing)(arg[0], arg[1], arg[2], arg[3]);

			    if (arg.length == 5)
				    scriptArray[i].get(thing)(arg[0], arg[1], arg[2], arg[3], arg[4]);

			    if (arg.length == 6)
				    scriptArray[i].get(thing)(arg[0], arg[1], arg[2], arg[3], arg[4], arg[5]);
			}
        }
	}

	public function setOnScripts(vari:String, val:Dynamic)
	{
		for (i in 0...scriptArray.length)
		{
			scriptArray[i].set(vari, val);
		}
	}

    function theTrace(val:Dynamic)
    {
        trace(val);
    }

	function addScript(scriptPath:String)
	{
		scriptArray.push(HscriptManager.load(scriptPath, hscriptVars));
	}

	function removeScript(ind:Int)
	{
		// goofyahh
		var daScript:HscriptScript = scriptArray[ind];
		daScript.dispose();
		scriptArray.remove(daScript);
	}

	function screenCenter(obj:FlxObject, ?pl:String = "XY")
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

	function setCamBgAlpha(camera:FlxCamera, ?alpha:Float = 0)
	{
		camera.bgColor.alpha = 0;
	}

	function alignText(text:FlxText, ?place:String = "left")
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

    function setHscriptVars()
    {
        hscriptVars.set("add", add);
		hscriptVars.set("remove", remove);
		hscriptVars.set("insert", insert);

		hscriptVars.set("screenCenter", screenCenter);
		hscriptVars.set("setCamBgAlpha", setCamBgAlpha);
		hscriptVars.set("alignText", alignText);

        hscriptVars.set("controls", controls);
		hscriptVars.set("openSubState", openSubState);
        hscriptVars.set("getBlend", getBlend);
        hscriptVars.set("trace", theTrace);
		hscriptVars.set("addScript", addScript);
		hscriptVars.set("removeScript", removeScript);

		hscriptVars.set("callOnScripts", callOnScripts);

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
}