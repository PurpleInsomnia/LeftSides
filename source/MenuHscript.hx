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
            return;
        }
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

	#if LUA_ALLOWED
	public static function addLuaScript(scriptPath:String)
	{
		return new GlobalLua(scriptPath, parent);
	}
	#end

	public static function addScript(scriptPath:String)
	{
        @:privateAccess
		MusicBeatState.menuHscripts.push(MenuHscriptFile.load(Paths.preloadFunny("states/" + MusicBeatState.currentStateName + "/" + scriptPath + ".hxs"), hscriptVars, MusicBeatState.getState()));
	}

	public static function removeScript(ind:Int)
	{
		// goofyahh
		var daScript:MenuScript = MusicBeatState.menuHscripts[ind];
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

    public static function setHscriptVars(parent:Dynamic)
    {
		MenuHscript.parent = parent;

        hscriptVars.set("add", parent.add);
		hscriptVars.set("remove", parent.remove);
		hscriptVars.set("insert", parent.insert);

		hscriptVars.set("screenCenter", screenCenter);
		hscriptVars.set("setCamBgAlpha", setCamBgAlpha);
		hscriptVars.set("alignText", alignText);

        hscriptVars.set("controls", parent.controls);
		hscriptVars.set("openSubState", parent.openSubState);
        hscriptVars.set("getBlend", getBlend);
        hscriptVars.set("trace", theTrace);
		hscriptVars.set("addScript", addScript);
		hscriptVars.set("removeScript", removeScript);
		#if LUA_ALLOWED
		hscriptVars.set("addLuaScript", addLuaScript);
		#end

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
        MenuHscriptFile.initialize();

        @:privateAccess
        var state:String = MusicBeatState.currentStateName;

        var daPath:String = Paths.preloadFunny("states/" + state + "/" + path + ".hxs");
        setHscriptVars(MusicBeatState.getState());
        return MenuHscriptFile.load(daPath, hscriptVars, MusicBeatState.getState());
    }
}

class MenuHscriptFile
{
    public static var exp:StringMap<Dynamic>;

	public static var parser:Parser = new Parser();

