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

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Downscroll', //Name
			'If checked, notes go Down instead of Up, simple enough.', //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option('Middlescroll',
			'If checked, your notes get centered.',
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option('Ghost Tapping',
			"If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.",
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Directional Camera',
			"If checked, the camera moves based on what note\nYou/Your Opponent hits.",
			'camMove',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option("Game Over Quotes",
			"Text with a icon shows up whever you get blueballed when checked.",
			'justDont',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Dialogue Voices',
			"If checked, a voice will play for (almost) all dialogue characters\nwhenever they speak.",
			'dialogueVoices',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Mute Miss Sounds',
		'If checked, no sound will play when you miss a note\n(or break your combo)',
		'muteMiss',
		'bool',
		false);

		addOption(option);

		var option:Option = new Option('Jumpscares',
			"If unchecked, you won't piss yourself when the funny",
			'jumpscares',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option('Content Warnings',
		'Check this if you are sensitive to topics about Blood, Suicide, Abuse and/or Self Harm',
		'contentWarnings',
		'bool',
		false);

		addOption(option);

		var option:Option = new Option('Swear Filter',
			"If unchecked, you will see violent and innapropriate language\n>:(",
			'swearFilter',
			'bool',
			false);
		addOption(option);

		super();
	}
}