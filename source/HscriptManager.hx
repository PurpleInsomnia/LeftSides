package;

import WiggleEffect.WiggleEffectType;
#if DISCORD
import Discord.DiscordClient;
#end
import GameJolt.GameJoltAPI;
import FunkinLua;
import comics.ComicsMenu;
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
import flixel.util.FlxColor;
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

class HscriptManager
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
		exp.set("Type", Type);

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
		exp.set("FlxTypedGroup", HscriptGroup);
		exp.set("FlxShader", FlxShader);
		exp.set("FlxSound", FlxSound);
		exp.set("FlxBar", FlxBar);
		exp.set("FlxGraphic", FlxGraphic);
		exp.set("FlxText", FlxText);
		exp.set("FlxTypeText", FlxTypeText);
		exp.set("FlxDirectionFlags", HscriptDirection);
		exp.set("FlxCollision", FlxCollision);
		exp.set("FlxFlicker", FlxFlicker);
        exp.set("FlxTweenType", HscriptType);
        exp.set("FlxTextBorderStyle", HscriptBorder);
		exp.set("FlxVideo", FlxVideo);
		exp.set("FlxColor", CoolColor);
		
		// Classes
		exp.set("Conductor", Conductor);
		exp.set("Character", Character);
		exp.set("Boyfriend", Boyfriend);
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

		// trophies
		exp.set("TrophySelectState", TrophySelectState);
		exp.set("TrophiesState", TrophiesState);
		exp.set("TrophyUtil", TrophyUtil);

        // Playstate.        
		exp.set("ModchartSprite", ModchartSprite);
		exp.set("ModchartText", ModchartText);
		exp.set("LuaButton", LuaButton);

		// note shit.
		exp.set("Note", Note);
		exp.set("NoteSplash", NoteSplash);
		exp.set("StrumNote", StrumNote);

        // shader classes
        exp.set("ShaderFilter", ShaderFilter);
        exp.set("BitmapFilter", BitmapFilter);
		exp.set("ColorMatrixFilter", ColorMatrixFilter);

		// allowed states
		exp.set("MainMenuState", MainMenuState);
		exp.set("FreeplayState", FunnyFreeplayState);
		exp.set("OptionsState", options.OptionsState);
		exp.set("TitleState", TitleScreenState);
		exp.set("HealthLossState", HealthLossState);
		exp.set("LoadingScreenState", LoadingScreenState);
		exp.set("StoryMenuState", StoryMenuState);
		exp.set("StoryEncoreState", StoryEncoreState);
		exp.set("ChooseCreditsState", ChooseCredits);
		exp.set("CreidtsState", CreditsState);
		exp.set("DoodlesState", DoodlesState);
		exp.set("MonsterLairState", MonsterLairState);
		exp.set("DlcMenuState", dlc.DlcMenuState);
		exp.set("SelectSongTypeState", SelectSongTypeState);
		exp.set("SideStorySelectState", SideStorySelectState);
		exp.set("SideStoryState", SideStoryState);
		exp.set("MasterEditorMenu", editors.MasterEditorMenu);
		exp.set("ResultsScreen", ResultsScreen);
		exp.set("ResultsSong", ResultsSong);
		//exp.set("SoundtrackState", SoundtrackState);
        exp.set("ComicsState", ComicsMenu);
		exp.set("TwoPlayerState", twoplayer.TwoPlayerState);
		exp.set("CheckifyLoadingState", checkify.CheckifyLoadingState);

		// substates :)
		exp.set("ResetScoreSubState", ResetScoreSubState);
		exp.set("ResetEncoreScoreSubState", ResetEncoreScoreSubState);
        exp.set("GameOverSubState", GameOverSubstate);

        // custom shit.
        exp.set("CustomState", CustomState);
        exp.set("CustomSubState", CustomSubState);
        exp.set("CustomGameOverState", CustomGameOverState);

		// filters
		exp.set("Scanline", Scanline);
		exp.set("Tiltshift", Tiltshift);
		exp.set("TV", TV);
		exp.set("VCR", VCR);
		exp.set("PixelateShader", PixelateShader);
		exp.set("ChromaticAberation", ChromaticAberation);
		exp.set("CustomShader", hxshaders.FlxRuntimeShader);
		exp.set("FlxShaderToy", hxshaders.FlxShaderToy);
		exp.set("WiggleEffect", WiggleEffect);
		exp.set("WiggleEffectType", WET);

		// lol backend shit.
		exp.set("Internet", InternetAPI);

		// ogmo
		exp.set("FlxOgmo", FlxOgmo3Loader);
		exp.set("FlxTilemap", FlxTilemap);

		// system shit
		exp.set("Application", lime.app.Application);
        
		parser.allowTypes = true;
        parser.resumeErrors = true;
		parser.allowJSON = true;
	}

	public static function load(path:String, ?extraParams:StringMap<Dynamic>)
	{
		return new HscriptScript(parser.parseString(File.getContent(path)), extraParams);
	}
}

