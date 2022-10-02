package;

import flixel.addons.display.FlxBackdrop;
import flixel.graphics.FlxGraphic;

class Backdrop extends FlxBackdrop
{
	// IMAGE MUST BE 2560 X 1440 px!!!!
	public function new(image:String)
	{
		var graphic:FlxGraphic = Paths.addFlxGraphic(image);

		super(graphic, 1, 1, true, true, 0, 0);

		velocity.set(80, 45);
	}
}