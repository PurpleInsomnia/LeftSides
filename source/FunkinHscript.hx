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
import FunkinLua;
import trophies.TrophyUtil;
import trophies.TrophiesState;
import trophies.TrophiesState.TrophySelectState;

using StringTools;
// ogmo bs

// Im not using lua on here because...you already have lua in playstate.

class FunkinHscript
{
    var scriptName:String;
    public var realName:String = "";

    var hscriptVars:StringMap<Dynamic> = new StringMap<Dynamic>();

    public var lePlayState:PlayState = null;

    public var daScript:HscriptScript = null;

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

        setHscriptVars();

        daScript = HscriptManager.load(scriptName, hscriptVars);

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

	// only I can use this HAHAHAHAHAHA!!!
	public static function unlockGameJoltTrophy(id:Int, icon:String)
	{
		GameJoltAPI.getTrophy(id, icon);
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

	public function addToPlayState(shit:Dynamic, ?front:Bool = true)
	{
		if(front) 
		{
			lePlayState.add(shit);
		} 
		else 
		{
			var position:Int = lePlayState.members.indexOf(lePlayState.gfGroup);
			if(lePlayState.members.indexOf(lePlayState.boyfriendGroup) < position) 
			{
				position = lePlayState.members.indexOf(lePlayState.boyfriendGroup);
			} 
			else if(lePlayState.members.indexOf(lePlayState.dadGroup) < position) 
			{
				position = lePlayState.members.indexOf(lePlayState.dadGroup);
			}
			lePlayState.insert(position, shit);
		}
	}

    function setHscriptVars()
    {
        hscriptVars.set("Function_Continue", Function_Continue);
        hscriptVars.set("Function_Stop", Function_Stop);

        hscriptVars.set("add", addToPlayState);
		hscriptVars.set("remove", lePlayState.remove);
		hscriptVars.set("insert", lePlayState.insert);
        hscriptVars.set("lePlayState", lePlayState);

		hscriptVars.set("screenCenter", screenCenter);
		hscriptVars.set("setCamBgAlpha", setCamBgAlpha);
		hscriptVars.set("alignText", alignText);
		hscriptVars.set("unlockGameJoltTrophy", unlockGameJoltTrophy);
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
		hscriptVars.set('altSection', false);
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