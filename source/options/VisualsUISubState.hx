package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Note Splashes',
			"If unchecked, hitting \"Sick!\" notes won't show particles.",
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Hide HUD',
			'If checked, hides most HUD elements.',
			'hideHud',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option("Limited HUD",
			"Like hide HUD, but the health bar, icons and score text are visible too.\nNote: A certain event will not trigger if this is on.",
			"limitedHud",
			"bool",
			false);
		addOption(option);

		var option:Option = new Option("Health Icon Style",
			"How the health icons should be displayed.",
			"iconStyle",
			"string",
			"Default",
			["Default", "Classic"]);
		addOption(option);

		var option:Option = new Option("Icon Glows",
			"If checked, the icons glow depending on how much health you have.",
			"iconGlows",
			"bool",
			true);
		addOption(option);
		
		var option:Option = new Option('Hide Time Bar',
			"If unchecked, A bar will show how much\nTime there is left in a song",
			'hideTime',
			'bool',
			'false');
		addOption(option);

		// FUCK YOU!
		/*
		var option:Option = new Option("Bloom Shaders",
			"If checked, glows appear around characters, stages & notes that give\nthe mod a prettier look",
			"bloom",
			"bool",
			"true");
		addOption(option);
		*/

		var option:Option = new Option("Time Bar Colour",
			"What colours the time bar should be",
			"timeColour",
			"string",
			"Gradient & Black",
			["Gradient & Black", "Gold & Magenta", "Magenta & Gold", "White & Black"]);

		addOption(option);

		var option:Option = new Option('Flashing Lights',
			"Uncheck this if you're sensitive to flashing lights!",
			'flashing',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Camera Zooms',
			"If unchecked, the camera won't zoom in on a beat hit.",
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option("Screen Shake",
			"If checked, screen shaking will be enabled.",
			"screenShake",
			"bool",
			true);
		addOption(option);
		
		#if !mobile
		var option:Option = new Option('FPS Counter',
			'If unchecked, hides FPS Counter.',
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end

		var option:Option = new Option("Prefered Window Size:",
		"Your Prefered Window Size (1280 x 720 is default).\nSmaller Sizes Cause Less Lag.",
		"preferedDimens",
		"string",
		"1280 x 720",
		["1280 x 720", "960 x 540", "640 x 360", "320 x 180"]);
		addOption(option);
		option.onChange = onChangeWindowSize;

		super();
	}

	override function destroy()
	{
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end

	function onChangeWindowSize()
	{
		var split:Array<String> = ClientPrefs.preferedDimens.split(" x ");
		var toMod:Array<Int> = [Std.parseInt(split[0]), Std.parseInt(split[1])];
		FlxG.resizeWindow(toMod[0], toMod[1]);
		WindowControl.rePosWindow();
	}
}