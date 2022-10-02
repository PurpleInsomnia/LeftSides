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

		var option:Option = new Option('UK Time Format',
		'If checked, the time format is changed to "Day/Month/Year" ' + "(Bri'ish)",
		'ukFormat',
		'bool',
		false);

		addOption(option);

		#if desktop
		var option:Option = new Option("Discord Rich Presence",
		"If checked, Discord will display this game (and it's curent state) as a status message\n(YOU MUST RESTART THE GAME TO ACTIVATE)",
		"discord",
		"bool",
		true);

		addOption(option);
		#end

		super();
	}
}