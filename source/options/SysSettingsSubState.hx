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

class SysSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'System Settings';
		rpcTitle = 'System Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option('Audio Offset',
			"This option will help with audio lag from Wireless Headphones\n(Notes will spawn later)",
			'noteOffset',
			'int',
			0);
		addOption(option);

		var option:Option = new Option('Show PC Username',
		"Check this if you don't want this mod to pull a" + ' "Monika from DDLC"\n(lmao funny reference)',
		'showUsername',
		'bool',
		false);

		addOption(option);

		var option:Option = new Option("Use Prefered Name As PC Username",
		"Check this if you want to use the prefered name you typed into the 'Name Box' inseted of your PC Username.",
		"usePNAsUser",
		"bool",
		false);

		addOption(option);

		var option:Option = new Option("Change Prefered Name",
		"Press this to change your name!",
		"lol",
		"callback");

		option.onChange = function()
		{
			canPress = false;
			add(new NameBox(null, function()
			{
				canPress = true;
			}));
		}

		addOption(option);

		#if desktop
		var option:Option = new Option("Discord Rich Presence",
		"If checked, Discord will display this game (and it's curent state) as a status message\n(YOU MUST RESTART THE GAME TO ACTIVATE)",
		"discord",
		"bool",
		true);

		addOption(option);
		#end

		// HAHAHAHAHAHAHAHAHAH DEVS ONLYYYYYYYY :skull:
		var devBuild:Bool = false;
		if (CoolUtil.username() == "purpl")
		{
			devBuild = true;
		}
		if (devBuild)
		{
			var option:Option = new Option("Developer Options",
			"If checked, locks will be removed in the story menu and freeplay menu.",
			"devMode",
			"bool",
			false);

			addOption(option);
		}

		var option:Option = new Option("Charting Mode",
		"If checked, charting is enabled",
		"chartingMode",
		"bool",
		false);

		addOption(option);

		var option:Option = new Option("Debug Check",
		"If checked, the game shows you which line of code in 'PlayState.hx' is problematic.",
		"debugCheck",
		"bool",
		false);

		addOption(option);

		super();
	}
}