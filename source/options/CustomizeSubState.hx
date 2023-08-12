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

class CustomizeSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Customize Assets';
		rpcTitle = 'Asset Customizing Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option("Customize UI",
		"Press this to customize your UI!",
		"lol",
		"callback");
		option.onChange = function()
		{
			canPress = false;
			LoadingState.loadAndSwitchState(new CustomizeState());
		}
		addOption(option);

        var option:Option = new Option("Loading Screens",
		"Press this to customize your loading screen!",
		"lol",
		"callback");
		option.onChange = function()
		{
			canPress = false;
			MusicBeatState.switchState(new CustomizeState.CustomizeLoadingScreenState());
		}
		addOption(option);

		super();
	}
}