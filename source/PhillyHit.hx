import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;

class PhillyHit extends FlxTypedGroup<FlxSprite>
{
	public function new(color:Int, time:Float)
	{
		super();

		var glow:FlxSprite = new FlxSprite().loadGraphic(Paths.image('philly/glow'));
		glow.color = color;
		glow.alpha = 0.75;
		add(glow);

		FlxTween.tween(glow, {alpha: 0}, time * 2, {ease: FlxEase.sineInOut});

		new FlxTimer().start(time * 3.7, function(tmr:FlxTimer)
		{
			this.kill();
		});
	}
}