	public static function initialize()
	{
		exp = new StringMap<Dynamic>();

		// Haxe
		exp.set("Sys", Sys);
		exp.set("Std", Std);
		exp.set("Math", Math);
		exp.set("StringTools", StringTools);
		exp.set("Reflect", Reflect);
		exp.set("Int", Int);
		exp.set("Float", Float);
		exp.set("Bool", Bool);
		exp.set("String", String);
		exp.set("Dynamic", Dynamic);
		exp.set("Array", Array);
		exp.set("Math", Math);
		exp.set("Date", Date);
		exp.set("StringMap", StringMap);
		exp.set("FileSystem", sys.FileSystem);
		exp.set("File", sys.io.File);
		exp.set("Bytes", haxe.io.Bytes);
		exp.set("Json", haxe.Json);

		// Flixel
		exp.set("FlxG", FlxG);
		exp.set("FlxSprite", FlxSprite);
		exp.set("FlxObject", FlxObject);
        exp.set("FlxButton", FlxButton);
		exp.set("FlxCamera", FlxCamera);
		exp.set("FlxMath", FlxMath);
		exp.set("FlxPoint", FlxPoint);
		exp.set("FlxRect", FlxRect);
		exp.set("FlxTween", FlxTween);
		exp.set("FlxTimer", FlxTimer);
		exp.set("FlxEase", FlxEase);
		exp.set("FlxGraphicsShader", FlxGraphicsShader);
		exp.set("FlxGroup", FlxGroup);
		// custom FlxTypedGroup class because it dosen't work on hscript for some strange reason :/
		exp.set("FlxTypedGroup", MenuGroup);
		exp.set("FlxShader", FlxShader);
		exp.set("FlxSound", FlxSound);
		exp.set("FlxBar", FlxBar);
		exp.set("FlxGraphic", FlxGraphic);
		exp.set("FlxText", FlxText);
		exp.set("FlxTypeText", FlxTypeText);
		exp.set("FlxDirectionFlags", MenuDirection);
		exp.set("FlxCollision", FlxCollision);
		exp.set("FlxFlicker", FlxFlicker);
		exp.set("FlxTweenType", MenuType);
        exp.set("FlxTextBorderStyle", MenuBorder);
		exp.set("FlxVideo", FlxVideo);
		
		// Classes
		exp.set("Conductor", Conductor);
		exp.set("Character", Character);
		exp.set("Boyfriend", Boyfriend);
		exp.set("DialogueBox", DialogueBoxPsych);
		exp.set("ClientPrefs", ClientPrefs);
		exp.set("CustomClientPrefs", CustomClientPrefs);
		exp.set("CoolUtil", CoolUtil);
		exp.set("Alphabet", Alphabet);
		exp.set("AttachedSprite", AttachedSprite);
		exp.set("AttachedText", AttachedText);
        exp.set("MusicBeatState", MusicBeatState);
        exp.set("MusicBeatSubstate", MusicBeatSubstate);
		exp.set("LoadingState", LoadingState);
        exp.set("GridBackdrop", GridBackdrop);
		exp.set("Backdrop", Backdrop);
        exp.set("Highscore", Highscore);
        exp.set("Paths", Paths);
		exp.set("Song", Song);
		exp.set("HealthIcon", HealthIcon);
		exp.set("PlayState", PlayState);
		exp.set("WeekData", WeekData);
		exp.set("TextFile", TextFile);
		exp.set("FileOpener", FileOpener);
		#if DISCORD
		exp.set("DiscordClient", DiscordClient);
		#end

		// note shit.
		exp.set("Note", Note);
		exp.set("NoteSplash", NoteSplash);
		exp.set("StrumNote", StrumNote);

        // shader classes
        exp.set("ShaderFilter", ShaderFilter);
        exp.set("BitmapFilter", BitmapFilter);
		exp.set("ColorMatrixFilter", ColorMatrixFilter);

		// allowed classes
		exp.set("MainMenuState", MainMenuState);
		exp.set("FreeplayState", FunnyFreeplayState);
		exp.set("OptionsState", options.OptionsState);
		exp.set("TitleState", TitleScreenState);
		exp.set("HealthLossState", HealthLossState);
		exp.set("LoadingScreenState", LoadingScreenState);
		exp.set("CustomState", CustomState);
		exp.set("StoryMenuState", StoryMenuState);
		exp.set("StoryEncoreState", StoryEncoreState);
		exp.set("ChooseCreditsState", ChooseCredits);
		exp.set("CreidtsState", CreditsState);
		exp.set("DoodlesState", DoodlesState);
		exp.set("MonsterLairState", MonsterLairState);
		exp.set("DlcMenuState", DlcMenuState);
		exp.set("SelectSongTypeState", SelectSongTypeState);
		exp.set("SideStorySelectState", SideStorySelectState);
		exp.set("SideStoryState", SideStoryState);
		exp.set("MasterEditorMenu", editors.MasterEditorMenu);
		exp.set("ResultsScreen", ResultsScreen);
		exp.set("ResultsSong", ResultsSong);
		exp.set("SoundtrackState", SoundtrackState);
		exp.set("CustomSubState", CustomSubState);

		// substates :)
		exp.set("ResetScoreSubState", ResetScoreSubState);
		exp.set("ResetEncoreScoreSubState", ResetEncoreScoreSubState);

		// filters
		exp.set("Scanline", Scanline);
		exp.set("Tiltshift", Tiltshift);
		exp.set("TV", TV);
		exp.set("VCR", VCR);
		exp.set("PixelateShader", PixelateShader);
		exp.set("ChromaticAberation", ChromaticAberation);
		exp.set("CustomShader", hxshaders.FlxRuntimeShader);
		exp.set("FlxShaderToy", hxshaders.FlxShaderToy);

		// lol backend shit.
		exp.set("Internet", InternetAPI);

		// ogmo
		exp.set("FlxOgmo", FlxOgmo3Loader);
		exp.set("FlxTilemap", FlxTilemap);
		// I guess if you want these classes I guess you're gonna have to use dynamic. :/
		/*
		exp.set("OgmoProjectData", ProjectData);
		exp.set("OgmoProjectLayerData", ProjectLayerData);
		exp.set("OgmoProjectEntityData", ProjectEntityData);
		exp.set("OgmoProjectTilesetData", ProjectTilesetData);
		exp.set("OgmoLevelData", LevelData);
		exp.set("OgmoLayerData", LayerData);
		exp.set("OgmoTileLayer", TileLayer);
		exp.set("OgmoGridLayer", GridLayer);
		exp.set("OgmoEntityLayer", EntityLayer);
		exp.set("OgmoEntityData", EntityData);
		exp.set("OgmoDecalLayer", DecalLayer);
		exp.set("OgmoDecalData", DecalData);
		exp.set("OgmoPoint", Point);
		*/

		#if LUA_ALLOWED
		exp.set("GlobalLua", GlobalLua);
		#end
        
		parser.allowTypes = true;
		parser.resumeErrors = true;
		parser.allowJSON = true;
	}

