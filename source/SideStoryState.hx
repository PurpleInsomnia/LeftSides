package;

#if DISCORD
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.addons.text.FlxTypeText;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import sys.FileSystem;
import sys.io.File;
import Type.ValueType;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import flash.media.Sound;
import fliters.*;

#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end

using StringTools;

class SideStoryState extends MusicBeatState
{
	public var curLine:Int = 0;
	public var curChar:String = "ben";
	public var curExp:String = "default";

	#if (haxe >= "4.0.0")
	public var luaTimers:Map<String, FlxTimer> = new Map();
	public var luaTweens:Map<String, FlxTween> = new Map();
	public var luaSprites:Map<String, FlxSprite> = new Map();
	public var luaSounds:Map<String, FlxSound> = new Map();
	#else
	public var luaTimers:Map<String, FlxTimer> = new Map(String, FlxTimer);
	public var luaTweens:Map<String, FlxTween> = new Map(String, FlxTween);
	public var luaSprites:Map<String, FlxSprite> = new Map(String, FlxSprite);
	public var luaSounds:Map<String, FlxSound> = new Map(String, FlxSound);
	#end

	public var bg:FlxSprite;
	public var text:FlxTypeText;

	public var box:FlxSprite;
	public var port:FlxSprite;

	public var luaArray:Array<SideStoryLua> = [];

	public var list:Array<String> = [];
	public var directory:String = "halloween";
	public var modDirect:String = "";

	public var canPress:Bool = false;

	public var events:Array<Array<String>> = [];

	public var timeCardSpr:FlxSprite;

	public static var showedDate:Bool = false;


	// LUA VARIABLES LETS FUCKING GOOOOOOOOOOOOOOOO
	public var nextOnFinish:Bool = false;
	public var luaControlNext:Bool = false;
	public var stopClose:Bool = false;

	public function new(?dialogue:Array<String>, directory:String, modDirect:String)
	{
		super();

		this.directory = directory;
		this.modDirect = modDirect;
		SideStoryDateState.directory = directory;
		SideStoryDateState.modDirect = modDirect;

		if (dialogue == null)
			list = ["ben|default|Lmao no cool swag file found (Bozo, L + ratio)|ohmagwad"];
		else
			list = dialogue;

		SideStoryDateState.dialogue = dialogue;
	}

