package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import Controls;

using StringTools;

class ClientPrefs {
	//TO DO: Redo ClientPrefs in a way that isn't too stupid
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = false;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var framerate:Int = 60;
	public static var swearFilter:Bool = false;
	public static var violence:Bool = true;
	public static var jumpscares:Bool = true;
	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var noteOffset:Int = 0;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var imagesPersist:Bool = false;
	public static var ghostTapping:Bool = true;
	public static var hideTime:Bool = false;


	public static var camMove:Bool = true;
	public static var doubShake:Bool = true;
	public static var bgSprite:String = 'starscape';
	public static var pauseMusic:String = 'breakfast';
	public static var closeSound:String = 'dialogueClose';
	public static var showComboSpr:Bool = true;
	public static var shaders:Bool = true;
	public static var week8Done:Bool = false;
	public static var setControls:Bool = false;
	public static var foundDmitri:Bool = false;
	public static var arcadeUnlocked:Bool = false;
	public static var dialogueVoices:Bool = true;
	public static var babyShitPiss:Bool = false;
	public static var justDont:Bool = true;
	public static var colorblind:String = 'Off';
	public static var customStrum:String = 'Off';
	public static var customBar:String = 'Default';
	public static var isCustomBar:Bool = false;
	public static var customRating:String = 'Default';
	public static var muteMiss:Bool = true;
	public static var ukFormat:Bool = false;
	public static var noStages:Bool = false;
	public static var contentWarnings:Bool = false;
	public static var defaultSaveFile:SaveFile;
	public static var createdFile:Bool = false;
	public static var showUsername:Bool = true;
	public static var discord:Bool = true;
	public static var newUnlocked:Bool = false;
	public static var preferedDimens:String = "1280 x 720";
	public static var devMode:Bool = false;
	public static var chartingMode:Bool = false;
	public static var screenShake:Bool = true;
	public static var customStrumFile:String = "";
	public static var customSplashFile:String = "";
	public static var timeColour:String = "Gradient & Black";
	public static var strumHealth:Bool = true;
	public static var bloom:Bool = true;
	public static var precacheCharacters:Bool = false;
	public static var limitedHud:Bool = false;
	public static var unlockedRestless:Bool = false;
	public static var lowQualitySongs:Bool = false;
	public static var iconStyle:String = "Default";
	public static var iconGlows:Bool = true;
	public static var playSoundOnNoteHit:Bool = false;
	public static var hitSoundVolume:Float = 1;

	public static var lostGame:Bool = false;
	public static var unlockedArchives:Bool = false;
	public static var unlockedVisit:Bool = false;

	public static var clickedClub:Bool = false;
	public static var fcTutorial:Bool = false;

	public static var debugCheck:Bool = false;

	public static var usePNAsUser:Bool = false;

	#if (haxe >= "4.0.0")
	public static var completedSideStories:Map<String, Bool> = new Map();
	public static var useless:Map<String, Bool> = new Map();
	#else
	public static var completedSideStories:Map<String, Bool> = new Map<String, Bool>();
	public static var useless:Map<String, Bool> = new Map<String, Bool>();
	#end


	#if (haxe >= "4.0.0")
	public static var luaSave:Map<String, Dynamic> = new Map();
	public static var customPrefs:Map<String, Dynamic> = new Map();
	#else
	public static var luaSave:Map<String, Dynamic> = new Map<String, Dynamic>();
	public static var customPrefs:Map<String, Dynamic> = new Map<String, Dynamic>();
	#end

	public static var gameJoltLogin:Array<String> = ["", ""];

	// shop shit :/
	public static var points:Int = 0;
	/**
	 * KEY: Tag, Amount.
	 * I'm still using this variable for backending some shit...
	 */
	public static var inventory:Array<Array<Dynamic>> = [];

	#if (haxe >= "4.0.0")
	public static var newInventory:Map<String, Dynamic> = new Map();
	#else
	public static var newInventory:Map<String, Dynamic> = new Map<String, Dynamic>();
	#end
	public static var lastShop:Bool = false;
	public static var itemUnlocks:Array<Bool> = [false, false];

