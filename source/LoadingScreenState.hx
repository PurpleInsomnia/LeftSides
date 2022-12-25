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
import sys.FileSystem;
import openfl.display.BitmapData;
import flixel.system.FlxSound;
import lime.utils.Assets as LimeAssets;

using StringTools;

class LoadingScreenState extends MusicBeatState
{
	private var camGame:FlxCamera;

	var peepeepoopoo:LoadingSpr;

	var files:Array<String> = [];

	var statusText:FlxText;

	var done:Bool = false;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Loading", null);
		#end

		files = ["..."];

		done = false;

		FlxG.sound.music.stop();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		var screen:FlxSprite = new FlxSprite().loadGraphic(Paths.image("loading/loadingScreen"));
		add(screen);

		var random:Int = FlxG.random.int(0, 6);
		var tip:FlxSprite = new FlxSprite(-1280, 0).loadGraphic(Paths.image("loading/tips/" + random));
		add(tip);

		peepeepoopoo = new LoadingSpr();
		add(peepeepoopoo);

		statusText = new FlxText(0, 0, 'Loading...', 24);
		statusText.font = Paths.font('eras.ttf');
		statusText.y = Std.int(FlxG.height - statusText.height);
		add(statusText);

		FlxTween.tween(tip, {x: 0}, 1.5, {ease: FlxEase.sineOut});

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			getStuff();
		});

		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			done = true;
			LoadingState.loadAndSwitchState(new PlayState());
		});
	}
	
	override function update(elapsed:Float)
	{
		
		if (FlxG.keys.justPressed.SPACE)
		{
			LoadingState.loadAndSwitchState(new PlayState());
		}
		peepeepoopoo.angle += 90 * elapsed;
		if (done)
		{
			statusText.text = 'Done!';
		}
		super.update(elapsed);
	}

	function getStuff()
	{
		/*
		for (file in FileSystem.readDirectory('assets/songs/' + Paths.formatToSongPath(PlayState.SONG.song) + "/"))
		{
			files.push(file);
		}
		for (file in FileSystem.readDirectory('assets/shared/images/'))
		{
			if (!FileSystem.isDirectory(file))
			{
				files.push(file);
			}
			else
			{
				for (file2 in FileSystem.readDirectory("assets/shared/images/" + file + "/"))
				{
					files.push(file2);
				}
			}
		}
		for (file in FileSystem.readDirectory('mods/images/'))
		{
			if (!FileSystem.isDirectory(file))
			{
				files.push(file);
			}
		}
		for (file in FileSystem.readDirectory('assets/shared/sounds/'))
		{
			if (!FileSystem.isDirectory(file))
			{
				files.push(file);
			}
		}
		for (file in FileSystem.readDirectory('mods/sounds/'))
		{
			if (!FileSystem.isDirectory(file))
			{
				files.push(file);
			}
		}
		for (i in 1...files.length)
		{
			if (files[i].endsWith("png"))
			{
				var newBitmap:BitmapData = BitmapData.fromFile(files[i]);
			}
			if (files[i].endsWith("ogg"))
			{
				var sound:FlxSound = new FlxSound().loadEmbedded(files[i]);
			}
			if (files[i].endsWith("xml") || files[i].endsWith("txt"))
			{
				var txt:Array<String> = CoolUtil.coolTextFile(files[i]);
			}
		}
		*/
		LimeAssets.loadLibrary("shared");
		files = LimeAssets.list(null);
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
