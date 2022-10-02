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
import flixel.ui.FlxButton;

using StringTools;

class AchievementsMenu extends MusicBeatState
{
	var theAcheiveBox:FlxSprite;
	var theIcon:FlxSprite;

	var theBoxThing:FlxTypedGroup<Dynamic>;
	var shit:FlxTypedGroup<Dynamic>;

	var penis:Acheivement;

	var AchieveList:Array<String>;
	var LockedList:Array<String> = [
		"The Story Begins...",
		"Passion for Art.",
		"Hey look! You are in the credits!",
		"That's how you do it!",
		'She calls me "Daddy" too.',
		"Worst Halloween ever.",
		"A way out",
		"Reunion of the Rivals.",
		"Some night huh...",
		"All is probably well...",
		"MILLIONS to ONE!",
		"It's been 17 days...",
		"Daring today, aren't we?",
		"Hello? Hi.",
		"That'll show 'em!",
		"The Fun Never Ends!",
		"It's Breakin' Time",
		"I think YOU'RE the faker.", 
		"Ring Hoarder",
		"Thanks Lol",
		"Focused",
		"Petscop Kid Very Smart"
	];
	// Now, you're probably wondering; "Why are there 2 lists that contain the achievement names?"
	// Well, When future weeks are added, I don't want to reorganize the origianl list and fit the award functions to that orginazation
	// I just want to add the name to the list and not do anything with it.
	// Now for this list, I provides orginazation!
	// So that's that

	var DescList:Array<String> = [
		"View the Main Menu",
		"View the Doodles Menu",
		"View the Credits Menu",
		"Complete the Tutorial",
		"Complete Week 1",
		"Complete Week 2",
		'Die in "Free Me"',
		"Complete Week 3",
		"Complete Week 4",
		"Complete Week 5",
		"Beat Matto",
		"Beat Fandub Eggman",
		'Emote in "Bopeebo"',
		"V",
		"Beat Eggnog with 0 Combo Breaks",
		"Have Some Fun!",
		"Break Bad",
		"Blue Ball a Faker(?)",
		"Complete a Sonic Stage Without Your Ring Count Dropping To 0",
		'Get a pretty sus ending for V2',
		'Complete "Free Me" without closing any error windows',
		'Ask a very simple question to The Terminal'
	];
	var iconList:Array<String> = [
		"story",
		"artist",
		"credit",
		"gf",
		"dad",
		"spooky",
		"spookyGlitch",
		"pico",
		"mom",
		"winterSpooky",
		"matto",
		"alphred",
		"susBf",
		"spoon",
		"parents",
		"mazin",
		"walart",
		"boyfriend",
		"ring",
		"benntess",
		"spookyGlitch",
		"petscop",
	];

	var theTextThing:FlxText;
	var theDescText:FlxText;
	var BlackBox:FlxSprite;

	var listText:FlxText;

	var curSelected:Int = 0;

	var canPress:Bool = true;

