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

class CustomizeState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Assets';
		rpcTitle = 'Customizing Assets'; //for Discord Rich Presence
	
		var option:Option = new Option('Menu Bg Sprite:',
			"What Bg Do You Prefer in the Main Menu?",
			'bgSprite',
			'string',
			'menuBg',
			['menuBG', 'funkinBG', 'starscape']);
		addOption(option);
		option.onChange = onBg;
	
		var option:Option = new Option('Pause Screen Song:',
			"What song do you prefer for the Pause Screen?",
			'pauseMusic',
			'string',
			'breakfast',
			['None', 'breakfast', 'synthDream', 'funkinBreakfast']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		var option:Option = new Option('Dialogue Close Sound:',
			"What sound do you prefer when closing a dialogue?",
			'closeSound',
			'string',
			'dialogue',
			['dialogueClose', 'pixelClose', 'coolClose']);
		addOption(option);
		option.onChange = onChangeClick;

		super();
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.volume = 1;
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	function onChangeClick()
	{
		FlxG.sound.music.volume = 0.3;
		FlxG.sound.play(Paths.sound(ClientPrefs.closeSound));
	}

	function onBg()
	{
		FlxG.sound.music.volume = 1;
	}


	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('options'));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}