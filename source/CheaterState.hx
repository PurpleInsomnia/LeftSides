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
import flixel.util.FlxTimer;
import lime.app.Application;
import editors.MasterEditorMenu;

using StringTools;

class CheaterState extends MusicBeatState
{
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Cheating", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('cheater'));
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		trace('cheater');

		FlxG.sound.playMusic(Paths.music('safe'));

		FlxG.sound.music.fadeIn(4, 0, 0.7);
	}
	
	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.play(Paths.sound('confirmMenu-laugh'));
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.sound.music.stop();
				MusicBeatState.switchState(new TitleScreenState());
			});
		}
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('confirmMenu-laugh'));
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxG.sound.music.stop();
				MusicBeatState.switchState(new TitleScreenState());
			});
		}
		if (FlxG.keys.justPressed.N)
		{
			// lmao
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}
}
