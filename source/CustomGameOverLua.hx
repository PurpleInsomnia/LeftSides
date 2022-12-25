#if LUA_ALLOWED
import llua.Lua;
import llua.LuaL;
import llua.State;
import llua.Convert;
#end

import flixel.FlxG;
import flixel.addons.effects.FlxTrail;
import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.FlxTweenType;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.ui.FlxButton;
import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxSprite;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.utils.Assets;
import flixel.math.FlxMath;
import flixel.util.FlxSave;
import flixel.addons.transition.FlxTransitionableState;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import Type.ValueType;
import Controls;
import haxe.Json;

using StringTools;

class CustomGameOverLua {
	public static var Function_Stop = 1;
	public static var Function_Continue = 0;

	#if LUA_ALLOWED
	public var lua:State = null;
	#end

	var lePlayState:CustomGameOverState = null;
	var scriptName:String = '';
	public var realName:String = "";
	var gonnaClose:Bool = false;

	private var luaArray:Array<CustomGameOverLua> = [];

	public var accessedProps:Map<String, Dynamic> = null;
	public function new(script:String) {
		#if LUA_ALLOWED
		lua = LuaL.newstate();
		LuaL.openlibs(lua);
		Lua.init_callbacks(lua);

		//trace('Lua version: ' + Lua.version());
		//trace("LuaJIT version: " + Lua.versionJIT());

		var result:Dynamic = LuaL.dofile(lua, script);
		var resultStr:String = Lua.tostring(lua, result);
		if(resultStr != null && result != 0) {
			lime.app.Application.current.window.alert(resultStr, 'Error on .LUA script!');
			trace('Error on .LUA script! ' + resultStr);
			lua = null;
			return;
		}
		scriptName = script;

		var scriptNameSplit:Array<String> = script.split("/");
		realName = scriptNameSplit[script.length - 1];

		trace('Lua file loaded succesfully:' + script);

		#if (haxe >= "4.0.0")
		accessedProps = new Map();
		#else
		accessedProps = new Map<String, Dynamic>();
		#end

		var curState:Dynamic = FlxG.state;
		lePlayState = curState;

		// Lua shit
		set('Function_Stop', Function_Stop);
		set('Function_Continue', Function_Continue);
		
		// Screen stuff
		set('screenWidth', FlxG.width);
		set('screenHeight', FlxG.height);

		// Some settings, no jokes
		set('downscroll', ClientPrefs.downScroll);
		set('middlescroll', ClientPrefs.middleScroll);
		set('framerate', ClientPrefs.framerate);
		set('ghostTapping', ClientPrefs.ghostTapping);
		set('hideHud', ClientPrefs.hideHud);
		set('hideTime', ClientPrefs.hideTime);
		set('cameraZoomOnBeat', ClientPrefs.camZooms);
		set('flashingLights', ClientPrefs.flashing);
		// compatability ig?
		set('flashing', ClientPrefs.flashing);
		set('noteOffset', ClientPrefs.noteOffset);
		set('lowQuality', ClientPrefs.lowQuality);
		set('jumpscares', ClientPrefs.jumpscares);
		set('shaders', ClientPrefs.shaders);

		//stuff 4 noobz like you B)
		Lua_helper.add_callback(lua, "getProperty", function(variable:String) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = null;
				if(lePlayState.gomodchartSprites.exists(killMe[0])) {
					coverMeInPiss = lePlayState.gomodchartSprites.get(killMe[0]);
				}
				if(lePlayState.gomodchartTexts.exists(killMe[0]) && coverMeInPiss == null) 
				{
					coverMeInPiss = lePlayState.gomodchartTexts.get(killMe[0]);
				}
				if(lePlayState.gomodchartButtons.exists(killMe[0]) && coverMeInPiss == null) 
				{
					coverMeInPiss = lePlayState.gomodchartButtons.get(killMe[0]);
				}
				if (coverMeInPiss == null) 
				{
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
				if(lePlayState.gomodchartSprites.exists(killMe[0])) {
					coverMeInPiss = lePlayState.gomodchartSprites.get(killMe[0]);
				}
				if(lePlayState.gomodchartTexts.exists(killMe[0]) && coverMeInPiss == null) 
				{
					coverMeInPiss = lePlayState.gomodchartTexts.get(killMe[0]);
				}
				if(lePlayState.gomodchartButtons.exists(killMe[0]) && coverMeInPiss == null) 
				{
					coverMeInPiss = lePlayState.gomodchartButtons.get(killMe[0]);
				}
				if (coverMeInPiss == null) 
				{
					coverMeInPiss = Reflect.getProperty(lePlayState, killMe[0]);
				}

				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			}
			return Reflect.setProperty(lePlayState, variable, value);
		});
		Lua_helper.add_callback(lua, "getPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic) {
			if(Std.isOfType(Reflect.getProperty(lePlayState, obj), FlxTypedGroup)) {
				return Reflect.getProperty(Reflect.getProperty(lePlayState, obj).members[index], variable);
			}

			var leArray:Dynamic = Reflect.getProperty(lePlayState, obj)[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					return leArray[variable];
				}
				return Reflect.getProperty(leArray, variable);
			}
			return null;
		});
		Lua_helper.add_callback(lua, "setPropertyFromGroup", function(obj:String, index:Int, variable:Dynamic, value:Dynamic) {
			if(Std.isOfType(Reflect.getProperty(lePlayState, obj), FlxTypedGroup)) {
				return Reflect.setProperty(Reflect.getProperty(lePlayState, obj).members[index], variable, value);
			}

			var leArray:Dynamic = Reflect.getProperty(lePlayState, obj)[index];
			if(leArray != null) {
				if(Type.typeof(variable) == ValueType.TInt) {
					return leArray[variable] = value;
				}
				return Reflect.setProperty(leArray, variable, value);
			}
		});
		Lua_helper.add_callback(lua, "removeFromGroup", function(obj:String, index:Int, dontDestroy:Bool = false) {
			if(Std.isOfType(Reflect.getProperty(lePlayState, obj), FlxTypedGroup)) {
				var sex = Reflect.getProperty(lePlayState, obj).members[index];
				if(!dontDestroy)
					sex.kill();
				Reflect.getProperty(lePlayState, obj).remove(sex, true);
				if(!dontDestroy)
					sex.destroy();
				return;
			}
			Reflect.getProperty(lePlayState, obj).remove(Reflect.getProperty(lePlayState, obj)[index]);
		});

		Lua_helper.add_callback(lua, "getPropertyFromClass", function(classVar:String, variable:String) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = Reflect.getProperty(Type.resolveClass(classVar), killMe[0]);
				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
			}
			return Reflect.getProperty(Type.resolveClass(classVar), variable);
		});
		Lua_helper.add_callback(lua, "setPropertyFromClass", function(classVar:String, variable:String, value:Dynamic) {
			var killMe:Array<String> = variable.split('.');
			if(killMe.length > 1) {
				var coverMeInPiss:Dynamic = Reflect.getProperty(Type.resolveClass(classVar), killMe[0]);
				for (i in 1...killMe.length-1) {
					coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
				}
				return Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
			}
			return Reflect.setProperty(Type.resolveClass(classVar), variable, value);
		});

		//shitass stuff for epic coders like me B)  *image of obama giving himself a medal*
		Lua_helper.add_callback(lua, "getObjectOrder", function(obj:String) {
			if(lePlayState.gomodchartSprites.exists(obj) && lePlayState.gomodchartSprites.get(obj).wasAdded) {
				return lePlayState.members.indexOf(lePlayState.gomodchartSprites.get(obj));
			}

			var leObj:FlxBasic = Reflect.getProperty(lePlayState, obj);
			if(leObj != null) {
				return lePlayState.members.indexOf(leObj);
			}
			return -1;
		});
		Lua_helper.add_callback(lua, "setObjectOrder", function(obj:String, position:Int) {
			if(lePlayState.gomodchartSprites.exists(obj)) {
				var spr:GameOverModchartSprite = lePlayState.gomodchartSprites.get(obj);
				if(spr.wasAdded) {
					lePlayState.remove(spr, true);
					lePlayState.insert(position, spr);
					return;
				}
			}

			var leObj:FlxBasic = Reflect.getProperty(lePlayState, obj);
			if(leObj != null) {
				lePlayState.remove(leObj, true);
				lePlayState.insert(position, leObj);
				return;
			}
		});

		// gay ass tweens
		Lua_helper.add_callback(lua, "doTweenX", function(tag:String, vars:String, value:Dynamic, duration:Float, option:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			var options:Array<Dynamic> = [];
			var split:Array<String> = option.split(":");
			options.push(getFlxEaseByString(split[0]));
			if (split[1] != null)
				options.push(getFlxTweenTypeByString(split[1]));

			if(penisExam != null) {
				if (options[1] != null)
				{
					lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {x: value}, duration, {ease: options[0], type: options[1],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.gomodchartTweens.remove(tag);
						}
					}));
				}
				else
				{
					lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {x: value}, duration, {ease: options[0],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.gomodchartTweens.remove(tag);
						}
					}));
				}
			}
		});
		Lua_helper.add_callback(lua, "doTweenY", function(tag:String, vars:String, value:Dynamic, duration:Float, option:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			var options:Array<Dynamic> = [];
			var split:Array<String> = option.split(":");
			options.push(getFlxEaseByString(split[0]));
			if (split[1] != null)
				options.push(getFlxTweenTypeByString(split[1]));

			if(penisExam != null) {
				if (options[1] != null)
				{
					lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {y: value}, duration, {ease: options[0], type: options[1],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.gomodchartTweens.remove(tag);
						}
					}));
				}
				else
				{
					lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {y: value}, duration, {ease: options[0],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.gomodchartTweens.remove(tag);
						}
					}));
				}
			}
		});
		Lua_helper.add_callback(lua, "doTweenAngle", function(tag:String, vars:String, value:Dynamic, duration:Float, option:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			var options:Array<Dynamic> = [];
			var split:Array<String> = option.split(":");
			options.push(getFlxEaseByString(split[0]));
			if (split[1] != null)
				options.push(getFlxTweenTypeByString(split[1]));

			if(penisExam != null) {
				if (options[1] != null)
				{
					lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {angle: value}, duration, {ease: options[0], type: options[1],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.gomodchartTweens.remove(tag);
						}
					}));
				}
				else
				{
					lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {angle: value}, duration, {ease: options[0],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.gomodchartTweens.remove(tag);
						}
					}));
				}
			}
		});
		Lua_helper.add_callback(lua, "doTweenAlpha", function(tag:String, vars:String, value:Dynamic, duration:Float, option:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			var options:Array<Dynamic> = [];
			var split:Array<String> = option.split(":");
			options.push(getFlxEaseByString(split[0]));
			if (split[1] != null)
				options.push(getFlxTweenTypeByString(split[1]));

			if(penisExam != null) {
				if (options[1] != null)
				{
					lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {alpha: value}, duration, {ease: options[0], type: options[1],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.gomodchartTweens.remove(tag);
						}
					}));
				}
				else
				{
					lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {alpha: value}, duration, {ease: options[0],
						onComplete: function(twn:FlxTween) {
							lePlayState.callOnLuas('onTweenCompleted', [tag]);
							lePlayState.gomodchartTweens.remove(tag);
						}
					}));
				}
			}
		});

		Lua_helper.add_callback(lua, "doTweenScale", function(tag:String, vars:String, value:Dynamic, duration:Float, option:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			var options:Array<Dynamic> = [];
			var split:Array<String> = option.split(":");
			options.push(getFlxEaseByString(split[0]));
			options.push(split[1].toLowerCase());
			if (split[2] != null)
				options.push(getFlxTweenTypeByString(split[2]));

			if(penisExam != null) {
				if (options[2] != null)
				{
					if (options[1] == "x")
					{
						lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {"scale.x": value}, duration, {ease: options[0], type: options[1],
							onComplete: function(twn:FlxTween) {
								lePlayState.callOnLuas('onTweenCompleted', [tag]);
								lePlayState.gomodchartTweens.remove(tag);
							}
						}));
					}
					if (options[1] == "y")
					{
						lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {"scale.y": value}, duration, {ease: options[0], type: options[1],
							onComplete: function(twn:FlxTween) {
								lePlayState.callOnLuas('onTweenCompleted', [tag]);
								lePlayState.gomodchartTweens.remove(tag);
							}
						}));
					}
					if (options[1] == "both")
					{
						lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {"scale.y": value, "scale.x": value}, duration, {ease: options[0], type: options[1],
							onComplete: function(twn:FlxTween) {
								lePlayState.callOnLuas('onTweenCompleted', [tag]);
								lePlayState.gomodchartTweens.remove(tag);
							}
						}));
					}
				}
				else
				{
					if (options[1] == "x")
					{
						lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {"scale.x": value}, duration, {ease: options[0],
							onComplete: function(twn:FlxTween) {
								lePlayState.callOnLuas('onTweenCompleted', [tag]);
								lePlayState.gomodchartTweens.remove(tag);
							}
						}));
					}
					if (options[1] == "y")
					{
						lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {"scale.y": value}, duration, {ease: options[0],
							onComplete: function(twn:FlxTween) {
								lePlayState.callOnLuas('onTweenCompleted', [tag]);
								lePlayState.gomodchartTweens.remove(tag);
							}
						}));
					}
					if (options[1] == "both")
					{
						lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {"scale.y": value, "scale.x": value}, duration, {ease: options[0],
							onComplete: function(twn:FlxTween) {
								lePlayState.callOnLuas('onTweenCompleted', [tag]);
								lePlayState.gomodchartTweens.remove(tag);
							}
						}));
					}
				}
			}
		});

		Lua_helper.add_callback(lua, "doTweenZoom", function(tag:String, vars:String, value:Dynamic, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				lePlayState.gomodchartTweens.set(tag, FlxTween.tween(penisExam, {zoom: value}, duration, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						lePlayState.callOnLuas('onTweenCompleted', [tag]);
						lePlayState.gomodchartTweens.remove(tag);
					}
				}));
			}
		});
		Lua_helper.add_callback(lua, "doTweenColor", function(tag:String, vars:String, targetColor:String, duration:Float, ease:String) {
			var penisExam:Dynamic = tweenShit(tag, vars);
			if(penisExam != null) {
				var color:Int = Std.parseInt(targetColor);
				if(!targetColor.startsWith('0x')) color = Std.parseInt('0xff' + targetColor);

				lePlayState.gomodchartTweens.set(tag, FlxTween.color(penisExam, duration, penisExam.color, color, {ease: getFlxEaseByString(ease),
					onComplete: function(twn:FlxTween) {
						lePlayState.gomodchartTweens.remove(tag);
						lePlayState.callOnLuas('onTweenCompleted', [tag]);
					}
				}));
			}
		});

		Lua_helper.add_callback(lua, "cancelTween", function(tag:String) {
			cancelTween(tag);
		});

		Lua_helper.add_callback(lua, "runTimer", function(tag:String, time:Float = 1, loops:Int = 1) {
			cancelTimer(tag);
			lePlayState.gomodchartTimers.set(tag, new FlxTimer().start(time, function(tmr:FlxTimer) {
				if(tmr.finished) {
					lePlayState.gomodchartTimers.remove(tag);
				}
				lePlayState.callOnLuas('onTimerCompleted', [tag, tmr.loops, tmr.loopsLeft]);
				//trace('Timer Completed: ' + tag);
			}, loops));
		});
		Lua_helper.add_callback(lua, "cancelTimer", function(tag:String) {
			cancelTimer(tag);
		});
		
		Lua_helper.add_callback(lua, "getColorFromHex", function(color:String) {
			if(!color.startsWith('0x')) color = '0xff' + color;
			return Std.parseInt(color);
		});
		Lua_helper.add_callback(lua, "keyJustPressed", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = lePlayState.getControl('NOTE_LEFT_P');
				case 'down': key = lePlayState.getControl('NOTE_DOWN_P');
				case 'up': key = lePlayState.getControl('NOTE_UP_P');
				case 'right': key = lePlayState.getControl('NOTE_RIGHT_P');
				case 'accept': key = lePlayState.getControl('ACCEPT');
				case 'back': key = lePlayState.getControl('BACK');
				case 'pause': key = lePlayState.getControl('PAUSE');
				case 'reset': key = lePlayState.getControl('RESET');
				case 'attack': key = lePlayState.getControl('EMOTE');
			}
			return key;
		});
		Lua_helper.add_callback(lua, "keyPressed", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = lePlayState.getControl('NOTE_LEFT');
				case 'down': key = lePlayState.getControl('NOTE_DOWN');
				case 'up': key = lePlayState.getControl('NOTE_UP');
				case 'right': key = lePlayState.getControl('NOTE_RIGHT');
			}
			return key;
		});
		Lua_helper.add_callback(lua, "keyReleased", function(name:String) {
			var key:Bool = false;
			switch(name) {
				case 'left': key = lePlayState.getControl('NOTE_LEFT_R');
				case 'down': key = lePlayState.getControl('NOTE_DOWN_R');
				case 'up': key = lePlayState.getControl('NOTE_UP_R');
				case 'right': key = lePlayState.getControl('NOTE_RIGHT_R');
			}
			return key;
		});
		Lua_helper.add_callback(lua, "mouseClicked", function(button:String) {
			var boobs = FlxG.mouse.justPressed;
			switch(button){
				case 'middle':
					boobs = FlxG.mouse.justPressedMiddle;
				case 'right':
					boobs = FlxG.mouse.justPressedRight;
			}
			
			
			return boobs;
		});
		Lua_helper.add_callback(lua, "mousePressed", function(button:String) {
			var boobs = FlxG.mouse.pressed;
			switch(button){
				case 'middle':
					boobs = FlxG.mouse.pressedMiddle;
				case 'right':
					boobs = FlxG.mouse.pressedRight;
			}
			return boobs;
		});
		Lua_helper.add_callback(lua, "mouseReleased", function(button:String) {
			var boobs = FlxG.mouse.justReleased;
			switch(button){
				case 'middle':
					boobs = FlxG.mouse.justReleasedMiddle;
				case 'right':
					boobs = FlxG.mouse.justReleasedRight;
			}
			return boobs;
		});

		Lua_helper.add_callback(lua, "precacheImage", function(name:String) {
			Paths.addCustomGraphic(name);
		});
		Lua_helper.add_callback(lua, "precacheSound", function(name:String) {
			CoolUtil.precacheSound(name);
		});

		Lua_helper.add_callback(lua, "makeLuaSprite", function(tag:String, image:String, x:Float, y:Float) {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:GameOverModchartSprite = new GameOverModchartSprite(x, y);
			if(image != null && image.length > 0) {
				leSprite.loadGraphic(Paths.image(image));
			}
			leSprite.antialiasing = ClientPrefs.globalAntialiasing;
			lePlayState.gomodchartSprites.set(tag, leSprite);
			leSprite.active = true;
		});
		Lua_helper.add_callback(lua, "makeAnimatedLuaSprite", function(tag:String, image:String, x:Float, y:Float) {
			tag = tag.replace('.', '');
			resetSpriteTag(tag);
			var leSprite:GameOverModchartSprite = new GameOverModchartSprite(x, y);
			leSprite.frames = Paths.getSparrowAtlas(image);
			leSprite.antialiasing = ClientPrefs.globalAntialiasing;
			lePlayState.gomodchartSprites.set(tag, leSprite);
		});

		Lua_helper.add_callback(lua, "makeGraphic", function(obj:String, width:Int, height:Int, color:String) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);

			if(lePlayState.gomodchartSprites.exists(obj)) {
				lePlayState.gomodchartSprites.get(obj).makeGraphic(width, height, colorNum);
				return;
			}

			var object:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(object != null) {
				object.makeGraphic(width, height, colorNum);
			}
		});
		Lua_helper.add_callback(lua, "addAnimationByPrefix", function(obj:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			if(lePlayState.gomodchartSprites.exists(obj)) {
				var cock:GameOverModchartSprite = lePlayState.gomodchartSprites.get(obj);
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
				return;
			}
			
			var cock:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(cock != null) {
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
			}
		});
		Lua_helper.add_callback(lua, "addAnimationByIndices", function(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			var strIndices:Array<String> = indices.trim().split(',');
			var die:Array<Int> = [];
			for (i in 0...strIndices.length) {
				die.push(Std.parseInt(strIndices[i]));
			}

			if(lePlayState.gomodchartSprites.exists(obj)) {
				var pussy:GameOverModchartSprite = lePlayState.gomodchartSprites.get(obj);
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
				return;
			}
			
			var pussy:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(pussy != null) {
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
			}
		});
		Lua_helper.add_callback(lua, "objectPlayAnimation", function(obj:String, name:String, forced:Bool = false) {
			if(lePlayState.gomodchartSprites.exists(obj)) {
				lePlayState.gomodchartSprites.get(obj).animation.play(name, forced);
				return;
			}

			var spr:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(spr != null) {
				spr.animation.play(name, forced);
			}
		});
		
		Lua_helper.add_callback(lua, "setScrollFactor", function(obj:String, scrollX:Float, scrollY:Float) {
			if(lePlayState.gomodchartSprites.exists(obj)) {
				lePlayState.gomodchartSprites.get(obj).scrollFactor.set(scrollX, scrollY);
				return;
			}

			var object:FlxObject = Reflect.getProperty(lePlayState, obj);
			if(object != null) {
				object.scrollFactor.set(scrollX, scrollY);
			}
		});
		Lua_helper.add_callback(lua, "addLuaSprite", function(tag:String) {
			if(lePlayState.gomodchartSprites.exists(tag)) {
				var shit:GameOverModchartSprite = lePlayState.gomodchartSprites.get(tag);
				if(!shit.wasAdded) 
				{
					lePlayState.add(shit);
					shit.wasAdded = true;
				}
			}
		});
		Lua_helper.add_callback(lua, "setGraphicSize", function(obj:String, x:Int, y:Int = 0) {
			if(lePlayState.gomodchartSprites.exists(obj)) {
				var shit:GameOverModchartSprite = lePlayState.gomodchartSprites.get(obj);
				shit.setGraphicSize(x, y);
				shit.updateHitbox();
				return;
			}

			var poop:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(poop != null) {
				poop.setGraphicSize(x, y);
				poop.updateHitbox();
				return;
			}
		});
		Lua_helper.add_callback(lua, "scaleObject", function(obj:String, x:Float, y:Float) {
			if(lePlayState.gomodchartSprites.exists(obj)) {
				var shit:GameOverModchartSprite = lePlayState.gomodchartSprites.get(obj);
				shit.scale.set(x, y);
				shit.updateHitbox();
				return;
			}

			var poop:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(poop != null) {
				poop.scale.set(x, y);
				poop.updateHitbox();
				return;
			}
		});
		Lua_helper.add_callback(lua, "updateHitbox", function(obj:String) {
			if(lePlayState.gomodchartSprites.exists(obj)) {
				var shit:GameOverModchartSprite = lePlayState.gomodchartSprites.get(obj);
				shit.updateHitbox();
				return;
			}

			var poop:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(poop != null) {
				poop.updateHitbox();
				return;
			}
		});
		Lua_helper.add_callback(lua, "removeLuaSprite", function(tag:String, destroy:Bool = true) {
			if(!lePlayState.gomodchartSprites.exists(tag)) {
				return;
			}
			
			var pee:GameOverModchartSprite = lePlayState.gomodchartSprites.get(tag);
			if(destroy) {
				pee.kill();
			}

			if(pee.wasAdded) {
				lePlayState.remove(pee, true);
				pee.wasAdded = false;
			}

			if(destroy) {
				pee.destroy();
				lePlayState.gomodchartSprites.remove(tag);
			}
		});

		Lua_helper.add_callback(lua, "setBlendMode", function(obj:String, blend:String = '') {
			if(lePlayState.gomodchartSprites.exists(obj)) {
				lePlayState.gomodchartSprites.get(obj).blend = blendModeFromString(blend);
				return true;
			}

			var spr:FlxSprite = Reflect.getProperty(lePlayState, obj);
			if(spr != null) {
				spr.blend = blendModeFromString(blend);
				return true;
			}
			return false;
		});

		Lua_helper.add_callback(lua, "screenCenter", function(obj:String, pos:String = 'xy') {
			var spr:FlxSprite;
			if(lePlayState.gomodchartSprites.exists(obj)) {
				spr = lePlayState.gomodchartSprites.get(obj);
			} else {
				spr = Reflect.getProperty(lePlayState, obj);
			}

			if(spr != null)
			{
				switch(pos.trim().toLowerCase())
				{
					case 'x':
						spr.screenCenter(X);
						return;
					case 'y':
						spr.screenCenter(Y);
						return;
					case 'xy':
						spr.screenCenter(XY);
						return;
				}
			}
		});

		Lua_helper.add_callback(lua, "getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Int> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseInt(excludeArray[i].trim()));
			}
			return FlxG.random.int(min, max, toExclude);
		});

		Lua_helper.add_callback(lua, "getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Float> = [];
			for (i in 0...excludeArray.length)
			{
				toExclude.push(Std.parseFloat(excludeArray[i].trim()));
			}
			return FlxG.random.float(min, max, toExclude);
		});

		Lua_helper.add_callback(lua, "getRandomBool", function(chance:Float = 50) {
			return FlxG.random.bool(chance);
		});

		Lua_helper.add_callback(lua, "callOnLuas", function(func:String, ?arg1:Dynamic = null, ?arg2:Dynamic = null, ?arg3:Dynamic = null, ?arg4:Dynamic = null)
		{
			var args:Array<Dynamic> = [];

			if (arg1 != null)
				args.push(arg1);
			if (arg2 != null)
				args.push(arg2);
			if (arg3 != null)
				args.push(arg3);
			if (arg4 != null)
				args.push(arg4);

			lePlayState.callOnLuas(func, args);
		});

		Lua_helper.add_callback(lua, "mouseVisible", function(bool:Bool) {
			FlxG.mouse.visible = bool;
		});

		Lua_helper.add_callback(lua, "setWindowSize", function(width:Int, height:Int) {
			FlxG.resizeWindow(width, height);
		});

		Lua_helper.add_callback(lua, "error", function(msg:String, ?title:String = 'Error') {
			lime.app.Application.current.window.alert(msg, title);
		});

		Lua_helper.add_callback(lua, "textFile", function(text:String, ?fileName:String = 'text') {
			TextFile.newFile(text, fileName);
		});

		Lua_helper.add_callback(lua, "openFile", function(path:String)
		{
			var fullpath:String = Paths.getModFile(path);
			if (!FileSystem.exists(fullpath))
			{
				fullpath = Paths.getPreloadPath(path);
			}
			FileOpener.openFile(fullpath);
		});

		Lua_helper.add_callback(lua, "stopMusic", function()
		{
			FlxG.sound.music.stop();
		});

		// string tools

		Lua_helper.add_callback(lua, "customString", function(?str1:String = '', ?str2:String = '', ?str3:String = '', ?str4:String = '', ?str5:String = '')
		{
			return str1 + str2 + str3 + str4 + str5;
		});

		Lua_helper.add_callback(lua, "formatToSongPath", function(song:String)
		{
			return Paths.formatToSongPath(song);
		});

		Lua_helper.add_callback(lua, "replace", function(string:String, what:String, with:String)
		{
			return string.replace(what, with);
		});

		Lua_helper.add_callback(lua, "startsWith", function(string:String, start:String)
		{
			return string.startsWith(start);
		});

		Lua_helper.add_callback(lua, "endsWith", function(string:String, end:String)
		{
			return string.endsWith(end);
		});

		// text Stuff

		Lua_helper.add_callback(lua, "makeLuaText", function(tag:String, text:String, x:Float, y:Float, ?size:Int = 12)
		{
			resetTextTag(tag);
			var sexPenis:GameOverModchartText = new GameOverModchartText(x, y, text, size);
			sexPenis.fontSizeThing = size;
			lePlayState.gomodchartTexts.set(tag, sexPenis);
		});

		Lua_helper.add_callback(lua, "setLuaTextFormat", function(tag:String, font:String, placement:String, colour:String, outlineColour:String)
		{
			if (lePlayState.gomodchartTexts.exists(tag))
			{
				if (!colour.startsWith('0xFF'))
				{
					colour = '0xFF' + colour;
				}
				if (!outlineColour.startsWith('0xFF'))
				{
					outlineColour = '0xFF' + outlineColour;
				}
				var size:Int = lePlayState.gomodchartTexts.get(tag).fontSizeThing;
				var realCol:FlxColor = Std.parseInt(colour);
				var realColOut:FlxColor = Std.parseInt(outlineColour);
				switch(placement.toLowerCase())
				{
					case 'left':
						lePlayState.gomodchartTexts.get(tag).setFormat(Paths.font(font), size, realCol, LEFT, FlxTextBorderStyle.OUTLINE, realColOut);
					case 'right':
						lePlayState.gomodchartTexts.get(tag).setFormat(Paths.font(font), size, realCol, RIGHT, FlxTextBorderStyle.OUTLINE, realColOut);
					case 'center':
						lePlayState.gomodchartTexts.get(tag).setFormat(Paths.font(font), size, realCol, CENTER, FlxTextBorderStyle.OUTLINE, realColOut);
					case 'justify':
						lePlayState.gomodchartTexts.get(tag).setFormat(Paths.font(font), size, realCol, JUSTIFY, FlxTextBorderStyle.OUTLINE, realColOut);
				}
			}
		});

		Lua_helper.add_callback(lua, "addLuaText", function(tag:String, ?front:Bool = false)
		{
			if (lePlayState.gomodchartTexts.exists(tag))
			{
				var shit:GameOverModchartText = lePlayState.gomodchartTexts.get(tag);
				if(!shit.wasAdded) 
				{
					lePlayState.add(shit);
					shit.wasAdded = true;
				}
			}
		});

		Lua_helper.add_callback(lua, "removeLuaText", function(tag:String, destroy:Bool = true) {
			if(!lePlayState.gomodchartTexts.exists(tag)) {
				return;
			}
			
			var pee:GameOverModchartText = lePlayState.gomodchartTexts.get(tag);
			if(destroy) {
				pee.kill();
			}

			if(pee.wasAdded) {
				lePlayState.remove(pee, true);
				pee.wasAdded = false;
			}

			if(destroy) {
				pee.destroy();
				lePlayState.gomodchartTexts.remove(tag);
			}
		});

		// button shit :/

		Lua_helper.add_callback(lua, "makeLuaButton", function(tag:String, image:String, x:Int, y:Int, ?widthheight:String = "150|150")
		{
			resetButtonTag(tag);
			var split:Array<String> = widthheight.split("|");
			var button:GameOverLuaButton = new GameOverLuaButton(x, y, "", function()
			{
				lePlayState.callOnLuas("onButtonPress", [tag]);
			});
			button.loadGraphic(Paths.image(image), true, Std.parseInt(split[0]), Std.parseInt(split[1]));
			lePlayState.gomodchartButtons.set(tag, button);
		});

		Lua_helper.add_callback(lua, "loadButtonGraphic", function(tag:String, image:String, width:Int, height:Int)
		{
			if (!lePlayState.gomodchartButtons.exists(tag))
			{
				var button:GameOverLuaButton = lePlayState.gomodchartButtons.get(tag);
				button.loadGraphic(Paths.image(image), true, width, height);
			}
		});

		Lua_helper.add_callback(lua, "addLuaButton", function(tag:String, ?front:Bool = false)
		{
			if (!lePlayState.gomodchartButtons.exists(tag))
			{
				var shit:GameOverLuaButton = lePlayState.gomodchartButtons.get(tag);
				if(!shit.wasAdded) 
				{
					lePlayState.add(shit);
					shit.wasAdded = true;
				}
			}
		});

		Lua_helper.add_callback(lua, "removeLuaButton", function(tag:String, destroy:Bool = true) {
			if(!lePlayState.gomodchartButtons.exists(tag)) {
				return;
			}
			
			var pee:GameOverLuaButton = lePlayState.gomodchartButtons.get(tag);
			if(destroy) {
				pee.kill();
			}

			if(pee.wasAdded) {
				lePlayState.remove(pee, true);
				pee.wasAdded = false;
			}

			if(destroy) {
				pee.destroy();
				lePlayState.gomodchartButtons.remove(tag);
			}
		});

		// save data
		Lua_helper.add_callback(lua, "saveData", function(tag:String, val:Dynamic)
		{
			if (!ClientPrefs.luaSave.exists(tag))
			{
				ClientPrefs.luaSave.set(tag, val);
			}
			ClientPrefs.saveSettings();
		});

		Lua_helper.add_callback(lua, "removeData", function(tag:String)
		{
			if (ClientPrefs.luaSave.exists(tag))
			{
				ClientPrefs.luaSave.remove(tag);
				ClientPrefs.saveSettings();
			}
		});


		// based
		Lua_helper.add_callback(lua, "username", function()
		{
			return CoolUtil.username();
		});

		Lua_helper.add_callback(lua, "loadSong", function(?name:String = null, ?difficultyNum:Int = 1) {
			if(name == null || name.length < 1)
				name = PlayState.SONG.song;
			if (difficultyNum == -1)
				difficultyNum = PlayState.storyDifficulty;

			var poop = Highscore.formatSong(name, difficultyNum);
			PlayState.SONG = Song.loadFromJson(poop, name);
			PlayState.storyDifficulty = difficultyNum;
			lePlayState.persistentUpdate = false;
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.pause();
			FlxG.sound.music.volume = 0;
		});

		// Animated images lol.

		Lua_helper.add_callback(lua, "loadGraphic", function(variable:String, image:String, ?animated:Bool = false, ?width:Int, ?height:Int) {
			var spr:FlxSprite = getObjectDirectly(variable);
			if (!animated)
			{
				if(spr != null && image != null && image.length > 0)
				{
					spr.loadGraphic(Paths.image(image));
				}
			}
			else
			{
				if(spr != null && image != null && image.length > 0)
				{
					spr.loadGraphic(Paths.image(image), true, width, height);
				}
			}
		});

		Lua_helper.add_callback(lua, "addGraphicAnimation", function(variable:String, anim:String, nums:String, ?looped:Bool = false)
		{
			var spr:FlxSprite = getObjectDirectly(variable);

			var theFrames:Array<Int> = [];

			var split:Array<String> = nums.split("|");
			for (i in 0...split.length)
			{
				theFrames.push(Std.parseInt(split[i]));
			}

			spr.animation.add(anim, theFrames, looped);
		});

		Lua_helper.add_callback(lua, "playGraphicAnimation", function(variable:String, animation:String, ?forced:Bool = false)
		{
			var spr:FlxSprite = getObjectDirectly(variable);
			spr.animation.play(animation, forced);
		});
		
		Lua_helper.add_callback(lua, "playMusic", function(?volume:Float = 1, ?loop:Bool = true) {
			lePlayState.playMusic(volume, loop);
		});

		Lua_helper.add_callback(lua, "playSound", function(sound:String, volume:Float = 1, ?tag:String = null) {
			if(tag != null && tag.length > 0) {
				tag = tag.replace('.', '');
				if(lePlayState.gomodchartSounds.exists(tag)) {
					lePlayState.gomodchartSounds.get(tag).stop();
				}
				lePlayState.gomodchartSounds.set(tag, FlxG.sound.play(Paths.sound(sound), volume, false, function() {
					lePlayState.gomodchartSounds.remove(tag);
					lePlayState.callOnLuas('onSoundFinished', [tag]);
				}));
				return;
			}
			FlxG.sound.play(Paths.sound(sound), volume);
		});
		Lua_helper.add_callback(lua, "stopSound", function(tag:String) {
			if(tag != null && tag.length > 1 && lePlayState.gomodchartSounds.exists(tag)) {
				lePlayState.gomodchartSounds.get(tag).stop();
				lePlayState.gomodchartSounds.remove(tag);
			}
		});
		Lua_helper.add_callback(lua, "pauseSound", function(tag:String) {
			if(tag != null && tag.length > 1 && lePlayState.gomodchartSounds.exists(tag)) {
				lePlayState.gomodchartSounds.get(tag).pause();
			}
		});
		Lua_helper.add_callback(lua, "resumeSound", function(tag:String) {
			if(tag != null && tag.length > 1 && lePlayState.gomodchartSounds.exists(tag)) {
				lePlayState.gomodchartSounds.get(tag).play();
			}
		});
		Lua_helper.add_callback(lua, "soundFadeIn", function(tag:String, duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			if(tag == null || tag.length < 1) {
				FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			} else if(lePlayState.gomodchartSounds.exists(tag)) {
				lePlayState.gomodchartSounds.get(tag).fadeIn(duration, fromValue, toValue);
			}
			
		});
		Lua_helper.add_callback(lua, "soundFadeOut", function(tag:String, duration:Float, toValue:Float = 0) {
			if(tag == null || tag.length < 1) {
				FlxG.sound.music.fadeOut(duration, toValue);
			} else if(lePlayState.gomodchartSounds.exists(tag)) {
				lePlayState.gomodchartSounds.get(tag).fadeOut(duration, toValue);
			}
		});
		Lua_helper.add_callback(lua, "soundFadeCancel", function(tag:String) {
			if(tag == null || tag.length < 1) {
				if(FlxG.sound.music.fadeTween != null) {
					FlxG.sound.music.fadeTween.cancel();
				}
			} else if(lePlayState.gomodchartSounds.exists(tag)) {
				var theSound:FlxSound = lePlayState.gomodchartSounds.get(tag);
				if(theSound.fadeTween != null) {
					theSound.fadeTween.cancel();
					lePlayState.gomodchartSounds.remove(tag);
				}
			}
		});
		Lua_helper.add_callback(lua, "getSoundVolume", function(tag:String) {
			if(tag == null || tag.length < 1) {
				if(FlxG.sound.music != null) {
					return FlxG.sound.music.volume;
				}
			} else if(lePlayState.gomodchartSounds.exists(tag)) {
				return lePlayState.gomodchartSounds.get(tag).volume;
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "setSoundVolume", function(tag:String, value:Float) {
			if(tag == null || tag.length < 1) {
				if(FlxG.sound.music != null) {
					FlxG.sound.music.volume = value;
				}
			} else if(lePlayState.gomodchartSounds.exists(tag)) {
				lePlayState.gomodchartSounds.get(tag).volume = value;
			}
		});
		Lua_helper.add_callback(lua, "getSoundTime", function(tag:String) {
			if(tag != null && tag.length > 0 && lePlayState.gomodchartSounds.exists(tag)) {
				return lePlayState.gomodchartSounds.get(tag).time;
			}
			return 0;
		});
		Lua_helper.add_callback(lua, "setSoundTime", function(tag:String, value:Float) {
			if(tag != null && tag.length > 0 && lePlayState.gomodchartSounds.exists(tag)) {
				var theSound:FlxSound = lePlayState.gomodchartSounds.get(tag);
				if(theSound != null) {
					var wasResumed:Bool = theSound.playing;
					theSound.pause();
					theSound.time = value;
					if(wasResumed) theSound.play();
				}
			}
		});
    
		Lua_helper.add_callback(lua, "musicFadeIn", function(duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			FlxG.sound.music.fadeIn(duration, fromValue, toValue);

		});
		Lua_helper.add_callback(lua, "musicFadeOut", function(duration:Float, toValue:Float = 0) {
			FlxG.sound.music.fadeOut(duration, toValue);
		});

		Lua_helper.add_callback(lua, "switchState", function(?bruh:String = "bruh")
		{
			lePlayState.switchState();
		});

		Lua_helper.add_callback(lua, "back", function(?bruh:String = "bruh")
		{
			lePlayState.back();
		});

		Lua_helper.add_callback(lua, "trace", function(to:String)
		{
			trace(to);
		});

		Lua_helper.add_callback(lua, "cameraShake", function(intensity:Float, duration:Float) {
			FlxG.camera.shake(intensity, duration);
		});
		
		Lua_helper.add_callback(lua, "cameraFlash", function(color:String, duration:Float, forced:Bool) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			FlxG.camera.flash(colorNum, duration, null, forced);
		});

		Lua_helper.add_callback(lua, "cameraFade", function(color:String, duration:Float, forced:Bool) {
			var colorNum:Int = Std.parseInt(color);
			if(!color.startsWith('0x')) colorNum = Std.parseInt('0xff' + color);
			FlxG.camera.fade(colorNum, duration, false, null, forced);
		});
		#end
	}

	function resetSpriteTag(tag:String) {
		if(!lePlayState.gomodchartSprites.exists(tag)) {
			return;
		}
		
		var pee:GameOverModchartSprite = lePlayState.gomodchartSprites.get(tag);
		pee.kill();
		if(pee.wasAdded) {
			lePlayState.remove(pee, true);
		}
		pee.destroy();
		lePlayState.gomodchartSprites.remove(tag);
	}

	function resetTextTag(tag:String) {
		if(!lePlayState.gomodchartTexts.exists(tag)) {
			return;
		}
		
		var pee:GameOverModchartText = lePlayState.gomodchartTexts.get(tag);
		pee.kill();
		if(pee.wasAdded) {
			lePlayState.remove(pee, true);
		}
		pee.destroy();
		lePlayState.gomodchartTexts.remove(tag);
	}

	function resetButtonTag(tag:String) {
		if(!lePlayState.gomodchartButtons.exists(tag)) {
			return;
		}
		
		var pee:GameOverLuaButton = lePlayState.gomodchartButtons.get(tag);
		pee.kill();
		if(pee.wasAdded) {
			lePlayState.remove(pee, true);
		}
		pee.destroy();
		lePlayState.gomodchartButtons.remove(tag);
	}


	function cancelTween(tag:String) {
		if(lePlayState.gomodchartTweens.exists(tag)) {
			lePlayState.gomodchartTweens.get(tag).cancel();
			lePlayState.gomodchartTweens.get(tag).destroy();
			lePlayState.gomodchartTweens.remove(tag);
		}
	}

	function tweenShit(tag:String, vars:String) {
		cancelTween(tag);
		var variables:Array<String> = vars.replace(' ', '').split('.');
		var sexyProp:Dynamic = Reflect.getProperty(lePlayState, variables[0]);
		if(sexyProp == null && lePlayState.gomodchartSprites.exists(variables[0])) {
			sexyProp = lePlayState.gomodchartSprites.get(variables[0]);
		}
		if(sexyProp == null && lePlayState.gomodchartTexts.exists(variables[0])) {
			sexyProp = lePlayState.gomodchartTexts.get(variables[0]);
		}
		if(sexyProp == null && lePlayState.gomodchartButtons.exists(variables[0])) {
			sexyProp = lePlayState.gomodchartButtons.get(variables[0]);
		}

		for (i in 1...variables.length) {
			sexyProp = Reflect.getProperty(sexyProp, variables[i]);
		}
		return sexyProp;
	}

	function cancelTimer(tag:String) {
		if(lePlayState.gomodchartTimers.exists(tag)) {
			var theTimer:FlxTimer = lePlayState.gomodchartTimers.get(tag);
			theTimer.cancel();
			theTimer.destroy();
			lePlayState.gomodchartTimers.remove(tag);
		}
	}

	//Better optimized than using some getProperty shit or idk
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

	function blendModeFromString(blend:String):BlendMode {
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

	function getObjectDirectly(objectName:String, ?checkForTextsToo:Bool = true):Dynamic
	{
		var coverMeInPiss:Dynamic = null;
		if(lePlayState.gomodchartSprites.exists(objectName)) {
			coverMeInPiss = lePlayState.gomodchartSprites.get(objectName);
		}
		return coverMeInPiss;
	}

	#if LUA_ALLOWED
	function resultIsAllowed(leLua:State, leResult:Null<Int>) { //Makes it ignore warnings
		switch(Lua.type(leLua, leResult)) {
			case Lua.LUA_TNIL | Lua.LUA_TBOOLEAN | Lua.LUA_TNUMBER | Lua.LUA_TSTRING | Lua.LUA_TTABLE:
				return true;
		}
		return false;
	}
	#end

	public function set(variable:String, data:Dynamic) {
		#if LUA_ALLOWED
		if(lua == null) {
			return;
		}

		Convert.toLua(lua, data);
		Lua.setglobal(lua, variable);
		#end
	}

	#if LUA_ALLOWED
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
	#end
}

class GameOverModchartSprite extends FlxSprite
{
	public var wasAdded:Bool = false;
	//public var isInFront:Bool = false;
}

class GameOverModchartText extends FlxText
{
	public var fontSizeThing:Int = 12;
	public var wasAdded:Bool = false;
}

class GameOverLuaButton extends FlxButton
{
	public var wasAdded:Bool = false;
}

class GameOverDebugLuaText extends FlxText
{
	private var disableTime:Float = 6;
	public var parentGroup:FlxTypedGroup<GameOverDebugLuaText>; 
	public function new(text:String, parentGroup:FlxTypedGroup<GameOverDebugLuaText>) {
		this.parentGroup = parentGroup;
		super(10, 10, 0, text, 16);
		setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scrollFactor.set();
		borderSize = 1;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		disableTime -= elapsed;
		if(disableTime <= 0) {
			kill();
			parentGroup.remove(this);
			destroy();
		}
		else if(disableTime < 1) alpha = disableTime;
	}
}