class HscriptScript
{
    public var interp:Interp;
	public var assetGroup:String;

	public var alive:Bool = true;

	public function new(?contents:Expr, ?extraParams:StringMap<Dynamic>)
	{
		interp = new Interp();
		for (i in HscriptManager.exp.keys())
			interp.variables.set(i, HscriptManager.exp.get(i));
		if (extraParams != null)
		{
			for (i in extraParams.keys())
				interp.variables.set(i, extraParams.get(i));
		}
		interp.variables.set('dispose', dispose);
		interp.execute(contents);
		if (exists("onCreate"))
		{
			get("onCreate")();
		}
	}

	public function dispose():Dynamic
    {
		return this.alive = false;
    }

	public function get(field:String):Dynamic
    {
		return interp.variables.get(field);
    }

	public function set(field:String, value:Dynamic)
		interp.variables.set(field, value);

	public function exists(field:String):Bool
		return interp.variables.exists(field);
}

class HscriptGroup extends FlxTypedGroup<Dynamic>
{
    public function new()
    {
        super();
    }
}

class HscriptDirection
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

class HscriptType
{
    public static var oneshot:FlxTweenType = FlxTweenType.ONESHOT;
    public static var persist:FlxTweenType = FlxTweenType.PERSIST;
    public static var backward:FlxTweenType = FlxTweenType.BACKWARD;
    public static var looping:FlxTweenType = FlxTweenType.LOOPING;
    public static var pingpong:FlxTweenType = FlxTweenType.PINGPONG;
}

class HscriptBorder
{
    public static var outline:FlxTextBorderStyle = FlxTextBorderStyle.OUTLINE;
    public static var outlineFast:FlxTextBorderStyle = FlxTextBorderStyle.OUTLINE_FAST;
    public static var shadow:FlxTextBorderStyle = FlxTextBorderStyle.SHADOW;
    public static var none:FlxTextBorderStyle = FlxTextBorderStyle.NONE;
}

class WET
{
	public static var dreamy:WiggleEffectType = WiggleEffectType.DREAMY;
	public static var wavy:WiggleEffectType = WiggleEffectType.WAVY;
	public static var heat_wave_horizontal:WiggleEffectType = WiggleEffectType.HEAT_WAVE_HORIZONTAL;
	public static var flag:WiggleEffectType = WiggleEffectType.FLAG;
	public static var heat_wave_vertical:WiggleEffectType = WiggleEffectType.HEAT_WAVE_VERTICAL;
}

class CoolColor 
{
	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):FlxColor
	{
		return FlxColor.fromRGB(Red, Green, Blue, Alpha);
	}

	public static function fromHSB(Hue:Int, Sat:Int, Bright:Int):FlxColor
	{
		return FlxColor.fromHSB(Hue, Sat, Bright);
	}
}