package;

#if DISCORD
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
import sys.FileSystem;
import openfl.display.BitmapData;
import flixel.system.FlxSound;
import openfl.utils.Assets as LimeAssets;

using StringTools;

class LoadingScreenState extends MusicBeatState
{
	private var camGame:FlxCamera;

	var peepeepoopoo:LoadingSpr;

	var files:Array<String> = [];

	var statusText:FlxText;

	var done:Bool = false;

	/**
	 * Used mostly for week 8. But you can use this too.
	 */
	public static var folderDirectory:String = "";

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Loading", null);
		#end

		PlayStateMeta.setFile(PlayState.SONG.song);

		files = ["..."];

		done = false;

		FlxG.sound.music.stop();
		FlxG.sound.playMusic(Paths.music("loading"));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		folderDirectory = PlayStateMeta.dataFile.loadingDirectory;
		var fullPath:String = "";
		if (folderDirectory != "")
		{
			fullPath = folderDirectory + "/";
		}

		var screen:FlxSprite = new FlxSprite().loadGraphic(Paths.image("loading/" + fullPath + "loadingScreen"));
		add(screen);

		var random:Int = FlxG.random.int(0, 6);
		var tip:FlxSprite = new FlxSprite(-1280, 0).loadGraphic(Paths.image("loading/" + fullPath + "tips/" + random));
		add(tip);

		peepeepoopoo = new LoadingSpr();
		add(peepeepoopoo);

		statusText = new FlxText(0, 0, 'Loading...', 24);
		statusText.font = Paths.font('eras.ttf');
		statusText.y = Std.int(FlxG.height - statusText.height);
		add(statusText);

		FlxTween.tween(tip, {x: 0}, 1.5, {ease: FlxEase.sineOut});

		#if sys
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if (ClientPrefs.precacheCharacters)
			{
				CoolUtil.pcCharacters();
			}
		});
		#end

		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			if (!done)
			{
				done = true;
				LoadingState.loadAndSwitchState(new PlayState());
				FlxG.sound.music.stop();
			}
		});
	}
	
	override function update(elapsed:Float)
	{
		
		if (FlxG.keys.justPressed.SPACE && !done)
		{
			done = true;
			LoadingState.loadAndSwitchState(new PlayState());
			FlxG.sound.music.stop();
		}
		peepeepoopoo.angle += 90 * elapsed;
		if (done)
		{
			statusText.text = 'Done!';
		}
		super.update(elapsed);
	}
}

class LoadingSpr extends FlxSprite
{
	public function new()
	{
		super();
		loadGraphic(Paths.image('loadingCircle'));
		x = FlxG.width - 64;
		y = FlxG.height - 64;
	}
}