	public static var defaultKeys:Array<FlxKey> = [
		A, LEFT,			//Note Left
		S, DOWN,			//Note Down
		W, UP,				//Note Up
		D, RIGHT,			//Note Right

		A, LEFT,			//UI Left
		S, DOWN,			//UI Down
		W, UP,				//UI Up
		D, RIGHT,			//UI Right

		R, NONE,			//Reset
		ENTER, Z,		//Accept
		BACKSPACE, ESCAPE,	//Back
		ENTER, ESCAPE,		//Pause
		SHIFT, NONE	//Emote (I just got demons, cumming inside me)
	];
	//Every key has two binds, these binds are defined on defaultKeys! If you want your control to be changeable, you have to add it on ControlsSubState (inside OptionsState)'s list
	public static var keyBinds:Array<Dynamic> = [
		//Key Bind, Name for ControlsSubState
		[Control.NOTE_LEFT, 'Left'],
		[Control.NOTE_DOWN, 'Down'],
		[Control.NOTE_UP, 'Up'],
		[Control.NOTE_RIGHT, 'Right'],

		[Control.UI_LEFT, 'Left '],		//Added a space for not conflicting on ControlsSubState
		[Control.UI_DOWN, 'Down '],		//Added a space for not conflicting on ControlsSubState
		[Control.UI_UP, 'Up '],			//Added a space for not conflicting on ControlsSubState
		[Control.UI_RIGHT, 'Right '],	//Added a space for not conflicting on ControlsSubState

		[Control.RESET, 'Reset'],
		[Control.ACCEPT, 'Accept'],
		[Control.BACK, 'Back'],
		[Control.PAUSE, 'Pause'],
		[Control.EMOTE, 'Taunt']
	];
	public static var lastControls:Array<FlxKey> = defaultKeys.copy();

