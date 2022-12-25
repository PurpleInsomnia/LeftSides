package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.text.FlxText;
import haxe.ds.StringMap;
import CustomGameOverLua;

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
	var path:String = "";


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
		lua = new CustomGameOverLua(Paths.gameover(path + ".lua"));

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
			FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
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

	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = CustomGameOverLua.Function_Continue;
		#if LUA_ALLOWED
		var ret:Dynamic = lua.call(event, args);
		if(ret != CustomGameOverLua.Function_Continue) 
		{
			returnVal = ret;
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		lua.set(variable, arg);
		#end
	}
}