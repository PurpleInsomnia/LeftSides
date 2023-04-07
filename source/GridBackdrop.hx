package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;

class GridBackdrop extends FlxBackdrop
{
	public function new()
	{
		var penis:FlxGraphic = Paths.addFlxGraphic('gridBG');

		super(penis, 1, 1, true, true, 0, 0);

		velocity.set(64, 64);
	}
}