	public static function saveSettings() {
		FlxG.save.data.downScroll = downScroll;
		FlxG.save.data.middleScroll = middleScroll;
		FlxG.save.data.showFPS = showFPS;
		FlxG.save.data.flashing = flashing;
		FlxG.save.data.globalAntialiasing = globalAntialiasing;
		FlxG.save.data.noteSplashes = noteSplashes;
		FlxG.save.data.lowQuality = lowQuality;
		FlxG.save.data.framerate = framerate;
		FlxG.save.data.swearFilter = swearFilter;
		FlxG.save.data.violence = violence;
		FlxG.save.data.camZooms = camZooms;
		FlxG.save.data.noteOffset = noteOffset;
		FlxG.save.data.hideHud = hideHud;
		FlxG.save.data.arrowHSV = arrowHSV;
		FlxG.save.data.imagesPersist = imagesPersist;
		FlxG.save.data.ghostTapping = ghostTapping;
		FlxG.save.data.hideTime = hideTime;
		FlxG.save.data.jumpscares = jumpscares;
		FlxG.save.data.camMove = camMove;
		FlxG.save.data.doubShake = doubShake;
		FlxG.save.data.bgSprite = bgSprite;
		FlxG.save.data.pauseMusic = pauseMusic;
		FlxG.save.data.closeSound = closeSound;
		FlxG.save.data.showComboSpr = showComboSpr;
		FlxG.save.data.shaders = shaders;
		FlxG.save.data.dialogueVoices = dialogueVoices;
		FlxG.save.data.babyShitPiss = babyShitPiss;
		FlxG.save.data.colorblind = colorblind;
		FlxG.save.data.customStrum = customStrum;
		FlxG.save.data.customBar = customBar;
		FlxG.save.data.isCustomBar = isCustomBar;
		FlxG.save.data.customRating = customRating;
		FlxG.save.data.muteMiss = muteMiss;
		FlxG.save.data.ukFormat = ukFormat;
		FlxG.save.data.justDont = justDont;
		FlxG.save.data.week8Done = week8Done;
		FlxG.save.data.setControls = setControls;
		FlxG.save.data.foundDmitri = foundDmitri;
		FlxG.save.data.arcadeUnlocked = arcadeUnlocked;
		FlxG.save.data.noStages = noStages;
		FlxG.save.data.contentWarnings = contentWarnings;
		FlxG.save.data.createdFile = createdFile;
		FlxG.save.data.defaultSaveFile = defaultSaveFile;
		FlxG.save.data.showUsername = showUsername;
		#if desktop
		FlxG.save.data.discord = discord;
		#end
		FlxG.save.data.newUnlocked = newUnlocked;
		FlxG.save.data.preferedDimens = preferedDimens;
		FlxG.save.data.devMode = devMode;
		FlxG.save.data.chartingMode = chartingMode;
		FlxG.save.data.screenShake = screenShake;
		FlxG.save.data.customStrumFile = CustomStrum.strum;
		FlxG.save.data.customSplashFile = CustomStrum.splash;
		FlxG.save.data.timeColour = timeColour;
		FlxG.save.data.strumHealth = strumHealth;
		FlxG.save.data.customPrefs = CustomClientPrefs.saved;
		FlxG.save.data.bloom = bloom;
		FlxG.save.data.limitedHud = limitedHud;
		FlxG.save.data.unlockedRestless = unlockedRestless;
		FlxG.save.data.lowQualitySongs = lowQualitySongs;
		FlxG.save.data.iconStyle = iconStyle;
		FlxG.save.data.iconGlows = iconGlows;
		FlxG.save.data.playSoundOnNoteHit = playSoundOnNoteHit;
		FlxG.save.data.hitSoundVolume = hitSoundVolume;

		FlxG.save.data.lostGame = lostGame;
		FlxG.save.data.unlockedArchives = unlockedArchives;
		FlxG.save.data.unlockedVisit = unlockedVisit;

		FlxG.save.data.clickedClub = clickedClub;
		FlxG.save.data.fcTutorial = fcTutorial;
		FlxG.save.data.customChars = PlayState.customChars;
		FlxG.save.data.curSelectedChars = CoolUtil.curSelectedChars;

		FlxG.save.data.debugCheck = debugCheck;
		FlxG.save.data.usePNAsUser = usePNAsUser;

		// precache
		FlxG.save.data.precacheCharacters = precacheCharacters;

		// states bullshit :)
		FlxG.save.data.preferedHL = HealthLossState.preferedHL;

		FlxG.save.data.luaSave = luaSave;

		FlxG.save.data.gameJoltLogin = gameJoltLogin;

		FlxG.save.data.points = points;
		FlxG.save.data.inventory = inventory;
		FlxG.save.data.lastShop = lastShop;
		FlxG.save.data.itemUnlocks = itemUnlocks;
		FlxG.save.data.newInventory = newInventory;

		FlxG.save.data.completedSideStories = completedSideStories;
		FlxG.save.data.useless = useless;

		FlxG.save.flush();

		SideStorySelectState.save();

		var save:FlxSave = new FlxSave();
		save.bind('controls', 'ninjamuffin99'); //Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		save.data.customControls = lastControls;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static function loadPrefs() {
		if(FlxG.save.data.downScroll != null) {
			SaveFileStartState.existingSaveData = true;
			downScroll = FlxG.save.data.downScroll;
		}
		if(FlxG.save.data.middleScroll != null) {
			middleScroll = FlxG.save.data.middleScroll;
		}
		if(FlxG.save.data.showFPS != null) {
			showFPS = FlxG.save.data.showFPS;
			if(Main.fpsVar != null) {
				Main.fpsVar.visible = showFPS;
			}
		}
		if(FlxG.save.data.flashing != null) {
			flashing = FlxG.save.data.flashing;
		}
		if(FlxG.save.data.globalAntialiasing != null) {
			globalAntialiasing = FlxG.save.data.globalAntialiasing;
		}
		if(FlxG.save.data.noteSplashes != null) {
			noteSplashes = FlxG.save.data.noteSplashes;
		}
		if(FlxG.save.data.lowQuality != null) {
			lowQuality = FlxG.save.data.lowQuality;
		}
		if(FlxG.save.data.framerate != null) {
			framerate = FlxG.save.data.framerate;
			if(framerate > FlxG.drawFramerate) {
				FlxG.updateFramerate = framerate;
				FlxG.drawFramerate = framerate;
			} else {
				FlxG.drawFramerate = framerate;
				FlxG.updateFramerate = framerate;
			}
		}
		if(FlxG.save.data.swearFilter != null) {
			swearFilter = FlxG.save.data.swearFilter;
		}
		/*if(FlxG.save.data.violence != null) {
			violence = FlxG.save.data.violence;
		}*/
		if(FlxG.save.data.camZooms != null) {
			camZooms = FlxG.save.data.camZooms;
		}
		if(FlxG.save.data.jumpscares != null) {
			jumpscares = FlxG.save.data.jumpscares;
		}
		if(FlxG.save.data.hideHud != null) {
			hideHud = FlxG.save.data.hideHud;
		}
		if(FlxG.save.data.noteOffset != null) {
			noteOffset = FlxG.save.data.noteOffset;
		}
		if(FlxG.save.data.arrowHSV != null) {
			arrowHSV = FlxG.save.data.arrowHSV;
		}
		if(FlxG.save.data.imagesPersist != null) {
			imagesPersist = FlxG.save.data.imagesPersist;
			FlxGraphic.defaultPersist = ClientPrefs.imagesPersist;
		}
		if(FlxG.save.data.ghostTapping != null) {
			ghostTapping = FlxG.save.data.ghostTapping;
		}
		if(FlxG.save.data.hideTime != null) {
			hideTime = FlxG.save.data.hideTime;
		}
		if(FlxG.save.data.camMove != null) {
			camMove = FlxG.save.data.camMove;
		}
		if(FlxG.save.data.doubShake != null) {
			doubShake = FlxG.save.data.doubShake;
		}
		if(FlxG.save.data.showComboSpr != null) {
			showComboSpr = FlxG.save.data.showComboSpr;
		}
		if(FlxG.save.data.shaders != null) 
		{
			shaders = FlxG.save.data.shaders;
		}
		if(FlxG.save.data.dialogueVoices != null) {
			dialogueVoices = FlxG.save.data.dialogueVoices;
		}
		if(FlxG.save.data.babyShitPiss != null) {
			babyShitPiss = FlxG.save.data.babyShitPiss;
		}
		if(FlxG.save.data.justDont != null) {
			justDont = FlxG.save.data.justDont;
		}
		if (FlxG.save.data.colorblind != null) {
			colorblind = FlxG.save.data.colorblind;
		}
		if (FlxG.save.data.customStrum != null) {
			customStrum = FlxG.save.data.customStrum;
		}
		if (FlxG.save.data.customBar != null) 
		{
			customBar = FlxG.save.data.customBar;
			isCustomBar = FlxG.save.data.isCustomBar;
			if (customBar == "Sonic Spikes" && !isCustomBar)
			{
				customBar = "Default";
			}
		}
		if (FlxG.save.data.customRating != null) {
			customRating = FlxG.save.data.customRating;
		}
		if (FlxG.save.data.muteMiss != null) {
			muteMiss = FlxG.save.data.muteMiss;
		}
		if (FlxG.save.data.ukFormat != null) {
			ukFormat = FlxG.save.data.ukFormat;
		}
		if (FlxG.save.data.noStages != null) {
			noStages = FlxG.save.data.noStages;
		}
		if (FlxG.save.data.contentWarnings != null) {
			contentWarnings = FlxG.save.data.contentWarnings;
		}
		if (FlxG.save.data.showUsername != null)
		{
			showUsername = FlxG.save.data.showUsername;
		}
		#if desktop
		if (FlxG.save.data.discord != null) {
			discord = FlxG.save.data.discord;
		}
		#end
		if (FlxG.save.data.newUnlocked != null)
		{
			newUnlocked = FlxG.save.data.newUnlocked;
		}
		if (FlxG.save.data.preferedDimens != null)
		{
			preferedDimens = FlxG.save.data.preferedDimens;
		}
		if (FlxG.save.data.devMode != null)
		{
			devMode = FlxG.save.data.devMode;
		}
		if (FlxG.save.data.chartingMode != null)
		{
			chartingMode = FlxG.save.data.chartingMode;
		}
		if (FlxG.save.data.screenShake != null)
		{
			screenShake = FlxG.save.data.screenShake;
		}
		if (FlxG.save.data.customStrumFile != null)
		{
			CustomStrum.strum = FlxG.save.data.customStrumFile;
		}
		if (FlxG.save.data.customSplashFile != null)
		{
			CustomStrum.splash = FlxG.save.data.customSplashFile;
		}
		if (FlxG.save.data.timeColour != null)
		{
			timeColour = FlxG.save.data.timeColour;
		}
		if (FlxG.save.data.strumHealth != null)
		{
			strumHealth = FlxG.save.data.strumHealth;
		}
		if (FlxG.save.data.luaSave != null)
		{
			luaSave = FlxG.save.data.luaSave;
		}
		if (FlxG.save.data.customPrefs != null)
		{
			customPrefs = FlxG.save.data.customPrefs;
			CustomClientPrefs.saved = FlxG.save.data.customPrefs;
		}
		if (FlxG.save.data.preferedHL != null)
		{
			HealthLossState.preferedHL = FlxG.save.data.preferedHL;
		}
		if (FlxG.save.data.bloom != null)
		{
			bloom = FlxG.save.data.bloom;
		}
		if (FlxG.save.data.precacheCharacters != null)
		{
			precacheCharacters = FlxG.save.data.precacheCharacters;
		}
		if (FlxG.save.data.limitedHud != null)
		{
			limitedHud = FlxG.save.data.limitedHud;
		}
		if (FlxG.save.data.lastShop != null)
		{
			lastShop = FlxG.save.data.lastShop;
		}
		if (FlxG.save.data.unlockedRestless != null)
		{
			unlockedRestless = FlxG.save.data.unlockedRestless;
		}
		if (FlxG.save.data.lowQualitySongs != null)
		{
			lowQualitySongs = FlxG.save.data.lowQualitySongs;
		}
		if (FlxG.save.data.iconStyle != null)
		{
			iconStyle = FlxG.save.data.iconStyle;
		}
		if (FlxG.save.data.iconGlows != null)
		{
			iconGlows = FlxG.save.data.iconGlows;
		}
		if (FlxG.save.data.playSoundOnNoteHit != null)
		{
			playSoundOnNoteHit = FlxG.save.data.playSoundOnNoteHit;
		}
		if (FlxG.save.data.hitSoundVolume != null)
		{
			hitSoundVolume = FlxG.save.data.hitSoundVolume;
		}

		if (FlxG.save.data.clickedClub != null)
		{
			clickedClub = FlxG.save.data.clickedClub;
		}
		if (FlxG.save.data.fcTutorial != null)
		{
			fcTutorial = FlxG.save.data.fcTutorial;
		}
		if (FlxG.save.data.customChars != null)
		{
			PlayState.customChars = FlxG.save.data.customChars;
		}
		if (FlxG.save.data.curSelectedChars != null)
		{
			CoolUtil.curSelectedChars = FlxG.save.data.curSelectedChars;
		}
		if (FlxG.save.data.lostGame != null)
		{
			lostGame = FlxG.save.data.lostGame;
		}
		if (FlxG.save.data.unlockedArchives != null)
		{
			unlockedArchives = FlxG.save.data.unlockedArchives;
		}
		if (FlxG.save.data.unlockedVisit != null)
		{
			unlockedVisit = FlxG.save.data.unlockedVisit;
		}
		if (FlxG.save.data.debugCheck != null)
		{
			debugCheck = FlxG.save.data.debugCheck;
		}
		if (FlxG.save.data.usePNAsUser != null)
		{
			usePNAsUser = FlxG.save.data.usePNAsUser;
		}


		if (FlxG.save.data.completedSideStories != null)
		{
			completedSideStories = FlxG.save.data.completedSideStories;
		}
		else
		{
			completedSideStories = [
				"halloween" => {
					false;
				},
				"saturday" => {
					false;
				},
				"talking" => {
					false;
				},
				"visit" => {
					false;
				},
				"party-skip" => {
					false;
				},
				"happy" => {
					false;
				},
				"restless" => {
					false;
				},
				"bump" => {
					false;
				},
				"that-day" => {
					false;
				},
				"isolation" => {
					false;
				},
				"worries" => {
					false;
				}
			];
		}
		if (FlxG.save.data.useless != null)
		{
			useless = FlxG.save.data.useless;
			uselessCheck();
		}
		else
		{
			uselessCheck();
		}

		if (FlxG.save.data.gameJoltLogin != null)
		{
			gameJoltLogin = FlxG.save.data.gameJoltLogin;
		}

		if (FlxG.save.data.points != null)
		{
			points = FlxG.save.data.points;
			if (points < 0)
			{
				points = 0;
				saveSettings();
			}
		}
		if (FlxG.save.data.inventory != null)
		{
			inventory = FlxG.save.data.inventory;
			checkInventory();
		}
		else
		{
			checkInventory();
		}

		if (FlxG.save.data.newInventory != null)
		{
			newInventory = FlxG.save.data.newInventory;
			checkInventory();
		}
		else
		{
			checkInventory();
		}

		if (FlxG.save.data.itemUnlocks != null)
		{
			itemUnlocks = FlxG.save.data.itemUnlocks;
		}


		if (FlxG.save.data.setControls != null) {
			setControls = FlxG.save.data.setControls;
		}
		if(FlxG.save.data.bgSprite != null) {
			bgSprite = FlxG.save.data.bgSprite;
		}
		if(FlxG.save.data.pauseMusic != null) {
			pauseMusic = FlxG.save.data.pauseMusic;
		}
		if(FlxG.save.data.closeSound != null) {
			closeSound = FlxG.save.data.closeSound;
		}
		if(FlxG.save.data.foundDmitri != null) {
			foundDmitri = FlxG.save.data.foundDmitri;
		}
		if(FlxG.save.data.week8Done != null) {
			week8Done = FlxG.save.data.week8Done;
		}
		if(FlxG.save.data.arcadeUnlocked != null) {
			arcadeUnlocked = FlxG.save.data.arcadeUnlocked;
		}

		if (FlxG.save.data.dlcInventory != null)
		{
			dlc.DlcInventory.inventory = FlxG.save.data.dlcInventory;
		}

		if (FlxG.save.data.loadingScreenMetas != null)
		{
			LoadingScreenState.loadingScreenMeta = FlxG.save.data.loadingScreenMetas[0];
			LoadingScreenState.loadingScreen = FlxG.save.data.loadingScreenMetas[1];
		}
		else
		{
			LoadingScreenState.loadingScreenMeta = haxe.Json.parse(sys.io.File.getContent("assets/images/loading/meta.json"));
			LoadingScreenState.loadingScreen = LoadingScreenState.loadingScreenMeta.loadingScreens[0];
		}

		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
		{
			FlxG.sound.volume = FlxG.save.data.volume;
		}
		if (FlxG.save.data.mute != null)
		{
			FlxG.sound.muted = FlxG.save.data.mute;
		}

		var save:FlxSave = new FlxSave();
		save.bind('controls', 'ninjamuffin99');
		if(save != null && save.data.customControls != null) {
			reloadControls(save.data.customControls);
		}
	}

