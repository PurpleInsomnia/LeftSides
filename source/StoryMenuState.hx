package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flixel.tweens.FlxEase;
import flixel.ui.FlxButton;
import WeekData;

using StringTools;

class StoryMenuState extends MusicBeatState
{
	// Wether you have to beat the previous week for playing this one
	// Not recommended, as people usually download your mod for, you know,
	// playing just the modded week then delete it.
	// defaults to True
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	public var scoreText:FlxText;

	private static var curDifficulty:Int = 1;

	var txtWeekTitle:FlxText;
	var bgSprite:FlxSprite;

	private static var curWeek:Int = 0;

	public var txtTracklist:FlxText;

	// var coolswag:WeekFile;
	// dont need it.

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficultyGroup:FlxTypedGroup<FlxSprite>;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var instSpr:FlxSprite;
	var leftArrow2:FlxSprite;
	var rightArrow2:FlxSprite;

	var ratingSpr:FlxSprite;

	var curInst:Int = 0;

	var unlockButton:FlxButton;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end
		WeekData.reloadWeekFiles(true);
		if(curWeek >= WeekData.weeksList.length) curWeek = 0;
		persistentUpdate = persistentDraw = true;

		FlxTransitionableState.skipNextTransIn = false;
		// FlxG.sound.music.stop();

		// FlxG.sound.playMusic(Paths.music('weekMusic/week0'));
		PlayState.songPrefix = "";

		var check:Bool = StateManager.check("story-menu");
		var blackOverlay:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		blackOverlay.scrollFactor.set();

		if (!FlxG.sound.music.playing && !check)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		var bgThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		add(bgThingie);

