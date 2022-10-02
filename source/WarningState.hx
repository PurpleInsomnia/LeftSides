package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class WarningState extends MusicBeatState
{
	public static var left:Bool = false;

	override function create()
	{
		FlxG.sound.music.stop();

		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		// Yes this is a copy of MainMenuState, am I ashamed of it? No.

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('warning'));
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		FlxG.sound.playMusic(Paths.music('warning'));

		super.create();
	}


	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.music.stop();
		}

		if (controls.ACCEPT)
		{
			left = true;
			FlxG.save.data.left = true;
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.play(Paths.sound('pressWarning'));
			FlxG.sound.music.stop();
		}

		super.update(elapsed);
	}
}