	override public function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('achievements/bg'));
		bg.screenCenter();
		add(bg);

		AchieveList = Acheivement.unlocked;
		// LockedList = Acheivement.acheivements;

		theBoxThing = new FlxTypedGroup<Dynamic>();
		add(theBoxThing);

		var noIcon:FlxSprite = new FlxSprite().loadGraphic(Paths.image('achievements/lockedIcon'));
		noIcon.antialiasing = ClientPrefs.globalAntialiasing;
		add(noIcon);

		theIcon = new FlxSprite().loadGraphic(Paths.image('achievements/noIcon'));
		theIcon.antialiasing = ClientPrefs.globalAntialiasing;

		theTextThing = new FlxText(150 + 8.4, 0, 'AMOGUS', 32);
		theTextThing.setFormat(Paths.font("eras.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		theTextThing.borderSize = 2.4;
		for (i in 0...LockedList.length)
		{
			var hiddenSprite:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.TRANSPARENT);
			hiddenSprite.ID = i;
			theBoxThing.add(hiddenSprite);
		}
		noIcon.screenCenter(Y);
		theIcon.screenCenter(Y);
		theTextThing.screenCenter(Y);

		theDescText = new FlxText(0, (720 / 4) * 3, 'amongus', 24);
		theDescText.font = Paths.font('eras.ttf');
		BlackBox = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		BlackBox.antialiasing = ClientPrefs.globalAntialiasing;
		BlackBox.y = theDescText.y - 10;
		BlackBox.alpha = 0.6;
		add(BlackBox);
		add(theDescText);

		// theBoxThing.add(theTextThing);
		// theBoxThing.add(theIcon);
		add(theTextThing);
		add(theIcon);
		theBoxThing.visible = false;

		// Make List Text LMAO.
		listText = new FlxText(20, 20, 'sussyBaka', 48);
		listText.setFormat(Paths.font('eras.ttf'), 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		listText.text = listTextSet();
		add(listText);

		// Reset Button?
		var resetButton = new FlxButton(FlxG.width - 150, 20, 'RESET', resetPress);
		resetButton.color = FlxColor.RED;
		resetButton.label.font = Paths.font('eras.ttf');
		resetButton.setGraphicSize(150, 75);
		// add(resetButton);

		// Shout out to my math teacher for teaching me math. :)
		var completed:Int = Std.int((AchieveList.length / LockedList.length) * 100);
		completed = Std.int(Math.round(completed));
		var sussyText:FlxText = new FlxText(20, 20 + Std.int(listText.height), 'Progress: ' + Std.string(completed) + '%', 48);
		sussyText.setFormat(Paths.font('eras.ttf'), 48, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(sussyText);

		changeSelection(0);
	}

	override public function update(elapsed:Float)
	{
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP && canPress)
		{
			changeSelection(-1);
		}
		if (downP && canPress)
		{
			changeSelection(1);
		}

		if (controls.BACK && canPress)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}

		if (FlxG.keys.anyJustPressed([R]) && canPress)
		{
			resetPress();
		}
	}

	function changeSelection(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= LockedList.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = LockedList.length - 1;

		FlxG.sound.play(Paths.sound('awardTilt'));

		theDescText.text = DescList[curSelected];
		theTextThing.text = LockedList[curSelected];

		if (AchieveList.contains(LockedList[curSelected]))
		{
			theIcon.visible = true;
			remove(theIcon);
			if (FileSystem.exists(Paths.image('achievements/' + iconList[curSelected])))
				theIcon = new FlxSprite().loadGraphic(Paths.image('achievements/' + iconList[curSelected]));
			else
				theIcon = new FlxSprite().loadGraphic(Paths.image('achievements/noIcon'));
			theIcon.screenCenter(Y);
			theIcon.antialiasing = ClientPrefs.globalAntialiasing;
			add(theIcon);

			if (!ClientPrefs.ukFormat)
				theDescText.text += '\nUnlocked On: ' + Acheivement.dates.get(LockedList[curSelected]);
			else
				theDescText.text += '\nUnlocked On: ' + Acheivement.datesUk.get(LockedList[curSelected]);
		}
		else
		{
			theIcon.visible = false;
		}

		theDescText.text += '\n(Press R to reset ALL achievements)\n'; 

		theBoxThing.forEach(function(balls:FlxSprite)
		{
			if (balls.ID == curSelected)
			{
				theBoxThing.visible = true;
				// trace(LockedList[curSelected]);
			}
			else
			{
				theBoxThing.visible = false;
			}
		});
	}

	function listTextSet()
	{
		var text:String = 'Achievements: ' + AchieveList.length + '/' + LockedList.length;
		if (AchieveList.length == LockedList.length)
		{
			listText.color = FlxColor.YELLOW;
		}
		else
		{
			listText.color = FlxColor.WHITE;
		}
		return text;
	}

	function resetPress()
	{
		persistentUpdate = false;
		openSubState(new AchievementResetSubstate());
	}

	override function closeSubState() {
		persistentUpdate = true;
		super.closeSubState();
	}
}