	override function create()
	{
		PathSS.modDirect = modDirect;
		if (!showedDate && FileSystem.exists((PathSS.data(directory + "/date.txt"))))
		{
			var date:Array<String> = CoolUtil.coolTextFile(PathSS.data(directory + "/date.txt"));
			showedDate = true;
			MusicBeatState.switchState(new SideStoryDateState(date));
			return;
		}

		#if desktop
		DiscordClient.changePresence("Reading The Side Story: " + directory.toUpperCase(), null);
		#end

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(bg);

		events = [];
		var split:Array<String> = list[0].split("|");

		if (split[4] != null || split[4].length > 0)
			loadBg(split[4]);

		port = new FlxSprite();

		box = new FlxSprite();
		box.visible = false;
		reloadBox("default");

		reloadPort("default");
		port.visible = false;
		add(port);

		add(box);

		text = new FlxTypeText(box.x + 20, box.y + 20, Std.int(box.width - 20), "", 42);
		text.setFormat(Paths.font("eras.ttf"), 42, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		text.visible = false;
		text.sounds = [FlxG.sound.load(PathSS.sound('dialogue'), 0.6)];
		add(text);

		if (FileSystem.exists(PathSS.data(directory + "/script.lua")))
		{
			luaArray.push(new SideStoryLua(PathSS.data(directory + "/" + "script.lua")));
		}

		trace("bruh");

		if (FileSystem.exists(PathSS.data(directory + "/events.txt")))
		{
			var array:Array<String> = CoolUtil.coolTextFile(PathSS.data(directory + "/events.txt"));
			for (i in 0...array.length)
			{
				var split:Array<String> = array[i].split("|");
				events.push(split);
			}
		}

		new FlxTimer().start(0.08, function(tmr:FlxTimer)
		{
			canPress = true;
			nextLine();
		});

		callOnLuas("onCreatePost", []);

		super.create();
	}

	public var ended:Bool = false;

	override function update(elapsed:Float)
	{
		setOnLuas("curChar", curChar);
		setOnLuas("curExp", curExp);
		setOnLuas("curLine", curLine);

		callOnLuas("onUpdate", [elapsed]);

		if (canPress && !luaControlNext)
		{
			if (ended)
			{
				if (nextOnFinish)
				{
					ended = false;
					curLine++;
					nextLine();
				}
				if (controls.ACCEPT && !nextOnFinish)
				{
					ended = false;
					curLine++;
					if (curLine >= list.length)
					{
						close();
					}
					else
					{
						nextLine();
					}
				}
			}
			else
			{
				if (controls.ACCEPT)
				{
					ended = false;
					callOnLuas("onSkip", [curLine]);
					FlxG.sound.play(PathSS.sound("skip"));
					text.skip();
				}
			}

			if (controls.BACK)
			{
				FlxG.sound.play(PathSS.sound("exit"));
				close();
			}
		}

		super.update(elapsed);

		callOnLuas("onUpdatePost", [elapsed]);
	}

	public function nextLine()
	{
		if (timeCardSpr != null)
			remove(timeCardSpr);

		setOnLuas("curLine", curLine);
		callOnLuas("onNextLine", [curLine]);

		var split:Array<String> = list[curLine].split("|");

		curChar = split[0];
		curExp = split[1];
		if (curChar != "none")
			reloadPort(curExp);

		if (split[3] != null && split[3].length > 1)
		{
			loadBg(split[3]);
		}
		if (split[4] != null && split[4].length > 1)
		{
			reloadBox(split[4]);
		}
		if (split[5] != null && split[5].length > 1)
		{
			var colourStr:String = "0xFF" + split[5];
			var colour:Int = Std.parseInt(colourStr);
			text.color = colour;
		}
		else
		{
			text.color = 0xFFFFFFFF;
		}

		box.visible = true;
		if (curChar != "none")
			port.visible = true;
		else
			port.visible = false;

		text.visible = true;

		if (events.length > 0)
		{
			for (i in 0...events.length)
			{
				if (Std.parseInt(events[i][0]) == curLine)
				{
					triggerEvent(events[i][1], events[i][2], events[i][3]);
				}
			}
		}

		// helps with lag??
		callOnLuas("onNextLinePost", [curLine]);

		var toAdd:String = "";

		if (curChar != "none")
			toAdd = '"';

		var toUse:String = checkText(split[2]);

		if (toUse.length > 1)
			text.sounds = [FlxG.sound.load(PathSS.sound('dialogue'), 0.6)];
		else
			text.sounds = [FlxG.sound.load(PathSS.sound('dialogue'), 0)];

		text.resetText(toAdd + toUse + toAdd);
		text.start(0.04, true);
		text.completeCallback = function() {
			callOnLuas("onEnded", [curLine]);
			ended = true;
		};
	}

	public function preloadShit()
	{
		var split:Array<String> = list[curLine].split("|");

		curChar = split[0];
		curExp = split[1];
		if (curChar != "none")
			reloadPort(curExp);

		if (split[3] != null && split[3].length > 1)
		{
			loadBg(split[3]);
		}
		if (split[4] != null && split[4].length > 1)
		{
			reloadBox(split[4]);
		}

		if (curChar != "none")
			port.visible = true;
		else
			port.visible = false;
	}

	public function reloadPort(gra:String)
	{
		port.loadGraphic(PathSS.image("ports/" + curChar + "/" + gra));
		if (curChar.startsWith("ben") || curChar.startsWith("tess") || curChar.startsWith("bf") || curChar.startsWith("gf") || curChar == "yBen" || curChar == "yTess")
		{
			port.flipX = false;
		}
		else
		{
			port.flipX = true;
		}	
		resetCharPos();
	}

	public function resetCharPos()
	{
		if (!port.flipX)
		{
			port.x = (box.x + box.width) - (port.width - 20);
		}
		else
		{
			port.x = box.x + 20;
		}
		// phone shit.
		switch(curChar)
		{
			case "phone":
				port.flipX = false;
		}
		port.y = box.y - port.height;
	}

	public function loadBg(gra:String)
	{
		if (gra.toUpperCase() != "BLACK" && gra.toUpperCase() != "NONE" && gra.length > 1)
		{
			if (FileSystem.exists(PathSS.getPath("images/bgs/" + gra + ".png")))
				bg.loadGraphic(PathSS.image("bgs/" + gra));
		}
		else
		{
			bg.makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		}
	}

	public function reloadBox(path:String)
	{
		box.loadGraphic(PathSS.image("boxes/" + path));
		box.screenCenter(X);
		box.y = (FlxG.height - box.height) - 50;
	}

	public function setOnLuas(toSet:String, val:Dynamic)
	{
		for (i in 0...luaArray.length)
		{
			luaArray[i].set(toSet, val);
		}
	}

	public function callOnLuas(call:String, val:Array<Dynamic>)
	{
		for (i in 0...luaArray.length)
		{
			luaArray[i].call(call, val);
		}
	}

	public function close()
	{
		showedDate = false;
		callOnLuas("onEnd", []);
		if (stopClose)
		{
			// No lol.
			return;
		}
		canPress = false;
		showedDate = false;
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.fadeOut(0, 1);
		}
		if (!ClientPrefs.completedSideStories.exists(directory))
		{
			ClientPrefs.completedSideStories.set(directory, true);
		}
		else
		{
			ClientPrefs.completedSideStories.remove(directory);
			ClientPrefs.completedSideStories.set(directory, true);
		}
		ClientPrefs.saveSettings();
		FlxG.camera.fade(0xFF000000, 1, false, function()
		{
			FlxG.sound.music.stop();
			if (directory == "visit")
			{
				ClientPrefs.unlockedRestless = true;
				ClientPrefs.saveSettings();
				MusicBeatState.switchState(new MonsterLairState());
				return;
			}
			if (directory == "happy" && SideStorySelectState.storyList[7][2] != 1)
			{
				MusicBeatState.switchState(new UnlockState([["SideStorySelectState", 'The Side Story "That Day"', 7, 1]]));
				return;
			}
			MusicBeatState.switchState(new SideStorySelectState());
		});
	}

