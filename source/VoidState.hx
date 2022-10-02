package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.tweens.FlxEase;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;

using StringTools;

class VoidState extends MusicBeatState
{
	var songs:Array<String> = [
		'Remember My Name',
		'Limitless Fun',
		'Dense',
		'Crackin Eggs',
		'Doppelganger'
	];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var isDown:Bool = true;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var canPress:Bool = true;

	public static var textFileThing:String;

	private var grpSongs:FlxTypedGroup<AlphabetCool>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var record:FlxSprite;
	var spikesFg:FlxSprite;
	var centerRecord:FlxSprite;
	var vandalFg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var fallin:FlxSprite;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.reloadWeekFiles(false);
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Void", null);
		#end

		FlxG.sound.music.stop();

		FlxG.sound.play(Paths.sound('voidWelcome'));

		if (ClientPrefs.foundDmitri)
			songs.push('V');

		for (song in songs) {
			// addSong(song);
			// pretty sure this does nothing
		}

		add(new GridBackdrop());

		bg = new FlxSprite().loadGraphic(Paths.image('void/theVOID'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.blend = BlendMode.MULTIPLY; 
		add(bg);

		grpSongs = new FlxTypedGroup<AlphabetCool>();
		add(grpSongs);

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('void'));
		}

		for (i in 0...songs.length)
		{
			var songText:AlphabetCool = new AlphabetCool(0, (70 * i) + 30, songs[i], true, false);
			songText.isMenuItem = true;
			songText.screenCenter(X);
			songText.forceX = songText.x;
			// songText.y += (100 * (i - (songText.length / 2))) + 50;
			songText.targetY = i;
			grpSongs.add(songText);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		if(curSelected >= songs.length) curSelected = 0;
		changeSelection();

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	override function closeSubState() {
		changeSelection();
		super.closeSubState();
	}

	var instPlaying:Int = -1;
	private static var vocals:FlxSound = null;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var space = FlxG.keys.justPressed.SPACE;

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (upP && canPress)
		{
			changeSelection(-shiftMult);
		}
		if (downP && canPress)
		{
			changeSelection(shiftMult);
		}

		if (controls.BACK && canPress)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.music.stop();
		}

		if (accepted && canPress)
		{
			FlxG.sound.play(Paths.sound('voidWARP'));
			canPress = false;

			var songLowercase:String = Paths.formatToSongPath(songs[curSelected]);
			var poop:String = 'normal';
			#if MODS_ALLOWED
			if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}
			trace(poop);

			PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 1;

			PlayState.storyWeek = 0;
			PlayState.isVoid = true;
			FlxG.camera.fade(FlxColor.WHITE, 1, false, function()
			{
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					FlxG.sound.music.stop();
					MusicBeatState.switchState(new HealthLossState());
				});
			});

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
		}
		super.update(elapsed);
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('sonicTilt'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}