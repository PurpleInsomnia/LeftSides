package;

import flixel.tweens.FlxTween;
import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flixel.FlxSprite;
import flixel.FlxG;

/**
 * Shake effect for a FlxSprite
 */
class ShakeTween extends FlxTween
{
	/**
	 * Percentage representing the maximum distance that the object can move while shaking.
	 */
	 var intensity:Float;

	/**
	 * Defines on what axes to `shake()`. Default value is `XY` / both.
	 */
	 var axes:FlxAxes;

	/**
	 * The sprite to shake.
	 */
	 var sprite:FlxSprite;

	/**
	 * Defines the initial offset of the sprite at the beginning of the shake effect.
	 */
	 var initialOffset:FlxPoint;

     var axb:Array<Bool> = [false, false];

     var dur:Float = 0;

    public function new(options:TweenOptions, tween:FlxTweenManager)
    {
        super(options, tween);
    }

	/**
	 * A simple shake effect for FlxSprite.
	 *
	 * @param	Sprite       Sprite to shake.
	 * @param   Intensity    Percentage representing the maximum distance
	 *                       that the sprite can move while shaking.
	 * @param   Duration     The length in seconds that the shaking effect should last.
	 * @param   Axes         On what axes to shake. Default value is `FlxAxes.XY` / both.
	 */
	public function tween(Sprite:FlxSprite, Intensity:Float = 0.05, Duration:Float = 1, Axes:FlxAxes = XY)
	{
		intensity = Intensity;
		sprite = Sprite;
		dur = Duration;
		axes = Axes;
        switch (axes)
        {
            case X:
                axb = [true, false];
            case Y:
                axb = [false, true];
            case XY:
                axb = [true, true];
        }
		initialOffset = new FlxPoint(Sprite.offset.x, Sprite.offset.y);
		start();
	}

	override function destroy():Void
	{
		super.destroy();
		// Return the sprite to its initial offset.
		if (sprite != null && !sprite.offset.equals(initialOffset))
			sprite.offset.set(initialOffset.x, initialOffset.y);

		sprite = null;
		initialOffset = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (axb[0])
			sprite.offset.x = initialOffset.x + FlxG.random.float(-intensity * sprite.width, intensity * sprite.width);
		if (axb[1])
			sprite.offset.y = initialOffset.y + FlxG.random.float(-intensity * sprite.height, intensity * sprite.height);
	}

	override function isTweenOf(Object:Dynamic, ?Field:String):Bool
	{
		return sprite == Object && (Field == null || Field == "shake");
	}
}