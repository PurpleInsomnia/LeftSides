package;

import sys.FileSystem;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxBasic;

using StringTools;

class MusicBeatState extends FlxUIState
{
	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;

	private static var currentStateName:String = "";
	public static var menuHscripts:Array<MenuHscript.MenuScript> = [];

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;
		menuHscripts = [];
		if (FileSystem.exists(Paths.preloadFunny("states/" + currentStateName + "/" + "main.hxs")))
		{
			menuHscripts.push(MenuHscript.returnFile("main"));
		}
		MenuHscript.callOnScripts("onCreate", []);
		super.create();

		// Custom made Trans out
		if(!skip) {
			openSubState(new CustomFadeTransition(1, true));
		}
		FlxTransitionableState.skipNextTransOut = false;

		MenuHscript.callOnScripts("onCreatePost", []);
	}
	
	#if (VIDEOS_ALLOWED && windows)
	override public function onFocus():Void
	{
		FlxVideo.onFocus();
		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		FlxVideo.onFocusLost();
		super.onFocusLost();
	}
	#end

	override function update(elapsed:Float)
	{
		MenuHscript.callOnScripts("onUpdate", [elapsed]);
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();

		super.update(elapsed);

		MenuHscript.callOnScripts("onUpdatePost", [elapsed]);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		MenuHscript.setOnScripts("curBeat", curBeat);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor(((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / Conductor.stepCrochet);
		MenuHscript.setOnScripts("curStep", curStep);
	}

	public static function switchState(nextState:FlxState) {
		MenuHscript.callOnScripts("onSwitchState", []);
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;

		var readState:Class<Dynamic> = Type.getClass(nextState);
		currentStateName = Type.getClassName(readState);
		if (currentStateName.contains("."))
		{
			var cns:Array<String> = currentStateName.split(".");
			currentStateName = cns[cns.length - 1];
		}

		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new CustomFadeTransition(0.7, false));
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		MenuHscript.callOnScripts("onStepHit", []);
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		MenuHscript.callOnScripts("onBeatHit", []);
		//do literally nothing dumbass
	}

	public static function callOnHscripts(call:String, args:Array<Dynamic>)
	{
		MenuHscript.callOnScripts(call, args);
	}

	public static function setOnHscripts(va:String, val:Dynamic)
	{
		MenuHscript.setOnScripts(va, val);
	}
}
