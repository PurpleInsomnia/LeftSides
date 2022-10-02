package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;

using StringTools;

class VoidHighscoreState extends MusicBeatState
{
	var songs:Array<String> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	private static var curDifficulty:Int = 1;

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	public static var daScore:Int;

	var canPress:Bool = false;

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

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.reloadWeekFiles(false);
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Viewing Score in the void...", null);
		#end

		FlxG.sound.music.stop();

		FlxG.sound.play(Paths.sound('voidWelcome'));

		FlxG.sound.playMusic(Paths.music('void'));

		bg = new FlxSprite().loadGraphic(Paths.image('void/theVOID'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.screenCenter();
		add(bg);

		var sex:GridBackdrop = new GridBackdrop();
		sex.blend = BlendMode.MULTIPLY;
		add(sex);

		var pp:FlxSprite = new FlxSprite().loadGraphic(Paths.image('void/shader'));
		pp.antialiasing = ClientPrefs.globalAntialiasing;
		pp.blend = BlendMode.DARKEN;
		pp.screenCenter();
		add(pp);

		grpSongs = new FlxTypedGroup<AlphabetCool>();
		add(grpSongs);

		// alphabet vars
		var text1:AlphabetCool = new AlphabetCool(0, 70, 'Well Done...', true, false);
		text1.isMenuItem = true;
		text1.screenCenter(X);
		text1.forceX = text1.x;
		FlxG.sound.play(Paths.sound('voidSting'));
		grpSongs.add(text1);
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			var text2:AlphabetCool = new AlphabetCool(0, 140, 'Your Score Is', true, false);
			text2.isMenuItem = true;
			text2.screenCenter();
			text2.forceX = text2.x;
			text1.visible = false;
			FlxG.sound.play(Paths.sound('voidSting'));
			grpSongs.add(text2);
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				var text3:AlphabetCool = new AlphabetCool(0, text2.y + 70, daScore, true, false);
				text3.isMenuItem = true;
				text3.screenCenter(X);
				text3.forceX = text3.x;
				text2.visible = false;
				FlxG.sound.play(Paths.sound('confirmStoryMenu'));
				grpSongs.add(text3);
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					var text4:AlphabetCool = new AlphabetCool(0, 720 - 140, 'Press ENTER to continue', true, false);
					text4.isMenuItem = true;
					text4.screenCenter(X);
					text4.forceX = text4.x;
					text3.visible = false;
					FlxG.sound.play(Paths.sound('voidSting'));
					grpSongs.add(text4);
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						canPress = true;
					});
				});
			});
		});
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		var acceptedShitBalls = controls.ACCEPT;

		if (acceptedShitBalls && canPress)
		{
			FlxG.sound.play(Paths.sound('voidWARP'));
			canPress = false;

			FlxG.camera.fade(FlxColor.WHITE, 1, false, function()
			{
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					FlxG.sound.music.stop();
					MusicBeatState.switchState(new VoidState());
				});
			});

			FlxG.sound.music.volume = 0;
		}
		super.update(elapsed);
	}
}