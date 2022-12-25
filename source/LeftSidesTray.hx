#if FLX_SOUND_SYSTEM
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end
import flixel.system.ui.FlxSoundTray;

/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 */
class LeftSidesTray extends FlxSoundTray
{
	override public function show(Silent:Bool = false):Void
	{
		if (!Silent)
		{
			var sound = Paths.sound('beep');
			if (sound != null)
				FlxG.sound.load(sound).play();
		}

		_timer = 1;
		y = 0;
		visible = true;
		active = true;
		dtf.font = Paths.font('eras.ttf');
		if (dtf.size != 16)
			dtf.size = 16;
		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);

		if (FlxG.sound.muted)
		{
			globalVolume = 0;
		}

		for (i in 0..._bars.length)
		{
			if (i < globalVolume)
			{
				_bars[i].alpha = 1;
			}
			else
			{
				_bars[i].alpha = 0.5;
			}
		}
	}
}
#end
