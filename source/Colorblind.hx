package;

import flixel.FlxG;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.BitmapFilter;

class Colorblind
{
	public static var modes:Array<BitmapFilter> = [];
	public static var mm:Map<String, {filter:BitmapFilter}> = [];

	public static function changeMode(?mode:String)
	{
		// yes
		if (mode == null)
		{
			mode = ClientPrefs.colorblind;
		}
		makeFilters();
		switch(mode)
		{
			case 'Off':
				modes = [];
			case 'Deuteranopia' | 'Protanopia' | 'Tritanopia':
				modes = [mm.get(mode).filter];
		}
		FlxG.game.setFilters(modes);
	}

	public static function makeFilters()
	{
		mm = [
			"Deuteranopia" => {
				var matrix:Array<Float> = [
					0.43, 0.72, -.15, 0, 0,
					0.34, 0.57, 0.09, 0, 0,
					-.02, 0.03,    1, 0, 0,
					   0,    0,    0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Protanopia" => {
				var matrix:Array<Float> = [
					0.20, 0.99, -.19, 0, 0,
					0.16, 0.79, 0.04, 0, 0,
					0.01, -.01,    1, 0, 0,
					   0,    0,    0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			},
			"Tritanopia" => {
				var matrix:Array<Float> = [
					0.97, 0.11, -.08, 0, 0,
					0.02, 0.82, 0.16, 0, 0,
					0.06, 0.88, 0.18, 0, 0,
					   0,    0,    0, 1, 0,
				];

				{filter: new ColorMatrixFilter(matrix)}
			}
		];
	}
}