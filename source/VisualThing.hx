package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class VisualThing extends FlxSprite
{
	var lePlayState:PlayState;

	public var tweenTime:Float;
	public var timerTime:Float;

	public function new(colour:Int, tweenTime:Float, timerTime:Float, state:PlayState)
	{
		super();

		lePlayState = state;
		alpha = 0;
		loadGraphic(Paths.image("events/vg"));
	}

	public function start()
	{
		lePlayState.modchartTweens.set("vgEventTween", FlxTween.tween(this, {alpha: 1}, tweenTime));
		lePlayState.modchartTimers.set("vgEventTimer", new FlxTimer().start(timerTime, function(tmr:FlxTimer)
		{
			kill();
		}));
	}
}