	public static function load(path:String, ?extraParams:StringMap<Dynamic>, parent:Dynamic)
	{
		return new MenuScript(parser.parseString(File.getContent(path)), extraParams, parent);
	}
}

class MenuScript
{
    public var interp:Interp;
	public var assetGroup:String;

	public var alive:Bool = true;

	public function new(?contents:Expr, ?extraParams:StringMap<Dynamic>, parent:Dynamic)
	{
		interp = new Interp();
		for (i in MenuHscriptFile.exp.keys())
			interp.variables.set(i, MenuHscriptFile.exp.get(i));
		if (extraParams != null)
		{
			for (i in extraParams.keys())
				interp.variables.set(i, extraParams.get(i));
		}
		interp.variables.set('dispose', dispose);
        interp.variables.set("lePlayState", parent);
		interp.execute(contents);
		if (exists("onCreate"))
		{
			get("onCreate")();
		}
	}

	public function dispose():Dynamic
		return this.alive = false;

	public function get(field:String):Dynamic
		return interp.variables.get(field);

	public function set(field:String, value:Dynamic)
		interp.variables.set(field, value);

	public function exists(field:String):Bool
		return interp.variables.exists(field);
}

class MenuGroup extends FlxTypedGroup<Dynamic>
{
    public function new()
    {
        super();
    }
}

class MenuDirection
{
	public static var left:FlxDirectionFlags = FlxDirectionFlags.LEFT;
	public static var down:FlxDirectionFlags = FlxDirectionFlags.DOWN;
	public static var up:FlxDirectionFlags = FlxDirectionFlags.UP;
	public static var right:FlxDirectionFlags = FlxDirectionFlags.RIGHT;

	// collision bs.
	public static var none:FlxDirectionFlags = FlxDirectionFlags.NONE;
	public static var ceiling:FlxDirectionFlags = FlxDirectionFlags.CEILING;
	public static var floor:FlxDirectionFlags = FlxDirectionFlags.FLOOR;
	public static var wall:FlxDirectionFlags = FlxDirectionFlags.WALL;
	public static var any:FlxDirectionFlags = FlxDirectionFlags.ANY;
}

class MenuType
{
    public static var oneshot:FlxTweenType = FlxTweenType.ONESHOT;
    public static var persist:FlxTweenType = FlxTweenType.PERSIST;
    public static var backward:FlxTweenType = FlxTweenType.BACKWARD;
    public static var looping:FlxTweenType = FlxTweenType.LOOPING;
    public static var pingpong:FlxTweenType = FlxTweenType.PINGPONG;
}

class MenuBorder
{
    public static var outline:FlxTextBorderStyle = FlxTextBorderStyle.OUTLINE;
    public static var outlineFast:FlxTextBorderStyle = FlxTextBorderStyle.OUTLINE_FAST;
    public static var shadow:FlxTextBorderStyle = FlxTextBorderStyle.SHADOW;
    public static var none:FlxTextBorderStyle = FlxTextBorderStyle.NONE;
}