	public function removeLua(lua:SideStoryLua) {
		if(luaArray != null) {
			luaArray.remove(lua);
		}
	}

	public function triggerEvent(type:String, val1:String, val2:String)
	{
		switch(type.toLowerCase())
		{
			case "screen shake":
				FlxG.camera.shake(0.005, Std.parseFloat(val1));

			case "stop music":
				stopMusic();
		}
	}

	public function timeCard(name:String)
	{
		timeCardSpr = new FlxSprite().loadGraphic(PathSS.image("timeCards/" + name));
		add(timeCardSpr);
	}

	public function stopMusic()
	{
		FlxG.sound.music.fadeOut(0.5, 0);
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			FlxG.sound.music.stop();
		});
	}

	// swear filter stuff lol
	var badWords:Array<String> = ['Fuck', 'Shit', 'Bitch', 'Whore', 'Damn', 'Pussy', 'Dick', 'Cum', 'Twat', 'Wanker'];
	var goodWords:Array<String> = ['!#$%', '$!#%', 'Female Dog', '$&%!', 'Darn', 'Cat', 'Jerky Stick', 'Nut', '#$%!', '!#$%!#'];
	function checkText(swagtext:String)
	{
		var editedText:String = swagtext;
		if (swagtext.contains("[USERNAME]") || swagtext.contains("USERNAME"))
		{
			editedText = editedText.replace("USERNAME", CoolUtil.username());
			editedText = editedText.replace("[USERNAME]", CoolUtil.username());
		}
		if (ClientPrefs.swearFilter)
		{
			for (i in 0...badWords.length)
			{
				var badUp:String = badWords[i].toUpperCase();
				var goodUp:String = goodWords[i].toUpperCase();
				var badLow:String = badWords[i].toLowerCase();
				var goodLow:String = goodWords[i].toLowerCase();
				if (swagtext.contains(badWords[i]))
				{
					editedText = editedText.replace(badWords[i], goodWords[i]);
				}
				if (swagtext.contains(badUp))
				{
					editedText = editedText.replace(badUp, goodUp);
				}
				if (swagtext.contains(badLow))
				{
					editedText = editedText.replace(badLow, goodLow);
				}
			}
		}
		return editedText;
	}
}

class SideStoryLua
{
	public static var Function_Stop = 1;
	public static var Function_Continue = 0;

	var lua:State = null;

	var lePlayState:SideStoryState = null;

	public var accessedProps:Map<String, Dynamic> = null;
	public function new(path:String)
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

		#if (haxe >= "4.0.0")
		accessedProps = new Map();
		#else
		accessedProps = new Map<String, Dynamic>();
		#end

		var curState:Dynamic = FlxG.state;
		lePlayState = curState;


		// lua shit
		set('Function_Stop', Function_Stop);
		set('Function_Continue', Function_Continue);


		// other
		set("curLine", 0);
		set("curChar", "");

