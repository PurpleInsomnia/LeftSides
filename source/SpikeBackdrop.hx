package;

import flixel.addons.display.FlxBackdrop;
import flixel.graphics.FlxGraphic;

class SpikeBackdrop extends FlxBackdrop
{
	// MUST BE 1280 x 720 PX!!!!!
	public function new(image:String, type:String)
	{
		var graphic:FlxGraphic = Paths.addFlxGraphic(image);

		super(graphic, 1, 1, true, true, 0, 0);

		switch(type)
		{
			case 'BOTH':
				velocity.set(40, 22);
			case 'HORIZONTAL':
				velocity.set(40, 0);
			case 'VERTICAL':
				velocity.set(0, 22);
		}
	}
}