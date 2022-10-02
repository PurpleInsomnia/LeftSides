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
import Achievements;
import editors.MasterEditorMenu;

using StringTools;

class PreLoadingScreenState extends MusicBeatState
{
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var notDone:FlxSprite;
	var done:FlxSprite;

	public static var left:Bool = false;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Loading", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('preloadBG'));
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var notDone:FlxSprite = new FlxSprite().loadGraphic(Paths.image('loadingText'));
		notDone.screenCenter();
		notDone.antialiasing = ClientPrefs.globalAntialiasing;
		add(notDone);

		done = new FlxSprite().loadGraphic(Paths.image('loadingTextDone'));
		done.screenCenter();
		done.antialiasing = ClientPrefs.globalAntialiasing;
		add(done);
		done.visible = false;

		trace('Loading...');

		// FlxG.sound.playMusic(Paths.music('loading'));

		// FlxG.sound.music.fadeIn(4, 0, 0.7);

		new FlxTimer().start(15, function(tmr:FlxTimer)
		{
			trace('done!!!');
			// FlxG.sound.music.stop();
			FlxG.sound.play(Paths.sound('scrollFreeplay'));
			notDone.visible = false;
			done.visible = false;
			left = true;
			MusicBeatState.switchState(new TitleState());
		});
	}
	
	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.SPACE)
		{
			left = true;
			MusicBeatState.switchState(new TitleState());
		}
	}
}