	public static function reloadControls(newKeys:Array<FlxKey>) {
		ClientPrefs.removeControls(ClientPrefs.lastControls);
		ClientPrefs.lastControls = newKeys.copy();
		ClientPrefs.loadControls(ClientPrefs.lastControls);
	}

	private static function removeControls(controlArray:Array<FlxKey>) {
		for (i in 0...keyBinds.length) {
			var controlValue:Int = i*2;
			var controlsToRemove:Array<FlxKey> = [];
			for (j in 0...2) {
				if(controlArray[controlValue+j] != NONE) {
					controlsToRemove.push(controlArray[controlValue+j]);
				}
			}
			if(controlsToRemove.length > 0) {
				PlayerSettings.player1.controls.unbindKeys(keyBinds[i][0], controlsToRemove);
			}
		}
	}
	private static function loadControls(controlArray:Array<FlxKey>) {
		for (i in 0...keyBinds.length) {
			var controlValue:Int = i*2;
			var controlsToAdd:Array<FlxKey> = [];
			for (j in 0...2) {
				if(controlArray[controlValue+j] != NONE) {
					controlsToAdd.push(controlArray[controlValue+j]);
				}
			}
			if(controlsToAdd.length > 0) {
				PlayerSettings.player1.controls.bindKeys(keyBinds[i][0], controlsToAdd);
			}
		}
	}

