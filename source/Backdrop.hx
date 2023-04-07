package;

import flixel.graphics.FlxGraphic;

class Backdrop extends FlxBackdrop
{
	// IMAGE MUST BE 2560 X 1440 px!!!!
	public function new(image:String, ?scrollX:Float = 1, ?scrollY:Float = 1, ?type:String = "BOTH", ?smh:Int = 1, ?smv:Int = 1)
	{
		var graphic:FlxGraphic = Paths.addFlxGraphic(image);

		super(graphic, scrollX, scrollY, true, true, 0, 0);

		switch (type.toUpperCase())
		{
			case "BOTH":
				velocity.set(80 * smh, 45 * smv);
			case "HORIZONTAL":
				velocity.set(80 * smh, 0);
			case "VERTICAL":
				velocity.set(0, 45 * smv);
		}
	}
}