		// might add get property shit, might not.
		Lua_helper.add_callback(lua, "getProperty", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = null;
				if(lePlayState.luaSprites.exists(killMe[0])) {
					coverMeInPiss = lePlayState.luaSprites.get(killMe[0]);
				} else {
					coverMeInPiss = Reflect.getProperty(lePlayState, killMe[0]);
				}

				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
			}
			return Reflect.getProperty(lePlayState, variable);
		});

		Lua_helper.add_callback(lua, "setProperty", function(variable:String, value:Dynamic) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = null;
				if(lePlayState.luaSprites.exists(killMe[0])) {
					coverMeInPiss = lePlayState.luaSprites.get(killMe[0]);
				} else {
					coverMeInPiss = Reflect.getProperty(lePlayState, killMe[0]);
				}

				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			}
			return Reflect.setProperty(lePlayState, variable, value);
		});

		Lua_helper.add_callback(lua, "playSound", function(sound:String, ?volume:Float = 1, ?loop:Bool = false)
		{
			if (FileSystem.exists(PathSS.getPath("sounds/" + sound + ".ogg")))
			{
				if (lePlayState.luaSounds.exists(sound))
				{
					var leSound:FlxSound = lePlayState.luaSounds.get(sound);
					leSound.stop();
					lePlayState.luaSounds.remove(sound);
				}
				var newSound:FlxSound = FlxG.sound.load(PathSS.sound(sound), volume, loop);
				lePlayState.luaSounds.set(sound, newSound);
				newSound.play();
			}
		});

		Lua_helper.add_callback(lua, "stopSound", function(sound:String)
		{
			if (lePlayState.luaSounds.exists(sound))
			{
				var leSound:FlxSound = lePlayState.luaSounds.get(sound);
				leSound.stop();
				lePlayState.luaSounds.remove(sound);
			}
		});

		Lua_helper.add_callback(lua, "FADsound", function(sound:String, ?dur:Float = 1)
		{
			if (lePlayState.luaSounds.exists(sound))
			{
				var leSound:FlxSound = lePlayState.luaSounds.get(sound);
				leSound.fadeOut(dur, 0, function(twn:FlxTween)
				{
					leSound.stop();
					lePlayState.luaSounds.remove(sound);
				});
			}
		});

		Lua_helper.add_callback(lua, "playMusic", function(music:String, ?volume:Float = 1, ?loop:Bool = true)
		{
			if (FileSystem.exists(PathSS.getPath("music/" + music + ".ogg")))
			{
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.stop();
				}
				FlxG.sound.playMusic(Paths.music(music), volume, loop);
			}
		});

		Lua_helper.add_callback(lua, "nextLine", function()
		{
			lePlayState.nextLine();
		});

		Lua_helper.add_callback(lua, "endState", function()
		{
			lePlayState.close();
		});

		Lua_helper.add_callback(lua, "startTimer", function(tag:String, time:Float, ?loopTimes:Int = 1)
		{
			cancelTimer(tag);

			lePlayState.luaTimers.set(tag, new FlxTimer().start(time, function(tmr:FlxTimer)
			{
				lePlayState.callOnLuas("onTimerCompleted", [tag]);
			}, loopTimes));
		});

		Lua_helper.add_callback(lua, "cancelTimer", function(tag:String)
		{
			cancelTimer(tag);
		});

		Lua_helper.add_callback(lua, "doTweenX", function(tag:String, vars:String, val:Float, time:Float, option:String)
		{
			var penisExam:Dynamic = tweenShit(tag, vars);
			var options:Array<Dynamic> = [];
			var split:Array<String> = option.split(":");
			options.push(getFlxEaseByString(split[0]));
			if (split[1] != null)
				options.push(getFlxTweenTypeByString(split[1]));

			if(penisExam != null) {
				if (options[1] != null)
				{
					lePlayState.luaTweens.set(tag, FlxTween.tween(penisExam, {x: val}, time, {ease: options[0], type: options[1],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.luaTweens.remove(tag);
						}
					}));
				}
				else
				{
					lePlayState.luaTweens.set(tag, FlxTween.tween(penisExam, {x: val}, time, {ease: options[0],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.luaTweens.remove(tag);
						}
					}));
				}
			} else {
				trace('Couldnt find object: ' + vars);
			}
		});

		Lua_helper.add_callback(lua, "doTweenY", function(tag:String, vars:String, val:Float, time:Float, option:String)
		{
			var penisExam:Dynamic = tweenShit(tag, vars);
			var options:Array<Dynamic> = [];
			var split:Array<String> = option.split(":");
			options.push(getFlxEaseByString(split[0]));
			if (split[1] != null)
				options.push(getFlxTweenTypeByString(split[1]));

			if(penisExam != null) {
				if (options[1] != null)
				{
					lePlayState.luaTweens.set(tag, FlxTween.tween(penisExam, {y: val}, time, {ease: options[0], type: options[1],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.luaTweens.remove(tag);
						}
					}));
				}
				else
				{
					lePlayState.luaTweens.set(tag, FlxTween.tween(penisExam, {y: val}, time, {ease: options[0],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.luaTweens.remove(tag);
						}
					}));
				}
			} else {
				trace('Couldnt find object: ' + vars);
			}
		});

		Lua_helper.add_callback(lua, "doTweenAlpha", function(tag:String, vars:String, val:Float, time:Float, option:String)
		{
			var penisExam:Dynamic = tweenShit(tag, vars);
			var options:Array<Dynamic> = [];
			var split:Array<String> = option.split(":");
			options.push(getFlxEaseByString(split[0]));
			if (split[1] != null)
				options.push(getFlxTweenTypeByString(split[1]));

			if(penisExam != null) {
				if (options[1] != null)
				{
					lePlayState.luaTweens.set(tag, FlxTween.tween(penisExam, {alpha: val}, time, {ease: options[0], type: options[1],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.luaTweens.remove(tag);
						}
					}));
				}
				else
				{
					lePlayState.luaTweens.set(tag, FlxTween.tween(penisExam, {alpha: val}, time, {ease: options[0],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.luaTweens.remove(tag);
						}
					}));
				}
			} else {
				trace('Couldnt find object: ' + vars);
			}
		});

		Lua_helper.add_callback(lua, "doTweenAngle", function(tag:String, vars:String, val:Float, time:Float, option:String)
		{
			var penisExam:Dynamic = tweenShit(tag, vars);
			var options:Array<Dynamic> = [];
			var split:Array<String> = option.split(":");
			options.push(getFlxEaseByString(split[0]));
			if (split[1] != null)
				options.push(getFlxTweenTypeByString(split[1]));

			if(penisExam != null) {
				if (options[1] != null)
				{
					lePlayState.luaTweens.set(tag, FlxTween.tween(penisExam, {angle: val}, time, {ease: options[0], type: options[1],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.luaTweens.remove(tag);
						}
					}));
				}
				else
				{
					lePlayState.luaTweens.set(tag, FlxTween.tween(penisExam, {angle: val}, time, {ease: options[0],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.luaTweens.remove(tag);
						}
					}));
				}
			} else {
				trace('Couldnt find object: ' + vars);
			}
		});

		Lua_helper.add_callback(lua, "cancelTween", function(tag:String)
		{
			cancelTween(tag);
		});

		Lua_helper.add_callback(lua, "loadBg", function(pathString:String)
		{
			if (FileSystem.exists(PathSS.image("bgs/" + pathString)))
			{
				lePlayState.loadBg(pathString);
			}
			if (pathString == "none")
			{
				lePlayState.loadBg(pathString);
			}
		});

		Lua_helper.add_callback(lua, "reloadPort", function(path:String, ?flip:Bool = false)
		{
			lePlayState.port.flipX = flip;
			lePlayState.reloadPort(path);
		});

		Lua_helper.add_callback(lua, "restCharPos", function(?flip:Bool = false)
		{
			lePlayState.port.flipX = flip;
			lePlayState.resetCharPos();
		});

		Lua_helper.add_callback(lua, "reloadBox", function(path)
		{
			lePlayState.reloadBox(path);
		});

		// custom movement for portraits
		Lua_helper.add_callback(lua, "portMovement", function(type:String, ?loop:Bool = true)
		{
			switch(type)
			{
				case "spazz":

					// SPAZZ is a LOOP ONLY FUNCTION (because it uses FlxTweenType "PINGPONG") (also flashing lights needs to be on)
					if (!ClientPrefs.flashing)
					{
						if (lePlayState.luaTweens.exists("spazzEventTweenLua"))
						{
							var thing:Dynamic = lePlayState.luaTweens.get("spazzEventTweenLua");
							if (thing != null)
								thing.cancel();
							lePlayState.resetCharPos();
						}
						var portx:Float = lePlayState.port.x;
						var porty:Float = lePlayState.port.y;

						lePlayState.port.x -= 10;
						lePlayState.port.y += 10;

						lePlayState.luaTweens.set("spazzEventTweenLua", FlxTween.tween(lePlayState.port, {x: portx + 10, y: porty - 10}, 0.001, {type: PINGPONG}));
					}
				
				case "moveDown":
					if (lePlayState.luaTweens.exists("moveDownEventTweenLua"))
					{
						var thing:Dynamic = lePlayState.luaTweens.get("moveDownEventTweenLua");
						if (thing != null)
							thing.cancel();
						lePlayState.resetCharPos();
					}

					if (!loop)
						lePlayState.luaTweens.set("moveDownEventTweenLua", FlxTween.tween(lePlayState.port, {y: lePlayState.port.y + 20}, 0.67, {ease: FlxEase.sineOut}));
					else
						lePlayState.luaTweens.set("moveDownEventTweenLua", FlxTween.tween(lePlayState.port, {y: lePlayState.port.y + 20}, 0.67, {ease: FlxEase.sineOut, type: LOOPING}));

				case "scoot":
					if (lePlayState.luaTweens.exists("scootEventTweenLua"))
					{
						var thing:Dynamic = lePlayState.luaTweens.get("scootEventTweenLua");
						if (thing != null)
							thing.cancel();
						lePlayState.resetCharPos();
					}

					// No loops on this one, it would just look weird idk lmao

					var portx:Float = lePlayState.port.x;

					if (!lePlayState.port.flipX)
					{
						lePlayState.luaTweens.set("scootEventTweenLua", FlxTween.tween(lePlayState.port, {x: portx - 25}, 0.75, {type: PERSIST, ease: FlxEase.sineInOut}));
					}
					else
					{
						lePlayState.luaTweens.set("scootEventTweenLua", FlxTween.tween(lePlayState.port, {x: portx + 25}, 0.75, {type: PERSIST, ease: FlxEase.sineInOut}));
					}
			}
		});

		Lua_helper.add_callback(lua, "cancelPortMovement", function(type:String)
		{
			var tagToGet:String = type + "EventTweenLua";

			if (tagToGet.length > 1)
			{
				var thing:FlxTween = lePlayState.luaTweens.get(tagToGet);
				thing.cancel();
				thing.destroy();
				lePlayState.luaTweens.remove(tagToGet);
			}
		});

		// Sprite shit
		Lua_helper.add_callback(lua, "makeLuaSprite", function(tag:String, path:String, x:Float, y:Float)
		{
			if (lePlayState.luaSprites.exists(tag))
			{
				var thing:FlxSprite = lePlayState.luaSprites.get(tag);
				lePlayState.remove(thing);
				lePlayState.luaSprites.remove(tag);
			}

			var spr:FlxSprite = new FlxSprite(x, y);
			spr.loadGraphic(PathSS.image(path));
			lePlayState.luaSprites.set(tag, spr);
		});

		Lua_helper.add_callback(lua, "makeAnimatedLuaSprite", function(tag:String, path:String, x:Float, y:Float)
		{
			if (lePlayState.luaSprites.exists(tag))
			{
				var thing:FlxSprite = lePlayState.luaSprites.get(tag);
				lePlayState.remove(thing);
				lePlayState.luaSprites.remove(tag);
			}

			var spr:FlxSprite = new FlxSprite(x, y);
			spr.frames = PathSS.frames(path);
			lePlayState.luaSprites.set(tag, spr);
		});

		Lua_helper.add_callback(lua, "addAnimationByPrefix", function(tag:String, name:String, nox:String, fps:Int, loop:Bool)
		{
			if (lePlayState.luaSprites.exists(tag))
			{
				var spr:FlxSprite = lePlayState.luaSprites.get(tag);

				spr.animation.addByPrefix(name, nox, fps, loop);
				if (spr.animation.curAnim == null)
				{
					spr.animation.play(name, true);
				}
			}
		});

		Lua_helper.add_callback(lua, "objectPlayAnimation", function(tag:String, anim:String, ?force:Bool = true)
		{
			if (lePlayState.luaSprites.exists(tag))
			{
				lePlayState.luaSprites.get(tag).animation.play(anim, force);
			}
		});

		Lua_helper.add_callback(lua, "addLuaSprite", function(tag:String)
		{
			var spr:FlxSprite = lePlayState.luaSprites.get(tag);
			lePlayState.add(spr);
		});

		Lua_helper.add_callback(lua, "startMusic", function(fileName:String, ?vol:Float = 1)
		{
			trace("vine boom?");
			if (FlxG.sound.music.playing)
			{
				FlxG.sound.music.stop();
			}
			FlxG.sound.playMusic(PathSS.music(fileName), 0, true);
			FlxG.sound.music.fadeIn(0.5, 0, vol);
		});

		Lua_helper.add_callback(lua, "timeCard", function(name:String)
		{
			lePlayState.timeCard(name);
		});

		Lua_helper.add_callback(lua, "trace", function(bruh:Dynamic)
		{
			trace(bruh);
		});

		Lua_helper.add_callback(lua, "preloadShit", function(huh:String)
		{
			trace(huh);
			lePlayState.preloadShit();
		});

		Lua_helper.add_callback(lua, "loadSong", function(song:String, ?skipHL:Bool = false, ?isVoid:Bool = false, ?week:Int = 999)
		{
			var name:String = Paths.formatToSongPath(song);
			var poop = Highscore.formatSong(name, 1);
			PlayState.SONG = Song.loadFromJson(poop, name);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;
			PlayState.storyWeek = week;
			PlayState.isVoid = isVoid;
			if (skipHL)
			{
				MusicBeatState.switchState(new LoadingScreenState());
			}
			else
			{
				MusicBeatState.switchState(new HealthLossState());
			}
		});

		Lua_helper.add_callback(lua, "startSong", function(skipHL:Bool)
		{
			if (!skipHL)
			{
				MusicBeatState.switchState(new HealthLossState());
			}
			else
			{
				MusicBeatState.switchState(new LoadingScreenState());
			}
		});

		Lua_helper.add_callback(lua, "loadStoryMode", function(songs:String, week:Int, ?skipHL:Bool = false)
		{
			var split:Array<String> = songs.split("|");
			for (i in 0...split.length)
			{
				PlayState.storyPlaylist.push(split[i]);
			}
			var songLowercase:String = ""; 
            songLowercase = Paths.formatToSongPath(split[0]);
			var poop:String = 'normal';
			#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
			}

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = true;
			PlayState.storyDifficulty = 1;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			PlayState.campaignHits = 0;
			PlayState.campaignGMiss = 0;
			PlayState.campaignRatings = [];
            // Lullaby demo :)

            // Very imposible week to get to :thumbsup:
			PlayState.storyWeek = week;
			PlayState.isVoid = false;

			if (skipHL)
			{
				MusicBeatState.switchState(new LoadingScreenState());
			}
			else
			{
				MusicBeatState.switchState(new HealthLossState());
			}
		});

		call("onCreate", []);
	}

	function tweenShit(tag:String, vars:String) {
		cancelTween(tag);
		var variables:Array<String> = vars.replace(' ', '').split('.');
		var sexyProp:Dynamic = Reflect.getProperty(lePlayState, variables[0]);
		if(sexyProp == null && lePlayState.luaSprites.exists(variables[0])) {
			sexyProp = lePlayState.luaSprites.get(variables[0]);
		}

		for (i in 1...variables.length) {
			sexyProp = Reflect.getProperty(sexyProp, variables[i]);
		}
		return sexyProp;
	}

	public function cancelTween(tag:String) {
		if(lePlayState.luaTweens.exists(tag)) {
			var theTimer:FlxTween = lePlayState.luaTweens.get(tag);
			theTimer.cancel();
			theTimer.destroy();
			lePlayState.luaTweens.remove(tag);
		}
	}

	public function cancelTimer(tag:String) {
		if(lePlayState.luaTimers.exists(tag)) {
			var theTimer:FlxTimer = lePlayState.luaTimers.get(tag);
			theTimer.cancel();
			theTimer.destroy();
			lePlayState.luaTimers.remove(tag);
		}
	}

	public function call(event:String, args:Array<Dynamic>):Dynamic {
		#if LUA_ALLOWED
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
		#end
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

	public function stop() {
		if(lua == null) {
			return;
		}

		if(accessedProps != null) {
			accessedProps.clear();
		}
		lePlayState.removeLua(this);
		Lua.close(lua);
		lua = null;
	}

	function getFlxEaseByString(?ease:String = '') {
		switch(ease.toLowerCase().trim()) {
			case 'backin': return FlxEase.backIn;
			case 'backinout': return FlxEase.backInOut;
			case 'backout': return FlxEase.backOut;
			case 'bouncein': return FlxEase.bounceIn;
			case 'bounceinout': return FlxEase.bounceInOut;
			case 'bounceout': return FlxEase.bounceOut;
			case 'circin': return FlxEase.circIn;
			case 'circinout': return FlxEase.circInOut;
			case 'circout': return FlxEase.circOut;
			case 'cubein': return FlxEase.cubeIn;
			case 'cubeinout': return FlxEase.cubeInOut;
			case 'cubeout': return FlxEase.cubeOut;
			case 'elasticin': return FlxEase.elasticIn;
			case 'elasticinout': return FlxEase.elasticInOut;
			case 'elasticout': return FlxEase.elasticOut;
			case 'expoin': return FlxEase.expoIn;
			case 'expoinout': return FlxEase.expoInOut;
			case 'expoout': return FlxEase.expoOut;
			case 'quadin': return FlxEase.quadIn;
			case 'quadinout': return FlxEase.quadInOut;
			case 'quadout': return FlxEase.quadOut;
			case 'quartin': return FlxEase.quartIn;
			case 'quartinout': return FlxEase.quartInOut;
			case 'quartout': return FlxEase.quartOut;
			case 'quintin': return FlxEase.quintIn;
			case 'quintinout': return FlxEase.quintInOut;
			case 'quintout': return FlxEase.quintOut;
			case 'sinein': return FlxEase.sineIn;
			case 'sineinout': return FlxEase.sineInOut;
			case 'sineout': return FlxEase.sineOut;
			case 'smoothstepin': return FlxEase.smoothStepIn;
			case 'smoothstepinout': return FlxEase.smoothStepInOut;
			case 'smoothstepout': return FlxEase.smoothStepInOut;
			case 'smootherstepin': return FlxEase.smootherStepIn;
			case 'smootherstepinout': return FlxEase.smootherStepInOut;
			case 'smootherstepout': return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}

	function getFlxTweenTypeByString(type:String):FlxTweenType
	{
		switch(type.toLowerCase().trim())
		{
			case "persist": return FlxTweenType.PERSIST;
			case "looping": return FlxTweenType.LOOPING;
			case "pingpong": return FlxTweenType.PINGPONG;
			case "backward": return FlxTweenType.BACKWARD;
		}
		return FlxTweenType.ONESHOT;
	}
}

class PathSS
{
	public static var modDirect:String = "";

	public static function getPath(key:String)
	{
		var toReturn:String = "assets/side-stories/" + key;
		if (!FileSystem.exists(toReturn) && modDirect != "")
		{
			toReturn = modDirect + "/side-stories/" + key;
		}
		return toReturn;
	}
	
	public static function image(key:String):Dynamic
	{
		if (FileSystem.exists("mods/" + modDirect + "/side-stories/images/" + key + ".png"))
		{
			var imageToReturn:FlxGraphic = addCustomGraphic("side-stories/images/" + key + ".png");
			if(imageToReturn != null) return imageToReturn;
		}
		return "assets/side-stories/images/" + key + ".png";
	}

	public static function frames(key:String)
	{
		if (FileSystem.exists("mods/" + modDirect + "/side-stories/images/" + key + ".png"))
		{
			var imageLoaded:FlxGraphic = addCustomGraphic("side-stories/images/" + key + ".png");

			return FlxAtlasFrames.fromSparrow(imageLoaded, File.getContent(Paths.getModFile("side-stories/images/" + key + ".xml")));
		}
		return FlxAtlasFrames.fromSparrow("assets/side-stories/images/" + key + ".png", "assets/side-stories/images/" + key + ".xml");
	}

	public static function sound(key:String):Dynamic
	{
		if (FileSystem.exists("mods/" + modDirect + "/side-stories/sounds/" + key + ".ogg"))
		{
			var file:String = Paths.getModFile("side-stories/sounds/" + key + ".ogg");
			if(!Paths.customSoundsLoaded.exists(file)) {
				Paths.customSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return Paths.customSoundsLoaded.get(file);
		}
		return "assets/side-stories/sounds/" + key + ".ogg";
	}

	public static function music(key:String):Dynamic
	{
		if (FileSystem.exists("mods/" + modDirect + "/side-stories/music/" + key + ".ogg"))
		{
			var file:String = Paths.getModFile("side-stories/music/" + key + ".ogg");
			if(!Paths.customSoundsLoaded.exists(file)) {
				Paths.customSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return Paths.customSoundsLoaded.get(file);
		}
		return "assets/side-stories/music/" + key + ".ogg";
	}

	public static function data(key:String)
	{
		if (FileSystem.exists("mods/" + modDirect + "/side-stories/data/" + key))
		{
			return Paths.getModFile("side-stories/data/" + key);
		}
		return "assets/side-stories/data/" + key;
	}

	public static function addCustomGraphic(key:String):FlxGraphic {
		var newBitmap:BitmapData = BitmapData.fromFile("assets/" + key);
		if(FileSystem.exists(Paths.getModFile(key)))
		{
			if(!Paths.customImagesLoaded.exists(key))
			{
				newBitmap = BitmapData.fromFile(Paths.getModFile(key));
			}
		}
		var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
		newGraphic.persist = true;
		FlxG.bitmap.addGraphic(newGraphic);
		Paths.customImagesLoaded.set(key, true);
		return FlxG.bitmap.get(key);
	}
}

class SideStoryDateState extends MusicBeatState
{
	var toType:String = "";
	var daColor:Int = 0xFFFFFFFF;
	public static var dialogue:Array<String> = [];
	public static var directory:String = "halloween";
	public static var modDirect:String = "";

	public function new(date:Array<String>)
	{
		super();
		toType = date[0];
		if (date[1] != null)
		{
			daColor = Std.parseInt("0xFF" + date[1]);
		}
	}

	var text:FlxText;
	override function create()
	{
		text = new FlxText(0, 0, 1200, toType, 42);
		text.alignment = CENTER;
		text.screenCenter();
		text.font = Paths.font("eras.ttf");
		text.alpha = 0;
		add(text);

		FlxTween.tween(text, {alpha: 1}, 1, {onComplete: function(twn:FlxTween)
		{
			FlxTween.tween(text, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
			{
				MusicBeatState.switchState(new SideStoryState(dialogue, directory, modDirect));
			}, startDelay: 1});
		}});
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}