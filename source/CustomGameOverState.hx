package;

#if DISCORD
import Discord.DiscordClient;
#end
import CustomGameOverLua;
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

class CustomGameOverState extends MusicBeatState
{
	#if (haxe >= "4.0.0")
	public var gomodchartTweens:Map<String, FlxTween> = new Map();
	public var gomodchartSprites:Map<String, GameOverModchartSprite> = new Map();
	public var gomodchartTexts:Map<String, GameOverModchartText> = new Map();
	public var gomodchartButtons:Map<String, GameOverLuaButton> = new Map();
	public var gomodchartTimers:Map<String, FlxTimer> = new Map();
	public var gomodchartSounds:Map<String, FlxSound> = new Map();
	#else
	public var gomodchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var gomodchartSprites:Map<String, GameOverModchartSprite> = new Map<String, Dynamic>();
	public var gomodchartTexts:Map<String, GameOverModchartText> = new Map<String, Dynamic>();
	public var gomodchartButtons:Map<String, GameOverLuaButton> = new Map<String, Dyanmic>();
	public var gomodchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var gomodchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	#end

	var lua:CustomGameOverLua = null;
	var script:HscriptScript;
	var path:String = "";

	var hscriptVars:StringMap<Dynamic> = new StringMap<Dynamic>();


	// lua vars.

	public var musicName:String = "";
	public var loopSound:FlxSound = null;
	public var canPress:Bool = false;

	public function new(path:String)
	{
		super();

		this.path = path;
	}

	override function create()
	{
		if (FileSystem.exists(Paths.gameover(path + ".lua")))
		{
			lua = new CustomGameOverLua(Paths.gameover(path + ".lua"));
		}
		if (FileSystem.exists(Paths.gameover(path + ".hxs")))
		{
			setHscript();
			script = HscriptManager.load(Paths.gameover(path + ".hxs"), hscriptVars);
		}

		callOnLuas("onCreate", []);
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		callOnLuas("onUpdate", [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();

		callOnLuas("onBeatHit", []);
	}

	public function playMusic(?vol:Float = 1, ?loop:Bool = true)
	{
		trace(Paths.getSharedMods("music/" + musicName + ".ogg"));
		/*
		loopSound = FlxG.sound.load(Paths.getSharedMods("music/" + musicName + ".ogg"), vol, loop);
		loopSound.time = 0;
		loopSound.play();
		*/
		FlxG.sound.playMusic(Paths.music(musicName), vol, loop);
	}

	public function switchState()
	{
		if (loopSound != null)
		{
			loopSound.stop();
		}
		if (FlxG.sound.music.playing)
		{
			FlxG.sound.music.stop();
		}
		new FlxTimer().start(0.7, function(tmr:FlxTimer)
		{
			FlxG.camera.fade(0xFF000000, 2, false, function()
			{
				MusicBeatState.switchState(new PlayState());
			});
		});
	}

	public function back() 
	{
		if (loopSound != null)
		{
			loopSound.stop();
		}
		if (FlxG.sound.music.playing)
		{
			FlxG.sound.music.stop();
		}
		PlayState.deathCounter = 0;
		PlayState.seenCutscene = false;

		if (PlayState.isStoryMode)
		{
			var check:Bool = StateManager.check("story-menu");
			if (!check)
			{
				MusicBeatState.switchState(new StoryMenuState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		}
		else
		{
			var check:Bool = StateManager.check("freeplay");
			if (!check)
			{
				MusicBeatState.switchState(new FunnyFreeplayState());
				FlxG.sound.playMusic(Paths.music('freeplay'));
			}
		}	
	}

	public function getControl(key:String) 
	{
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
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

	public function callOnLuas(event:String, arg:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = CustomGameOverLua.Function_Continue;
		#if LUA_ALLOWED
		if (lua != null)
		{
			var ret:Dynamic = lua.call(event, arg);
			if(ret != CustomGameOverLua.Function_Continue) 
			{
				returnVal = ret;
			}
		}
		#end
		if (script != null)
		{
			if (script.exists(event))
		    {
			    if (arg[0] == null)
				    script.get(event)();

			    if (arg.length == 1)
				    script.get(event)(arg[0]);

			    if (arg.length == 2)
				    script.get(event)(arg[0], arg[1]);

			    if (arg.length == 3)
				    script.get(event)(arg[0], arg[1], arg[2]);

			    if (arg.length == 4)
				    script.get(event)(arg[0], arg[1], arg[2], arg[3]);

			    if (arg.length == 5)
				    script.get(event)(arg[0], arg[1], arg[2], arg[3], arg[4]);

			    if (arg.length == 6)
				    script.get(event)(arg[0], arg[1], arg[2], arg[3], arg[4], arg[5]);
			}
		}
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) 
	{
		#if LUA_ALLOWED
		if (lua != null)
		{
			lua.set(variable, arg);
		}
		#end
		if (script != null)
		{
			script.set(variable, arg);
		}
	}

	// hscript shit lol
	function theTrace(val:Dynamic)
    {
        trace(val);
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

	public function setHscript()
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
		hscriptVars.set("lePlayState", this);

		hscriptVars.set("callOnScripts", callOnLuas);

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