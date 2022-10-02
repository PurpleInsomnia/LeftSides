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
import sys.FileSystem;

using StringTools;

class LoadingScreenState extends MusicBeatState
{
	private var camGame:FlxCamera;

	var peepeepoopoo:LoadingSpr;

	var files:Array<String> = [];

	var statusText:FlxText;

	var done:Bool = false;

	var pushedFiles:Bool = false;

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

		pushedFiles = false;

		FlxG.sound.music.stop();

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		peepeepoopoo = new LoadingSpr();
		add(peepeepoopoo);

		statusText = new FlxText(0, 0, 'Loading...', 24);
		statusText.font = Paths.font('eras.ttf');
		statusText.y = Std.int(FlxG.height - statusText.height);
		add(statusText);

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


		if (pushedFiles && !done)
		{
			statusText.text = 'Loading (' + files[files.length - 1] + ')...';
		}
		if (done)
		{
			statusText.text = 'Done!';
		}
		super.update(elapsed);
	}

	function getStuff()
	{
		return Paths.inst(PlayState.SONG.song);
		if (PlayState.encoreMode)
			return Paths.instEncore(PlayState.SONG.song);
		if (PlayState.SONG.needsVoices)
			return Paths.voices(PlayState.SONG.song);
		if (PlayState.SONG.needsVoices && PlayState.encoreMode)
			return Paths.voicesEncore(PlayState.SONG.song);

		pushedFiles = true;

		for (file in FileSystem.readDirectory('assets/shared/images/'))
		{
			files.push(file);
		}
		for (file in FileSystem.readDirectory('mods/images/'))
		{
			files.push(file);
		}
		for (file in FileSystem.readDirectory('assets/shared/sounds/'))
		{
			files.push(file);
		}
		for (file in FileSystem.readDirectory('mods/sounds/'))
		{
			files.push(file);
		}
		for (file in FileSystem.readDirectory('mods/' + Paths.currentModDirectory + '/images/'))
		{
			files.push(file);
		}
		for (file in FileSystem.readDirectory('mods/' + Paths.currentModDirectory + '/sounds/'))
		{
			files.push(file);
		}
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
