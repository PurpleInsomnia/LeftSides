package;

import Discord.DiscordClient;
import GameJolt.GameJoltAPI;
import flixel.ui.FlxButton;
import openfl.filters.BitmapFilter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.FlxGraphic;
import flixel.FlxCamera;
import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.tile.FlxGraphicsShader;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;
import haxe.ds.StringMap;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;
import openfl.filters.ShaderFilter;
import openfl.display.BlendMode;
import sys.FileSystem;
import sys.io.File;
import flixel.util.FlxAxes;
import flixel.util.FlxCollision;
import flixel.util.FlxDirectionFlags;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.text.FlxText.FlxTextBorderStyle;

// ogmo bs
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;

import filters.*;

using StringTools;

class FunkinHscript
{
    var scriptName:String;
    public var realName:String = "";

    var hscriptVars:StringMap<Dynamic> = new StringMap<Dynamic>();

    public var lePlayState:PlayState = null;

    public var daScript:FunkinScript = null;

    public static var Function_Stop = 1;
	public static var Function_Continue = 0;

    public function new(name:String)
    {
        scriptName = name;
        var scriptNameSplit:Array<String> = name.split("/");
		var funnySplit = scriptNameSplit[scriptNameSplit.length - 1].split(".");
		realName = funnySplit[0];

        var curState:Dynamic = FlxG.state;
		lePlayState = curState;

        trace("goofy ahh");

        PlayStateHscript.initialize();
        setHscriptVars();

        daScript = PlayStateHscript.load(scriptName, hscriptVars);

        trace("Loaded Hscript: " + name);
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

    public function call(thing:String, arg:Array<Dynamic>)
    {
        if (daScript.exists(thing))
        {
		    if (arg[0] == null)
			    daScript.get(thing)();

		    if (arg.length == 1)
			    daScript.get(thing)(arg[0]);

		    if (arg.length == 2)
			    daScript.get(thing)(arg[0], arg[1]);

		    if (arg.length == 3)
			    daScript.get(thing)(arg[0], arg[1], arg[2]);

		    if (arg.length == 4)
			    daScript.get(thing)(arg[0], arg[1], arg[2], arg[3]);

		    if (arg.length == 5)
			    daScript.get(thing)(arg[0], arg[1], arg[2], arg[3], arg[4]);

		    if (arg.length == 6)
			    daScript.get(thing)(arg[0], arg[1], arg[2], arg[3], arg[4], arg[5]);
        }
    }

    public function set(thing:String, val:Dynamic)
    {
        if (daScript == null)
        {
            return;
        }

        daScript.set(thing, val);
    }

    public function stop()
    {
        if (daScript == null)
        {
            return;
        }

        daScript.dispose();
        daScript = null;
    }

    function setHscriptVars()
    {
        hscriptVars.set("Function_Continue", Function_Continue);
        hscriptVars.set("Function_Stop", Function_Stop);

        hscriptVars.set("add", lePlayState.add);
		hscriptVars.set("remove", lePlayState.remove);
		hscriptVars.set("insert", lePlayState.insert);
        hscriptVars.set("lePlayState", lePlayState);

		hscriptVars.set("screenCenter", screenCenter);
		hscriptVars.set("setCamBgAlpha", setCamBgAlpha);
		hscriptVars.set("alignText", alignText);
		hscriptVars.set("openSubState", lePlayState.openSubState);
        hscriptVars.set("getBlend", getBlend);
        hscriptVars.set("trace", theTrace);

        hscriptVars.set('curBpm', Conductor.bpm);
		hscriptVars.set('bpm', PlayState.SONG.bpm);
		hscriptVars.set('scrollSpeed', PlayState.SONG.speed);
		hscriptVars.set('crochet', Conductor.crochet);
		hscriptVars.set('stepCrochet', Conductor.stepCrochet);
		hscriptVars.set('songLength', FlxG.sound.music.length);
		hscriptVars.set('songName', PlayState.SONG.song);
		hscriptVars.set('startedCountdown', false);

		hscriptVars.set('beat', Conductor.crochet / 1000);

		hscriptVars.set('isStoryMode', PlayState.isStoryMode);
		hscriptVars.set("encoreMode", PlayState.encoreMode);
		hscriptVars.set('difficulty', PlayState.storyDifficulty);
		hscriptVars.set('weekRaw', PlayState.storyWeek);
		hscriptVars.set('week', WeekData.weeksList[PlayState.storyWeek]);
		hscriptVars.set('seenCutscene', PlayState.seenCutscene);

		// Camera poo
		hscriptVars.set('cameraX', 0);
		hscriptVars.set('cameraY', 0);
		
		// Screen stuff
		hscriptVars.set('screenWidth', FlxG.width);
		hscriptVars.set('screenHeight', FlxG.height);

		// PlayState cringe ass nae nae bullcrap
		hscriptVars.set('curBeat', 0);
		hscriptVars.set('curStep', 0);

		hscriptVars.set('score', 0);
		hscriptVars.set('misses', 0);
		hscriptVars.set('ghostMisses', 0);
		hscriptVars.set('hits', 0);

		hscriptVars.set('rating', 0);
		hscriptVars.set('ratingName', '');
		
		hscriptVars.set('inGameOver', false);
		hscriptVars.set('mustHitSection', false);
		hscriptVars.set('botPlay', PlayState.cpuControlled);

		for (i in 0...4) {
			hscriptVars.set('defaultPlayerStrumX' + i, 0);
			hscriptVars.set('defaultPlayerStrumY' + i, 0);
			hscriptVars.set('defaultOpponentStrumX' + i, 0);
			hscriptVars.set('defaultOpponentStrumY' + i, 0);
            hscriptVars.set('defaultGFStrumX' + i, 0);
			hscriptVars.set('defaultGFStrumY' + i, 0);
		}

		// Default character positions woooo
		hscriptVars.set('defaultBoyfriendX', lePlayState.BF_X);
		hscriptVars.set('defaultBoyfriendY', lePlayState.BF_Y);
		hscriptVars.set('defaultOpponentX', lePlayState.DAD_X);
		hscriptVars.set('defaultOpponentY', lePlayState.DAD_Y);
		hscriptVars.set('defaultGirlfriendX', lePlayState.GF_X);
		hscriptVars.set('defaultGirlfriendY', lePlayState.GF_Y);

		// Some settings, no jokes
		hscriptVars.set('downscroll', ClientPrefs.downScroll);
		hscriptVars.set('middlescroll', ClientPrefs.middleScroll);
		hscriptVars.set('framerate', ClientPrefs.framerate);
		hscriptVars.set('ghostTapping', ClientPrefs.ghostTapping);
		hscriptVars.set('hideHud', ClientPrefs.hideHud);
		hscriptVars.set('hideTime', ClientPrefs.hideTime);
		hscriptVars.set('cameraZoomOnBeat', ClientPrefs.camZooms);
		hscriptVars.set('flashingLights', ClientPrefs.flashing);
		// compatability ig?
		hscriptVars.set('flashing', ClientPrefs.flashing);
		hscriptVars.set('noteOffset', ClientPrefs.noteOffset);
		hscriptVars.set('lowQuality', ClientPrefs.lowQuality);
		hscriptVars.set('jumpscares', ClientPrefs.jumpscares);
		hscriptVars.set('followchars', lePlayState.followChars);
		hscriptVars.set('shaders', ClientPrefs.shaders);
		hscriptVars.set('healthLoss', PlayState.healthLoss);
		hscriptVars.set("strumsGiveHealth", ClientPrefs.strumHealth);

		for (tag in ClientPrefs.luaSave.keys())
		{
			hscriptVars.set(tag, ClientPrefs.luaSave.get(tag));
		}

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

class PlayStateHscript
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
		exp.set("FlxTypedGroup", PlayStateGroup);
		exp.set("FlxShader", FlxShader);
		exp.set("FlxSound", FlxSound);
		exp.set("FlxBar", FlxBar);
		exp.set("FlxGraphic", FlxGraphic);
		exp.set("FlxText", FlxText);
		exp.set("FlxTypeText", FlxTypeText);
		exp.set("FlxDirectionFlags", PlayStateDirection);
		exp.set("FlxCollision", FlxCollision);
		exp.set("FlxFlicker", FlxFlicker);
        exp.set("FlxTweenType", PlayStateType);
        exp.set("FlxTextBorderStyle", PlayStateBorder);
		
		// Classes
		exp.set("Conductor", Conductor);
		exp.set("Character", Character);
		exp.set("Boyfriend", Boyfriend);
		exp.set("ClientPrefs", ClientPrefs);
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
        exp.set("DiscordClient", DiscordClient);
        exp.set("Paths", Paths);
		exp.set("Song", Song);
		exp.set("HealthIcon", HealthIcon);
		exp.set("PlayState", PlayState);
		exp.set("WeekData", WeekData);
		exp.set("TextFile", TextFile);
		exp.set("FileOpener", FileOpener);

		// note shit.
		exp.set("Note", Note);
		exp.set("NoteSplash", NoteSplash);
		exp.set("StrumNote", StrumNote);

        // shader classes
        exp.set("ShaderFilter", ShaderFilter);
        exp.set("BitmapFilter", BitmapFilter);

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

		// substates :)
		exp.set("ResetScoreSubState", ResetScoreSubState);
		exp.set("ResetEncoreScoreSubState", ResetEncoreScoreSubState);

		// filters
		exp.set("Scanline", Scanline);
		exp.set("Tiltshift", Tiltshift);
		exp.set("TV", TV);
		exp.set("VCR", VCR);

		// lol backend shit.
		exp.set("Internet", InternetAPI);

		// ogmo
		exp.set("FlxOgmo", FlxOgmo3Loader);
		exp.set("FlxTilemap", FlxTilemap);
        
		parser.allowTypes = true;
        parser.resumeErrors = true;
	}

	public static function load(path:String, ?extraParams:StringMap<Dynamic>)
	{
		return new FunkinScript(parser.parseString(File.getContent(path)), extraParams);
	}
}

class FunkinScript
{
    public var interp:Interp;
	public var assetGroup:String;

	public var alive:Bool = true;

	public function new(?contents:Expr, ?extraParams:StringMap<Dynamic>)
	{
		interp = new Interp();
		for (i in PlayStateHscript.exp.keys())
			interp.variables.set(i, PlayStateHscript.exp.get(i));
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

class PlayStateGroup extends FlxTypedGroup<Dynamic>
{
    public function new()
    {
        super();
    }
}

class PlayStateDirection
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

class PlayStateType
{
    public static var oneshot:FlxTweenType = FlxTweenType.ONESHOT;
    public static var persist:FlxTweenType = FlxTweenType.PERSIST;
    public static var backward:FlxTweenType = FlxTweenType.BACKWARD;
    public static var looping:FlxTweenType = FlxTweenType.LOOPING;
    public static var pingpong:FlxTweenType = FlxTweenType.PINGPONG;
}

class PlayStateBorder
{
    public static var outline:FlxTextBorderStyle = FlxTextBorderStyle.OUTLINE;
    public static var outlineFast:FlxTextBorderStyle = FlxTextBorderStyle.OUTLINE_FAST;
    public static var shadow:FlxTextBorderStyle = FlxTextBorderStyle.SHADOW;
    public static var none:FlxTextBorderStyle = FlxTextBorderStyle.NONE;
}