	public static function delete()
	{
		Delete.delete();
		saveSettings();
		loadPrefs();
		TitleScreenState.initialized = false;
		MusicBeatState.switchState(new TitleScreenState());
	}

	public static function checkInventory()
	{
		if (inventory[0] != null)
		{
			if (inventory[0] == null)
			{
				inventory.push(["week-key", 0]);
				if (!newInventory.exists("week-key"))
				{
					newInventory.set("week-key", 0);
				}
			}
			if (inventory[1] == null)
			{
				inventory.push(["story-key", 0]);
				if (!newInventory.exists("story-key"))
				{
					newInventory.set("story-key", 0);
				}
			}
			if (inventory[2] == null)
			{
				inventory.push(["secret-key", 0]);
				if (!newInventory.exists("secret-key"))
				{
					newInventory.set("secret-key", 0);
				}
			}
			if (inventory[3] == null)
			{
				inventory.push(["costume-box", 0]);
				if (!newInventory.exists("costume-box"))
				{
					newInventory.set("costume-box", 0);
				}
			}
		}

		for (file in FileSystem.readDirectory("assets/shop/data/"))
		{
			if (file.endsWith(".json"))
			{
				var form:String = file.replace(".json", "");
				if (!newInventory.exists(form))
				{
					newInventory.set(form, 0);
				}
				if (newInventory.exists(form))
				{
					for (inv in inventory)
					{
						if (inv[0] == form)
						{
							if (newInventory.get(form) != inv[1])
							{
								if (newInventory.get(form) < inv[1])
								{
									newInventory.set(form, inv[1]);
								}
							}
						}
					}
				}
			}
		}
	}

	public static function uselessCheck()
	{
		if (!useless.exists("wishDownscroll"))
		{
			useless.set("wishDownscroll", false);
		}
		if (!useless.exists("flipChar"))
		{
			useless.set("flipChar", false);
		}
		if (!useless.exists("leftSides"))
		{
			useless.set("leftSides", false);
		}
	}
}