		bgThingie.color = 0xFF202020;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);
		scoreText.borderStyle = FlxTextBorderStyle.OUTLINE;
		scoreText.borderColor = 0xFF000000;

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.borderStyle = FlxTextBorderStyle.OUTLINE;
		txtWeekTitle.borderColor = 0xFF000000;
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(-40, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		// var bgYellow:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 386, 0xFFF9CF51);
		bgSprite = new FlxSprite();
		bgSprite.antialiasing = ClientPrefs.globalAntialiasing;
		add(bgSprite);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.TRANSPARENT);
		add(blackBarThingie);

		blackBarThingie.y = blackBarThingie.y + bgSprite.height;

		var sideSpikes:FlxSprite = new FlxSprite().loadGraphic(Paths.image('weekSelect/spikes1'));
		sideSpikes.screenCenter();
		sideSpikes.antialiasing = ClientPrefs.globalAntialiasing;
		add(sideSpikes);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var topSpikes:FlxSprite = new FlxSprite().loadGraphic(Paths.image('weekSelect/topSpikes'));
		topSpikes.screenCenter();
		topSpikes.antialiasing = ClientPrefs.globalAntialiasing;

		ClientPrefs.saveSettings();

		var versionShit:FlxText = new FlxText(12, FlxG.height - 18, 0, "Press Enter To Play Selected Week. Press Up Or Down To Change Week.", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		versionShit.screenCenter(X);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[i]));
			var weekThing:MenuItem = new MenuItem(0, 0, WeekData.weeksList[i]);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(Y);

			weekThing.y += (30 * i);

			weekThing.antialiasing = ClientPrefs.globalAntialiasing;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (weekIsLocked(i))
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = ClientPrefs.globalAntialiasing;
				grpLocks.add(lock);
			}
		}

		ratingSpr = new FlxSprite().loadGraphic(Paths.image('storyRATINGS/none'));
		ratingSpr.screenCenter();
		add(ratingSpr);

		WeekData.setDirectoryFromWeek(WeekData.weeksLoaded.get(WeekData.weeksList[0]));
		var charArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[0]).weekCharacters;
		for (char in 0...3)
		{
			var weekCharacterThing:MenuCharacter = new MenuCharacter((FlxG.width * 0.25) * (1 + char) - 150, charArray[char]);
			weekCharacterThing.y += 70;
			weekCharacterThing.y += -56;
			weekCharacterThing.visible = false;
			grpWeekCharacters.add(weekCharacterThing);
		}

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		leftArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(leftArrow);

		sprDifficultyGroup = new FlxTypedGroup<FlxSprite>();

		add(topSpikes);

		add(sprDifficultyGroup);

		for (i in 0...CoolUtil.difficultyStuff.length) {
			var sprDifficulty:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menudifficulties/' + CoolUtil.difficultyStuff[i][0].toLowerCase()));
			sprDifficulty.screenCenter();
			sprDifficulty.visible = false;
			sprDifficulty.ID = i;
			sprDifficulty.antialiasing = ClientPrefs.globalAntialiasing;
			sprDifficultyGroup.add(sprDifficulty);
		}
		changeDifficulty();

		difficultySelectors.add(sprDifficultyGroup);

		rightArrow = new FlxSprite(leftArrow.x + 376, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		rightArrow.antialiasing = ClientPrefs.globalAntialiasing;
		difficultySelectors.add(rightArrow);

		// add(bgYellow);
		// add(grpWeekCharacters);

		var tracksSprite:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('Menu_Tracks'));
		tracksSprite.antialiasing = ClientPrefs.globalAntialiasing;
		tracksSprite.screenCenter(Y);
		tracksSprite.y -= 245;
		add(tracksSprite);

		// trace(tracksSprite.x);
		// needed that for track list alingment

		txtTracklist = new FlxText(0, tracksSprite.y + 60, 0, "", 32);
		// txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		txtTracklist.borderStyle = FlxTextBorderStyle.OUTLINE;
		txtTracklist.borderColor = 0xFFFFD400;
		// txtTracklist.x -= 40;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);
		add(versionShit);

		unlockButton = new FlxButton(0, 0, "", function()
		{
			ClientPrefs.newInventory.set("week-key", ClientPrefs.newInventory.get("week-key") - 1);
			ClientPrefs.saveSettings();
			FlxG.sound.play(Paths.sound("confirmMenu"));
			weekCompleted.set(WeekData.weeksList[curWeek - 1], true);
			FlxG.save.data.weekCompleted = weekCompleted;
			FlxG.save.flush();
			MusicBeatState.switchState(new StoryMenuState());
		});
		unlockButton.loadGraphic(Paths.image("weekSelect/unlock"), true, 150, 150);
		unlockButton.screenCenter(X);
		unlockButton.y = 720 - 150;
		add(unlockButton);

		changeWeek();

		var unlocks:Array<Array<Dynamic>> = [];

		// get new unlocks for returning players
		if (Highscore.getWeekScore("week2", 1) > 0 && SideStorySelectState.storyList[0][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story "Halloween"', 0, 1]);
		}
		if (Highscore.getScore("Doppelganger", 1) > 0 && SideStorySelectState.storyList[1][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story "Saturday"', 1, 1]);
		}
		if (Highscore.getWeekScore("week6", 1) > 0 && SideStorySelectState.storyList[2][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story "Talking"', 2, 1]);
		}
		if (Highscore.getWeekScore("week6", 1) > 0 && !ClientPrefs.unlockedVisit)
		{
			ClientPrefs.unlockedVisit = true;
			ClientPrefs.saveSettings();
			unlocks.push(["Huh?", 'The Side Story: "Visit" (Located in Monster' + "'s" + 'Lair)']);
		}
		if (Highscore.getWeekScore("week3", 1) > 0 && SideStorySelectState.storyList[3][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story "Party Skippers"', 3, 1]);
		}
		if (Highscore.getWeekScore("week5", 1) > 0 && SideStorySelectState.storyList[4][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story "Happy"', 4, 1]);
		}
		if (!ClientPrefs.unlockedRestless && SideStorySelectState.storyList[5][2] != 1 && Highscore.getWeekScore("week5", 1) > 0)
		{
			ClientPrefs.unlockedRestless = true;
			ClientPrefs.saveSettings();
			unlocks.push(["SideStorySelectState", 'The Side Story "Restless"', 5, 1]);
		}
		if (Highscore.getWeekScore("week7", 1) > 0 && SideStorySelectState.storyList[6][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story "Bump In"', 6, 1]);
		}
		if (Highscore.getWeekScore("week8", 1) > 0 && SideStorySelectState.storyList[8][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story: "Worries"', 8, 1]);
		}
		var checks:Array<Bool> = [];
		for (key in ClientPrefs.completedSideStories.keys())
		{
			if (ClientPrefs.completedSideStories.get(key))
			{
				checks.push(true);
			}
			else
			{
				checks.push(false);
			}
		}
		var canUnlock:Bool = true;
		for (i in 0...checks.length)
		{
			if (canUnlock)
			{
				canUnlock = checks[i];
			}
		}
		if (ClientPrefs.week8Done && !ClientPrefs.newUnlocked)
		{
			unlocks.push(["OptionsState", "New Songs In Monster's Lair! (formerly THE VOID)", true]);
		}

		if (unlocks.length > 0 && unlocks[0] != null)
		{
			trace("Unlocking Somethin");
			MusicBeatState.switchState(new UnlockState(unlocks));
			add(blackOverlay);
		}

		if (check)
		{
			add(blackOverlay);
            FlxG.sound.music.stop();
		}

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek();
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 30, 0, 1)));
		if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;

		scoreText.text = "WEEK SCORE:" + lerpScore;

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = !weekIsLocked(curWeek);

		var shift = FlxG.keys.pressed.SHIFT;

		if (!movedBack && !selectedWeek)
		{
			if (controls.UI_UP_P)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_DOWN_P)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', curDifficulty, '', curWeek));
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	var warn:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(curWeek))
		{

			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmStoryMenu'));

				grpWeekText.members[curWeek].startFlashing();
				if(grpWeekCharacters.members[1].character != '') grpWeekCharacters.members[1].animation.play('confirm');
				stopspamming = true;
			}

			warn = false;

			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			PlayState.storyPlaylist = songArray;
			PlayState.isStoryMode = true;
			PlayState.isVoid = false;
			selectedWeek = true;

			ResultsScreen.divNum = songArray.length;

			var diffic = CoolUtil.difficultyStuff[curDifficulty][1];
			if(diffic == null) diffic = '';

			PlayState.storyDifficulty = curDifficulty;

			PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + diffic, PlayState.storyPlaylist[0].toLowerCase());
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			PlayState.campaignMisses = 0;
			PlayState.campaignHits = 0;
			PlayState.campaignGMiss = 0;
			PlayState.campaignRatings = [];
			// storymode changeables
		
			var thingy:Array<String> = [];
			switch (PlayState.storyPlaylist[0].toLowerCase())
			{
				case 'spookeez':
					warn = true;
					thingy = ['Blood', 'Suicide', 'References of Self Harm'];
				case 'cocoa':
					warn = true;
					thingy = ['Blood', 'References of Physical and Mental Abuse', 'References of Suicide'];
			}
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				if (!warn)
				{
					MusicBeatState.switchState(new HealthLossState());
				}
				if (warn)
				{
					if (ClientPrefs.contentWarnings)
						MusicBeatState.switchState(new ContentWarningState(thingy))
					else
						MusicBeatState.switchState(new HealthLossState());
				}
			});
		} else {
			FlxG.sound.play(Paths.sound('nahFam'), 0.5);
		}
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var firstChanged:Bool = false;

	function changeDifficulty()
	{
		var rating:Int = Highscore.getWeekRating(WeekData.weeksList[curWeek], curDifficulty);
		changeRating(rating);
	}

	function changeRating(rating:Int)
	{
		var ratingStr:String = 'none';
		switch(rating)
		{
			case 0:
				ratingStr = 'none';
			case 1:
				ratingStr = 'f';
			case 2:
				ratingStr = 'd';
			case 4:
				ratingStr = 'c';
			case 6:
				ratingStr = 'b';
			case 8:
				ratingStr = 'a';
			case 10:
				ratingStr = 's';
		}

		ratingSpr.loadGraphic(Paths.image('storyRATINGS/' + ratingStr));
	}

	var mainTween:FlxTween;
	var upTween:FlxTween;
	var downTween:FlxTween;
	function changeWeek(change:Int = 0):Void
	{
		if (mainTween != null)
			mainTween.cancel();
		if (upTween != null)
			upTween.cancel();
		if (downTween != null)
			downTween.cancel();

		curWeek += change;

		if (curWeek >= WeekData.weeksList.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = WeekData.weeksList.length - 1;

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		WeekData.setDirectoryFromWeek(leWeek);

		var leName:String = leWeek.storyName;
		txtWeekTitle.text = leName.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// trace('cur week music is Week ' + curWeek);

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && !weekIsLocked(curWeek))
				item.alpha = 1;
			if (item.targetY == Std.int(0) && !weekIsLocked(curWeek))
				mainTween = FlxTween.tween(item, {x: item.width * Std.int(1.5)}, 0.5, {ease: FlxEase.elasticOut});
			if (item.targetY < Std.int(0))
			{
				item.alpha = 0.5;
				upTween = FlxTween.tween(item, {x: 0}, 0.25, {ease: FlxEase.elasticOut});
			}
			if (item.targetY > Std.int(0))
			{
				item.alpha = 0.5;
				downTween = FlxTween.tween(item, {x: 0}, 0.25, {ease: FlxEase.elasticOut});
			}
			bullShit++;
		}

		firstChanged = true;

		bgSprite.visible = true;
		var assetName:String = leWeek.weekBackground;
		if(assetName == null || assetName.length < 1) {
			bgSprite.visible = false;
		} else {
			if (!weekIsLocked(curWeek))
				bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName));
			else
				bgSprite.loadGraphic(Paths.image('menubackgrounds/menu_' + assetName + 'LOCKED'));			
		}

		var pp:Array<String> = [];
		if (WeekData.weeksList[0] == "tutorial")
		{
			switch(curWeek)
			{
				case 2:
					pp = ["Spookeez", "Treats And Tricks", "South"];
				case 5:
					pp = ["Cocoa", "Eggnog"];
				case 7:
					// LMFAOOOO FUCKING EPIC PRANK XDDDDDSDSDSDS
					pp = ["Ugh", "Guns", "Stress"];
			}
		}

		if (weekIsLocked(curWeek) && ClientPrefs.inventory[0][1] > 0)
		{
			FlxG.mouse.visible = true;
			unlockButton.visible = true;
		}
		else
		{
			FlxG.mouse.visible = false;
			unlockButton.visible = false;
		}

		if (pp.length != 0)
			updateText(pp);
		else
			updateText([]);
	}

	function weekIsLocked(weekNum:Int) {
		if (ClientPrefs.devMode)
		{
			return false;
		}
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}

	function updateText(?hideSong:Array<String>)
	{
		var weekArray:Array<String> = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]).weekCharacters;
		for (i in 0...grpWeekCharacters.length) {
			grpWeekCharacters.members[i].changeCharacter(weekArray[i]);
		}

		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[curWeek]);
		var stringThing:Array<String> = [];
		for (i in 0...leWeek.songs.length) {
			stringThing.push(leWeek.songs[i][0]);
		}

		txtTracklist.text = '';
		if (hideSong.length == 0)
		{
			for (i in 0...stringThing.length)
			{
				txtTracklist.text += stringThing[i] + '\n';
			}
		}
		else
		{
			for (i in 0...hideSong.length)
			{
				txtTracklist.text += hideSong[i] + '\n';
			}
		}

		txtTracklist.text = txtTracklist.text.toUpperCase();

		var rating:Int = Highscore.getWeekRating(WeekData.weeksList[curWeek], curDifficulty);
		changeRating(rating);

		#if !switch
		intendedScore = Highscore.getWeekScore(WeekData.weeksList[curWeek], curDifficulty);
		#end
	}
}
