package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import sys.FileSystem;

using StringTools;

class Acheivement extends FlxTypedGroup<Dynamic>
{
	public static var unlocked:Array<String> = [];
	var locked:Array<String> = [];
	// locked is unused but might not be later.

	#if (haxe >= "4.0.0")
	public static var dates:Map<String, String> = new Map();
	public static var datesUk:Map<String, String> = new Map();
	#else
	public static var dates:Map<String, String> = new Map<String, String>();
	public static var datesUk:Map<String, String> = new Map<String, String>();
	#end

	public static var acheivements:Array<String> = [
		"The Story Begins...", // 0
		"Passion for Art.", // 1
		"Hey look! You are in the credits!", // 2
		"That's how you do it!", // 3
		'She calls me "Daddy" too.', // 4
		"Worst Halloween ever.", // 5
		"Reunion of the Rivals.", // 6
		"Some night huh...", // 7
		"All is probably well...", // 8
		// song specific acheivements
		"MILLIONS to ONE!", // 9 (Beat Matto)
		"It's been 17 days...", // 10 (Beat Fandub Eggman)
		"Daring today, aren't we?", // 11 (Emote durring bopeebo)
		"Hello? Hi.", // start up "Dmitri" 12
		"That'll show 'em!", // Finish Eggnog with 0 misses 13
		"The Fun Never Ends!", // Beat Mazin Sonic 14
		"It's Breakin' Time", // Beat Walt with no combo breaks. 15
		"I think YOU'RE the faker.", // 16
		"Ring Hoarder", // 17
		"Focused", // 18 Beat Free Me without closing ANY tabs
		"A way out", // 19
		"Thanks Lol", // 20
		"Petscop Kid Very Smart" // 21
	];

	var theAcheiveBox:FlxSprite;
	var theIcon:FlxSprite;

	var theBoxThing:FlxTypedGroup<Dynamic>;

	public function new(num:Int, desc:String, icon:String, ?camera:FlxCamera = null)
	{
		super();
		if (!unlocked.contains(acheivements[num]))
		{
			theBoxThing = new FlxTypedGroup<Dynamic>();
			add(theBoxThing);

			var theTextThing:FlxText = new FlxText(150 + 2, 0, acheivements[num], 14);
			var theDescText:FlxText = new FlxText(150 + 2, theTextThing.height + 2, desc, 12);

			theAcheiveBox = new FlxSprite().makeGraphic(420, 230, FlxColor.BLACK);
			theAcheiveBox.alpha = 0.6;

			if (FileSystem.exists(Paths.image('achievements/' + icon)))
			{
				theIcon = new FlxSprite().loadGraphic(Paths.image('achievements/' + icon));
			}
			else
			{
				theIcon = new FlxSprite().loadGraphic(Paths.image('achievements/noIcon'));
			}

			theTextThing.scrollFactor.set(0, 0);
			theDescText.scrollFactor.set(0, 0);
			theAcheiveBox.scrollFactor.set(0, 0);
			theIcon.scrollFactor.set(0, 0);

			theBoxThing.add(theAcheiveBox);
			theBoxThing.add(theTextThing);
			theBoxThing.add(theDescText);
			theBoxThing.add(theIcon);

			var cam:Array<FlxCamera> = FlxCamera.defaultCameras;
			if (camera != null)
			{
				cam = [camera];
			}

			theBoxThing.cameras = cam;

			// awards the thing
			unlocked.push(acheivements[num]);
			trace(unlocked);

			trace(acheivements[num] + ' is now unlocked!');

			FlxG.sound.play(Paths.sound('award'));

			var dumb = Date.now();
			var thaDate:String;
			var thaDateUk:String;

			var month:Int = Std.int(dumb.getMonth() + 1);

			thaDate = Std.string(dumb.getMonth() + 1 + '/' + dumb.getDate() + '/' + dumb.getFullYear());
			thaDateUk = Std.string(dumb.getDate() + '/' + month + '/' + dumb.getFullYear());

			thaDate += Std.string(' ' + dumb.getHours() + ':' + dumb.getMinutes());
			thaDateUk += Std.string(' ' + dumb.getHours() + ':' + dumb.getMinutes());

			saveUnlocks();
			saveDate(acheivements[num], thaDate);
			saveDateUk(acheivements[num], thaDateUk);

			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				FlxTween.tween(theAcheiveBox, {alpha: 0}, 0.5);
				FlxTween.tween(theDescText, {alpha: 0}, 0.5);
				FlxTween.tween(theTextThing, {alpha: 0}, 0.5);
				FlxTween.tween(theIcon, {alpha: 0}, 0.5);
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					remove(theBoxThing);
				});
			});
		}
		else
		{
			trace(acheivements[num] + ' is already unlocked!');
		}
	}

	// used for other things lmao.
	public function clearData()
	{
		// no more fortnite
		trace('deleting achievement save data....');
		unlocked = [];
		ClientPrefs.achievementUnlocked = unlocked;
		saveUnlocks();
	}

	public static function loadShit()
	{
		unlocked = ClientPrefs.achievementUnlocked;
		var saved:Array<String> = unlocked;
		unlocked = saved;
		ClientPrefs.achievementUnlocked = saved;

		// unlocked = FlxG.save.data.unlocked;
	}

	public function saveUnlocks()
	{
		ClientPrefs.achievementUnlocked = unlocked;
		unlocked = ClientPrefs.achievementUnlocked;
		ClientPrefs.saveSettings();
		loadShit();
		// aughhhhhhhhhhhhhhhhhhhhhhhh
	}

	public static function saveDate(name:String, date:String)
	{
		dates.set(name, date);
		FlxG.save.data.dates = dates;
		FlxG.save.flush();
	}

	public static function saveDateUk(name:String, date:String)
	{
		datesUk.set(name, date);
		FlxG.save.data.datesUk = datesUk;
		FlxG.save.flush();
	}

	public static function loadDates()
	{
		if (FlxG.save.data.dates != null)
		{
			dates = FlxG.save.data.dates;
		}
		if (FlxG.save.data.datesUk != null)
		{
			datesUk = FlxG.save.data.datesUk;
		}
	}

	public static function saveAllDates()
	{
		FlxG.save.data.dates = dates;
		FlxG.save.data.datesUk = datesUk;
		FlxG.save.flush();
	}
}