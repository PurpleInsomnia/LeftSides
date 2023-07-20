package;

#if DISCORD
import Discord.DiscordClient;
#end
import DialogueBoxPsych;
import FlxTransWindow;
import FunkinLua;
import GameJolt.GameJoltAPI;
import HealthIcon.IconGlow;
import Section.SwagSection;
import Song.SwagSong;
import StageData;
import WiggleEffect.WiggleEffectType;
import editors.CharacterEditorState;
import editors.ChartingState;
import filters.*;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import hxshaders.*;
import lime.app.Application;
import lime.graphics.RenderContext;
import lime.ui.KeyCode;
import lime.ui.KeyModifier;
import lime.ui.MouseButton;
import lime.ui.Window;
import lime.ui.WindowAttributes;
import lime.utils.Assets;
import openfl.Lib;
import openfl.display.BlendMode;
import openfl.display.GraphicsShader;
import openfl.display.Sprite;
import openfl.display.StageQuality;
import openfl.errors.Error;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;
import openfl.filters.ColorMatrixFilter;
import openfl.filters.ShaderFilter;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import openfl.utils.Assets as OpenFlAssets;
import openfl.utils.Assets;
import openfl8.*;

using StringTools;
#if sys
import sys.FileSystem;
import sys.io.File;
#end


typedef WindowData = {
	var type:String;
	var name:String;
	var pos:Array<Int>;
	var size:Array<Int>;
	var borderless:Bool;
	var aot:Bool;
	var args:Array<Dynamic>;
	var sprsToAdd:Array<Array<Dynamic>>;
}

typedef RatingChart = {
	var bads:Int;
	var goods:Int;
	var shits:Int;
	var sicks:Int;
}

class PlayState extends MusicBeatState
{
	public static var STRUM_X = 42;
	public static var STRUM_X_MIDDLESCROLL = -278;

	public static var ratingStuffTess:Array<Dynamic> = [
		['Needs work...', 0.5],
		['Not bad...', 0.7],
		['Sweet!', 0.8],
		['Cute', 0.9],
		['Hot~', 0.95],
		['Sexy~', 1],
		[';)', 1]
	];

	public static var ratingStuff:Array<Dynamic> = [
		['Bad', 0.5], //From 0% to 19%
		['Okay', 0.7], //From 20% to 39%
		['Good', 0.8], //69%
		['Great', 0.9], //From 70% to 79%
		['Awesome', 0.95], //From 80% to 89%
		['Outstanding!', 1], //From 90% to 99%
		['AMAZING!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	public var camGameFilters:Array<BitmapFilter> = [];
	public var camHUDFilters:Array<BitmapFilter> = [];
	public var camOtherFilters:Array<BitmapFilter> = [];
	public var pauseFilters:Array<BitmapFilter> = [];
	public var WiggleShaders:Array<WiggleEffect> = [];
	#if (haxe >= "4.0.0")
	public var filterMapGame:Map<String, BitmapFilter> = new Map();
	public var filterMapHud:Map<String, BitmapFilter> = new Map();
	public var filterMapOther:Map<String, BitmapFilter> = new Map();
	#else
	public var filterMapGame:Map<String, BitmapFilter> = new Map(String, BitmapFilter);
	public var filterMapHud:Map<String, BitmapFilter> = new Map(String, BitmapFilter);
	public var filterMapOther:Map<String, BitmapFilter> = new Map(String, BitmapFilter);
	#end
	
	#if (haxe >= "4.0.0")
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSprite> = new Map();
	public var modchartTexts:Map<String, ModchartText> = new Map();
	public var modchartButtons:Map<String, LuaButton> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	#else
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSprite> = new Map<String, Dynamic>();
	public var modchartTexts:Map<String, ModchartText> = new Map<String, Dynamic>();
	public var modchartButtons:Map<String, LuaButton> = new Map<String, Dyanmic>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	#end

	//event variables
	private var isCameraOnForcedPos:Bool = false;
	#if (haxe >= "4.0.0")
	public var boyfriendMap:Map<String, Boyfriend> = new Map();
	public var dadMap:Map<String, Character> = new Map();
	public var gfMap:Map<String, Character> = new Map();
	#else
	public var boyfriendMap:Map<String, Boyfriend> = new Map<String, Boyfriend>();
	public var dadMap:Map<String, Character> = new Map<String, Character>();
	public var gfMap:Map<String, Character> = new Map<String, Character>();
	#end

	#if (haxe >= "4.0.0")
	public var characters:Map<String, Character> = new Map();
	#else
	public var characters:Map<String, Character> = new Map<String, Character>();
	#end

	public var BF_X:Float = 770;
	public var BF_Y:Float = 100;
	public var DAD_X:Float = 100;
	public var DAD_Y:Float = 100;
	public var GF_X:Float = 400;
	public var GF_Y:Float = 130;

	public var boyfriendGroup:FlxSpriteGroup;
	public var dadGroup:FlxSpriteGroup;
	public var gfGroup:FlxSpriteGroup;

	public var gfLayer:FlxTypedGroup<Dynamic>;
	public var dadLayer:FlxTypedGroup<Dynamic>;

	public static var curStage:String = '';
	public static var isPixelStage:Bool = false;
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public var isSecret:Bool = false;
	public var isScary:Bool = false;
	public static var isMad:Bool = false;
	public var isRing:Bool = false;
	public static var staticRing:Bool = false;
	public var lostAllRings = false;
	public var changedShow:Bool = false;
	public var ringCountIsUp = false;
	public static var isVoid:Bool = false;
	public static var voidSkip:Bool = false;
	public var attackMode:Bool = false;
	public static var canDance:Bool = true;
	public static var attackPress = false;
	public var dialogueCount:Int = 0;
	public var followChars:Bool = true;
	public var lastSong:String = "";

	public var songPrefix:String = "";
	public var vocals:FlxSound;

	public var dialogueName:String = 'default';

	public var isPiece:Bool = false;

	public var trueX:Array<Float>;
	public var trueY:Array<Float>;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	public var dadName:String = '';
	public var gfName:String = '';
	public var bfName:String = '';

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];
	public var eventNotes:Array<Dynamic> = [];

	public var strumLine:FlxSprite;

	//Handles the new epic mega sexy cam code that i've done
	private var camFollow:FlxPoint;
	private var camFollowPos:FlxObject;
	private static var prevCamFollow:FlxPoint;
	private static var prevCamFollowPos:FlxObject;
	private static var resetSpriteCache:Bool = false;
	private var mswo:Bool = false;

	public var strumLineNotes:FlxTypedGroup<StrumNote>;
	public var opponentStrums:FlxTypedGroup<StrumNote>;
	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var gfStrums:FlxTypedGroup<StrumNote>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var camZoomEvent:Bool = false;
	private var curSong:String = "";
	public static var curSongShit:String = '';

	public var composer:String;
	public var songInfo:FlxTypedGroup<FlxSprite>;

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	public var babyArrow:StrumNote;

	private var healthBarBG:AttachedSprite;
	public var healthBar:FlxBar;
	public var barBG:FlxSprite;
	public var songPercent:Float = 0;

	private var timeBarBG:AttachedSprite;
	public var timeBar:FlxBar;

	private var generatedMusic:Bool = false;
	public var endingSong:Bool = false;
	private var startingSong:Bool = false;
	private var updateTime:Bool = false;
	public static var practiceMode:Bool = false;
	public static var usedPractice:Bool = false;
	public static var changedDifficulty:Bool = false;
	public static var cpuControlled:Bool = false;

	var botplaySine:Float = 0;
	public var botplayTxt:FlxText;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var iconGlowP1:IconGlow;
	public var iconGlowP2:IconGlow;


	public var camHUD:FlxCamera;
	public var camShader:FlxCamera;
	public var camBars:FlxCamera;
	public var camVideo:FlxCamera;
	public var camGame:FlxCamera;
	public var camInfo:FlxCamera;
	public var camOther:FlxCamera;
	public var cameraSpeed:Float = 1;

	// shader stuff lmao
	public var dadShadow:FlxSprite;
	public var gfShadow:FlxSprite;
	public var bfShadow:FlxSprite;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];
	var dialogueJson:FunnyDialogueFile = null;

	var stupidThing:FunnyDialogueLine;

	var halloweenBG:BGSprite;
	var halloweenWhite:BGSprite;

	var phillyCityLights:FlxTypedGroup<BGSprite>;
	var phillyTrain:BGSprite;
	var phillyShader:FlxSprite;
	var phillyBg:BGSprite;
	var blammedLightsBlack:ModchartSprite;
	var blammedLightsBlackTween:FlxTween;
	var phillyCityLightsEvent:FlxTypedGroup<BGSprite>;
	var phillyCityLightsEventTween:FlxTween;
	var ronPoster:FlxButton;
	var trainSound:FlxSound;

	var fastCar:BGSprite;

	var upperBoppers:BGSprite;
	var bottomBoppers:BGSprite;
	var santa:BGSprite;
	var heyTimer:Float;

	var dumbDialChar:String;
	var dumbDialExpress:String;

	var alertAttackSpr:FlxSprite;
	public var comboSpr:FlxSprite;
	public var comboBreakSpr:FlxSprite;
	public var comboText:FlxText;

	public var ringSpr:FlxSprite;
	public var ringText:FlxText;
	public var ringCount:Float = 0;

	var sansUndertaleAfter:DialogueBoxUndertale;

	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	public var ghostMisses:Int = 0;
	public var scoreTxt:FlxText;
	public var timeTxt:FlxText;
	var scoreTxtTween:FlxTween;

	public static var campaignScore:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignHits:Int = 0;
	public static var campaignGMiss:Int = 0;
	public static var seenCutscene:Bool = false;
	public static var deathCounter:Int = 0;

	public static var defaultCamZoom:Float = 1.05;
	public var realDefaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public var inCutscene:Bool = false;
	public var songLength:Float = 0;
	public var realLength:Float = 0;

	public var delayedInfo:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	public static var instance:PlayState;
	public var luaArray:Array<FunkinLua> = [];
	public var scriptArray:Array<FunkinHscript> = [];

	//Achievement shit
	var keysPressed:Array<Bool> = [false, false, false, false];
	var boyfriendIdleTime:Float = 0.0;
	var boyfriendIdled:Bool = false;

	// Lua shit
	private var luaDebugGroup:FlxTypedGroup<DebugLuaText>;

	var dialogueLua:String = 'data/dialogueScript.lua';

	var coolFunctionsLua:String = 'data/coolFunctions.lua';

	var infoScript:String = 'data/songInfo.lua';

	var dialCharacter:String;

	public static var encoreMode:Bool = false;
	public static var extremeMode:Bool = false;
	public static var healthLoss:Float = 0.0475;

	var topBar:FlxSprite;
	var bottomBar:FlxSprite;

	public var scrollMult:Float = 1;
	public var songSpeed:Float = 1;
	var noteKillOffset:Float = 350;

	public var lyricText:FlxText;
	public var icon:HealthIcon;
	public var lyricPixelFont:String = "pixel.otf";
	public var lyricFont:String = "eras.ttf";

	var blackFade:FlxSprite;

	public var fadeSongs:Array<String> = ['Free Me', 'Nightmare'];
	public var fadeTimes:Array<Float> = [7, 5.83];

	public var highestCombo:Int = 0;

	public var hideElements:Array<Dynamic> = [];
	public var camHudStuff:Array<Dynamic> = [];

	var zoomMult:Float = 1;
	var zoomHit:Bool = false;
	var hitInt:Int = 1;
	public var mustHitSection:Bool = false;
	public var altSection:Bool = false;

	var closedTabs:Bool = false;

	public var skipCountdown:Bool = false;

	public var artistNameText:FlxText;
	public var songNameText:FlxText;
	public static var funnyBarColour:Int = 0;

	public var customScoreTxt:Bool = false;
	public var fpm:Bool = false;
	public var startFlipped:Bool = false;
	public var flippedStrum:Bool = false;
	public var crochet:Float = 0;
	public var currentStage:String = "";
	public var customTimeText:Bool = false;
	var glitchedTexts:Bool = false;
	// set default to false.
	public var bfZoom:Bool = false;

	// custom game overs.
	public var gameoverscript:String = "";
	public var videoGameOver:String = "";

	private var thirdStrum:Bool = false;

	// chromatic aberation shader shit.
	public var chromaticabShader:ChromaticAberation = null;

	public var realRatingPercent:Float = 0;

	public var pauseCharacter:String = "none";
	public var preventPCChange:Bool = false;

	public var curDialogueBox:DialogueBoxPsych = null;

	public static var customChars:Array<String> = ["none", "none"];

	public var dadCPos:Array<Float> = [0, 0];
	public var bfCPos:Array<Float> = [0, 0];
	public var gfCPos:Array<Float> = [0, 0];
	public var gfInFront:Bool = false;
	public var dadInFront:Bool = false;

	public static var campaignRatings:Array<RatingChart> = [];
	public var songRatings:RatingChart;

	public var stageMetaData:StageFile = null;

	public var backgroundSprites:Array<FNFSprite> = [];

	private var dbc:Int = 0;

	override public function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages(resetSpriteCache);
		#end
		resetSpriteCache = false;

		instance = this;

		preventPCChange = false;
		if (!isStoryMode)
		{
			lastSong = "";
		}

		songRatings = {
			bads: 0,
			goods: 0,
			shits: 0,
			sicks: 0
		}



		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		closedTabs = false;

		practiceMode = false;
		voidSkip = false;
		zoomMult = 1;
		zoomHit = false;
		hitInt = 1;
		hideElements = [];
		camHudStuff = [];



		if (scrollMult != 1)
			scrollMult = 1;

		highestCombo = 0;



		if (twoplayer.TwoPlayerState.tpm && ClientPrefs.middleScroll)
		{
			mswo = true;
			ClientPrefs.middleScroll = false;
		}



		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camShader = new FlxCamera();
		camVideo = new FlxCamera();
		camBars = new FlxCamera();
		camHUD = new FlxCamera();
		camInfo = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camBars.bgColor.alpha = 0;
		camInfo.bgColor.alpha = 0;
		camVideo.bgColor.alpha = 0;
		camShader.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camShader);
		FlxG.cameras.add(camVideo);
		FlxG.cameras.add(camBars);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camInfo);
		FlxG.cameras.add(camOther);
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		FlxCamera.defaultCameras = [camGame];
		CustomFadeTransition.nextCamera = camOther;
		//FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = true;
		persistentDraw = true;

		isRing = false;
		skipCountdown = false;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		// nooooo mooooorreee FORTNITE! *VINE BOOM*
		FlxG.mouse.visible = false;

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		songSpeed = SONG.speed;
		if (extremeMode)
		{
			healthLoss = 0.25;
			health = 2;
		}
		noteKillOffset = 350 / songSpeed;

		#if desktop
		storyDifficultyText = '' + CoolUtil.difficultyStuff[storyDifficulty][0];

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: " + WeekData.getCurrentWeek().weekName;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		GameOverSubstate.resetVariables();
		var songName:String = Paths.formatToSongPath(SONG.song);

		var nameFileString:String = songName + '/composer';
		var artistColour:String = "";

		if (encoreMode)
		{
			if (FileSystem.exists(Paths.txt(nameFileString + '-encore')) || FileSystem.exists('mods/' + Paths.currentModDirectory + '/data/' + nameFileString + '-encore.txt'))
				nameFileString = songName + '/composer-encore';
		}
		if (FileSystem.exists(Paths.txt(nameFileString)))
		{
			var artistNameFile:Array<String> = CoolUtil.coolTextFile(Paths.txt(nameFileString));
			composer = artistNameFile[0];
			if (artistNameFile[1] != null)
			{
				artistColour = artistNameFile[1]; 
			}
		}
		if (FileSystem.exists('mods/' + Paths.currentModDirectory + '/data/' + nameFileString + '.txt'))
		{
			var artistNameFile:Array<String> = CoolUtil.coolTextFile('mods/' + Paths.currentModDirectory + '/data/' + nameFileString + '.txt');
			composer = artistNameFile[0];
			if (artistNameFile[1] != null)
			{
				artistColour = artistNameFile[1]; 
			}
		}



		curStage = PlayState.SONG.stage;
		trace('stage is: ' + curStage);
		if(PlayState.SONG.stage == null || PlayState.SONG.stage.length < 1) {
			switch (songName)
			{
				case 'tutorial' | 'bopeebo':
					curStage = 'dad';
				case 'fresh':
					curStage = 'stage-sundown';
				case 'dad-battle':
					curStage = 'stage-night';
				case 'spookeez' | 'south':
					curStage = 'hill';
				case 'pico' | 'philly' | 'philly-nice' | 'blammed':
					curStage = 'pico';
				case 'milf' | 'satin-panties' | 'high':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'horrifying-truth':
					curStage = 'mallEvil';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				default:
					curStage = 'stage';
			}
		}

		var stageData:StageFile = StageData.getStageFile(curStage);
		if(stageData == null) 
		{
			stageData = StageData.getDefaultFile();
		}
		else
		{
			var cs:Dynamic = stageData.cameraSpeed;
			if (cs == null)
			{
				stageData.cameraSpeed = 1;
			}
			if (stageData.cameraPositions == null)
			{
				stageData.cameraPositions = {
					dad: [0, 0],
					bf: [0, 0],
					gf: [0, 0]
				}
			}
		}



		currentStage = curStage;

		defaultCamZoom = stageData.defaultZoom;
		realDefaultCamZoom = stageData.defaultZoom;
		isPixelStage = stageData.isPixelStage;
		BF_X = stageData.boyfriend[0];
		BF_Y = stageData.boyfriend[1];
		GF_X = stageData.girlfriend[0];
		GF_Y = stageData.girlfriend[1];
		DAD_X = stageData.opponent[0];
		DAD_Y = stageData.opponent[1];
		cameraSpeed = stageData.cameraSpeed;
		dadCPos = stageData.cameraPositions.dad;
		gfCPos = stageData.cameraPositions.gf;
		bfCPos = stageData.cameraPositions.bf;

		stageMetaData = stageData;

		boyfriendGroup = new FlxSpriteGroup(BF_X, BF_Y);
		dadGroup = new FlxSpriteGroup(DAD_X, DAD_Y);
		gfGroup = new FlxSpriteGroup(GF_X, GF_Y);

		if (Paths.formatToSongPath(SONG.song) == "tutorial")
		{
			defaultCamZoom = 1;
		}

		switch (curStage)
		{
			case 'limo': //Week 4
				var suffix:String = "";

				if (SONG.song == 'Satin Panties' || SONG.song == 'Dance Interstate')
				{
					suffix = 'SUNSET';
				}

				fastCar = new BGSprite('limo/fastCarLol' + suffix, -300, 160);
				fastCar.active = true;
		}

		if(isPixelStage) 
		{
			introSoundsSuffix = '-pixel';
		}
		if(curStage == 'mallEvil') 
		{
			introSoundsSuffix = '-bf';
		}
		if(SONG.song == 'Free Me' || SONG.song == "Isolation") 
		{
			introSoundsSuffix = '-silent';
		}

		trace('stage shit');

		add(gfGroup);

		gfLayer = new FlxTypedGroup<Dynamic>();
		add(gfLayer);

		add(dadGroup);

		dadLayer = new FlxTypedGroup<Dynamic>();
		add(dadLayer);

		add(boyfriendGroup);
		
		if(curStage == 'spooky') 
		{
			add(halloweenWhite);
		}

		#if LUA_ALLOWED
		luaDebugGroup = new FlxTypedGroup<DebugLuaText>();
		luaDebugGroup.cameras = [camOther];
		add(luaDebugGroup);
		#end

		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;
		var luaFile:String = "";

		if (!encoreMode)
		{
			luaFile = 'stages/' + curStage + '.lua';
		}
		else
		{
			luaFile = 'stages/encore/' + curStage + '.lua';
		}

		if (!encoreMode)
		{
			if(FileSystem.exists(Paths.modFolders(luaFile))) 
			{
				luaFile = Paths.modFolders(luaFile);
				doPush = true;
			} 
			else 
			{
				luaFile = Paths.getPreloadPath(luaFile);
				if(FileSystem.exists(luaFile)) 
				{
					doPush = true;
				}
			}
		}
		else
		{
			if(FileSystem.exists(Paths.modFolders(luaFile))) 
			{
				luaFile = Paths.modFolders(luaFile);
				doPush = true;
			}
			if (FileSystem.exists(Paths.getPreloadPath(luaFile)))
			{
				luaFile = Paths.getPreloadPath(luaFile); 
				doPush = true;
			}
			if (FileSystem.exists(Paths.modFolders("stages/" + curStage + ".lua")))
			{
				luaFile = Paths.modFolders("stages/" + curStage + ".lua");
				doPush = true;
			}
			if (FileSystem.exists(Paths.getPreloadPath("stages/" + curStage + ".lua")))
			{
				luaFile = Paths.getPreloadPath("stages/" + curStage + ".lua");
				doPush = true;
			}
		}

		if (!encoreMode)
		{
			if (FileSystem.exists(Paths.modFolders("stages/" + curStage + ".hxs")))
			{
				scriptArray.push(new FunkinHscript(Paths.modFolders("stages/" + curStage + ".hxs")));
			}
			else
			{
				if (FileSystem.exists(Paths.getPreloadPath("stages/" + curStage + ".hxs")))
				{
					scriptArray.push(new FunkinHscript(Paths.getPreloadPath("stages/" + curStage + ".hxs")));
				}
			}
		}
		else
		{
			if (FileSystem.exists(Paths.modFolders("stages/encore/" + curStage + ".hxs")))
			{
				scriptArray.push(new FunkinHscript(Paths.modFolders("stages/" + curStage + ".hxs")));
			}
			else
			{
				if (FileSystem.exists(Paths.getPreloadPath("stages/encore/" + curStage + ".hxs")))
				{
					scriptArray.push(new FunkinHscript(Paths.getPreloadPath("stages/" + curStage + ".hxs")));
				}
			}
		}



		var filesPushed:Array<String> = [];
		var scriptFolder:Array<String> = [Paths.getPreloadPath('scripts/')];

		scriptFolder.insert(0, Paths.mods('scripts/'));
		if (Paths.currentModDirectory != "")
		{
			scriptFolder.insert(0, Paths.getModFile('scripts/'));
		}
		
		for (folder in scriptFolder)
		{
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.lua') && !filesPushed.contains(file))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushed.push(file);
					}
					if (file.endsWith(".hxs") && !filesPushed.contains(file))
					{
						scriptArray.push(new FunkinHscript(folder + file));
					}
				}
			}
		}


		
		if(doPush && !ClientPrefs.noStages)
		{
			luaArray.push(new FunkinLua(luaFile));
		}



		if(!modchartSprites.exists('blammedLightsBlack')) { //Creates blammed light black fade in case you didn't make your own
			blammedLightsBlack = new ModchartSprite(FlxG.width * -0.5, FlxG.height * -0.5);
			if (curStage == "pico")
			{
				blammedLightsBlack.x = 0;
				blammedLightsBlack.y = 0;
			}
			blammedLightsBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2.2), FlxColor.BLACK);
			var position:Int = members.indexOf(gfGroup);
			if(members.indexOf(boyfriendGroup) < position) {
				position = members.indexOf(boyfriendGroup);
			} else if(members.indexOf(dadGroup) < position) {
				position = members.indexOf(dadGroup);
			}
			insert(position, blammedLightsBlack);

			blammedLightsBlack.wasAdded = true;
			modchartSprites.set('blammedLightsBlack', blammedLightsBlack);
		}
		blammedLightsBlack = modchartSprites.get('blammedLightsBlack');
		blammedLightsBlack.alpha = 0.0;
		#end

		var gfVersion:String = SONG.player3;
		if(gfVersion == null || gfVersion.length < 1) {
			switch (curStage)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall':
					gfVersion = 'gf-christmas';
				case 'mallEvil':
					gfVersion = 'speakers';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			SONG.player3 = gfVersion; //Fix for the Chart Editor
		}

		var gfCharacterName:String = gfVersion;
		var dadCharacterName:String = SONG.player2;
		var bfCharacterName:String = SONG.player1;

		if (PlayStateMeta.dataFile.wardrobeEnabled)
		{
			if (customChars[0] != "none")
			{
				bfCharacterName = customChars[0];
			}
			if (customChars[1] != "none")
			{
				gfCharacterName = customChars[1];
			}
		}

		gf = new Character(0, 0, gfCharacterName);
		if (!gfInFront)
		{
			startCharacterPos(gf);
		}
		gf.scrollFactor.set(0.95, 0.95);
		gfName = gfCharacterName;
		if (!gfInFront)
		{
			gfGroup.add(gf);
		}

		dad = new Character(0, 0, dadCharacterName);
		if (!dadInFront)
		{
			startCharacterPos(dad, true);
		}
		dadName = dadCharacterName;
		if (!dadInFront)
		{
			dadGroup.add(dad);
		}

		boyfriend = new Boyfriend(0, 0, bfCharacterName);
		startCharacterPos(boyfriend);
		bfName = bfCharacterName;
		boyfriendGroup.add(boyfriend);
		if (gfInFront)
		{
			gf.x = GF_X;
			gf.y = GF_Y;
			startCharacterPos(gf);
			add(gf);
		}
		if (dadInFront)
		{
			dad.x = DAD_X;
			dad.y = DAD_Y;
			startCharacterPos(dad, true);
			add(dad);
		}

		// wooooah. custom animations for different note types????
		// das crazzy.
		characters.set("dad", dad);
		characters.set("gf", gf);
		characters.set("boyfriend", boyfriend);
		
		var camPos:FlxPoint = new FlxPoint(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y);
		camPos.x += gf.cameraPosition[0];
		camPos.y += gf.cameraPosition[1];

		if(dad.curCharacter.startsWith('gf') || dad.curCharacter == "date-gf" || dad.curCharacter == "brand-new-tess") 
		{
			dad.setPosition(GF_X, GF_Y);
			gf.visible = false;
		}



		reloadQuotes();
		reloadPauseMusic();

		if (ClientPrefs.shaders && !isPixelStage)
		{
			dadShadow = new FlxSprite().loadGraphic(Paths.image('shaders/shadow'));
			gfShadow = new FlxSprite().loadGraphic(Paths.image('shaders/shadow'));
			bfShadow = new FlxSprite().loadGraphic(Paths.image('shaders/shadow'));

			// graphic sizes
			dadShadow.setGraphicSize(Std.int(dad.width + 30), Std.int(dadShadow.height));
			gfShadow.setGraphicSize(Std.int(gf.width + 40), Std.int(gfShadow.height));
			bfShadow.setGraphicSize(Std.int(boyfriend.width + 30), Std.int(bfShadow.height));

			// x & y's
			dadShadow.x = dad.getGraphicMidpoint().x - (dadShadow.width / 2);
			gfShadow.x = gf.getGraphicMidpoint().x - (gfShadow.width / 2);
			bfShadow.x = boyfriend.getGraphicMidpoint().x - (bfShadow.width / 2);

			var shadowOffs:Float = -40;
			dadShadow.y = (dad.getGraphicMidpoint().y + (dad.height / 2)) - ((dadShadow.height / 2) - (shadowOffs / 2));
			gfShadow.y = (gf.getGraphicMidpoint().y + (gf.height / 2)) - (gfShadow.height / 2);
			bfShadow.y = (boyfriend.getGraphicMidpoint().y + (boyfriend.height / 2)) - ((bfShadow.height / 2) - shadowOffs);

			// scroll factors
			gfShadow.scrollFactor.set(0.95, 0.95);

			// insert(members.indexOf(dadGroup) - 1, dadShadow);
			// insert(members.indexOf(gfGroup) - 1, gfShadow);
			// insert(members.indexOf(boyfriendGroup) - 1, bfShadow);
			// just gonna remove this :/
		}



		if (dad.curCharacter == 'pico')
		{
			// resize because yes.
			dadShadow.setGraphicSize(Std.int(bfShadow.width), Std.int(bfShadow.height));
			dadShadow.x = dad.getGraphicMidpoint().x - (dadShadow.width / 2);
		}

		if (dad.curCharacter == 'gf' || dad.curCharacter == 'no-char')
		{
			dadShadow.visible = false;
		}

		switch(curStage)
		{
			case 'limo':
				resetFastCar();
				insert(members.indexOf(gfGroup) - 1, fastCar);

				fastCar.inFront = true;
				backgroundSprites.push(fastCar);

				modchartTweens.get('limoSunsetMove').active = false;
		}

		var file:String = Paths.json(songName + '/dialogue'); //Checks for json/Psych Engine dialogue
		if (OpenFlAssets.exists(file)) {
			dialogueJson = DialogueBoxPsych.loadDialogue(file);
		}

		var file:String = Paths.txt(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (OpenFlAssets.exists(file)) {
			dialogue = CoolUtil.coolTextFile(file);
		}
		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = startNextDialogue;
		doof.skipDialogueThing = skipDialogue;

		var doof1:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof1.scrollFactor.set();
		doof1.finishThing = startCountdown;
		doof1.nextDialogueThing = startNextDialogue;
		doof1.skipDialogueThing = skipDialogue;

		var sansList:Array<String> = CoolUtil.coolTextFile(Paths.txt(songName + '/sansUndertale'));
		var sansListAfter:Array<String> = CoolUtil.coolTextFile(Paths.txt(songName + '/sansUndertaleAfter'));

		var sansUndertale:DialogueBoxUndertale = new DialogueBoxUndertale(sansList);
		sansUndertale.scrollFactor.set();
		sansUndertale.finishThing = startCountdown;
		sansUndertale.nextDialogueThing = startNextDialogue;
		sansUndertale.skipDialogueThing = skipDialogue;

		sansUndertaleAfter = new DialogueBoxUndertale(sansListAfter);
		sansUndertaleAfter.scrollFactor.set();
		sansUndertaleAfter.finishThing = endSong;
		sansUndertaleAfter.nextDialogueThing = startNextDialogue;
		sansUndertaleAfter.skipDialogueThing = skipDialogue;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(ClientPrefs.middleScroll ? STRUM_X_MIDDLESCROLL : STRUM_X, 70).makeGraphic(FlxG.width, 10);
		if(ClientPrefs.downScroll) strumLine.y = FlxG.height - 170;
		strumLine.scrollFactor.set();

		topBar = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		topBar.cameras = [camBars];
		topBar.y -= FlxG.height;
		add(topBar);

		bottomBar = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bottomBar.cameras = [camBars];
		bottomBar.y += FlxG.height;
		add(bottomBar);

		// Sussy Customization Stuff ;)
		if (ClientPrefs.customBar != 'Default')
		{
			topBar.loadGraphic(Paths.image('cinematicBars/' + ClientPrefs.customBar));
			topBar.flipY = true;
			topBar.flipX = true;
			topBar.setGraphicSize(FlxG.width, FlxG.height);
			topBar.y = 0;
			topBar.y -= FlxG.height;

			bottomBar.loadGraphic(Paths.image('cinematicBars/' + ClientPrefs.customBar));
			bottomBar.setGraphicSize(FlxG.width, FlxG.height);
			bottomBar.y = 0;
			bottomBar.y += FlxG.height;
		}

		timeTxt = new FlxText(STRUM_X + (FlxG.width / 2) - 248, 20, 400, "", 32);
		timeTxt.setFormat(Paths.font("eras.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.alpha = 0;
		timeTxt.borderSize = 2;
		timeTxt.visible = !ClientPrefs.hideTime;
		if(ClientPrefs.downScroll) timeTxt.y = FlxG.height - 45;
		hideElements.push(timeTxt);

		timeBarBG = new AttachedSprite('timeBar');
		timeBarBG.x = timeTxt.x;
		timeBarBG.y = timeTxt.y + (timeTxt.height / 4);
		timeBarBG.scrollFactor.set();
		timeBarBG.alpha = 0;
		timeBarBG.visible = !ClientPrefs.hideTime;
		timeBarBG.color = FlxColor.BLACK;
		timeBarBG.xAdd = -4;
		timeBarBG.yAdd = -4;
		hideElements.push(timeBarBG);
		add(timeBarBG);

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, LEFT_TO_RIGHT, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), this,
			'songPercent', 0, 1);
		timeBar.scrollFactor.set();
		timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		switch (ClientPrefs.timeColour)
		{
			case "Gradient & Black":
				// first one for bg
				timeBar.createGradientFilledBar([0xFFD000FF, 0xFFFFC500]);
			case "Gold & Magenta":
				timeBar.createFilledBar(0xFFD000FF, 0xFFFFC500);
			case "Magenta & Gold":
				timeBar.createFilledBar(0xFFFFC500, 0xFFD000FF);
			case "White & Black":
				// basic ass mf
				timeBar.createFilledBar(0xFF000000, 0xFFFFFFFF);
		}
		timeBar.numDivisions = 800; //How much lag this causes?? Should i tone it down to idk, 400 or 200?
		timeBar.alpha = 0;
		timeBar.visible = !ClientPrefs.hideTime;
		hideElements.push(timeBar);
		add(timeBar);
		add(timeTxt);
		timeBarBG.sprTracker = timeBar;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		camHudStuff.push(splash);
		splash.alpha = 0;

		opponentStrums = new FlxTypedGroup<StrumNote>();
		playerStrums = new FlxTypedGroup<StrumNote>();
		gfStrums = new FlxTypedGroup<StrumNote>();

		// startCountdown();

		generateSong(SONG.song);
		#if LUA_ALLOWED
		for (notetype in noteTypeMap.keys()) {
			var luaToLoad:String = Paths.preloadFunny('custom_notetypes/' + notetype + '.lua');
			if(FileSystem.exists(luaToLoad)) 
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			if (FileSystem.exists(Paths.preloadFunny("custom_notetypes/" + notetype + ".hxs")))
			{
				scriptArray.push(new FunkinHscript(Paths.preloadFunny("custom_notetypes/" + notetype + ".hxs")));
			}
		}
		if (FileSystem.exists(Paths.preloadFunny("data/" + Paths.formatToSongPath(SONG.song) + '/notes/')))
		{
			var daPushed:Array<String> = [];
			for (file in FileSystem.readDirectory(Paths.preloadFunny("data/" + Paths.formatToSongPath(SONG.song) + '/notes/')))
			{
				if (file.endsWith(".lua") && !daPushed.contains(file))
				{
					var path = haxe.io.Path.join([Paths.preloadFunny("data/" + Paths.formatToSongPath(SONG.song) + '/notes/'), file]);
					luaArray.push(new FunkinLua(path));
					daPushed.push(file);
				}
				if (file.endsWith(".hxs") && !daPushed.contains(file))
				{
					var path = haxe.io.Path.join([Paths.preloadFunny("data/" + Paths.formatToSongPath(SONG.song) + "/notes/"), file]);
					scriptArray.push(new FunkinHscript(path));
					daPushed.push(file);
				}
			}
		}
		for (event in eventPushedMap.keys()) {
			var luaToLoad:String = Paths.preloadFunny('custom_events/' + event + '.lua');
			if(FileSystem.exists(luaToLoad)) 
			{
				luaArray.push(new FunkinLua(luaToLoad));
			}
			if (FileSystem.exists(Paths.preloadFunny("custom_pathevents/" + event + ".hxs")))
			{
				scriptArray.push(new FunkinHscript(Paths.preloadFunny("custom_events/" + event + ".hxs")));
			}
		}
		if (FileSystem.exists(Paths.preloadFunny("data/" + Paths.formatToSongPath(SONG.song) + '/events/')))
		{
			for (file in FileSystem.readDirectory(Paths.preloadFunny("data/" + Paths.formatToSongPath(SONG.song) + '/events/')))
			{
				var daPushed:Array<String> = [];
				if (file.endsWith(".lua")  && !daPushed.contains(file))
				{
					var path = haxe.io.Path.join([Paths.preloadFunny("data/" + Paths.formatToSongPath(SONG.song) + '/events/'), file]);
					luaArray.push(new FunkinLua(path));
				}
				if (file.endsWith(".hxs")  && !daPushed.contains(file))
				{
					var path = haxe.io.Path.join([Paths.preloadFunny("data/" + Paths.formatToSongPath(SONG.song) + "/events/"), file]);
					scriptArray.push(new FunkinHscript(path));
				}
			}
		}


		if (FileSystem.exists(Paths.preloadFunny(dialogueLua)))
		{
			dialogueLua = Paths.preloadFunny(dialogueLua);
			luaArray.push(new FunkinLua(dialogueLua));
			trace('the funny script!!');	
		}
		if (FileSystem.exists(Paths.preloadFunny(coolFunctionsLua)))
		{
			coolFunctionsLua = Paths.preloadFunny(coolFunctionsLua);
			luaArray.push(new FunkinLua(coolFunctionsLua));
			trace('heheheha');
		}
		if (FileSystem.exists(Paths.preloadFunny(infoScript)))
		{
			infoScript = Paths.preloadFunny(infoScript);
			luaArray.push(new FunkinLua(infoScript));
		}

		if (FileSystem.exists(Paths.preloadFunny('characters/' + dad.curCharacter + '.lua')))
		{
			var dadScript = Paths.preloadFunny('characters/' + dad.curCharacter + '.lua');
			luaArray.push(new FunkinLua(dadScript));
			// some cool character script I guess
		}
		if (FileSystem.exists(Paths.preloadFunny('characters/' + gf.curCharacter + '.lua')))
		{
			var gfScript = Paths.preloadFunny('characters/' + gf.curCharacter + '.lua');
			luaArray.push(new FunkinLua(gfScript));
			// some cool character script I guess
		}
		if (FileSystem.exists(Paths.preloadFunny('characters/' + boyfriend.curCharacter + '.lua')))
		{
			var bfScript = Paths.preloadFunny('characters/' + boyfriend.curCharacter + '.lua');
			luaArray.push(new FunkinLua(bfScript));
			// some cool character script I guess
		}
		#end
		noteTypeMap.clear();
		noteTypeMap = null;
		eventPushedMap.clear();
		eventPushedMap = null;

		// After all characters being loaded, it makes then invisible 0.01s later so that the player won't freeze when you change characters
		// add(strumLine);

		camFollow = new FlxPoint();
		camFollowPos = new FlxObject(0, 0, 1, 1);

		snapCamFollowToPos(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (prevCamFollowPos != null)
		{
			camFollowPos = prevCamFollowPos;
			prevCamFollowPos = null;
		}
		add(camFollowPos);

		FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow);

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		//moveCameraSection(0);

		healthBarBG = new AttachedSprite('healthBar');
		healthBarBG.y = FlxG.height * 0.89;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.visible = !ClientPrefs.hideHud;
		healthBarBG.xAdd = -4;
		healthBarBG.yAdd = -4;
		add(healthBarBG);
		if(ClientPrefs.downScroll) healthBarBG.y = 0.11 * FlxG.height;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		// healthBar
		healthBar.visible = !ClientPrefs.hideHud;
		add(healthBar);
		healthBarBG.sprTracker = healthBar;

		barBG = new FlxSprite(healthBarBG.x, healthBarBG.y).loadGraphic(Paths.image('barBG'));
		barBG.screenCenter(X);
		barBG.visible = !ClientPrefs.hideHud;
		add(barBG);

		if (!ClientPrefs.lowQuality)
		{
			iconGlowP1 = new IconGlow(boyfriend);
			iconGlowP1.cameras = [camHUD];
			iconGlowP1.visible = !ClientPrefs.hideHud;
			add(iconGlowP1);
			iconGlowP2 = new IconGlow(dad);
			iconGlowP2.cameras = [camHUD];
			iconGlowP2.visible = !ClientPrefs.hideHud;
			add(iconGlowP2);
			camHudStuff.push(iconGlowP1);
			camHudStuff.push(iconGlowP2);
		}



		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		iconP1.visible = !ClientPrefs.hideHud;
		camHudStuff.push(iconP1);
		add(iconP1);

		if (curStage == 'schoolEvil')
		{
			var iconTrail:FlxTrail = new FlxTrail(iconP1, null, 10, 2, 0.4, 0.05);
			iconTrail.cameras = [camHUD];
			add(iconTrail);
		}

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		iconP2.visible = !ClientPrefs.hideHud;
		camHudStuff.push(iconP2);
		add(iconP2);

		if (curStage == 'schoolEvil')
		{
			var iconTrail:FlxTrail = new FlxTrail(iconP2, null, 10, 2, 0.4, 0.05);
			iconTrail.cameras = [camHUD];
			add(iconTrail);
		}



		// artist Stuff
		songInfo = new FlxTypedGroup<FlxSprite>();
		add(songInfo);

		switch (PlayStateMeta.dataFile.songInfoType.toLowerCase())
		{
			case "custom":
				var infoBox:FlxSprite = new FlxSprite(0, 150).loadGraphic(Paths.image("songInfo/" + Paths.formatToSongPath(SONG.song)));
				songInfo.add(infoBox);
			default:
				songNameText = new FlxText(10, 150, 0, "", 32);
				songNameText.setFormat(Paths.font('eras.ttf'), 32, FlxColor.WHITE, LEFT);
				songNameText.text = SONG.song;

				artistNameText = new FlxText(10, songNameText.y + songNameText.height + 5, 0, "", 24);
				var daColour:Int = 0xFFFFFFFF;
				switch (composer)
				{
					case "purpleinsomnia" | "PurpleInsomnia" | "PURPLEINSOMNIA":
						daColour = 0xFFC100FF;
				}
				if (artistColour != "")
				{
					daColour = Std.parseInt(artistColour);
				}
				artistNameText.setFormat(Paths.font('eras.ttf'), 24, daColour, LEFT);
				artistNameText.text = composer;

				if (encoreMode)
				{
					songNameText.text += ' (ENCORE)';
				}

				if (songNameText.width > artistNameText.width)
				{
					var blackInfo:FlxSprite = new FlxSprite(0, 150).makeGraphic(1, Std.int(songNameText.height + artistNameText.height), 0xFF000000);
					blackInfo.setGraphicSize(Std.int((songNameText.width + 35) * 2) + 25, Std.int(blackInfo.height * 2));
					songInfo.add(blackInfo);
				}
				else
				{
					var blackInfo:FlxSprite = new FlxSprite(0, 150).makeGraphic(1, Std.int(songNameText.height + artistNameText.height), 0xFF000000);
					blackInfo.setGraphicSize(Std.int((artistNameText.width + 35) * 2) + 25, Std.int(blackInfo.height * 2));
					songInfo.add(blackInfo);
				}

				songInfo.add(songNameText);
				songInfo.add(artistNameText);
		}

		camInfo.x = 0 - 1280;

		reloadHealthBarColors();

		scoreTxt = new FlxText(0, healthBarBG.y + 36, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("eras.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.visible = !ClientPrefs.hideHud;
		if (!ClientPrefs.limitedHud)
		{
			hideElements.push(scoreTxt);
		}
		add(scoreTxt);

		botplayTxt = new FlxText(400, timeBarBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("eras.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 1.25;
		botplayTxt.visible = cpuControlled;
		add(botplayTxt);
		if(ClientPrefs.downScroll) {
			botplayTxt.y = timeBarBG.y - 78;
		}

		if (isRing)
		{
			ringSpr = new FlxSprite().loadGraphic(Paths.image('ringBox'));
			ringSpr.x = 1280 - Std.int(ringSpr.width);
			ringSpr.y = 720 - Std.int(ringSpr.height);
			hideElements.push(ringSpr);
			camHudStuff.push(ringSpr);
			add(ringSpr);

			ringText = new FlxText(0, 0, '' + ringCount, 24);
			ringText.color = FlxColor.YELLOW;
			ringText.font = Paths.font('sonic-cd-menu-font.ttf');
			ringText.x = ringSpr.x + 64;
			ringText.y = ringSpr.y;
			hideElements.push(ringText);
			add(ringText);

			changeRingCount(0);
		}

		var pixelShit1:String = "";
		var pixelShit2:String = '';

		if (SONG.song == 'Free Me')
		{
			isScary = true;
		}

		if (PlayState.isPixelStage)
		{
			pixelShit1 = '';
			pixelShit2 = '-pixel';
		}
		if (ClientPrefs.showComboSpr)
		{
			comboSpr = new FlxSprite().loadGraphic(Paths.image(pixelShit1 + 'combo' + pixelShit2));
			comboSpr.visible = false;
			// comboSpr.updateHitbox();
			hideElements.push(comboSpr);
			camHudStuff.push(comboSpr);
			add(comboSpr);

			comboBreakSpr = new FlxSprite().loadGraphic(Paths.image(pixelShit1 + 'comboBreak' + pixelShit2));
			comboBreakSpr.visible = false;
			comboBreakSpr.updateHitbox();
			hideElements.push(comboBreakSpr);
			camHudStuff.push(comboBreakSpr);
			add(comboBreakSpr);

			if (!PlayState.isPixelStage)
			{
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = ClientPrefs.globalAntialiasing;
				comboBreakSpr.setGraphicSize(Std.int(comboBreakSpr.width * 0.7));
				comboBreakSpr.antialiasing = ClientPrefs.globalAntialiasing;
			}
			else
			{
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboBreakSpr.setGraphicSize(Std.int(comboBreakSpr.width * 0.7));
			}

			comboText = new FlxText(0, 0, '', 36);
			comboText.text = '' + combo;
			comboText.alpha = 0.8;
			comboText.setFormat(Paths.font("eras.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			hideElements.push(comboText);
			add(comboText);
		}



		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		barBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		if (isRing)
		{
			ringSpr.cameras = [camHUD];
			ringText.cameras = [camHUD];
		}
		if (ClientPrefs.showComboSpr)
		{
			comboSpr.cameras = [camHUD];
			comboBreakSpr.cameras = [camHUD];
			comboText.cameras = [camHUD];
		}
		doof.cameras = [camHUD];
		doof1.cameras = [camHUD];

		lyricText = new FlxText(0, 0, '', 42);
		lyricText.setFormat(Paths.font("eras.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		lyricText.cameras = [camHUD];
		lyricText.visible = false;
		add(lyricText);
		icon = new HealthIcon('bf');
		icon.cameras = [camHUD];
		icon.visible = false;
		add(icon);
		songInfo.cameras = [camInfo];

		if (isPixelStage)
			formatToPixel();

		blackFade = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
		blackFade.cameras = [camVideo];
		blackFade.alpha = 0;
		for (i in 0...fadeSongs.length)
		{
			if (SONG.song == fadeSongs[i] && !encoreMode)
			{
				blackFade.alpha = 1;
				add(blackFade);
			}
		}

		if (ClientPrefs.useless.get("wishDownscroll"))
		{
			camHUD.angle = 180;
		}

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		updateTime = true;

		#if (MODS_ALLOWED && LUA_ALLOWED)
		var doPush:Bool = false;

		var filesPushedThing:Array<String> = [];
		var scriptFolderThing:Array<String> = [Paths.getPreloadPath('data/' + Paths.formatToSongPath(SONG.song) + "/")];

		scriptFolderThing.insert(0, Paths.mods('data/' + Paths.formatToSongPath(SONG.song) + '/'));
		scriptFolderThing.push('mods/' + Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(SONG.song) + '/');
		
		for (folder in scriptFolderThing)
		{
			if (FileSystem.exists(folder))
			{
				for (file in FileSystem.readDirectory(folder))
				{
					if (file.endsWith('.lua') && !filesPushedThing.contains(file) && !file.endsWith("-encore.lua"))
					{
						luaArray.push(new FunkinLua(folder + file));
						filesPushedThing.push(file);
					}
					if (file.endsWith('.hxs') && !filesPushedThing.contains(file) && !file.endsWith("-encore.hxs"))
					{
						scriptArray.push(new FunkinHscript(folder + file));
						filesPushedThing.push(file);
					}
				}
			}
		}

		if (encoreMode)
		{
			for (folder in scriptFolderThing)
			{
				if (FileSystem.exists(folder))
				{
					for (file in FileSystem.readDirectory(folder))
					{
						if (file.endsWith('.lua') && !filesPushedThing.contains(file))
						{
							luaArray.push(new FunkinLua(folder + file));
							filesPushedThing.push(file);
						}
						if (file.endsWith('.hxs') && !filesPushedThing.contains(file))
						{
							scriptArray.push(new FunkinHscript(folder + file));
							filesPushedThing.push(file);
						}
					}
				}
			}
		}

		var shaderLua:String = 'stages/shaders/' + curStage + '.lua';
		if (FileSystem.exists(Paths.preloadFunny(shaderLua)))
		{
			shaderLua = Paths.preloadFunny(shaderLua);
			luaArray.push(new FunkinLua(shaderLua));
		}

		var mouseClickLua:String = 'data/' + Paths.formatToSongPath(SONG.song) + '/mouseClickFunctions.lua';
		if (FileSystem.exists(Paths.preloadFunny(mouseClickLua)))
		{
			mouseClickLua = Paths.preloadFunny(mouseClickLua);
			luaArray.push(new FunkinLua(mouseClickLua));
		} 
		
		if(doPush) 
			luaArray.push(new FunkinLua(luaFile));
		#end

		/*
		if (ClientPrefs.lowQualitySongs)
		{
			var pxShader:PixelateShader = new PixelateShader();
			pxShader.changeBlocks(10, 10);
			camGameFilters.push(new ShaderFilter(pxShader.shader));
			camGame.setFilters(camGameFilters);

			var pixShader:PixelateShader = new PixelateShader();
			pixShader.changeBlocks(3, 3);
			camHUDFilters.push(new ShaderFilter(pixShader.shader));
			camHUD.setFilters(camHUDFilters);
		}
		*/

		// note for like guides and shit.

		var ctc:Array<Character> = [boyfriend, gf, dad];
		if (ClientPrefs.shaders)
		{
			for (i in 0...ctc.length)
			{
				if (ctc[i].chromab && chromaticabShader == null)
				{
					chromaticabShader = new ChromaticAberation();
					chromaticabShader.shader.intensity.value[0] = 0;
					camGameFilters.push(new ShaderFilter(chromaticabShader.shader));
					camGame.setFilters(camGameFilters);
				}
			}
		}

		curSongShit = Paths.formatToSongPath(curSong);
		
		var daSong:String = Paths.formatToSongPath(curSong);
		if (isStoryMode && !seenCutscene)
		{
			switch (daSong)
			{
				case "monster":
					var whiteScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.WHITE);
					add(whiteScreen);
					whiteScreen.scrollFactor.set();
					whiteScreen.blend = ADD;
					camHUD.visible = false;
					snapCamFollowToPos(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
					inCutscene = true;

					FlxTween.tween(whiteScreen, {alpha: 0}, 1, {
						startDelay: 0.1,
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween)
						{
							camHUD.visible = true;
							remove(whiteScreen);
							startCountdown();
						}
					});
					FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
					gf.playAnim('scared', true);
					boyfriend.playAnim('scared', true);

				case 'cocoa' | 'eggnog':
					callOnLuas('onChristmasCountdown', []);

				case "horrifying-truth":
					var blackScreen:FlxSprite = new FlxSprite().makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					inCutscene = true;

					FlxTween.tween(blackScreen, {alpha: 0}, 0.7, {
						ease: FlxEase.linear,
						onComplete: function(twn:FlxTween) {
							remove(blackScreen);
						}
					});
					FlxG.sound.play(Paths.sound('Lights_Turn_On'));
					snapCamFollowToPos(400, -2050);
					FlxG.camera.focusOn(camFollow);
					FlxG.camera.zoom = 1.5;

					new FlxTimer().start(0.8, function(tmr:FlxTimer)
					{
						camHUD.visible = true;
						remove(blackScreen);
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween)
							{
								callOnLuas('onMonsterCutsceneDone', []);
							}
						});
					});
				case 'thorns':
					schoolIntro(doof);
				default:
					startCountdown();
			}
			seenCutscene = true;
		} 
		else 
		{
			startCountdown();
		}
		RecalculateRating();



		//PRECACHING MISS SOUNDS BECAUSE I THINK THEY CAN LAG PEOPLE AND FUCK THEM UP IDK HOW HAXE WORKS
		CoolUtil.precacheSound('missnote1');
		CoolUtil.precacheSound('missnote2');
		CoolUtil.precacheSound('missnote3');

		setOnLuas("encoreMode", encoreMode);

		callOnLuas('onCreatePost', []);



		if (gf.curCharacter == "none" && gf.visible)
		{
			gf.visible = false;
		}

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		#end

		moveCameraSection(0);


		super.create();
	}

	public function sansUndertaleThing(undertale:DialogueBoxUndertale)
	{
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			add(undertale);
		});
	}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaText) {
			spr.y += 20;
		});
		luaDebugGroup.add(new DebugLuaText(text, luaDebugGroup));
		#end
	}

	public function reloadHealthBarFromChar(player:Character, oppt:Character)
	{
		iconP1.changeIcon(player.healthIcon);
		iconP2.changeIcon(oppt.healthIcon);
		healthBar.createFilledBar(FlxColor.fromRGB(oppt.healthColorArray[0], oppt.healthColorArray[1], oppt.healthColorArray[2]),
			FlxColor.fromRGB(player.healthColorArray[0], player.healthColorArray[1], player.healthColorArray[2]));
		healthBar.updateBar();
		PauseSubState.dadCol = FlxColor.fromRGB(oppt.healthColorArray[0], oppt.healthColorArray[1], oppt.healthColorArray[2]);
		PauseSubState.bfCol = FlxColor.fromRGB(player.healthColorArray[0], player.healthColorArray[1], player.healthColorArray[2]);
		if (!ClientPrefs.lowQuality)
		{
			iconGlowP1.updateProperties(player);
			iconGlowP2.updateProperties(oppt);
		}
	}

	public function reloadHealthBarColors() 
	{
		healthBar.createFilledBar(FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]),
			FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]));
		healthBar.updateBar();
		PauseSubState.dadCol = FlxColor.fromRGB(dad.healthColorArray[0], dad.healthColorArray[1], dad.healthColorArray[2]);
		PauseSubState.bfCol = FlxColor.fromRGB(boyfriend.healthColorArray[0], boyfriend.healthColorArray[1], boyfriend.healthColorArray[2]);
	}

	public function customHealthBarColors(color:Int, color2:Int) {
		healthBar.createFilledBar(color, color2);
		healthBar.updateBar();
		PauseSubState.dadCol = color;
		PauseSubState.bfCol = color2;
	}

	public function addCharacterToList(newCharacter:String, type:Int) {
		switch(type) {
			case 0:
				if(!boyfriendMap.exists(newCharacter)) {
					var newBoyfriend:Boyfriend = new Boyfriend(0, 0, newCharacter);
					boyfriendMap.set(newCharacter, newBoyfriend);
					boyfriendGroup.add(newBoyfriend);
					startCharacterPos(newBoyfriend);
					newBoyfriend.alpha = 0.00001;
					newBoyfriend.alreadyLoaded = false;
				}

			case 1:
				if(!dadMap.exists(newCharacter)) {
					var newDad:Character = new Character(0, 0, newCharacter);
					dadMap.set(newCharacter, newDad);
					if (!dadInFront)
					{
						dadGroup.add(newDad);
					}
					else
					{
						newDad.x = DAD_X;
						newDad.y = DAD_Y;
						add(newDad);
					}
					startCharacterPos(newDad, true);
					newDad.alpha = 0.00001;
					newDad.alreadyLoaded = false;
				}

			case 2:
				if(!gfMap.exists(newCharacter)) {
					var newGf:Character = new Character(0, 0, newCharacter);
					newGf.scrollFactor.set(0.95, 0.95);
					gfMap.set(newCharacter, newGf);
					if (!gfInFront)
					{
						gfGroup.add(newGf);
					}
					else
					{
						newGf.x = GF_X;
						newGf.y = GF_Y;
						add(newGf);
					}
					startCharacterPos(newGf);
					newGf.alpha = 0.00001;
					newGf.alreadyLoaded = false;
				}
		}
	}
	
	public function startCharacterPos(char:Character, ?gfCheck:Bool = false) {
		if(gfCheck && char.curCharacter.startsWith('gf')) { //IF DAD IS GIRLFRIEND, HE GOES TO HER POSITION
			char.setPosition(GF_X, GF_Y);
			char.scrollFactor.set(0.95, 0.95);
		}
		char.x += char.positionArray[0];
		char.y += char.positionArray[1];
	}

	public function startVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camHUD];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				if(endingSong) {
					endSong();
				} else {
					startCountdown();
				}
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
		}
		#end
		if(endingSong) {
			endSong();
		} else {
			startCountdown();
		}
	}

	public function coolVideo(name:String):Void {
		#if VIDEOS_ALLOWED
		var foundFile:Bool = false;
		var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
		#if sys
		if(FileSystem.exists(fileName)) {
			foundFile = true;
		}
		#end

		if(!foundFile) {
			fileName = Paths.video(name);
			#if sys
			if(FileSystem.exists(fileName)) {
			#else
			if(OpenFlAssets.exists(fileName)) {
			#end
				foundFile = true;
			}
		}

		if(foundFile) {
			inCutscene = true;
			var bg = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			bg.scrollFactor.set();
			bg.cameras = [camVideo];
			add(bg);

			(new FlxVideo(fileName)).finishCallback = function() {
				remove(bg);
				callOnLuas('onVideoDone', [name]);
			}
			return;
		} else {
			FlxG.log.warn('Couldnt find video file: ' + fileName);
		}
		#end
	}

	//You don't have to add a song, just saying. You can just do "startDialogue(dialogueJson);" and it should work
	public function startDialogue(dialogueFile:FunnyDialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			callOnLuas('onDialogueOpen', []);
			isPiece = false;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogueFile, song, this);
			doof.scrollFactor.set();
			if(endingSong) {
				doof.finishThing = endSong;
			} else {
				doof.finishThing = startCountdown;
			}
			doof.nextDialogueThing = startNextDialogue;
			doof.backDialogueThing = backDialogue;
			doof.skipDialogueThing = skipDialogue;
			doof.cameras = [camHUD];
			add(doof);
			curDialogueBox = doof;
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	public function startDialoguePiece(dialogueFile:FunnyDialogueFile, ?song:String = null, name:String = 'default'):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			callOnLuas('onDialogueOpen', []);
			isPiece = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			var doof:DialogueBoxPsych = new DialogueBoxPsych(dialogueFile, song, this);
			doof.scrollFactor.set();

			trace(name);

			dialogueName = name;

			doof.finishThing = dialogueComplete;
			doof.nextDialogueThing = startNextDialogue;
			doof.backDialogueThing = backDialogue;
			doof.skipDialogueThing = skipDialogue;
			doof.cameras = [camHUD];
			add(doof);
			curDialogueBox = doof;
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) {
				endSong();
			} else {
				startCountdown();
			}
		}
	}

	public function startAfterDialogue(dialogueFile:FunnyDialogueFile, ?song:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			isPiece = false;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			var doof1:DialogueBoxPsych = new DialogueBoxPsych(dialogueFile, song, this);
			doof1.scrollFactor.set();
			if(endingSong) 
			{
				doof1.finishThing = endSong;
			}
			doof1.nextDialogueThing = startNextDialogue;
			doof1.backDialogueThing = backDialogue;
			doof1.skipDialogueThing = skipDialogue;
			doof1.cameras = [camHUD];
			add(doof1);
			curDialogueBox = doof1;
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			if(endingSong) 
			{
				endSong();
			}
		}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		inCutscene = true;
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;

		var songName:String = Paths.formatToSongPath(SONG.song);
		if (songName == 'thorns')
		{
			remove(black);

			if (songName == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					if (Paths.formatToSongPath(SONG.song) == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										callOnLuas('onSenpaiDies', []);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						startCountdown();
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var finishTimer:FlxTimer = null;

	// For being able to mess with the sprites on Lua
	public var countDownSprites:Array<FlxSprite> = [];

	public function dialogueComplete()
	{
		if (isPiece)
		{
			callOnLuas('onDialogueComplete', [dialogueName]);
		}
	}

	public var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
	public var introAlts:Array<String> = [];
	public var introSoundsSuffix:String = '';

	public function startCountdown():Void
	{
		if(startedCountdown) 
		{
			callOnLuas('onStartCountdown', []);
			return;
		}

		inCutscene = false;
		var ret:Dynamic = callOnLuas('onStartCountdown', []);
		if (SONG.song == "Cocoa" || SONG.song == "Eggnog")
		{
			ret = 0;
		}
		if(ret != FunkinLua.Function_Stop) 
		{
			if (!startFlipped)
			{
				generateStaticArrows(0);
				generateStaticArrows(1);
				var tso:Dynamic = SONG.thirdStrum;
				if (tso == null)
				{
					tso = false;
				}
				var tsb:Bool = tso;
				if (tsb)
				{
					generateStaticArrows(2);
				}
			}
			else
			{
				flippedStrum = true;
				if (!ClientPrefs.middleScroll)
				{
					generateStaticArrows(1);
					generateStaticArrows(0);
					var tso:Dynamic = SONG.thirdStrum;
					if (tso == null)
					{
						tso = false;
					}
					var tsb:Bool = tso;
					if (tsb)
					{
						generateStaticArrows(2);
					}
				}
				else
				{
					generateStaticArrows(0);
					generateStaticArrows(1);
				}
			}
			for (i in 0...playerStrums.length) {
				setOnLuas('defaultPlayerStrumX' + i, playerStrums.members[i].x);
				setOnLuas('defaultPlayerStrumY' + i, playerStrums.members[i].y);
			}
			for (i in 0...opponentStrums.length) {
				setOnLuas('defaultOpponentStrumX' + i, opponentStrums.members[i].x);
				setOnLuas('defaultOpponentStrumY' + i, opponentStrums.members[i].y);
				if(ClientPrefs.middleScroll) 
				{
					opponentStrums.members[i].visible = false;
					if (thirdStrum)
					{
						gfStrums.members[i].visible = false;
					}
				}
			}
			if (PlayStateMeta.dataFile.strumSkins != null)
			{
				for (i in 0...4)
				{
					if (PlayStateMeta.dataFile.strumSkins.dad != "")
					{
						opponentStrums.members[i].changeSkin(PlayStateMeta.dataFile.strumSkins.dad, i);
					}
					if (PlayStateMeta.dataFile.strumSkins.bf != "")
					{
						playerStrums.members[i].changeSkin(PlayStateMeta.dataFile.strumSkins.bf, i);
					}
					if (thirdStrum)
					{
						if (PlayStateMeta.dataFile.strumSkins.gf != "")
						{
							gfStrums.members[i].changeSkin(PlayStateMeta.dataFile.strumSkins.gf, i);
						}
					}
				}
			}

			if (PlayStateMeta.dataFile.strumSkins != null)
			{
				for (i in 0...unspawnNotes.length)
				{
					if (PlayStateMeta.dataFile.strumSkins.dad != "")
					{
						if (!unspawnNotes[i].mustPress)
						{
							if (thirdStrum)
							{
								if (!unspawnNotes[i].isGfNote)
								{
									if (unspawnNotes[i].noteGraphic == "NOTE_assets")
									{
										unspawnNotes[i].reloadNote(null, PlayStateMeta.dataFile.strumSkins.dad);
									}
								}
							}
							else
							{
								if (unspawnNotes[i].noteGraphic == "NOTE_assets")
								{
									unspawnNotes[i].reloadNote(null, PlayStateMeta.dataFile.strumSkins.dad);
								}
							}
						}
					}
					if (PlayStateMeta.dataFile.strumSkins.bf != "")
					{
						if (unspawnNotes[i].mustPress)
						{
							if (unspawnNotes[i].noteGraphic == "NOTE_assets")
							{
								unspawnNotes[i].reloadNote(null, PlayStateMeta.dataFile.strumSkins.bf);
							}
						}
					}
					if (PlayStateMeta.dataFile.strumSkins.gf != "")
					{
						if (unspawnNotes[i].isGfNote && thirdStrum)
						{
							if (unspawnNotes[i].noteGraphic == "NOTE_assets")
							{
								unspawnNotes[i].reloadNote(null, PlayStateMeta.dataFile.strumSkins.gf);
							}
						}
					}
				}
			}

			if (ClientPrefs.showComboSpr)
			{
				comboSpr.visible = true;
				updateComboHitboxes();
			}

			startedCountdown = true;
			Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.crochet * 5;
			setOnLuas('startedCountdown', true);

			var swagCounter:Int = 0;

			if (SONG.song == 'Dense' || SONG.song == 'Remember My Name' || SONG.song == 'Crackin Eggs')
			{
				if (ClientPrefs.swearFilter)
				{
					badWords();
				}	
			}

			if (SONG.song == 'Satin Panties' || SONG.song == "Dance Interstate" || SONG.song == 'High' || SONG.song == 'Milf')
			{
				modchartTweens.get('limoSunsetMove').active = true;
			}

			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				if (tmr.loopsLeft % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
				{
					gf.dance();
				}
				if(tmr.loopsLeft % 2 == 0) {
					if (boyfriend.animation.curAnim != null && !boyfriend.animation.curAnim.name.startsWith('sing'))
					{
						boyfriend.dance();
					}
					if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith('sing') && !dad.stunned)
					{
						dad.dance();
					}
				}
				else if(dad.danceIdle && dad.animation.curAnim != null && !dad.stunned && !dad.curCharacter.startsWith('gf') && dad.curCharacter != "date-gf" && !dad.animation.curAnim.name.startsWith("sing"))
				{
					dad.dance();
				}

				introAssets.set('default', ['three', 'two', 'one', 'go']);
				introAssets.set('silent', ['no-image', 'no-image', 'no-image', 'no-image']);
				introAssets.set('bf', ['three-bf', 'two-bf', 'one-bf', 'go-bf']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				introAlts = introAssets.get("default");
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}
				if(SONG.song == 'Free Me' || SONG.song == 'Isolation')
				{
					introAlts = introAssets.get('silent');
				}
				if(curStage == 'mallEvil') {
					introAlts = introAssets.get('bf');
				}
				// compatability :)
				callOnLuas("onIntroAssetsSet", []);

				switch (swagCounter)
				{
					case 0:
						if (ClientPrefs.limitedHud)
						{
							for (i in 0...hideElements.length)
							{
								hideElements[i].alpha = 0;
							}
						}
						if (!skipCountdown)
						{
							var pissFart:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
							pissFart.scrollFactor.set();
							pissFart.cameras = [camHUD];
							pissFart.updateHitbox();
							if (PlayState.isPixelStage)
								pissFart.setGraphicSize(Std.int(pissFart.width * daPixelZoom));

							pissFart.screenCenter();
							pissFart.antialiasing = antialias;
							add(pissFart);
							countDownSprites.push(pissFart);
							FlxTween.tween(pissFart, {y: pissFart.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									countDownSprites.remove(pissFart);
									remove(pissFart);
									pissFart.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro3' + introSoundsSuffix), 0.6);
						}
						FlxTween.tween(topBar, {y: (-FlxG.height + 70)}, Conductor.crochet / 333, {ease: FlxEase.sineOut});
						FlxTween.tween(bottomBar, {y: (FlxG.height - 70)}, Conductor.crochet / 333, {ease: FlxEase.sineOut});
					case 1:
						if (!skipCountdown)
						{
							var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
							ready.scrollFactor.set();
							ready.updateHitbox();
							ready.cameras = [camHUD];

							if (PlayState.isPixelStage)
								ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

							ready.screenCenter();
							ready.antialiasing = antialias;
							add(ready);
							countDownSprites.push(ready);
							FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									countDownSprites.remove(ready);
									remove(ready);
									ready.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro2' + introSoundsSuffix), 0.6);
						}
					case 2:
						if (!skipCountdown)
						{
							var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
							set.scrollFactor.set();

							if (PlayState.isPixelStage)
								set.setGraphicSize(Std.int(set.width * daPixelZoom));

							set.cameras = [camHUD];

							set.screenCenter();
							set.antialiasing = antialias;
							add(set);
							countDownSprites.push(set);
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									countDownSprites.remove(set);
									remove(set);
									set.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('intro1' + introSoundsSuffix), 0.6);
						}
					case 3:
						if (!skipCountdown)
						{
							var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
							go.scrollFactor.set();

							if (PlayState.isPixelStage)
								go.setGraphicSize(Std.int(go.width * daPixelZoom));

							go.cameras = [camHUD];

							go.updateHitbox();

							go.screenCenter();
							go.antialiasing = antialias;
							add(go);
							countDownSprites.push(go);
							FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									countDownSprites.remove(go);
									remove(go);
									go.destroy();
								}
							});
							FlxG.sound.play(Paths.sound('introGo' + introSoundsSuffix), 0.6);
						}
					case 4:
				}

				notes.forEachAlive(function(note:Note) {
					note.copyAlpha = false;
					note.alpha = 1 * note.multAlpha;
				});
				callOnLuas('onCountdownTick', [swagCounter]);

				if (generatedMusic)
				{
					notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
				}

				swagCounter += 1;
				// generateSong('fresh');
			}, 5);
		}
	}

	function startNextDialogue() {
		dialogueCount++;
		callOnLuas('onNextDialogue', [dialogueCount]);
	}

	function backDialogue() {
		dialogueCount -= 1;
		callOnLuas("onNextDialogue", [dialogueCount]);
	}

	function skipDialogue() {
		callOnLuas('onSkipDialogue', [dialogueCount]);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;
		
		if (encoreMode && FileSystem.exists('assets/songs/' + Paths.formatToSongPath(PlayState.SONG.song) + '/InstEncore.ogg'))
		{
			FlxG.sound.playMusic(Paths.instEncore(PlayState.SONG.song), 1, false);
		}
		else
		{
			FlxG.sound.playMusic(Paths.inst(Paths.formatToSongPath(PlayState.SONG.song)), 1, false);
		}

		FlxG.sound.music.onComplete = finishSong;
		vocals.play();

		if(paused) {
			//trace('Oopsie doopsie! Paused sound');
			FlxG.sound.music.pause();
			vocals.pause();
		}

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;
		realLength = songLength;
		callOnLuas('onLengthSet', []);
		if (!ClientPrefs.limitedHud)
		{
			FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
			FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
		}

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song, iconP2.getCharacter(), true, songLength);
		#end
		setOnLuas('songLength', songLength);
		callOnLuas('onSongStart', []);
	}

	var debugNum:Int = 0;
	private var noteTypeMap:Map<String, Bool> = new Map<String, Bool>();
	private var eventPushedMap:Map<String, Bool> = new Map<String, Bool>();

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		var noVocals:Bool = true;

		if (SONG.needsVoices)
		{
			noVocals = false;
		}

		if (!noVocals)
		{
			if (encoreMode && FileSystem.exists('assets/songs/' + Paths.formatToSongPath(PlayState.SONG.song) + '/VoicesEncore.ogg') || encoreMode && FileSystem.exists('mods/' + Paths.currentModDirectory + '/songs/' + Paths.formatToSongPath(PlayState.SONG.song) + '/VoicesEncore.ogg'))
			{
				vocals = new FlxSound().loadEmbedded(Paths.voicesEncore(PlayState.SONG.song, "ogg", "VoicesEncore" + songPrefix));
			}
			else
			{	
				vocals = new FlxSound().loadEmbedded(Paths.voices(Paths.formatToSongPath(PlayState.SONG.song), "ogg", "Voices" + songPrefix));
			}
		}
		else
		{
			vocals = new FlxSound();
		}

		FlxG.sound.list.add(vocals);

		if (encoreMode && FileSystem.exists('assets/songs/' + Paths.formatToSongPath(PlayState.SONG.song) + '/InstEncore' + songPrefix + '.ogg') || encoreMode && FileSystem.exists('mods/' + Paths.currentModDirectory + '/songs/' + Paths.formatToSongPath(PlayState.SONG.song) + '/InstEncore' + songPrefix + '.ogg'))
			FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.instEncore(PlayState.SONG.song, songPrefix)));	
		else
			FlxG.sound.list.add(new FlxSound().loadEmbedded(Paths.inst(Paths.formatToSongPath(PlayState.SONG.song), songPrefix)));

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var songName:String = Paths.formatToSongPath(SONG.song);
		var file:String; 
		var fileEventThing:String = "/events";
		var fullTag:String = "events";
		var fileAdd:String = "";
		if (encoreMode)
		{
			fullTag = "eventsEncore";
			fileEventThing = '/eventsEncore';
		}
		file = Paths.json(songName + fileEventThing);
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + fileEventThing)) || FileSystem.exists(file)) {
		#else
		if (OpenFlAssets.exists(file)) {
		#end
			var eventsData:Array<SwagSection> = Song.loadFromJson(fullTag + fileAdd, songName).notes;
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if(songNotes[1] < 0) {
						eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
						eventPushed(songNotes);
					}
				}
			}
		}

		EventBundle.data = null;
		EventBundle.loadEventsFromSong(Paths.formatToSongPath(SONG.song));

		var scarefile:String = Paths.json(songName + '/jumpscares' + fileAdd);
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/jumpscares' + fileAdd)) || FileSystem.exists(scarefile)) {
		#else
		if (OpenFlAssets.exists(scarefile)) {
		#end
			var eventsData:Array<SwagSection> = Song.loadFromJson('jumpscares' + fileAdd, songName).notes;
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if(songNotes[1] < 0) {
						eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
						eventPushed(songNotes);
					}
				}
			}
		}

		var zoomfile:String = Paths.json(songName + '/camzooms' + fileAdd);
		#if sys
		if (FileSystem.exists(Paths.modsJson(songName + '/camzooms')) || FileSystem.exists(zoomfile)) {
		#else
		if (OpenFlAssets.exists(zoomfile)) {
		#end
			var eventsData:Array<SwagSection> = Song.loadFromJson('camzooms' + fileAdd, songName).notes;
			for (section in eventsData)
			{
				for (songNotes in section.sectionNotes)
				{
					if(songNotes[1] < 0) {
						eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
						eventPushed(songNotes);
					}
				}
			}
		}

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				if(songNotes[1] > -1) 
				{
					//Real notes
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);

					var gottaHitNote:Bool = section.mustHitSection;

					if (songNotes[1] > 3 && songNotes[1] < 8)
					{
						gottaHitNote = !section.mustHitSection;
					}

					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;

					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = songNotes[2];
					swagNote.noteType = songNotes[3];
					if(!Std.isOfType(songNotes[3], String))
					{
						swagNote.noteType = editors.ChartingState.noteTypeList[songNotes[3]]; //Backward compatibility + compatibility with Week 7 charts
					}

					if (songNotes[1] > 7)
					{
						gottaHitNote = false;
						swagNote.mustPress = false;
						swagNote.isGfNote = true;
					}

					swagNote.scrollFactor.set();

					var susLength:Float = swagNote.sustainLength;

					susLength = susLength / Conductor.stepCrochet;
					unspawnNotes.push(swagNote);

					var floorSus:Int = Math.floor(susLength);
					if(floorSus > 0) {
						for (susNote in 0...floorSus+1)
						{
							oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + (Conductor.stepCrochet / FlxMath.roundDecimal((songSpeed), 2)), daNoteData, oldNote, true);
							sustainNote.mustPress = gottaHitNote;
							sustainNote.noteType = swagNote.noteType;
							sustainNote.isGfNote = swagNote.isGfNote;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}

					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2; // general offset
					}
					else {}

					if(!noteTypeMap.exists(swagNote.noteType)) {
						noteTypeMap.set(swagNote.noteType, true);
					}
				} else { //Event Notes
					eventNotes.push([songNotes[0], songNotes[1], songNotes[2], songNotes[3], songNotes[4]]);
					eventPushed(songNotes);
				}
			}
			daBeats += 1;
		}
		trace("BITCH WTF");

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);
		if(eventNotes.length > 1) { //No need to sort if there's a single one or none at all
			eventNotes.sort(sortByTime);
		}
		checkEventNote();
		generatedMusic = true;
	}

	public function eventPushed(event:Array<Dynamic>) 
	{
		switch(event[2]) {
			case 'Change Character':
				var charType:Int = 0;
				switch(event[3].toLowerCase()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					default:
						charType = Std.parseInt(event[3]);
						if(Math.isNaN(charType)) charType = 0;
				}

				var newCharacter:String = event[4];
				addCharacterToList(newCharacter, charType);
		}

		if(!eventPushedMap.exists(event[2])) {
			eventPushedMap.set(event[2], true);
		}
	}

	function eventNoteEarlyTrigger(event:Array<Dynamic>):Float {
		var returnedValue:Float = callOnLuas('eventEarlyTrigger', [event[2]]);
		if(returnedValue != 0) {
			return returnedValue;
		}

		switch(event[2]) {
			case 'Kill Henchmen': //Better timing so that the kill sound matches the beat intended
				return 280; //Plays 280ms before the actual position
			case 'Countdown':
				return Conductor.crochet / 1000;
		}
		return 0;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	function sortByTime(Obj1:Array<Dynamic>, Obj2:Array<Dynamic>):Int
	{
		var earlyTime1:Float = eventNoteEarlyTrigger(Obj1);
		var earlyTime2:Float = eventNoteEarlyTrigger(Obj2);
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1[0] - earlyTime1, Obj2[0] - earlyTime2);
	}

	public function generateStaticArrows(player:Int, ?skipTween:Bool = false):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var center:Bool = false;
			if (ClientPrefs.middleScroll || player == 2)
			{
				center = true;
			}

			var targAng:Int = 0;

			if (ClientPrefs.useless.get("wishDownscroll"))
			{
				targAng = 180;
			}

			var targy:Float = strumLine.y;
			if (player == 2)
			{
				targy += 96;
			}

			babyArrow = new StrumNote(center ? STRUM_X_MIDDLESCROLL : STRUM_X, targy, i, player);
			if (!skipTween)
			{
				if (!isPixelStage)
					babyArrow.y -= 30;
				else
					babyArrow.y -= 20;

				babyArrow.alpha = 0;

				if (i > 1)
					babyArrow.angle = 360;
				if (i < 2)
					babyArrow.angle = -360;

				FlxTween.tween(babyArrow, {y: babyArrow.y + 30, alpha: 1, angle: targAng}, 1, {ease: FlxEase.elasticOut, startDelay: 0.5 + (0.2 * i)});
			}
			else
			{
				babyArrow.angle = targAng;
			}

			if (player == 0)
			{
				opponentStrums.add(babyArrow);
			}
			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			if (player == 2)
			{
				gfStrums.add(babyArrow);
				setOnLuas('defaultGFStrumX' + i, gfStrums.members[i].x);
				setOnLuas('defaultGFStrumY' + i, gfStrums.members[i].y);
			}
			strumLineNotes.add(babyArrow);
			if (player != 2)
			{
				babyArrow.postAddedToGroup();
			}
			else
			{
				babyArrow.postAddedToGroup(1);
			}

			if (!skipTween)
				babyArrow.alpha = 0;
		}
		if (player == 2)
		{
			thirdStrum = true;
		}
		if (ClientPrefs.useless.get("wishDownscroll"))
		{
			var xs:Array<Int> = [];
			for (i in 0...4)
			{
				if (player == 0)
				{
					xs.push(Std.int(opponentStrums.members[i].x));
				}
				if (player == 1)
				{
					xs.push(Std.int(playerStrums.members[i].x));
				}
				if (player == 2)
				{
					xs.push(Std.int(gfStrums.members[i].x));
				}
			}
			for (i in 0...4)
			{
				switch (i)
				{
					case 0:
						if (player == 0)
						{
							opponentStrums.members[0].x = xs[3];
						}
						if (player == 1)
						{
							playerStrums.members[0].x = xs[3];
						}
						if (player == 2)
						{
							gfStrums.members[0].x = xs[3];
						}
					case 1:
						if (player == 0)
						{
							opponentStrums.members[1].x = xs[2];
						}
						if (player == 1)
						{
							playerStrums.members[1].x = xs[2];
						}
						if (player == 2)
						{
							gfStrums.members[1].x = xs[2];
						}
					case 2:
						if (player == 0)
						{
							opponentStrums.members[2].x = xs[1];
						}
						if (player == 1)
						{
							playerStrums.members[2].x = xs[1];
						}
						if (player == 2)
						{
							gfStrums.members[2].x = xs[1];
						}
					case 3:
						if (player == 0)
						{
							opponentStrums.members[3].x = xs[0];
						}
						if (player == 1)
						{
							playerStrums.members[3].x = xs[0];
						}
						if (player == 2)
						{
							gfStrums.members[3].x = xs[0];
						}
				}
			}
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = false;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = false;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = false;

			if(carTimer != null) carTimer.active = false;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = false;
				}
			}

			for (tween in modchartTweens) {
				tween.active = false;
			}
			for (timer in modchartTimers) {
				timer.active = false;
			}
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = true;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = true;
			
			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			if (camGameFilters.length >= 1)
				camGame.setFilters(camGameFilters);
			if (camHUDFilters.length >= 1)
				camHUD.setFilters(camHUDFilters);
			if (camOtherFilters.length >= 1)
				camOther.setFilters(camOtherFilters);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}

		super.closeSubState();
	}

	override public function onFocus():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
		}
		#end

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		#if desktop
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
		}
		#end

		super.onFocusLost();
	}

	function resyncVocals():Void
	{
		if(finishTimer != null) return;

		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	public var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var limoSpeed:Float = 0;

	public var focusPlayerChar:Character = null;
	public var focusOpptChar:Character = null;

	public var focusedChar:Character;
	public var focusedAnim:String = "";
	public var camMoveOffset:Float = 25;

	public var ratingFCs:Array<String> = ["FC", "SCDB", "Clear"];

	var numberGlitch:Int = 0;
	var numberGlitchMult = 1;

	var hue:Float = 0;
	override public function update(elapsed:Float)
	{	
		debugCheck();
		callOnLuas('onUpdate', [elapsed]);
		for (i in 0...scriptArray.length)
		{
			scriptArray[i].set("controls", controls);
		}

		debugCheck();

		updateAddedShaders(elapsed);

		scoreTxt.screenCenter(X);
		// idk if I did this already :shrug:

		if (isRing)
		{
			ringText.text = Std.string(ringCount);
		}

		debugCheck();


		comboText.text = '' + combo;

		if (!mustHitSection)
		{
			if (focusOpptChar == null)
			{
				focusOpptChar = dad;
			}
			focusedChar = focusOpptChar;
		}
		else
		{
			if (focusPlayerChar == null)
			{
				focusPlayerChar = boyfriend;
			}
			focusedChar = focusPlayerChar;
		}

		debugCheck();

		var charAnimOffsetX:Float = 0;
		var charAnimOffsetY:Float = 0;
		if (ClientPrefs.camMove && followChars)
		{
			if(focusedChar != null)
			{
				if(focusedChar.animation.curAnim != null)
				{
					// for hscript
					
					// Wait, tf you mean "for hscript" me from a few months ago :skull:
					focusedAnim = "";
					if (focusedChar.animation.curAnim.name.startsWith("singUP"))
					{
						charAnimOffsetY -= camMoveOffset;
						focusedAnim = "Up";
					}
					if (focusedChar.animation.curAnim.name.startsWith("singDOWN"))
					{
						charAnimOffsetY += camMoveOffset;
						focusedAnim = "Down";
					}
					if (focusedChar.animation.curAnim.name.startsWith("singLEFT"))
					{
						charAnimOffsetX -= camMoveOffset;
						focusedAnim = "Left";
					}
					if (focusedChar.animation.curAnim.name.startsWith("singRIGHT"))
					{
						charAnimOffsetX += camMoveOffset;
						focusedAnim = "Right";
					}
				}
			}
		}

		debugCheck();

		if (ClientPrefs.shaders)
		{
			if (chromaticabShader != null && (dad.animation.curAnim != null || gf.animation.curAnim != null))
			{
				if ((gf.chromab && gf.animation.curAnim.name.startsWith("sing")) || (dad.chromab && dad.animation.curAnim.name.startsWith("sing")))
				{
					chromaticabShader.shader.intensity.value[0] += 0.01;
					if (chromaticabShader.shader.intensity.value[0] > chromaticabShader.max)
					{
						chromaticabShader.shader.intensity.value[0] = chromaticabShader.max;
					}
				}
				else
				{
					chromaticabShader.shader.intensity.value[0] -= 0.005;
					if (chromaticabShader.shader.intensity.value[0] < 0)
					{
						chromaticabShader.shader.intensity.value[0] = 0;
					}
				}
			}
		}

		debugCheck();

		if(!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 2.4 * (cameraSpeed / 1.15), 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x + charAnimOffsetX, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y + charAnimOffsetY, lerpVal));
			if(!startingSong && !endingSong && boyfriend.animation.curAnim.name.startsWith('idle')) {
				boyfriendIdleTime += elapsed;
				if(boyfriendIdleTime >= 0.15) { // Kind of a mercy thing for making the achievement easier to get as it's apparently frustrating to some playerss
					boyfriendIdled = true;
				}
			} else {
				boyfriendIdleTime = 0;
			}
		}

		debugCheck();

		super.update(elapsed);

		debugCheck();

		for (key in modchartSprites.keys())
		{
			modchartSprites.get(key).spawnParticle(elapsed);
		}

		debugCheck();

		realRatingPercent = Math.floor(ratingPercent * 100);

		var ratingFC:String = ratingFCs[0];
		if (songMisses == 0)
		{
			ratingFC = ratingFCs[0];
		}
		if (songMisses >= 1 && songMisses < 10)
		{
			ratingFC = ratingFCs[1];
		}
		if (songMisses >= 10)
		{
			ratingFC = ratingFCs[2];
		}
		setOnLuas("ratingFC", ratingFC);

		if (!customScoreTxt)
		{
			if ((gf.curCharacter.startsWith("gf") || gf.curCharacter == "date-gf" || gf.curCharacter == "two-gf" || gf.curCharacter == "brand-new-tess" || gf.curCharacter.startsWith("tess")) && gf.visible && SONG.song != "Horrifying Truth")
			{
				if(ratingString == '?') {
					scoreTxt.text = 'Score: ' + songScore + ' | Combo Breaks: ' + songMisses + " | Tess' Rating: " + ratingString;
				} else {
					scoreTxt.text = 'Score: ' + songScore + ' | Combo Breaks: ' + songMisses + " | Tess' Rating: " + ratingString + ' (' + Math.floor(ratingPercent * 100) + '%) | ' + ratingFC;
				}
			}
			else
			{
				if(ratingString == '?') {
					scoreTxt.text = 'Score: ' + songScore + ' | Combo Breaks: ' + songMisses + ' | Rating: ' + ratingString;
				} else {
					scoreTxt.text = 'Score: ' + songScore + ' | Combo Breaks: ' + songMisses + ' | Rating: ' + ratingString + ' (' + Math.floor(ratingPercent * 100) + '%) | ' + ratingFC;
				}
			}

			// rating string functions
			if(ratingFC == ratingFCs[2])
			{
				scoreTxt.color = FlxColor.WHITE;
			}
			else
			{
				hue += elapsed * 100;
				if (hue > 360)
					hue -= 360;

				var color = FlxColor.fromHSB(Std.int(hue), 1, 1);
				scoreTxt.color = color;
			}
		}

		debugCheck();

		if (ClientPrefs.useless.get("flipChar"))
		{
			dad.flipY = true;
			gf.flipY = true;
			boyfriend.flipY = true;
		}

		if(cpuControlled) {
			botplaySine += 180 * elapsed;
			botplayTxt.alpha = 1 - Math.sin((Math.PI * botplaySine) / 180);
		}
		botplayTxt.visible = cpuControlled;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			var ret:Dynamic = callOnLuas('onPause', []);
			if(ret != FunkinLua.Function_Stop) {
				persistentUpdate = false;
				persistentDraw = true;
				paused = true;

				// 1 / 1000
				if (FlxG.random.bool(0.1))
				{
					cancelFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					MusicBeatState.switchState(new GitarooPause());
				}
				else 
				{
					if(FlxG.sound.music != null) {
						FlxG.sound.music.pause();
						vocals.pause();
					}
					PauseSubState.transCamera = camOther;
					openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, pauseCharacter));
				}
			
				#if desktop
				DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
			}
		}

		if (FlxG.keys.justPressed.SEVEN && !endingSong && !inCutscene && ClientPrefs.chartingMode)
		{
			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new ChartingState(encoreMode));

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		debugCheck();

		if (ringCount > 0)
		{
			ringCountIsUp = true;
		}

		if (ringCountIsUp && ringCount == 0 && isRing)
		{
			lostAllRings = true;
		}

		if (!followChars)
		{
			setOnLuas('followchars', false);
		}
		else
		{
			setOnLuas('followchars', true);
		}

		if (!ClientPrefs.lowQuality)
		{
			iconGlowP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconGlowP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
			iconGlowP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconGlowP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
			iconGlowP1.updateHitbox();
			iconGlowP2.updateHitbox();
		}
		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, CoolUtil.boundTo(1 - (elapsed * 30), 0, 1))));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		switch (ClientPrefs.iconStyle)
		{
			case "Classic":
				iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
				iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
			default:
				iconP1.x = (healthBar.x + healthBar.width) - Std.int(iconP1.width / 2);
				iconP2.x = healthBar.x - Std.int(iconP2.width / 2);
		}
		if (!ClientPrefs.lowQuality)
		{
			iconGlowP1.x = iconP1.x;
			iconGlowP1.y = iconP1.y;
			iconGlowP2.x = iconP2.x;
			iconGlowP2.y = iconP2.y;
			iconGlowP1.visible = iconP1.visible;
			iconGlowP2.visible = iconP2.visible;
		}

		debugCheck();

		if (health > 2)
			health = 2;

		debugCheck();

		if (!ClientPrefs.lowQuality && !endingSong && startedCountdown)
		{
			iconGlowP1.alpha = health / 2;
			iconGlowP2.alpha = ((health * -1) + 2) * 0.5;
		}
		else
		{
			if (!ClientPrefs.lowQuality)
			{
				iconGlowP1.alpha = 0;
				iconGlowP2.alpha = 0;
			}
		}

		debugCheck();

		if (healthBar.percent < 20)
		{
			iconP1.animation.play("losing");
			iconP2.animation.play("winning");
		}

		if (healthBar.percent > 80)
		{
			iconP2.animation.play("losing");
			iconP1.animation.play("winning");
		}

		if (healthBar.percent < 80 && healthBar.percent > 20)
		{
			iconP1.animation.play("default");
			iconP2.animation.play("default");
		}

		debugCheck();

		if (FlxG.keys.justPressed.EIGHT && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new CharacterEditorState(SONG.player2));
		}

		if (FlxG.keys.justPressed.NINE && !endingSong && !inCutscene) {
			persistentUpdate = false;
			paused = true;
			cancelFadeTween();
			CustomFadeTransition.nextCamera = camOther;
			MusicBeatState.switchState(new editors.StageEditorState(curStage, SONG));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}

				if(updateTime) {
					var curTime:Float = FlxG.sound.music.time - ClientPrefs.noteOffset;
					if(curTime < 0) curTime = 0;
					songPercent = (curTime / songLength);

					var secondsTotal:Int = Math.floor((songLength - curTime) / 1000);
					if(secondsTotal < 0) secondsTotal = 0;

					var minutesRemaining:Int = Math.floor(secondsTotal / 60);
					var secondsRemaining:String = '' + secondsTotal % 60;
					if(secondsRemaining.length < 2) secondsRemaining = '0' + secondsRemaining; //Dunno how to make it display a zero first in Haxe lol
					if (!customTimeText)
					{
						timeTxt.text = minutesRemaining + ':' + secondsRemaining;
					}
					GameOverSubstate.timeString = minutesRemaining + ':' + secondsRemaining;
				}

				if (glitchedTexts && !customTimeText)
				{
					var glitches:Array<String> = ["NV!1O*&$", "V)(*$CS", "PC@!S**@A", "ER00R"];
					if (numberGlitch > 1000)
					{
						numberGlitchMult = -1;
					}
					if (numberGlitch < 0)
					{
						numberGlitchMult = 1;
					}
					numberGlitch += Std.int(1 * numberGlitchMult);
					timeTxt.text = glitches[FlxG.random.int(0, glitches.length - 1)];
					scoreTxt.text = "Score: " + glitches[FlxG.random.int(0, glitches.length - 1)] + " | Combo Breaks: " + glitches[FlxG.random.int(0, glitches.length - 1)] + " | Rating: " + glitches[FlxG.random.int(0, glitches.length - 1)];
					if (isRing)
					{
						ringText.text = Std.string(numberGlitch);
					}
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		debugCheck();

		/*
		if (camZooming && !bfZoom)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}
		if (bfZoom)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		}
		*/
		FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));
		camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3.125), 0, 1));

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		// RESET = Quick Game Over Screen
		if (controls.RESET && !inCutscene && !endingSong)
		{
			health = 0;
			trace("RESET = True");
		}
		// look at dis emote look at.............I just got-demons cumming inside me
		if (controls.EMOTE && !attackMode && startedCountdown && boyfriend.animOffsets.exists("emote"))
		{
			boyfriend.playAnim('emote', true);
			// songScore += 25;
			funnyScoreTween(50);
		}
		if (controls.EMOTE && attackMode && attackPress)
		{
			var pressed:Bool = false;
			if (!pressed)
			{
				attack();
				pressed = true;
			}
			else
			{
				// nothing, l + boxo + white
			}
		}
		if (boyfriend.animation.curAnim.name == 'attack')
		{
			if(boyfriend.animation.curAnim.curFrame == 2)
			{
				FlxG.sound.play(Paths.sound('attackHit'));
				health += 0.3;
			}
			if(boyfriend.animation.curAnim.curFrame == 5)
			{
				boyfriend.playAnim('idle', true);
			}
		}
		if (!attackMode)
		{
			canDance = true;
		}
		doDeathCheck();

		//var roundedSpeed:Float = FlxMath.roundDecimal((SONG.speed * scrollMult), 2);
		var roundedSpeed:Float = (songSpeed * scrollMult);
		if (unspawnNotes[0] != null)
		{
			var time:Float = 1500;
			if(roundedSpeed < 1) time /= roundedSpeed;

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			var fakeCrochet:Float = (60 / SONG.bpm) * 1000;
			notes.forEachAlive(function(daNote:Note)
			{
				if(!daNote.mustPress && ClientPrefs.middleScroll)
				{
					daNote.active = true;
					daNote.visible = false;
				}
				else if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (ClientPrefs.downScroll)
				{
					daNote.distance = (0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
				}
				else
				{
					daNote.distance = (-0.45 * (Conductor.songPosition - daNote.strumTime) * roundedSpeed);
				}

				// i am so fucking sorry for this if condition
				var strumX:Float = 0;
				var strumY:Float = 0;
				var strumAngle:Float = 0;
				var strumAlpha:Float = 0;
				if(daNote.mustPress) {
					strumX = playerStrums.members[daNote.noteData].x;
					strumY = playerStrums.members[daNote.noteData].y;
					strumAngle = playerStrums.members[daNote.noteData].angle;
					strumAlpha = playerStrums.members[daNote.noteData].alpha;
				} else {
					strumX = opponentStrums.members[daNote.noteData].x;
					strumY = opponentStrums.members[daNote.noteData].y;
					strumAngle = opponentStrums.members[daNote.noteData].angle;
					strumAlpha = opponentStrums.members[daNote.noteData].alpha;
				}

				if ((daNote.noteType == "GF Sing" || daNote.isGfNote) && thirdStrum)
				{
					strumX = gfStrums.members[daNote.noteData].x;
					strumY = gfStrums.members[daNote.noteData].y;
					strumAngle = gfStrums.members[daNote.noteData].angle;
					strumAlpha = gfStrums.members[daNote.noteData].alpha;
				}

				strumX += daNote.offsetX;
				strumY += daNote.offsetY;
				strumAngle += daNote.offsetAngle;
				strumAlpha *= daNote.multAlpha;
				var center:Float = strumY + Note.swagWidth / 2;
				var angleDir = 90 * Math.PI / 180;

				if(daNote.copyX) {
					daNote.x = strumX;
				}
				if(daNote.copyAngle) {
					daNote.angle = strumAngle;
				}
				if(daNote.copyAlpha) {
					daNote.alpha = strumAlpha;
				}
				if(daNote.copyY) 
				{
					daNote.y = strumY + Math.sin(angleDir) * daNote.distance;

					if (ClientPrefs.downScroll) 
					{
						if (daNote.isSustainNote) 
						{
							//Jesus fuck this took me so much mother fucking time AAAAAAAAAA
							if (daNote.animation.curAnim.name.endsWith('end')) {
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * roundedSpeed + (46 * (roundedSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * roundedSpeed;
								if(PlayState.isPixelStage) {
									daNote.y += 8;
								} else {
									daNote.y -= 19;
								}
							} 
							daNote.y += (Note.swagWidth / 2) - (60.5 * (roundedSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (roundedSpeed - 1);

							if(daNote.mustPress || !daNote.ignoreNote)
							{
								if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
									&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
								{
									var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
									swagRect.height = (center - daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
						}
					}
					else 
					{
						if(daNote.mustPress || !daNote.ignoreNote)
						{
							if (daNote.isSustainNote
								&& daNote.y + daNote.offset.y * daNote.scale.y <= center
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.hitByOpponent && !daNote.ignoreNote && !twoplayer.TwoPlayerState.tpm)
				{
					if (Paths.formatToSongPath(SONG.song) != 'tutorial')
						camZooming = true;

					var ign:Bool = false;
					if (daNote.noteType == "GF Sing")
					{
						ign = true;
					}
					if (daNote.isGfNote)
					{
						ign = true;
					}

					if(daNote.noteType == 'Hey!' && dad.animOffsets.exists('hey')) 
					{
						if (ign)
						{
							gf.playAnim('hey', true);
							gf.specialAnim = true;
							gf.heyTimer = 0.6;
						}
						else
						{
							dad.playAnim('hey', true);
							dad.specialAnim = true;
							dad.heyTimer = 0.6;
						}
					} 
					else if(!daNote.noAnimation) 
					{
						var altAnim:String = "";

						if (SONG.notes[Math.floor(curStep / 16)] != null)
						{
							if (SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.noteType == 'Alt Animation') {
								altAnim = '-alt';
							}
						}

						var animToPlay:String = '';
						switch (Math.abs(daNote.noteData))
						{
							case 0:
								animToPlay = 'singLEFT';
							case 1:
								animToPlay = 'singDOWN';
							case 2:
								animToPlay = 'singUP';
							case 3:
								animToPlay = 'singRIGHT';
						}
						if (ign)  
						{
							if (gf.animOffsets.exists(animToPlay + altAnim))
							{
								gf.playAnim(animToPlay + altAnim, true);
							}
							else
							{
								gf.playAnim(animToPlay, true);
							}
							gf.holdTimer = 0;
						} 
						else 
						{
							if (dad.animOffsets.exists(animToPlay + altAnim))
							{
								var daGet:String = "dad";
								if (daNote.char != "")
								{
									daGet = daNote.char;
								}
								characters.get(daGet).playAnim(animToPlay + altAnim, true);
							}
							else
							{
								var daGet:String = "dad";
								if (daNote.char != "")
								{
									daGet = daNote.char;
								}
								characters.get(daGet).playAnim(animToPlay, true);
							}
							dad.holdTimer = 0;
						}
					}

					if (SONG.needsVoices)
						vocals.volume = 1;

					var time:Float = 0.15;
					if(daNote.isSustainNote && !daNote.animation.curAnim.name.endsWith('end')) {
						time += 0.15;
					}

					if (ign && thirdStrum)
					{
						StrumPlayAnim(2, Std.int(Math.abs(daNote.noteData)) % 4, time);
					}
					else
					{
						StrumPlayAnim(0, Std.int(Math.abs(daNote.noteData)) % 4, time);
					}
					
					daNote.hitByOpponent = true;

					if (ign)
					{
						callOnLuas('gfNoteHit', [notes.members.indexOf(daNote), Math.abs(daNote.noteData), daNote.noteType, daNote.isSustainNote]);	
					}
					else
					{
						callOnLuas('opponentNoteHit', [notes.members.indexOf(daNote), Math.abs(daNote.noteData), daNote.noteType, daNote.isSustainNote]);
					}

					if (zoomHit && !daNote.isSustainNote)
					{
						if (ClientPrefs.camZooms && FlxG.camera.zoom < defaultCamZoom + ((0.015 * hitInt) * zoomMult) && !mustHitSection)
						{
							FlxG.camera.zoom += ((0.015 * hitInt) * zoomMult);
							camHUD.zoom += ((0.03 * hitInt) * zoomMult);
						}
					}



					noteTweenO(Std.int(Math.abs(daNote.noteData)), daNote.isSustainNote);

					if (!daNote.isSustainNote)
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}

				if(daNote.mustPress && cpuControlled) 
				{
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote);
					}
				}
				if(!daNote.mustPress && cpuControlled && twoplayer.TwoPlayerState.tpm) 
				{
					if(daNote.isSustainNote) {
						if(daNote.canBeHit) {
							goodNoteHit(daNote, true);
						}
					} else if(daNote.strumTime <= Conductor.songPosition || (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress)) {
						goodNoteHit(daNote, true);
					}
				}

				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				//var doKill:Bool = daNote.y < -daNote.height;
				//if(ClientPrefs.downScroll) doKill = daNote.y > FlxG.height;

				var doKill:Bool = Conductor.songPosition > noteKillOffset + daNote.strumTime;

				if (doKill)
				{
					if (!twoplayer.TwoPlayerState.tpm)
					{
						if (daNote.mustPress && !cpuControlled &&!daNote.ignoreNote && !endingSong && (daNote.tooLate || !daNote.wasGoodHit)) {
							noteMiss(daNote);
						}
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		debugCheck();
		checkEventNote();

		if (!inCutscene) {
			if(!cpuControlled) {
				keyShit();
			} else if(boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss')) {
				boyfriend.dance();
			}
		}
		
		if(!endingSong && !startingSong && ClientPrefs.devMode) 
		{
			if (FlxG.keys.justPressed.ONE) {
				KillNotes();
				FlxG.sound.music.onComplete();
			}
			if(FlxG.keys.justPressed.TWO) { //Go 10 seconds into the future :O
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if(daNote.strumTime + 800 < Conductor.songPosition) {
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime + 800 >= Conductor.songPosition) {
						break;
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
					daNote.destroy();
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}

		debugCheck();

		if (twoplayer.TwoPlayerState.tpm)
		{
			health = 1;
			healthBar.visible = false;
			healthBarBG.visible = false;
			barBG.visible = false;
			iconP1.visible = false;
			iconP2.visible = false;
			if (!ClientPrefs.lowQuality)
			{
				iconGlowP1.visible = false;
				iconGlowP2.visible = false;
			}
			comboSpr.visible = false;
			comboText.visible = false;
		}

		debugCheck();

		setOnLuas('cameraX', camFollowPos.x);
		setOnLuas('cameraY', camFollowPos.y);
		setOnLuas('botPlay', PlayState.cpuControlled);
		callOnLuas('onUpdatePost', [elapsed]);

		debugCheck();
	}

	var isDead:Bool = false;
	function doDeathCheck() 
	{
		if (health <= 0 && !practiceMode && !isDead && ringCount == 0)
		{
			var ret:Dynamic = callOnLuas('onGameOver', []);
			if(ret != FunkinLua.Function_Stop) 
			{
				boyfriend.stunned = true;
				deathCounter++;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				GameJoltAPI.getTrophy(178530, "misinput");

				// Mostly gonna be used for Hentur :skull:
				var ret2:Dynamic = callOnLuas("onGameOverInit", []);
				if (ret2 != FunkinLua.Function_Stop)
				{
					if (videoGameOver != "")
					{
						FlxG.switchState(new VideoGameOverState(videoGameOver));
						return true;
					}
					if (gameoverscript.length > 1)
					{
						FlxG.switchState(new CustomGameOverState(gameoverscript));
						return true;
					}
					if (SONG.song == 'Free Me')
					{
						openSubState(new GameOverSuicideSubstate(this));
					}
					if (SONG.song == 'Horrifying Truth')
					{
						openSubState(new GameOverIceSubstate(this));
					}
					if (SONG.song != 'Free Me' && SONG.song != 'Horrifying Truth')
					{
						if (isPixelStage)
							openSubState(new GameOverPixelSubstate(this));
						else
							openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollowPos.x, camFollowPos.y, this));
					}				
				}
				else
				{
					// fixes the music restarting.
					startedCountdown = false;
					if (FlxG.sound.music != null)
					{
						FlxG.sound.music.pause();
						vocals.pause();
						FlxG.sound.music.volume = 0;
					}

					if (!startTimer.finished)
					{
						startTimer.active = false;
					}
					if (finishTimer != null && !finishTimer.finished)
					{
						finishTimer.active = false;
					}
				}

				for (tween in modchartTweens) 
				{
					tween.active = true;
				}
				for (timer in modchartTimers) 
				{
					timer.active = true;
				}

				// MusicBeatState.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
				#end
				isDead = true;
				return true;
			}
		}
		if (health <= 0 && !practiceMode && !isDead && ringCount != 0)
		{
			health = 1;
			FlxG.sound.play(Paths.sound("ringLoss"));
			ringCount = 0;
		}
		return false;
	}

	public function checkEventNote() {
		while(eventNotes.length > 0) {
			var early:Float = eventNoteEarlyTrigger(eventNotes[0]);
			var leStrumTime:Float = eventNotes[0][0];
			if(Conductor.songPosition < leStrumTime - early) {
				break;
			}

			var value1:String = '';
			if(eventNotes[0][3] != null)
				value1 = eventNotes[0][3];

			var value2:String = '';
			if(eventNotes[0][4] != null)
				value2 = eventNotes[0][4];

			triggerEventNote(eventNotes[0][2], value1, value2);
			eventNotes.shift();
		}
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function triggerEventNote(eventName:String, value1:String, value2:String) {
		switch(eventName) {
			case 'Hey!':
				var value:Int = 2;
				switch(value1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						value = 0;
					case 'gf' | 'girlfriend' | '1':
						value = 1;
				}

				var time:Float = Std.parseFloat(value2);
				if(Math.isNaN(time) || time <= 0) time = 0.6;

				if(value != 0) {
					if(dad.curCharacter.startsWith('gf')) { //Tutorial GF is actually Dad! The GF is an imposter!! ding ding ding ding ding ding ding, dindinding, end my suffering
						if (dad.animOffsets.exists('hey'))
						{
							dad.playAnim('cheer', true);
							dad.specialAnim = true;
							dad.heyTimer = time;
						}
					} else {
						if (gf.animOffsets.exists('hey'))
						{
							gf.playAnim('cheer', true);
							gf.specialAnim = true;
							gf.heyTimer = time;
						}
					}

					if(curStage == 'mall') {
						bottomBoppers.animation.play('hey', true);
						heyTimer = time;
					}
				}
				if(value != 1) {
					if (boyfriend.animOffsets.exists('hey'))
					{
						boyfriend.playAnim('hey', true);
						boyfriend.specialAnim = true;
						boyfriend.heyTimer = time;
					}
				}

			case 'Set GF Speed':
				var value:Int = Std.parseInt(value1);
				if(Math.isNaN(value)) value = 1;
				gfSpeed = value;

			case 'Blammed Lights':
				var lightId:Int = Std.parseInt(value1);
				if(Math.isNaN(lightId)) lightId = 0;
				blammedLightsBlack.color = FlxColor.BLACK;

				if(lightId > 0 && curLightEvent != lightId) {
					if(lightId > 5) lightId = FlxG.random.int(1, 5, [curLightEvent]);

					var color:Int = 0xffffffff;
					switch(lightId) {
						case 1: //Blue
							color = 0xff31a2fd;
						case 2: //Green
							color = 0xff31fd8c;
						case 3: //Pink
							color = 0xfff794f7;
						case 4: //Red
							color = 0xfff96d63;
						case 5: //Orange
							color = 0xfffba633;
					}
					curLightEvent = lightId;

					var hit:PhillyHit = new PhillyHit(color, Conductor.crochet / 250);
					hit.cameras = [camHUD];
					add(hit);
					FlxG.camera.zoom += 0.015;
					camHUD.zoom += 0.03;

					if (SONG.song == "Blammed" && value1 != "0")
					{
						notes.forEachAlive(function(daNote:Note)
						{
							if (daNote.noteType == "Bullet Note Grey")
							{
								daNote.color = color;
							}
						});
						for (i in 0...unspawnNotes.length)
						{
							if (unspawnNotes[i].noteType == "Bullet Note Grey")
							{
								unspawnNotes[i].color = color;
							}
						}
					}

					if(blammedLightsBlack.alpha == 0) 
					{
						if (SONG.song == "Blammed" || value2 == "1")
						{
							triggerEventNote("Hide Hud", "0", "1");
						}

						for (i in 0...backgroundSprites.length)
						{
							backgroundSprites[i].saveAlpha();
							modchartTweens.set("bgSpriteLIGHTEVENTON" + i, FlxTween.tween(backgroundSprites[i], {alpha: 0}, 1, {ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									modchartTweens.remove("bgSpriteLIGHTEVENTON" + i);
								}
							}));
						}

						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 1}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = FlxTween.color(chars[i], 1, FlxColor.WHITE, color, {onComplete: function(twn:FlxTween) {
								chars[i].colorTween = null;
							}, ease: FlxEase.quadInOut});
						}
					} else {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = null;
						blammedLightsBlack.alpha = 1;

						var chars:Array<Character> = [boyfriend, gf, dad];
						for (i in 0...chars.length) {
							if(chars[i].colorTween != null) {
								chars[i].colorTween.cancel();
							}
							chars[i].colorTween = null;
						}
						dad.color = color;
						boyfriend.color = color;
						gf.color = color;
					}
				} 
				else 
				{
					if (SONG.song == "Blammed" || value2 == "1")
					{
						triggerEventNote("Hide Hud", "1", "1");
					}

					for (i in 0...backgroundSprites.length)
					{
						if (modchartTweens.exists("bgSpriteLIGHTEVENTON" + i))
						{
							var twn:FlxTween = modchartTweens.get("bgSpriteLIGHTEVENTON" + i);
							twn.cancel();
							modchartTweens.remove("bgSpriteLIGHTEVENTON" + i);
						}
						modchartTweens.set("bgSpriteLIGHTEVENTOFF" + i, FlxTween.tween(backgroundSprites[i], {alpha: backgroundSprites[i].savedAlpha}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) 
							{
								modchartTweens.remove("bgSpriteLIGHTEVENTOFF" + i);
							}
						}));
					}

					if(blammedLightsBlack.alpha != 0) {
						if(blammedLightsBlackTween != null) {
							blammedLightsBlackTween.cancel();
						}
						blammedLightsBlackTween = FlxTween.tween(blammedLightsBlack, {alpha: 0}, 1, {ease: FlxEase.quadInOut,
							onComplete: function(twn:FlxTween) {
								blammedLightsBlackTween = null;
							}
						});
					}

					var chars:Array<Character> = [boyfriend, gf, dad];
					for (i in 0...chars.length) {
						if(chars[i].colorTween != null) {
							chars[i].colorTween.cancel();
						}
						chars[i].colorTween = FlxTween.color(chars[i], 1, chars[i].color, FlxColor.WHITE, {onComplete: function(twn:FlxTween) {
							chars[i].colorTween = null;
						}, ease: FlxEase.quadInOut});
					}

					curLight = 0;
					curLightEvent = 0;
				}

			case 'Kill Henchmen':
				// killHenchmen();
				// no lmao

			case 'Add Camera Zoom':
				if (!isPixelStage)
				{
					if(ClientPrefs.camZooms && FlxG.camera.zoom < 1.35) 
					{
						var camZoom:Float = Std.parseFloat(value1);
						var hudZoom:Float = Std.parseFloat(value2);
						if(Math.isNaN(camZoom)) camZoom = 0.015;
						if(Math.isNaN(hudZoom)) hudZoom = 0.03;

						FlxG.camera.zoom += camZoom;
						camHUD.zoom += hudZoom;
					}
				}
				else
				{
					if(ClientPrefs.camZooms) 
					{
						var camZoom:Float = Std.parseFloat(value1);
						var hudZoom:Float = Std.parseFloat(value2);
						if(Math.isNaN(camZoom)) camZoom = 0.015;
						if(Math.isNaN(hudZoom)) hudZoom = 0.03;

						FlxG.camera.zoom += camZoom;
						camHUD.zoom += hudZoom;
					}
				}

			case 'Play Animation':
				//trace('Anim to play: ' + value1);
				var char:Character = dad;
				switch(value2.toLowerCase().trim()) {
					case 'bf' | 'boyfriend':
						char = boyfriend;
					case 'gf' | 'girlfriend':
						char = gf;
					default:
						var val2:Int = Std.parseInt(value2);
						if(Math.isNaN(val2)) val2 = 0;
		
						switch(val2) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.playAnim(value1, true);
				char.specialAnim = true;

			case 'Camera Follow Pos':
				var val1:Float = Std.parseFloat(value1);
				var val2:Float = Std.parseFloat(value2);
				if(Math.isNaN(val1)) val1 = 0;
				if(Math.isNaN(val2)) val2 = 0;

				isCameraOnForcedPos = false;
				if(!Math.isNaN(Std.parseFloat(value1)) || !Math.isNaN(Std.parseFloat(value2))) {
					camFollow.x = val1;
					camFollow.y = val2;
					isCameraOnForcedPos = true;
				}

			case 'Alt Idle Animation':
				var char:Character = dad;
				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						char = gf;
					case 'boyfriend' | 'bf':
						char = boyfriend;
					default:
						var val:Int = Std.parseInt(value1);
						if(Math.isNaN(val)) val = 0;

						switch(val) {
							case 1: char = boyfriend;
							case 2: char = gf;
						}
				}
				char.idleSuffix = value2;
				char.recalculateDanceIdle();

			case 'Screen Shake':
				// Idk why this isn't on regular Psych builds :/
				if (ClientPrefs.screenShake)
				{
					var valuesArray:Array<String> = [value1, value2];
					var targetsArray:Array<FlxCamera> = [camGame, camHUD];
					for (i in 0...targetsArray.length) {
						var split:Array<String> = valuesArray[i].split(',');
						var duration:Float = Std.parseFloat(split[0].trim());
						var intensity:Float = Std.parseFloat(split[1].trim());
						if(Math.isNaN(duration)) duration = 0;
						if(Math.isNaN(intensity)) intensity = 0;

						if(duration > 0 && intensity != 0) {
							targetsArray[i].shake(intensity, duration);
						}
					}
				}

			case 'Change Character':
				var charType:Int = Std.parseInt(value1);
				if(Math.isNaN(charType)) charType = 0;

				switch(value1.toLowerCase()) {
					case 'gf' | 'girlfriend':
						charType = 2;
					case 'dad' | 'opponent':
						charType = 1;
					case "bf" | "boyfriend":
						charType = 0;
					default:
						charType = Std.parseInt(value1);
						if(Math.isNaN(charType)) charType = 0;
				}

				switch(charType) {
					case 0:
						if(boyfriend.curCharacter != value2) 
						{
							var resetFPC:Bool = false;
							if (focusPlayerChar == boyfriend)
							{
								resetFPC = true;
							}

							if(!boyfriendMap.exists(value2)) 
							{
								addCharacterToList(value2, charType);
							}

							var color:Int = boyfriend.color;
							boyfriend.visible = false;
							boyfriend = boyfriendMap.get(value2);
							if(!boyfriend.alreadyLoaded) {
								boyfriend.alpha = 1;
								boyfriend.alreadyLoaded = true;
							}
							boyfriend.color = color;
							boyfriend.visible = true;
							iconP1.changeIcon(boyfriend.healthIcon);
							if (!ClientPrefs.lowQuality)
							{
								iconGlowP1.updateProperties(boyfriend);
							}
							if (resetFPC)
							{
								focusPlayerChar = boyfriend;
							}
							characters.set("boyfriend", boyfriend);
						}

					case 1:
						if(dad.curCharacter != value2) 
						{
							var resetFOC:Bool = false;
							if (focusOpptChar == dad)
							{
								resetFOC = true;
							}

							if(!dadMap.exists(value2)) 
							{
								addCharacterToList(value2, charType);
							}

							var color:Int = dad.color;
							var wasGf:Bool = dad.curCharacter.startsWith('gf');
							dad.visible = false;
							dad = dadMap.get(value2);
							if(!dad.curCharacter.startsWith('gf')) {
								if(wasGf) {
									gf.visible = true;
								}
							} else {
								gf.visible = false;
							}
							if(!dad.alreadyLoaded) {
								dad.alpha = 1;
								dad.alreadyLoaded = true;
							}
							dad.color = color;
							dad.visible = true;
							iconP2.changeIcon(dad.healthIcon);
							if (!ClientPrefs.lowQuality)
							{
								iconGlowP2.updateProperties(dad);
							}
							if (resetFOC)
							{
								focusOpptChar = dad;
							}
							reloadQuotes();
							characters.set("dad", dad);
						}

					case 2:
						if(gf.curCharacter != value2) 
						{
							var resetFGC:Bool = false;
							if (focusOpptChar == gf)
							{
								resetFGC = true;
							}

							if(!gfMap.exists(value2)) 
							{
								addCharacterToList(value2, charType);
							}
							var color:Int = gf.color;

							gf.visible = false;
							gf = gfMap.get(value2);
							if(!gf.alreadyLoaded) {
								gf.alpha = 1;
								gf.alreadyLoaded = true;
							}
							gf.color = color;
							if (resetFGC)
							{
								focusOpptChar = gf;
							}
							characters.set("gf", gf);
						}
				}
				reloadHealthBarColors();

			case 'Change Scroll Speed':
				if (value2 != "")
				{
					var daTime:Float = 0.25;
					daTime = Std.parseFloat(value2);
					modchartTweens.set("scroll speed tween", FlxTween.tween(this, {scrollMult: Std.parseFloat(value1)}, daTime));
				}
				else
				{
					scrollMult = Std.parseFloat(value1);
				}

				if(generatedMusic)
				{
					var ratio:Float = (Std.parseFloat(value1) * songSpeed) / songSpeed; // "This is one of the twitter moments of all time" - Penguinz0
					for (note in notes)
					{
						if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
						{
							if (note.trueScaleY == 0)
							{
								note.trueScaleY = note.scale.y;
							}
							else
							{
								note.scale.y = note.trueScaleY;
							}
							note.scale.y *= ratio;
							note.updateHitbox();
						}
					}
					for (note in unspawnNotes)
					{
						if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end'))
						{
							if (note.trueScaleY == 0)
							{
								note.trueScaleY = note.scale.y;
							}
							else
							{
								note.scale.y = note.trueScaleY;
							}
							note.scale.y *= ratio;
							note.updateHitbox();
						}
					}
				}
				noteKillOffset = 350 / (Std.parseFloat(value1) * songSpeed);

			case 'Cinematic Bar Zoom':
				if (value1 != '1')
				{
					modchartTweens.set('topBar1', FlxTween.tween(topBar, {y: (-FlxG.height + 70) + Std.parseFloat(value1)}, Std.parseFloat(value2), {ease: FlxEase.sineOut}));
					modchartTweens.set('bottBar2', FlxTween.tween(bottomBar, {y: (FlxG.height - 70) - Std.parseFloat(value1)}, Std.parseFloat(value2), {ease: FlxEase.sineOut}));
				}
				else
				{
					modchartTweens.set('topBar2', FlxTween.tween(topBar, {y: (-FlxG.height + 70)}, Std.parseFloat(value2), {ease: FlxEase.sineOut}));
					modchartTweens.set('bottBar1', FlxTween.tween(bottomBar, {y: (FlxG.height - 70)}, Std.parseFloat(value2), {ease: FlxEase.sineOut}));
				}

			case 'Cam Tween Zoom':
				if (modchartTweens.exists("camZoomEventThing"))
				{
					return;
				}
				if (value2 != '' || value2 != null)
				{
					var camZoom:Float = Std.parseFloat(value1);
					camZoomEvent = true;
					camZooming = false;
					modchartTweens.set('camZoomEventThing', FlxTween.tween(PlayState, {defaultCamZoom: camZoom}, Std.parseFloat(value2), {ease: FlxEase.sineInOut,
						onComplete: function(tween:FlxTween)
						{
							camZoomEvent = false;
							camZooming = true;
							modchartTweens.remove('camZoomEventThing');
						}
					}));
				}
				else
				{
					var camZoom:Float = Std.parseFloat(value1);
					camGame.zoom = camZoom;
					defaultCamZoom = camZoom;
				}

			case 'Lyrics':
				var textS:String = value1;
				var val2Split:Array<String> = [];
				var iconS:String = value2;
				var barBool:String = "";
				if (value2.contains("|"))
				{
					val2Split = value2.split("|");
					iconS = val2Split[0];
					barBool = val2Split[1];
				}

				textS = CoolUtil.swearFilter(textS);

				lyricText.color = FlxColor.WHITE;

				if (isPixelStage)
				{
					lyricText.font = Paths.font(lyricPixelFont);
				}
				else
				{
					lyricText.font = Paths.font(lyricFont);
				}

				if (textS != 'remove')
				{
					if (textS.contains('<>'))
					{
						var split:Array<String> = textS.split('<>');
						lyricText.text = '"' + split[0] + '"';
						lyricText.color = Std.parseInt('0xFF' + split[1]);
					}
					else
					{
						lyricText.text = '"' + textS + '"';
					}
					var newIcon:String = iconS;
					if (iconS == "" || iconS == "none")
					{
						newIcon = "face";
					}
					icon.changeIcon(newIcon);

					// pos
					icon.screenCenter();
					if (iconS != "" || iconS != "none")
						icon.visible = true;
					else
						icon.visible = false;
					lyricText.visible = true;
					lyricText.screenCenter();
					if (barBool == "0" || barBool == "")
						lyricText.y = icon.y + Std.int(icon.height);
					else
						lyricText.y = bottomBar.y;

					// repos x.

					lyricText.fieldWidth = (1280 - lyricText.x);
					if (textS.contains('<>'))
					{
						var split:Array<String> = textS.split('<>');
						lyricText.text = '"' + split[0] + '"';
						lyricText.color = Std.parseInt('0xFF' + split[1]);
					}
					else
					{
						lyricText.text = '"' + textS + '"';
					}
					lyricText.screenCenter();
					if (barBool == "0" || barBool == "")
						lyricText.y = icon.y + Std.int(icon.height);
					else
						lyricText.y = bottomBar.y;
				}
				else
				{
					lyricText.visible = false;
					icon.visible = false;
				}

			case "Third Strumline":
				if (!ClientPrefs.middleScroll)
				{
					if (!thirdStrum)
					{
						if (value1 == "true" || value1 == "")
						{
							generateStaticArrows(2);
						}
						else
						{
							generateStaticArrows(2, true);
						}
					}
					else
					{
						var toRemove:Array<StrumNote> = [];
						for (i in 0...4)
						{
							toRemove.push(gfStrums.members[i]);
						}
						if (value1 == "true" || value1 == "")
						{
							if (value2 == "")
							{
								value2 = "1";
							}
							for (i in 0...4)
							{
								modchartTweens.set("removeThirdStrum", FlxTween.tween(gfStrums.members[i], {y: -100, alpha: 0, angle: -360}, Std.parseInt(value2), {ease: FlxEase.sineInOut, startDelay: (0.2 * i), onComplete: function(twn:FlxTween)
								{
									gfStrums.remove(toRemove[i]);
								}}));
							}
							thirdStrum = false;
						}
						else
						{
							for (i in 0...4)
							{
								gfStrums.remove(toRemove[i]);
							}
							thirdStrum = false;
						}
					}
				}

			case 'Countdown':
				swagCountdown();

			case 'Note Spin':
				fuckUpArrows(360, Conductor.crochet / 1000, false);

			case 'Screen Flash':
				camVideo.flash(FlxColor.WHITE, 0.75);

			case 'Switch Note Sides':
				if (!ClientPrefs.middleScroll)
				{
					// goofy ahh.
					flippedStrum = !flippedStrum;
					var x:Array<Float> = [];
					var y:Array<Float> = [];
					var x2:Array<Float> = [];
					var y2:Array<Float> = [];
					for (i in 0...4)
					{
						var num:Float = playerStrums.members[i].x;
						var num2:Float = playerStrums.members[i].y;
						var num3:Float = opponentStrums.members[i].x;
						var num4:Float = opponentStrums.members[i].y;
						x.push(num);
						y.push(num2);
						x2.push(num3);
						y2.push(num4);
					}

					if (value1 == "")
					{
						for (i in 0...4)
						{
							playerStrums.members[i].x = x2[i];
							playerStrums.members[i].y = y2[i];
							opponentStrums.members[i].x = x[i];
							opponentStrums.members[i].y = y[i];
						}
					}
					else
					{
						for (i in 0...4)
						{
							modchartTweens.set("flipStrumEventPlayer" + i, FlxTween.tween(playerStrums.members[i], {x: x2[i], y: y2[i]}, Std.parseFloat(value1), {ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									modchartTweens.remove("flipStrumEventPlayer" + i);
								}
							}));
							modchartTweens.set("flipStrumEventOppt" + i, FlxTween.tween(opponentStrums.members[i], {x: x[i], y: y[i]}, Std.parseFloat(value1), {ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									modchartTweens.remove("flipStrumEventOppt" + i);
								}
							}));
						}
					}
				}

			case 'Real Time':
				// D sides too slow?
				modchartTweens.set('realTime', FlxTween.tween(this, {songLength: realLength}, Std.parseFloat(value1)));

			case 'Change UI':
				if (!isPixelStage)
				{
					isPixelStage = true;
					formatToPixel();
				}
				else
				{
					isPixelStage = false;
					formatToNormal();
				}

				if (isPixelStage)
				{
					comboSpr.loadGraphic(Paths.image('combo-pixel'));
					comboBreakSpr.loadGraphic(Paths.image('comboBreak-pixel'));
				}
				else
				{
					comboSpr.loadGraphic(Paths.image('combo'));
					comboBreakSpr.loadGraphic(Paths.image('comboBreak'));
				}
				var skin:String;
				if (SONG.arrowSkin == null || SONG.arrowSkin.length < 1)
					skin = 'NOTE_assets';
				else
					skin = SONG.arrowSkin;
				for (i in 0...4)
				{
					playerStrums.members[i].changeSkin(skin, i);
					opponentStrums.members[i].changeSkin(skin, i);
				}
				for (i in 0...unspawnNotes.length)
				{
					if (unspawnNotes[i].noteType == '')
					{
						unspawnNotes[i].reloadNote();
					}
					else
					{
						if (unspawnNotes[i].texture != null || unspawnNotes[i].texture.length > 0)
						{
							unspawnNotes[i].reloadNote(null, unspawnNotes[i].texture);
						}
						// yikes :/
						switch(unspawnNotes[i].noteType)
						{
							case 'Hurt Note':
								unspawnNotes[i].reloadNote('HURT');
							case 'Glitch Note':
								unspawnNotes[i].reloadNote('glitch');
							default:
								unspawnNotes[i].reloadNote();
						}
					}
				}

			case 'Hide HUD':
				if (ClientPrefs.limitedHud)
				{
					return;
				}

				if (value2 == '0')
				{
					for (i in 0...hideElements.length)
					{
						hideElements[i].alpha = Std.parseFloat(value1);
					}
				}
				else
				{
					for (i in 0...hideElements.length)
					{
						modchartTweens.set('hideElements', FlxTween.tween(hideElements[i], {alpha: Std.parseFloat(value1)}, Std.parseFloat(value2)));
					}
				}

			case 'Zoom Multiplier':
				if (Std.parseFloat(value1) > 0)
				{
					if (value1 != '1')
					{
						zoomMult = Std.parseFloat(value1);
					}
					else
					{
						zoomMult = 1;
					}
				}

			case 'Zoom On Note Hit':
				if (Std.parseInt(value1) > 0)
				{
					hitInt = Std.parseInt(value1);
				}

				if (!zoomHit)
				{
					zoomHit = true;
				}
				else
				{
					zoomHit = false;
				}

			case 'Camera Angle':
				if (Std.parseFloat(value2) != 0)
				{
					if (value2.contains('<>'))
					{
						var split:Array<String> = value2.split('<>');
						modchartTweens.set('CamAngleThingyMbob', FlxTween.tween(FlxG.camera, {angle: Std.parseFloat(value1)}, Std.parseFloat(split[0]), {ease: easeFromString(split[1])}));
						modchartTweens.set('CamAngleThingyMbobHUD', FlxTween.tween(camHUD, {angle: Std.parseFloat(value1)}, Std.parseFloat(split[0]), {ease: easeFromString(split[1])}));
					}
					else
					{
						modchartTweens.set('CamAngleThingyMbob', FlxTween.tween(FlxG.camera, {angle: Std.parseFloat(value1)}, Std.parseFloat(value2)));
						modchartTweens.set('CamAngleThingyMbobHUD', FlxTween.tween(camHUD, {angle: Std.parseFloat(value1)}, Std.parseFloat(value2)));
					}
				}
				else
				{
					FlxG.camera.angle = Std.parseFloat(value1);
					camHUD.angle = Std.parseFloat(value1);
				}

			case 'Note Angle':
				if (Std.parseFloat(value2) != 0 || value2 != '')
				{
					for (i in 0...4)
					{
						if (value2.contains('|'))
						{
							var split:Array<String> = value2.split('|');
							modchartTweens.set('PlayStrumAngleEvent', FlxTween.tween(playerStrums.members[i], {angle: Std.parseFloat(value1)}, Std.parseFloat(split[0]), {ease: easeFromString(split[1])}));
							modchartTweens.set('OpptStrumAngleEvent', FlxTween.tween(opponentStrums.members[i], {angle: Std.parseFloat(value1)}, Std.parseFloat(split[0]), {ease: easeFromString(split[1])}));
						}
						else
						{
							modchartTweens.set('PlayStrumAngleEvent', FlxTween.tween(playerStrums.members[i], {angle: Std.parseFloat(value1)}, Std.parseFloat(value2)));
							modchartTweens.set('OpptStrumAngleEvent', FlxTween.tween(opponentStrums.members[i], {angle: Std.parseFloat(value1)}, Std.parseFloat(value2)));
						}
					}
				}
				else
				{
					for (i in 0...4)
					{
						playerStrums.members[i].angle = Std.parseFloat(value1);
						opponentStrums.members[i].angle = Std.parseFloat(value1);
					}
				}

			case 'Blammed Angle':
				var time:Float = 0.5;
				var angle:Float = 0;
				if (value1.toLowerCase() == 'dad')
				{
					angle = Std.parseFloat(value2) * -1;
				}
				else
				{
					angle = Std.parseFloat(value2);
				}
				modchartTweens.set('CamAngleThingyMbob', FlxTween.tween(FlxG.camera, {angle: angle}, time));
				modchartTweens.set('CamAngleThingyMbobHUD', FlxTween.tween(camHUD, {angle: angle}, time));
				for (i in 0...4)
				{
					modchartTweens.set('PlayStrumAngleEvent', FlxTween.tween(playerStrums.members[i], {angle: angle * -1}, time));
					modchartTweens.set('OpptStrumAngleEvent', FlxTween.tween(opponentStrums.members[i], {angle: angle * -1}, time));
				}

			case "Vine Boom":
				var split:Array<String> = value1.split("|");
				if (split[0] != "")
				{
					FlxG.sound.play(Paths.sound("VINEBOOM"));
				}
				if (split[1] != "")
				{
					triggerEventNote("Add Camera Zoom", "0.015", "0.015");
				}
				var time:Float = Std.parseFloat(value2);
				triggerEventNote("Screen Shake", "" + time + ", 0.05", "" + time + ", 0.05");

			case "Change Note Skin":
				var skin:String = value1;

				if (skin == null || skin.length < 1)
				{
					skin = "NOTE_assets";
				}

				for (i in 0...4)
				{
					playerStrums.members[i].changeSkin(skin, i);
					opponentStrums.members[i].changeSkin(skin, i);
				}
				for (i in 0...unspawnNotes.length)
				{
					if (unspawnNotes[i].noteType == '')
					{
						unspawnNotes[i].reloadNote(null, skin);
					}
					else
					{
						if (unspawnNotes[i].texture != null || unspawnNotes[i].texture.length > 0)
						{
							unspawnNotes[i].reloadNote(null, unspawnNotes[i].texture);
						}
						// yikes :/
						switch(unspawnNotes[i].noteType)
						{
							case 'Hurt Note':
								unspawnNotes[i].reloadNote('HURT');
							case 'Glitch Note':
								unspawnNotes[i].reloadNote('glitch');
							case 'No Animation' | 'GF Sing' | 'Alt Animation':
								unspawnNotes[i].reloadNote();
						}
					}
				}

			case "Screen VG":
				var bigBalls:VisualThing = new VisualThing(FlxColor.BLACK, Std.parseFloat(value1), Std.parseFloat(value2), this);
				bigBalls.cameras = [camShader];
				add(bigBalls);

				bigBalls.start();

			// triple trouble
			case "Triple Trouble Static":
				var tts:TripleTroubleStatic = new TripleTroubleStatic(this);
				tts.cameras = [camShader];
				add(tts);

			case "Glitch Texts":
				glitchedTexts = true;

			case "Background Visibility":
				switch (value1.toLowerCase())
				{
					case "frontonly":
						for (bg in backgroundSprites)
						{
							if (bg.inFront)
							{
								bg.visible = !bg.visible;
							}
						}
					case "lightsonly":
						for (bg in backgroundSprites)
						{
							if (bg.isLightSource)
							{
								bg.visible = !bg.visible;
							}
						}
					case "frontonlynolights":
						for (bg in backgroundSprites)
						{
							if (bg.inFront && !bg.isLightSource)
							{
								bg.visible = !bg.visible;
							}
						}
					default:
						for (bg in backgroundSprites)
						{
							bg.visible = !bg.visible;
						}
				}

		}
		callOnLuas('onEvent', [eventName, value1, value2]);
	}

	function reloadQuotes()
	{
		var char:String = dad.curCharacter;
		if (char.startsWith("dad"))
		{
			char = "dad";
		}
		if (char.startsWith("gf") || char == "date-gf")
		{
			char = "gf";
		}
		if (char == "real-bf")
		{
			char = "bgOg";
		}
		if (char.startsWith("freeme"))
		{
			char = "monster";
		}
		if (char.startsWith("mom"))
		{
			char = "mom";
		}
		if (char.startsWith("parents"))
		{
			char = "parents";
		}
		if (char.startsWith("sonic"))
		{
			char = "sonic";
		}
		var array:Array<String> = ["LOSER!!", "Haha!"];
		if (FileSystem.exists(Paths.quotes(char)))
		{
			array = CoolUtil.coolTextFile(Paths.quotes(char));
		}
		if (FileSystem.exists("mods/quotes/" + char + ".txt"))
		{
			array = CoolUtil.coolTextFile("mods/quotes/" + char + ".txt");
		}
		if (FileSystem.exists("mods/" + Paths.currentModDirectory + "/quotes/" + char + ".txt"))
		{
			array = CoolUtil.coolTextFile("mods/" + Paths.currentModDirectory + "/quotes/" + char + ".txt");
		}
		GameOverSubstate.setStrings(array, dad.healthIcon);
	}

	function reloadPauseMusic()
	{
		PauseSubState.pauseString = PlayStateMeta.dataFile.pauseMusic;
	}

	function moveCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (!SONG.notes[id].mustHitSection)
		{
			moveCamera(true);
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			moveCamera(false);
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	function falseCameraSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (!SONG.notes[id].mustHitSection)
		{
			callOnLuas('onMoveCamera', ['dad']);
		}
		else
		{
			callOnLuas('onMoveCamera', ['boyfriend']);
		}
	}

	var comboShowing:Bool = false;
	function checkSection(?id:Int = 0):Void {
		if(SONG.notes[id] == null) return;

		if (!SONG.notes[id].mustHitSection)
		{
			if (!comboShowing)
			{
				comboShowing = true;
				callOnLuas('onMoveCamera', ['dad']);
				modchartTimers.set('comboCountTimer', new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					if (SONG.song != 'Free Me' || SONG.song != 'Winter Horrorland' || SONG.song != 'Nightmare' || !isScary)
						comboCount();
					else
						popUpCombo();
				}));
			}
		}
		else
		{
			comboShowing = false;
			callOnLuas('onMoveCamera', ['boyfriend']);
			modchartTimers.get('comboCountTimer').active = false;
		}
	}

	var cameraTwn:FlxTween;

	public var fpmDadOff:Int = 0;
	public var fpmBfOff:Int = 0;
	public var focusOnGf:Bool = false;
	public var reverseSectionCamera:Bool = false;

	public var camFollowOpptChar:Character = null;
	public var camFollowPlayerChar:Character = null;
	public var camFollowGfChar:Character = null;
	public function moveCamera(isDad:Bool) 
	{
		// unlucky.
		if (reverseSectionCamera)
		{
			isDad = !isDad;
		}

		if(isDad) 
		{
			if (!focusOnGf)
			{
				var dadChar:Character = null;
				if (camFollowOpptChar == null)
				{
					dadChar = dad;
				}
				else
				{
					dadChar = camFollowOpptChar;
				}
				camFollow.set(dadChar.getMidpoint().x + 150, dadChar.getMidpoint().y - 100);
				if (!fpm)
				{
					camFollow.x += dadChar.cameraPosition[0];
				}
				else
				{
					camFollow.x = (dadChar.getMidpoint().x + 100) + fpmDadOff;
				}
				camFollow.y += dadChar.cameraPosition[1];

				camFollow.x += dadCPos[0];
				camFollow.y += dadCPos[1];
			}
			else
			{
				var gfChar:Character = null;
				if (camFollowGfChar == null)
				{
					gfChar = gf;
				}
				else
				{
					gfChar = camFollowGfChar;
				}
				camFollow.set(gfChar.getMidpoint().x + 150, gfChar.getMidpoint().y - 100);
				if (!fpm)
				{
					camFollow.x += gfChar.cameraPosition[0];
				}
				else
				{
					camFollow.x = (gfChar.getMidpoint().x + 100) + fpmDadOff;
				}
				camFollow.y += gfChar.cameraPosition[1];

				camFollow.x += gfCPos[0];
				camFollow.y += gfCPos[1];
			}
			tweenCamIn();
		} 
		else 
		{
			var bfChar:Character = null;
			if (camFollowPlayerChar == null)
			{
				bfChar = boyfriend;
			}
			else
			{
				bfChar = camFollowPlayerChar;
			}
			camFollow.set(bfChar.getMidpoint().x - 100, bfChar.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = bfChar.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = bfChar.getMidpoint().y - 200;
				case 'school' | 'schoolEvil':
					camFollow.x = bfChar.getMidpoint().x - 200;
					camFollow.y = bfChar.getMidpoint().y - 200;
			}
			if (!fpm)
			{
				camFollow.x -= bfChar.cameraPosition[0];
			}
			else
			{
				camFollow.x = (bfChar.getMidpoint().x + 100) + fpmBfOff;
			}
			camFollow.y += bfChar.cameraPosition[1];

			camFollow.x += bfCPos[0];
			camFollow.y += bfCPos[1];

			if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1) 
			{
				defaultCamZoom = 1;
			}
		}
	}

	function tweenCamIn() {
		if (Paths.formatToSongPath(SONG.song) == 'tutorial' && cameraTwn == null && FlxG.camera.zoom != 1.3) 
		{
			defaultCamZoom = 1.3;
		}
	}

	function snapCamFollowToPos(x:Float, y:Float) {
		camFollow.set(x, y);
		camFollowPos.setPosition(x, y);
	}

	function finishSong():Void
	{
		var finishCallback:Void->Void = endSong; //In case you want to change it in a specific song.

		var daSong:String = SONG.song.toLowerCase();
		if (daSong == 'lazybones')
			finishCallback = sansAfter;
		else
			finishCallback = endSong;

		updateTime = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		vocals.pause();
		if(ClientPrefs.noteOffset <= 0) {
			award(finishCallback);
			//finishCallback();
		} else {
			finishTimer = new FlxTimer().start(ClientPrefs.noteOffset / 1000, function(tmr:FlxTimer) {
				award(finishCallback);
				//finishCallback();
			});
		}
	}

	public function sansAfter():Void
	{
		add(sansUndertaleAfter);
	}


	var transitioning = false;
	public function endSong():Void
	{
		//Should kill you if you tried to cheat
		if(!startingSong) {
			notes.forEach(function(daNote:Note) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= healthLoss;
				}
			});
			for (daNote in unspawnNotes) {
				if(daNote.strumTime < songLength - Conductor.safeZoneOffset) {
					health -= healthLoss;
				}
			}

			if(doDeathCheck()) {
				return;
			}
		}
		
		timeBarBG.visible = false;
		timeBar.visible = false;
		timeTxt.visible = false;
		strumLineNotes.visible = false;
		healthBar.visible = false;
		healthBarBG.visible = false;
		barBG.visible = false;
		if (ClientPrefs.showComboSpr)
		{
			comboBreakSpr.visible = false;
			comboSpr.visible = false;
		}
		icon.visible = false;
		lyricText.visible = false;
		canPause = false;
		endingSong = true;
		camZooming = false;
		inCutscene = false;
		updateTime = false;
		vocals.volume = 0;

		deathCounter = 0;
		seenCutscene = false;

		#if ACHIEVEMENTS_ALLOWED
		if(achievementObj != null) {
			return;
		} else {
			var achieve:Int = checkForAchievement([1, 2, 3, 4, 5, 6, 7, 8, 9, 12, 13, 14, 15, 16, 17, 18]);
			if(achieve > -1) {
				startAchievement(achieve);
				return;
			}
		}
		#end

		#if LUA_ALLOWED
		var ret:Dynamic = callOnLuas('onEndSong', []);
		#else
		var ret:Dynamic = FunkinLua.Function_Continue;
		#end

		if (songMisses == 0 && SONG.song == "Tutorial" && encoreMode)
		{
			ClientPrefs.fcTutorial = true;
			ClientPrefs.saveSettings();
		}

		if(ret != FunkinLua.Function_Stop && !transitioning) {
			if (SONG.validScore)
			{
				#if !switch
				var percent:Float = ratingPercent;
				if(Math.isNaN(percent)) percent = 0;
				if (!encoreMode)
					Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
				else
					Highscore.saveEncoreScore(SONG.song, songScore, storyDifficulty, percent);

				var ratingF:Float = songScore / ((songHits + songMisses - ghostMisses) * 350);
				var ratingString:String = '';

				if (ratingF <= 0.5)
					ratingString = 'f';
				if (ratingF <= 0.7 && ratingF >= 0.5)
					ratingString = 'd';
				if (ratingF <= 0.8 && ratingF >= 0.7)
					ratingString = 'c';
				if (ratingF <= 0.9 && ratingF >= 0.8)
					ratingString = 'b';
				if (ratingF <= 0.99 && ratingF >= 0.9)
					ratingString = 'a';
				if (ratingF >= 1)
					ratingString = 's';

				if (PlayState.encoreMode)
					Highscore.saveEncoreSongRank(SONG.song, storyDifficulty, ratingString);
				else
					Highscore.saveSongRank(SONG.song, storyDifficulty, ratingString);
				#end

				callOnLuas("onScoreSave", [songScore, ratingF, ratingString]);
			}

			if (SONG.song == "Free Me")
			{
				trace('error');
				var username:String = CoolUtil.username();
				lime.app.Application.current.window.title = 'He Knows What Happend. He Just Wont Come To Terms With It';
				if (!ClientPrefs.swearFilter)
					lime.app.Application.current.window.alert('GET ME OUT OF THIS FUCKING GAME ' + username + '!!', 'HELP ME!!!');
				else
					lime.app.Application.current.window.alert('GET ME OUT OF THIS GAME ' + username + '!!', 'HELP ME!!!');
			}

			var exc:Bool = false;

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignMisses += songMisses;
				campaignHits += songHits;
				campaignGMiss += ghostMisses;
				campaignRatings.push(songRatings);

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					cancelFadeTween();
					CustomFadeTransition.nextCamera = camOther;
					if(FlxTransitionableState.skipNextTransIn) {
						CustomFadeTransition.nextCamera = null;
					}
					FlxG.sound.music.stop();
					GameJoltAPI.alert("points", 250);
					ClientPrefs.points += 250;
					ClientPrefs.saveSettings();
					MusicBeatState.switchState(new ResultsScreen());
					ResultsScreen.week = storyWeek;
					ResultsScreen.curDifficulty = storyDifficulty;
					ResultsScreen.score = campaignScore;
					ResultsScreen.hits = campaignHits;
					ResultsScreen.misses = campaignMisses;
					ResultsScreen.gMiss = campaignGMiss;
					ResultsScreen.ratings = campaignRatings;

					// if ()
					if(!usedPractice) {
						if (!encoreMode)
							StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
						else
							StoryEncoreState.weekEncoreCompleted.set(WeekData.weeksList[storyWeek], true);

						if (SONG.validScore)
						{
							Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
						}

						FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
						FlxG.save.data.weekEncoreCompleted = StoryEncoreState.weekEncoreCompleted;
						FlxG.save.flush();
					}
					usedPractice = false;
					changedDifficulty = false;
					cpuControlled = false;
				}
				else
				{
					var difficulty:String = '' + CoolUtil.difficultyStuff[storyDifficulty][1];

					trace('LOADING NEXT SONG');
					trace(Paths.formatToSongPath(PlayState.storyPlaylist[0]) + difficulty);

					var winterHorrorlandNext = (Paths.formatToSongPath(SONG.song) == "eggnog");
					if (winterHorrorlandNext)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;

					prevCamFollow = camFollow;
					prevCamFollowPos = camFollowPos;

					if (!encoreMode)
					{
						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);
					}
					else
					{
						if (FileSystem.exists('assets/data/' + Paths.formatToSongPath(PlayState.storyPlaylist[0]) + '/' + Paths.formatToSongPath(PlayState.storyPlaylist[0]) + '-encore.json'))
							PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + '-encore', PlayState.storyPlaylist[0]);	
						else
							PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0] + difficulty, PlayState.storyPlaylist[0]);				
					}
					FlxG.sound.music.stop();

					PlayStateMeta.setFile(PlayState.SONG.song);

					if(winterHorrorlandNext) {
						new FlxTimer().start(0.5, function(tmr:FlxTimer) {
							FlxG.sound.play(Paths.sound("mallScream"));
							new FlxTimer().start(8.57, function(tmr:FlxTimer)
							{
								cancelFadeTween();
								//resetSpriteCache = true;
								LoadingState.loadAndSwitchState(new PlayState());
							});
						});
					} else {
						cancelFadeTween();
						//resetSpriteCache = true;
						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
			}
			if (isVoid && !isStoryMode)
			{
				cancelFadeTween();
				var skipSongs:Array<String> = ["Isolation", "No Hard Feelings", "Endless", 'Doppelganger', "Manipulator", "Dont Lie"];
				for (i in 0...skipSongs.length)
				{
					if (SONG.song == skipSongs[i])
					{
						voidSkip = true;
					}
				}
				if (!voidSkip)
				{
					FlxG.sound.play(Paths.sound('voidWARP'));
					setOnLuas('mustHitSection', true);
					moveCamera(false);
					doDumbPortalThing(false);
				}
				CustomFadeTransition.nextCamera = camOther;
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}

				if (!voidSkip)
				{
					new FlxTimer().start(3, function(tmr:FlxTimer) 
					{
						MusicBeatState.switchState(new MonsterLairState());
					});
				}
				usedPractice = false;
				changedDifficulty = false;
				cpuControlled = false;
				if (voidSkip)
				{
					MusicBeatState.switchState(new MonsterLairState());
				}
			}
			if (!isStoryMode && !isVoid && !exc)
			{
				trace('WENT BACK TO FREEPLAY??');
				cancelFadeTween();
				CustomFadeTransition.nextCamera = camOther;
				if(FlxTransitionableState.skipNextTransIn) {
					CustomFadeTransition.nextCamera = null;
				}

				ResultsSong.song = SONG.song;
				ResultsSong.curDifficulty = storyDifficulty;
				ResultsSong.score = songScore;
				ResultsSong.misses = songMisses;
				ResultsSong.hits = songHits;
				ResultsSong.gMiss = ghostMisses;
				ResultsSong.ratings = songRatings;

				if (combo > highestCombo)
					highestCombo = combo;

				ResultsSong.highestCombo = highestCombo;

				GameJoltAPI.alert("points", 50);
				ClientPrefs.points += 50;
				ClientPrefs.saveSettings();
				MusicBeatState.switchState(new ResultsSong());
				if (!isSecret)
				{
					// FlxG.sound.playMusic(Paths.music('freakyMenu'));
				}
				usedPractice = false;
				changedDifficulty = false;
				cpuControlled = false;
			}
			if (isSecret)
			{
				GameJoltAPI.alert("points", 50);
				ClientPrefs.points += 50;
				ClientPrefs.saveSettings();
				FlxG.sound.music.stop();
				MusicBeatState.switchState(new FunnyFreeplayState());
				FlxG.sound.playMusic(Paths.music('freeplay'));
			}
			transitioning = true;
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	var achievementObj:AchievementObject = null;
	function startAchievement(achieve:Int) {
		achievementObj = new AchievementObject(achieve, camOther);
		achievementObj.onFinish = achievementEnd;
		add(achievementObj);
		trace('Giving achievement ' + achieve);
	}
	function achievementEnd():Void
	{
		achievementObj = null;
		if(endingSong && !inCutscene) {
			endSong();
		}
	}
	#end

	public function KillNotes() {
		while(notes.length > 0) {
			var daNote:Note = notes.members[0];
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
		eventNotes = [];
	}

	private function popUpScore(note:Note = null):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition + 8); 

		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'shit';
			songRatings.shits += 1;
			score = 50;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.5)
		{
			daRating = 'bad';
			songRatings.bads += 1;
			score = 100;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.25)
		{
			daRating = 'good';
			songRatings.goods += 1;
			score = 200;
		}

		callOnLuas("onRatingCalculation", [daRating]);

		if (daRating == "sick")
		{
			songRatings.sicks += 1;
		}

		if(daRating == 'sick' && !note.noteSplashDisabled)
		{
			var isGfNote:Bool = false;
			if (note.noteType == "GF Sing")
			{
				isGfNote = true;
			}
			if (note.isGfNote)
			{
				isGfNote = true;
			}

			if (isGfNote && thirdStrum)
			{
				spawnNoteSplashOnNote(note, 2);
			}
			else
			{
				if (twoplayer.TwoPlayerState.tpm && !note.mustPress)
				{
					spawnNoteSplashOnNote(note, 1);
				}
				else
				{
					spawnNoteSplashOnNote(note, 0);
				}
			}
		}

		if(!practiceMode && !cpuControlled) {
			// songScore += score;
			funnyScoreTween(score);
			songHits++;
			RecalculateRating();
			if(scoreTxtTween != null) {
				scoreTxtTween.cancel();
			}
			scoreTxt.scale.x = 1.1;
			scoreTxt.scale.y = 1.1;
			scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
				onComplete: function(twn:FlxTween) {
					scoreTxtTween = null;
				}
			});
		}

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = '';
		var pixelShitPart2:String = '';

		if (PlayState.isPixelStage)
		{
			pixelShitPart2 = 'pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		var ratingPath:String = ClientPrefs.customRating;
		if (PlayStateMeta.dataFile.ratingPack != null)
		{
			if (PlayStateMeta.dataFile.ratingPack != "")
			{
				ratingPath = PlayStateMeta.dataFile.ratingPack;
			}
		}

		rating.loadGraphic(Paths.image('ratingPacks/' + ratingPath + '/' + daRating + pixelShitPart2));
		rating.y = healthBarBG.y;
		if (ClientPrefs.downScroll)
		{
			rating.y += (healthBarBG.height * 4);
		}
		else
		{
			rating.y -= (healthBarBG.height * 4);
		}
		rating.acceleration.y = 550;
		rating.cameras = [camHUD];
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.visible = !ClientPrefs.hideHud;
		rating.scale.x = 0.75;
		rating.scale.y = 0.75;
		rating.scrollFactor.set();
		if (!ClientPrefs.middleScroll)
		{
			rating.screenCenter(X);
		}
		else
		{
			rating.x = 0;
		}

		add(rating);

		if (!PlayState.isPixelStage)
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = ClientPrefs.globalAntialiasing;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
		}

		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		if(combo >= 1000) {
			seperatedScore.push(Math.floor(combo / 1000) % 10);
		}
		seperatedScore.push(Math.floor(combo / 100) % 10);
		seperatedScore.push(Math.floor(combo / 10) % 10);
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			if (!ClientPrefs.showComboSpr)
			{
				numScore.screenCenter();
				numScore.x = coolText.x + (43 * daLoop) - 90;
				numScore.y += 80;
			}
			else
			{
				numScore.x = (0 + comboSpr.width + 20) + (43 * daLoop) - 20;
				numScore.y = comboSpr.y + (comboSpr.height / 2);
				numScore.alpha = 1;
				numScore.visible = false;
				numScore.cameras = [camHUD];
				numScore.updateHitbox();
			}

			if (!PlayState.isPixelStage)
			{
				numScore.antialiasing = ClientPrefs.globalAntialiasing;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			if (!ClientPrefs.showComboSpr)
			{
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
			}
			if (!ClientPrefs.showComboSpr)
			{
				numScore.visible = !ClientPrefs.hideHud;
			}

			//if (combo >= 10 || combo == 0)
				insert(members.indexOf(strumLineNotes), numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: comboText.alpha}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				// comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function keyShit():Void
	{
		var controlArray:Array<Bool> = [];
		var controlReleaseArray:Array<Bool> = [];
		var controlHoldArray:Array<Bool> = [];

		// two players
		var controlArray2:Array<Bool> = [];
		var controlReleaseArray2:Array<Bool> = [];
		var controlHoldArray2:Array<Bool> = [];

		// HOLDING
		if (!twoplayer.TwoPlayerState.tpm)
		{
			var up = controls.NOTE_UP;
			var right = controls.NOTE_RIGHT;
			var down = controls.NOTE_DOWN;
			var left = controls.NOTE_LEFT;

			var upP = controls.NOTE_UP_P;
			var rightP = controls.NOTE_RIGHT_P;
			var downP = controls.NOTE_DOWN_P;
			var leftP = controls.NOTE_LEFT_P;

			var upR = controls.NOTE_UP_R;
			var rightR = controls.NOTE_RIGHT_R;
			var downR = controls.NOTE_DOWN_R;
			var leftR = controls.NOTE_LEFT_R;

			controlArray = [leftP, downP, upP, rightP];
			controlReleaseArray = [leftR, downR, upR, rightR];
			controlHoldArray = [left, down, up, right];
		}
		else
		{
			var up = FlxG.keys.anyPressed([UP, NUMPADONE]);
			var right = FlxG.keys.anyPressed([RIGHT, NUMPADTWO]);
			var down = FlxG.keys.anyPressed([DOWN, X]);
			var left = FlxG.keys.anyPressed([LEFT, Z]);

			var upP = FlxG.keys.anyJustPressed([UP, NUMPADONE]);
			var rightP = FlxG.keys.anyJustPressed([RIGHT, NUMPADTWO]);
			var downP = FlxG.keys.anyJustPressed([DOWN, X]);
			var leftP = FlxG.keys.anyJustPressed([LEFT, Z]);

			var upR = FlxG.keys.anyJustReleased([UP, NUMPADONE]);
			var rightR = FlxG.keys.anyJustReleased([RIGHT, NUMPADTWO]);
			var downR = FlxG.keys.anyJustReleased([DOWN, X]);
			var leftR = FlxG.keys.anyJustReleased([LEFT, Z]);

			controlArray = [leftP, downP, upP, rightP];
			controlReleaseArray = [leftR, downR, upR, rightR];
			controlHoldArray = [left, down, up, right];

			var up2 = FlxG.keys.anyPressed([W, K]);
			var right2 = FlxG.keys.anyPressed([D, L]);
			var down2 = FlxG.keys.anyPressed([S, J]);
			var left2 = FlxG.keys.anyPressed([A, H]);

			var upP2 = FlxG.keys.anyJustPressed([W, K]);
			var rightP2 = FlxG.keys.anyJustPressed([D, L]);
			var downP2 = FlxG.keys.anyJustPressed([S, J]);
			var leftP2 = FlxG.keys.anyJustPressed([A, H]);

			var upR2 = FlxG.keys.anyJustReleased([W, K]);
			var rightR2 = FlxG.keys.anyJustReleased([D, L]);
			var downR2 = FlxG.keys.anyJustReleased([S, J]);
			var leftR2 = FlxG.keys.anyJustReleased([A, H]);

			controlArray2 = [leftP2, downP2, upP2, rightP2];
			controlReleaseArray2 = [leftR2, downR2, upR2, rightR2];
			controlHoldArray2 = [left2, down2, up2, right2];
		}

		// FlxG.watch.addQuick('asdfa', upP);
		if (!boyfriend.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray[daNote.noteData] && daNote.canBeHit 
				&& daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote);
				}
			});

			if ((controlHoldArray.contains(true) || controlArray.contains(true)) && !endingSong) {
				var canMiss:Bool = !ClientPrefs.ghostTapping;
				if (controlArray.contains(true)) {
					for (i in 0...controlArray.length) {
						// heavily based on my own code LOL if it aint broke dont fix it
						var pressNotes:Array<Note> = [];
						var notesDatas:Array<Int> = [];
						var notesStopped:Bool = false;

						var sortedNotesList:Array<Note> = [];
						notes.forEachAlive(function(daNote:Note)
						{
							if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate 
							&& !daNote.wasGoodHit && daNote.noteData == i) {
								sortedNotesList.push(daNote);
								notesDatas.push(daNote.noteData);
								canMiss = true;
							}
						});
						sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

						if (sortedNotesList.length > 0) {
							for (epicNote in sortedNotesList)
							{
								for (doubleNote in pressNotes) {
									if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 10) {
										doubleNote.kill();
										notes.remove(doubleNote, true);
										doubleNote.destroy();
									} else
										notesStopped = true;
								}
									
								// eee jack detection before was not super good
								if (controlArray[epicNote.noteData] && !notesStopped) {
									goodNoteHit(epicNote);
									pressNotes.push(epicNote);
								}

							}
						}
						else if (canMiss) 
							ghostMiss(controlArray[i], i, true);

						// I dunno what you need this for but here you go
						//									- Shubs

						// Shubs, this is for the "Just the Two of Us" achievement lol
						//									- Shadow Mario
						if (!keysPressed[i] && controlArray[i]) 
							keysPressed[i] = true;
					}
				}
			} 
			else if (boyfriend.holdTimer > Conductor.stepCrochet * 0.001 * boyfriend.singDuration && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.dance();
			}
		}
		if (twoplayer.TwoPlayerState.tpm && !dad.stunned && generatedMusic)
		{
			// rewritten inputs???
			notes.forEachAlive(function(daNote:Note)
			{
				// hold note functions
				if (daNote.isSustainNote && controlHoldArray2[daNote.noteData] && daNote.canBeHit 
				&& !daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					goodNoteHit(daNote, true);
				}
			});

			if ((controlHoldArray2.contains(true) || controlArray2.contains(true)) && !endingSong) {
				var canMiss:Bool = !ClientPrefs.ghostTapping;
				if (controlArray2.contains(true)) {
					for (i in 0...controlArray2.length) {
						// heavily based on my own code LOL if it aint broke dont fix it
						var pressNotes:Array<Note> = [];
						var notesDatas:Array<Int> = [];
						var notesStopped:Bool = false;

						var sortedNotesList:Array<Note> = [];
						notes.forEachAlive(function(daNote:Note)
						{
							if (daNote.canBeHit && !daNote.mustPress && !daNote.tooLate 
							&& !daNote.wasGoodHit && daNote.noteData == i) {
								sortedNotesList.push(daNote);
								notesDatas.push(daNote.noteData);
								canMiss = true;
							}
						});
						sortedNotesList.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

						if (sortedNotesList.length > 0) {
							for (epicNote in sortedNotesList)
							{
								for (doubleNote in pressNotes) {
									if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 10) {
										doubleNote.kill();
										notes.remove(doubleNote, true);
										doubleNote.destroy();
									} else
										notesStopped = true;
								}
									
								// eee jack detection before was not super good
								if (controlArray2[epicNote.noteData] && !notesStopped) {
									goodNoteHit(epicNote, true);
									pressNotes.push(epicNote);
								}

							}
						}
						else if (canMiss) 
							ghostMiss(controlArray2[i], i, true);

						// I dunno what you need this for but here you go
						//									- Shubs

						// Shubs, this is for the "Just the Two of Us" achievement lol
						//									- Shadow Mario
						if (!keysPressed[i] && controlArray2[i]) 
							keysPressed[i] = true;
					}
				}
			}
			else if (dad.holdTimer > Conductor.stepCrochet * 0.001 * dad.singDuration && dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.endsWith('miss'))
			{
				dad.dance();
			}
		}

		playerStrums.forEach(function(spr:StrumNote)
		{
			if(controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm') {
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			if(controlReleaseArray[spr.ID]) 
			{
				callOnLuas("onControlRelease", [spr.ID]);
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		});
		opponentStrums.forEach(function(spr:StrumNote)
		{
			if(controlArray2[spr.ID] && spr.animation.curAnim.name != 'confirm') {
				spr.playAnim('pressed');
				spr.resetAnim = 0;
			}
			if(controlReleaseArray2[spr.ID]) 
			{
				callOnLuas("onControlRelease", [spr.ID]);
				spr.playAnim('static');
				spr.resetAnim = 0;
			}
		});
	}

	function ghostMiss(statement:Bool = false, direction:Int = 0, ?ghostMiss:Bool = false) {
		if (statement) 
		{
			if (!twoplayer.TwoPlayerState.tpm)
			{
				noteMissPress(direction, ghostMiss);
			}
			callOnLuas('noteMissPress', [direction]);
		}
	}

	function noteMiss(daNote:Note, ?oppt:Bool = false):Void { //You didn't hit the key and let it go offscreen, also used by Hurt Notes
		//Dupe note remove
		notes.forEachAlive(function(note:Note) 
		{
			if (daNote != note && daNote.mustPress && daNote.noteData == note.noteData && daNote.isSustainNote == note.isSustainNote && Math.abs(daNote.strumTime - note.strumTime) < 10) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		});

		if (twoplayer.TwoPlayerState.tpm)
		{
			callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
			return;
		}

		if (!daNote.isSustainNote)
		{
			health -= healthLoss;
		}
		//For testing purposes
		// trace(daNote.missHealth);
		if (!daNote.isSustainNote)
		{
			songMisses++;
		}

		if (isRing)
		{
			if (ringCount > 0)
			{
				ringCount -= 1;
			} 
		}
		vocals.volume = 0;
		RecalculateRating();

		if (!ClientPrefs.muteMiss && combo > 5)
		{
			FlxG.sound.play(Paths.sound('comboBreak'), 0.2);
		}

		if (!daNote.isSustainNote)
		{

			if (combo > highestCombo)
			{
				highestCombo = combo;
			}

			combo = 0;
		}

		if (ClientPrefs.showComboSpr && !daNote.isSustainNote)
		{
			comboSpr.visible = false;
			comboBreakSpr.visible = true;
		}

		var animToPlay:String = '';
		switch (Math.abs(daNote.noteData) % 4)
		{
			case 0:
				animToPlay = 'singLEFTmiss';
			case 1:
				animToPlay = 'singDOWNmiss';
			case 2:
				animToPlay = 'singUPmiss';
			case 3:
				animToPlay = 'singRIGHTmiss';
		}

		var ign:Bool = false;
		if (daNote.noteType == "GF Sing")
		{
			ign = true;
		}
		if (daNote.isGfNote)
		{
			ign = true;
		}
		var daAlt = '';
		if (SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.noteType == 'Alt Animation') 
		{
			daAlt = '-alt';
		}

		if (!ign)
		{
			if (!daNote.noAnimation)
			{
				if (boyfriend.animOffsets.exists(animToPlay + "-alt"))
				{
					var daGet:String = "boyfriend";
					if (daNote.char != "")
					{
						daGet = daNote.char;
					}
					if (daNote.char == "bf")
					{
						daGet = "boyfriend";
					}
					characters.get(daGet).playAnim(animToPlay + daAlt, true);
				}
				else
				{
					var daGet:String = "boyfriend";
					if (daNote.char != "")
					{
						daGet = daNote.char;
					}
					if (daNote.char == "bf")
					{
						daGet = "boyfriend";
					}
					characters.get(daGet).playAnim(animToPlay, true);
				}
			}
		}
		else
		{
			if (!daNote.noAnimation)
			{
				if (gf.animOffsets.exists(animToPlay + daAlt))
				{
					gf.playAnim(animToPlay + daAlt, true);
				}
				else
				{
					gf.playAnim(animToPlay, true);
				}
			}
		}
		callOnLuas('noteMiss', [notes.members.indexOf(daNote), daNote.noteData, daNote.noteType, daNote.isSustainNote]);
	}

	function noteMissPress(direction:Int = 1, ?ghostMiss:Bool = false):Void //You pressed a key when there was no notes to press for this key
	{
		if (!boyfriend.stunned && !dad.stunned)
		{
			if (!twoplayer.TwoPlayerState.tpm)
			{
				health -= healthLoss;
			}

			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			if (ClientPrefs.showComboSpr)
			{
				comboSpr.visible = false;
				comboBreakSpr.visible = true;
				if (!ClientPrefs.muteMiss && combo > 5)
				{
					FlxG.sound.play(Paths.sound('comboBreak'), 0.2);
				}

			}

			if (combo > highestCombo)
			{
				highestCombo = combo;
			}

			combo = 0;

			if (isRing)
			{
				if (ringCount > 0)
				{
					ringCount -= 1;
				} 
			}

			// if(!practiceMode) songScore -= 10;
			if(!practiceMode) funnyScoreTween(-10);
			if(!endingSong) {
				if(ghostMiss) ghostMisses++;
				songMisses++;
			}
			RecalculateRating();

			if (!ClientPrefs.muteMiss)
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			/*boyfriend.stunned = true;

			// get stunned for 1/60 of a second, makes you able to
			new FlxTimer().start(1 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});*/

			var daGet:String = "boyfriend";
			switch (direction)
			{
				case 0:
					characters.get(daGet).playAnim('singLEFTmiss', true);
				case 1:
					characters.get(daGet).playAnim('singDOWNmiss', true);
				case 2:
					characters.get(daGet).playAnim('singUPmiss', true);
				case 3:
					characters.get(daGet).playAnim('singRIGHTmiss', true);
			}
			vocals.volume = 0;
		}
	}

	function goodNoteHit(note:Note, ?oppt:Bool = false):Void
	{
		if (!note.wasGoodHit)
		{
			if(cpuControlled && (note.ignoreNote || note.hitCausesMiss)) return;

			if(note.hitCausesMiss) 
			{
				if (!twoplayer.TwoPlayerState.tpm)
				{
					noteMiss(note, oppt);
				}
				if(!note.noteSplashDisabled && !note.isSustainNote) 
				{
					if ((note.noteType == "GF Sing" || note.isGfNote) && thirdStrum)
					{
						spawnNoteSplashOnNote(note, 2);
					}
					else
					{
						if (twoplayer.TwoPlayerState.tpm && !note.mustPress)
						{
							spawnNoteSplashOnNote(note, 1);
						}
						else
						{
							spawnNoteSplashOnNote(note, 0);
						}
					}
				}

				switch(note.noteType) 
				{
					case 'Hurt Note': //Hurt note
						if(boyfriend.animation.getByName('hurt') != null) {
							boyfriend.playAnim('hurt', true);
							boyfriend.specialAnim = true;
						}
					case 'Glitch Note':
						callOnLuas('onGlitchHit', []);
						glitchNotes();
				}
				
				note.wasGoodHit = true;
				if (!note.isSustainNote)
				{
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}
				return;
			}

			switch (note.noteType)
			{
				case "Fulminated Mercury":
					var predictHealth:Float = health - 0.25;
					if (predictHealth <= 0)
					{
						videoGameOver = "waltuh";
						GameJoltAPI.getTrophy(200307, "woltuh-why");
					}
					else
					{
						videoGameOver = "";
					}
			}

			if (!note.isSustainNote)
			{
				if (ClientPrefs.playSoundOnNoteHit && !twoplayer.TwoPlayerState.tpm)
				{
					FlxG.sound.play(Paths.sound("HITSOUND"), ClientPrefs.hitSoundVolume, false);
				}
				popUpScore(note);
				comboSpr.visible = true;
				comboBreakSpr.visible = false;
				combo += 1;
				if(combo > 9999)
				{
					combo = 9999;
				}
			}

			if (!note.isSustainNote || ClientPrefs.strumHealth)
			{
				if (!twoplayer.TwoPlayerState.tpm)
				{
					if (!extremeMode)
					{
						health += note.hitHealth;
					}
				}
			}

			if(!note.noAnimation) {
				var daAlt = '';
				if (SONG.notes[Math.floor(curStep / 16)].altAnim || note.noteType == 'Alt Animation') 
				{
					daAlt = '-alt';
				}
	
				var animToPlay:String = '';
				switch (Std.int(Math.abs(note.noteData)))
				{
					case 0:
						animToPlay = 'singLEFT';
					case 1:
						animToPlay = 'singDOWN';
					case 2:
						animToPlay = 'singUP';
					case 3:
						animToPlay = 'singRIGHT';
				}

				if(note.noteType == 'GF Sing' || note.isGfNote) 
				{
					if (gf.animOffsets.exists(animToPlay + daAlt))
						gf.playAnim(animToPlay + daAlt, true);
					else
						gf.playAnim(animToPlay, true);
					gf.holdTimer = 0;
				} 
				else 
				{
					if (note.mustPress)
					{
						if (boyfriend.animOffsets.exists(animToPlay + daAlt))
						{
							var daGet:String = "boyfriend";
							if (note.char != "")
							{
								daGet = note.char;
							}
							if (note.char == "bf")
							{
								daGet = "boyfriend";
							}
							characters.get(daGet).playAnim(animToPlay + daAlt, true);
						}
						else
						{
							var daGet:String = "boyfriend";
							if (note.char != "")
							{
								daGet = note.char;
							}
							if (note.char == "bf")
							{
								daGet = "boyfriend";
							}
							characters.get(daGet).playAnim(animToPlay, true);
						}
						boyfriend.holdTimer = 0;
					}
					if (!note.mustPress && twoplayer.TwoPlayerState.tpm)
					{
						if (dad.animOffsets.exists(animToPlay + daAlt))
						{
							var daGet:String = "dad";
							if (note.char != "")
							{
								daGet = note.char;
							}
							characters.get(daGet).playAnim(animToPlay + daAlt, true);
						}
						else
						{
							var daGet:String = "dad";
							if (note.char != "")
							{
								daGet = note.char;
							}
							characters.get(daGet).playAnim(animToPlay, true);
						}
						dad.holdTimer = 0;
					}
				}

				if(note.noteType == 'Hey!') 
				{
					var playerHey:Character = null;
					var daGet:String = "boyfriend";
					if (note.char != "")
					{
						daGet = note.char;
					}
					if (note.char == "bf")
					{
						daGet = "boyfriend";
					}
					playerHey = characters.get(daGet);

					if(playerHey.animOffsets.exists('hey')) 
					{
						playerHey.playAnim('hey', true);
						playerHey.specialAnim = true;
						playerHey.heyTimer = 0.6;
					}
	
					if(gf.animOffsets.exists('cheer')) {
						gf.playAnim('cheer', true);
						gf.specialAnim = true;
						gf.heyTimer = 0.6;
					}
				}
			}

			if(cpuControlled) 
			{
				var time:Float = 0.15;
				if(note.isSustainNote && !note.animation.curAnim.name.endsWith('end')) {
					time += 0.15;
				}

				var pgs:Bool = false;
				if ((note.noteType == "GF Sing" || note.isGfNote) && thirdStrum)
				{
					pgs = true;
				}

				if (twoplayer.TwoPlayerState.tpm)
				{
					if (!note.mustPress && !pgs)
					{
						StrumPlayAnim(0, Std.int(Math.abs(note.noteData)) % 4, time);
					}
				}
				else if (pgs)
				{
					StrumPlayAnim(2, Std.int(Math.abs(note.noteData)) % 4, time);
				}
				else
				{
					StrumPlayAnim(1, Std.int(Math.abs(note.noteData)) % 4, time);
				}
			} 
			else 
			{
				var pgs:Bool = false;
				if ((note.noteType == "GF Sing" || note.isGfNote) && thirdStrum)
				{
					pgs = true;
				}

				if (twoplayer.TwoPlayerState.tpm && !note.mustPress && !pgs)
				{
					opponentStrums.forEach(function(spr:StrumNote)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.playAnim('confirm', true);
						}
					});
				}
				else if (pgs)
				{
					gfStrums.forEach(function(spr:StrumNote)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.playAnim('confirm', true);
						}
					});
				}
				else
				{
					playerStrums.forEach(function(spr:StrumNote)
					{
						if (Math.abs(note.noteData) == spr.ID)
						{
							spr.playAnim('confirm', true);
						}
					});
				}
			}
			note.wasGoodHit = true;
			vocals.volume = 1;

			var isSus:Bool = note.isSustainNote; //GET OUT OF MY HEAD, GET OUT OF MY HEAD, GET OUT OF MY HEAD
			var leData:Int = Math.round(Math.abs(note.noteData));
			var leType:String = note.noteType;

			var pgs:Bool = false;
			if ((note.noteType == "GF Sing" || note.isGfNote) && thirdStrum)
			{
				pgs = true;
			}

			if (twoplayer.TwoPlayerState.tpm && !pgs && !note.mustPress)
			{
				callOnLuas('opponentNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
			}
			else if (pgs)
			{
				callOnLuas('gfNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
			}
			else
			{
				callOnLuas('goodNoteHit', [notes.members.indexOf(note), leData, leType, isSus]);
			}

			if (!camZoomEvent)
			{
				if (zoomHit && !isSus)
				{
					if (ClientPrefs.camZooms && FlxG.camera.zoom < defaultCamZoom + ((0.015 * hitInt) * zoomMult) && mustHitSection)
					{
						FlxG.camera.zoom += ((0.015 * hitInt) * zoomMult);
						camHUD.zoom += ((0.03 * hitInt) * zoomMult);
					}
				}
			}

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
				noteTweenP(leData);
			}
		}
	}

	function spawnNoteSplashOnNote(note:Note, ?char:Int = 0) {
		if(ClientPrefs.noteSplashes && note != null) 
		{
			var strum:StrumNote = null;
			if (char == 0)
			{
				strum = playerStrums.members[note.noteData];
			}
			if (char == 1)
			{
				strum = opponentStrums.members[note.noteData];
			}
			if (char == 2)
			{
				strum = gfStrums.members[note.noteData];
			}
			if(strum != null) 
			{
				spawnNoteSplash(strum.x, strum.y, note.noteData, note);
			}
		}
	}

	public function spawnNoteSplash(x:Float, y:Float, data:Int, ?note:Note = null) {
		var skin:String = 'noteSplashes';
		if(PlayState.SONG.splashSkin != null && PlayState.SONG.splashSkin.length > 0) skin = PlayState.SONG.splashSkin;
		
		var hue:Float = ClientPrefs.arrowHSV[data % 4][0] / 360;
		var sat:Float = ClientPrefs.arrowHSV[data % 4][1] / 100;
		var brt:Float = ClientPrefs.arrowHSV[data % 4][2] / 100;
		if(note != null) {
			skin = note.noteSplashTexture;
			hue = note.noteSplashHue;
			sat = note.noteSplashSat;
			brt = note.noteSplashBrt;
		}

		var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
		splash.setupNoteSplash(x, y, data, skin, hue, sat, brt);
		grpNoteSplashes.add(splash);
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	var carTimer:FlxTimer;
	function fastCarDrive()
	{
		//trace('Car drive');
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		carTimer = new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
			carTimer = null;
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
			gf.specialAnim = true;
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.danced = false; //Sets head to the correct position once the animation ends
		gf.playAnim('hairFall');
		gf.specialAnim = true;
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		if(!ClientPrefs.lowQuality) halloweenBG.animation.play('halloweem bg lightning strike');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if(boyfriend.animOffsets.exists('scared')) {
			boyfriend.playAnim('scared', true);
		}
		if(gf.animOffsets.exists('scared')) {
			gf.playAnim('scared', true);
		}

		if(ClientPrefs.camZooms) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;

			if(!camZooming) { //Just a way for preventing it to be permanently zoomed until Skid & Pump hits a note
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 0.5);
				FlxTween.tween(camHUD, {zoom: 1}, 0.5);
			}
		}

		if(ClientPrefs.flashing) {
			halloweenWhite.alpha = 0.4;
			FlxTween.tween(halloweenWhite, {alpha: 0.5}, 0.075);
			FlxTween.tween(halloweenWhite, {alpha: 0}, 0.25, {startDelay: 0.15});
		}
	}

	private var preventLuaRemove:Bool = false;
	private var preventScriptRemove:Bool = false;
	override function destroy() {
		preventLuaRemove = true;
		preventScriptRemove = true;
		for (i in 0...luaArray.length) 
		{
			luaArray[i].call('onDestroy', []);
			luaArray[i].stop();
		}
		for (i in 0...scriptArray.length)
		{
			scriptArray[i].call("onDestroy", []);
			scriptArray[i].stop();
		}
		luaArray = [];
		scriptArray = [];
		if (twoplayer.TwoPlayerState.tpm && mswo)
		{
			ClientPrefs.middleScroll = true;
		}
		super.destroy();
	}

	public function cancelFadeTween() {
		if(FlxG.sound.music.fadeTween != null) {
			FlxG.sound.music.fadeTween.cancel();
		}
		FlxG.sound.music.fadeTween = null;
	}

	public function removeLua(lua:FunkinLua) {
		if(luaArray != null && !preventLuaRemove) 
		{
			luaArray.remove(lua);
		}
	}

	public function removeScript(script:FunkinHscript)
	{
		if (scriptArray != null && !preventScriptRemove)
		{
			scriptArray.remove(script);
		}
	}

	var lastStepHit:Int = -1;
	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if(curStep == lastStepHit) 
		{
			return;
		}

		if (startedCountdown && !endingSong)
		{
			EventBundle.checkForATrigger(curStep, this);
		}

		if (curStep == 319 && SONG.song == 'Free Me' && !encoreMode && !endingSong && !twoplayer.TwoPlayerState.tpm)
		{
			freeMeModchart();
		}

		if (curStep == 1 && !endingSong)
		{
			for (i in 0...fadeSongs.length)
			{
				if (SONG.song == fadeSongs[i] && !encoreMode)
				{
					modchartTweens.set('blackScreenFade', FlxTween.tween(blackFade, {alpha: 0}, fadeTimes[i], {onComplete:
						function(twn:FlxTween)
						{
							remove(blackFade);
						}
					}));
				}
			}
			if (FileSystem.exists("assets/data/" + Paths.formatToSongPath(SONG.song) + "/lyrics.txt"))
			{
				setUpLyricFile(CoolUtil.coolTextFile("assets/data/" + Paths.formatToSongPath(SONG.song) + "/lyrics.txt"));
			}
			if (FileSystem.exists("mods/data/" + Paths.formatToSongPath(SONG.song) + "/lyrics.txt"))
			{
				setUpLyricFile(CoolUtil.coolTextFile("mods/data/" + Paths.formatToSongPath(SONG.song) + "/lyrics.txt"));
			}
			if (FileSystem.exists("mods/data/" + Paths.currentModDirectory + "/" + Paths.formatToSongPath(SONG.song) + "/lyrics.txt"))
			{
				setUpLyricFile(CoolUtil.coolTextFile("mods/data/" + Paths.currentModDirectory + "/" + Paths.formatToSongPath(SONG.song) + "/lyrics.txt"));
			}
		}

		lastStepHit = curStep;

		if (startedCountdown && !endingSong)
		{
			setOnLuas('curStep', curStep);
			callOnLuas('onStepHit', []);
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var lastBeatHit:Int = -1;
	override function beatHit()
	{
		super.beatHit();

		if(lastBeatHit >= curBeat) {
			trace('BEAT HIT: ' + curBeat + ', LAST HIT: ' + lastBeatHit);
			return;
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, ClientPrefs.downScroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				//FlxG.log.add('CHANGED BPM!');
				setOnLuas('curBpm', Conductor.bpm);
				setOnLuas('crochet', Conductor.crochet);
				setOnLuas("beat", Conductor.crochet / 1000);
				crochet = Conductor.crochet;
				setOnLuas('stepCrochet', Conductor.stepCrochet);
			}
			setOnLuas('mustHitSection', SONG.notes[Math.floor(curStep / 16)].mustHitSection);
			mustHitSection = SONG.notes[Math.floor(curStep / 16)].mustHitSection;
			altSection = SONG.notes[Math.floor(curStep / 16)].altAnim;
			setOnLuas("altSection", altSection);
			// else
			// Conductor.changeBPM(SONG.bpm);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		if (PlayState.SONG.notes[Std.int(curStep / 16)] != null && bfZoom && !endingSong)
		{
			if (SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				// lol ron maybe :/
				if (!modchartTweens.exists("camZoomEventThing"))
				{
					modchartTweens.set("bfZoomInMech", FlxTween.tween(PlayState, {defaultCamZoom: realDefaultCamZoom + 0.2}, (Conductor.crochet / 500) * cameraSpeed, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
					{
						modchartTweens.remove("bfZoomInMech");
					}}));
				}
			}
			else
			{
				if (!modchartTweens.exists("camZoomEventThing"))
				{
					modchartTweens.set("bfZoomOutMech", FlxTween.tween(PlayState, {defaultCamZoom: realDefaultCamZoom}, (Conductor.crochet / 500) * cameraSpeed, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
					{
						modchartTweens.remove("bfZoomOutMech");
					}}));
				}
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && !isCameraOnForcedPos)
		{
			moveCameraSection(Std.int(curStep / 16));
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null && !endingSong && isCameraOnForcedPos)
		{
			falseCameraSection(Std.int(curStep / 16));
		}

		if (!camZoomEvent)
		{
			if (camZooming && (FlxG.camera.zoom < 1.35 || (isPixelStage && FlxG.camera.zoom < (defaultCamZoom + 1.35))) && ClientPrefs.camZooms && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += (0.015 * zoomMult);
				camHUD.zoom += (0.03 * zoomMult);
			}
		}

		if (!ClientPrefs.lowQuality)
		{
			iconGlowP1.setGraphicSize(Std.int(iconGlowP1.width + 30));
			iconGlowP2.setGraphicSize(Std.int(iconGlowP1.width + 30));
			iconGlowP1.updateHitbox();
			iconGlowP2.updateHitbox();
		}
		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0 && !gf.stunned && gf.animation.curAnim.name != null && !gf.animation.curAnim.name.startsWith("sing"))
		{
			gf.dance();
		}

		if(curBeat % 2 == 0) {
			if (boyfriend.animation.curAnim.name != null && !boyfriend.animation.curAnim.name.startsWith("sing") && canDance)
			{
				boyfriend.dance();
			}
			if (dad.animation.curAnim.name != null && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned)
			{
				dad.dance();
			}
		} else if(dad.danceIdle && dad.animation.curAnim.name != null && !dad.curCharacter.startsWith('gf') && !dad.animation.curAnim.name.startsWith("sing") && !dad.stunned) {
			dad.dance();
		}

		var songName:String = Paths.formatToSongPath(SONG.song);
		switch(songName)
		{
			case 'dad-battle' | 'thorns' | 'milf' | 'roses' | 'guns' | 'stress' | 'blammed':
				if (curBeat % 2 == 0)
				{
					beatModchart();
				}
		}
		if (encoreMode)
		{
			switch(songName)
			{
				case "spookeez" | "south":
					if (curBeat % 2 == 0)
					{
						beatModchart();
					}
			}
		}

		switch (curStage)
		{
			case 'mall':
				if(!ClientPrefs.lowQuality) {
					upperBoppers.dance(true);
				}

				if(heyTimer <= 0) bottomBoppers.dance(true);
				santa.dance(true);

			case 'limo':
				if (FlxG.random.bool(10) && fastCarCanDrive)
				{
					fastCarDrive();
				}
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:BGSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1, [curLight]);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == 'spooky' && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}


		lastBeatHit = curBeat;

		// I think I need this lmao.
		if (startedCountdown && !endingSong)
		{
			setOnLuas('curBeat', curBeat);
			callOnLuas('onBeatHit', []);
		}
	}

	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = FunkinLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) 
		{
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != FunkinLua.Function_Continue) {
				returnVal = ret;
			}
		}
		for (i in 0...scriptArray.length)
		{
			scriptArray[i].call(event, args);
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		for (i in 0...scriptArray.length)
		{
			scriptArray[i].set(variable, arg);
		}
		#end
	}

	function StrumPlayAnim(?player:Int = 0, id:Int, time:Float) {
		var spr:StrumNote = null;
		if(player == 0) 
		{
			spr = strumLineNotes.members[id];
		} 
		if (player == 1) 
		{
			spr = playerStrums.members[id];
		}
		if (player == 2)
		{
			spr = gfStrums.members[id];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	public function comboCount()
	{
		var comboRating:String = '';
		
		// swag combo stuff lmao
		if (combo >= 0 && combo <= 5)
			comboRating = 'Kinda Shit...';
		if (combo > 5 && combo <= 10)
			comboRating = 'Meh';
		if (combo > 10 && combo <= 20)
			comboRating = 'Okay...';
		if (combo > 20 && combo <= 40)
			comboRating = 'Good!';
		if (combo > 40 && combo <= 45)
			comboRating = 'Great!';
		if (combo > 45 && combo <= 50)
			comboRating = 'Awesome!!';
		if (combo > 50 && combo <= 55)
			comboRating = 'Outstanding!!';
		if (combo > 55 && combo <= 60)
			comboRating = 'AMAZING!!!';
		if (combo > 60)
			comboRating = 'Sexy~';

		if (gf.curCharacter.startsWith('gf'))
		{
			var animToPlay:String = '';
			switch(comboRating)
			{
				case 'Kinda Shit...':
					animToPlay = 'sad';
				case 'Meh' | 'Okay...':
					animToPlay = 'bruh';
				case 'Good!' | 'Great!' | 'Awesome!!' | 'Outstanding!!' | 'AMAZING!!!':
					animToPlay = 'cheer';
				case 'Sexy~' | '*Horny Winky Face*':
					animToPlay = 'horny';

				if (gf.animOffsets.exists(animToPlay))
				{
					gf.playAnim(animToPlay);
				}
			}
		}

		// making the W sprites B)
		var comboRatingText:FlxText = new FlxText(-1280, 0, comboRating + '\nNote Combo! (' + combo + ')\n', 38);
		comboRatingText.setFormat(Paths.font("eras.ttf"), 38, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		comboRatingText.color = FlxColor.fromRGB(gf.healthColorArray[0], gf.healthColorArray[1], gf.healthColorArray[2]);
		comboRatingText.cameras = [camVideo];
		comboRatingText.screenCenter(Y);
		comboRatingText.y += 20;
		// comboRatingText.alpha = 0;
		var val:Float;
		if (ClientPrefs.middleScroll)
		{
			val = FlxG.width - (comboRatingText.width - 100);
		}
		else
		{
			comboRatingText.screenCenter(X);
			val = comboRatingText.x;
			comboRatingText.x = -1280;
		}
		add(comboRatingText);
		modchartTweens.set('comboRatingTextTween', FlxTween.tween(comboRatingText, {x: val, alpha: 1}, 0.65, {ease: FlxEase.elasticOut}));
		modchartTimers.set('comboRatingSound', new FlxTimer().start(0.49, function(tmr:FlxTimer) 
		{
			FlxG.sound.play(Paths.sound('comboRating'));
			modchartTimers.set('comboRatingTimer2', new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				modchartTweens.set('comboRatingTextTween2', FlxTween.tween(comboRatingText, {x: 1280, y: 1440, alpha: 0}, 0.35, {ease: FlxEase.elasticIn}));
				modchartTimers.set('comboRatingTimer3', new FlxTimer().start(0.65, function(tmr:FlxTimer)
				{
					remove(comboRatingText);
					comboRatingText.kill();
				}));
			}));
		}));
	}

	public function popUpCombo()
	{
		comboShowing = true;
		var comboRating:String = '';
		
		// swag combo stuff lmao
		if (combo > 0 && combo <= 5)
			comboRating = 'Kinda Shit...';
		if (combo > 5 && combo <= 10)
			comboRating = 'Meh';
		if (combo > 10 && combo <= 20)
			comboRating = 'Okay...';
		if (combo > 20 && combo <= 40)
			comboRating = 'Good!';
		if (combo > 40 && combo <= 45)
			comboRating = 'Great!';
		if (combo > 45 && combo <= 50)
			comboRating = 'Awesome!!';
		if (combo > 50 && combo <= 55)
			comboRating = 'Outstanding!!';
		if (combo > 55 && combo <= 60)
			comboRating = 'AMAZING!!!';
		if (combo > 60)
			comboRating = 'Sexy~';

		// making the W sprites B)
		var comboRatingText:FlxText = new FlxText(-1280, 0, comboRating + '\nNote Combo! (' + combo + ')\n', 38);
		comboRatingText.setFormat(Paths.font("eras.ttf"), 38, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		comboRatingText.cameras = [camVideo];
		comboRatingText.screenCenter(Y);
		comboRatingText.y += 20;
		// comboRatingText.alpha = 0;
		var val:Float;
		if (ClientPrefs.middleScroll)
		{
			val = FlxG.width - (comboRatingText.width - 100);
		}
		else
		{
			comboRatingText.screenCenter(X);
			val = comboRatingText.x;
			comboRatingText.x = -1280;
		}
		add(comboRatingText);
		modchartTweens.set('comboRatingTextTween', FlxTween.tween(comboRatingText, {x: val, alpha: 1}, 0.65, {ease: FlxEase.elasticOut}));
		modchartTimers.set('comboRatingSound', new FlxTimer().start(0.65, function(tmr:FlxTimer) 
		{
			FlxG.sound.play(Paths.sound('comboRating'));
			modchartTimers.set('comboRatingTimer2', new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				modchartTweens.set('comboRatingTextTween2', FlxTween.tween(comboRatingText, {x: 1280, y: 1440, alpha: 0}, 0.65, {ease: FlxEase.elasticIn}));
				modchartTimers.set('comboRatingTimer3', new FlxTimer().start(0.65, function(tmr:FlxTimer)
				{
					remove(comboRatingText);
					comboRatingText.kill();
				}));
			}));
		}));
	}

	public function funnyScoreTween(toAdd:Int)
	{
		songScore += toAdd;
	}

	public function doDumbPortalThing(theThing:Bool)
	{
		if (!theThing)
		{
			FlxG.camera.fade(FlxColor.WHITE, 0.25, false, function() 
			{
				doDumbPortalThing(true);
				boyfriend.visible = false;
				gf.visible = false;
				if (!isPixelStage)
				{
					bfShadow.visible = false;
					gfShadow.visible = false;
				}
			});
		}
		else
		{
			FlxG.camera.fade(FlxColor.WHITE, 0.25, true, function() 
			{
				// do nothing lmao
			});
		}
	}

	public function preparePortal(out:Bool, penis:Bool)
	{
		if (out)
		{
			if (!penis)
			{
				doDumbPortalThingCutscene(true, false);
			}
			else
			{
				doDumbPortalThingCutscene(true, true);
			}
		}
		else
		{
			if (!penis)
			{
				doDumbPortalThingCutscene(false, false);
			}
			else
			{
				doDumbPortalThingCutscene(false, true);
			}
		}
	}

	public function doDumbPortalThingCutscene(out:Bool, theThing:Bool)
	{
		FlxG.sound.play(Paths.sound('voidWARP'));
		if (!theThing)
		{
			FlxG.camera.fade(FlxColor.WHITE, 0.25, false, function() 
			{
				doDumbPortalThingCutscene(false, true);
				if (out)
				{
					if (!isPixelStage)
					{
						gfShadow.visible = false;
						bfShadow.visible = false;
					}
					gf.visible = false;
					boyfriend.visible = false;
				}
				else
				{
					if (!isPixelStage)
					{
						gfShadow.visible = true;
						bfShadow.visible = true;
					}
					gf.visible = true;
					boyfriend.visible = true;
				}
			});
		}
		else
		{
			FlxG.camera.fade(FlxColor.WHITE, 0.25, true, function() 
			{
				new FlxTimer().start(2.5, function(tmr:FlxTimer)
				{
					if (endingSong)
					{
						callOnLuas('onWarpped', [false]);
					}
					else
					{
						callOnLuas('onWarpped', [true]);
					}
				});
			});
		}
	}

	/*
	public function award()
	{
		if (!usedPractice && !cpuControlled)
		{
			// story mode shit.
			if (campaignMisses == 0 && songMisses == 0 && isStoryMode)
			{
				switch (SONG.song)
				{
					case "Tutorial":
						Trophies.unlock(1);						
					case "Dad Battle":
						Trophies.unlock(2);						
					case "Free Me":
						Trophies.unlock(3);						
					case "Blammed":
						Trophies.unlock(4);						
					case "Milf":
						Trophies.unlock(5);					
					case "Horrifying Truth":
						Trophies.unlock(6);
					case "Peppermints":
						Trophies.unlock(7);						
					case "Ron":
						Trophies.unlock(8);						
				}
			}

			// real
			switch (SONG.song)
			{
				case "Remember My Name":
					Trophies.unlock(9);					
				case "Dense":
					Trophies.unlock(10);					
				case "Crackin Eggs":
					Trophies.unlock(11);					
				case "Doppelganger":
					Trophies.unlock(12);					
				case "V":
					Trophies.unlock(13);					
				case "Isolation":
					Trophies.unlock(14);					
				case "No Hard Feelings":
					Trophies.unlock(15);					
				case "Too Fest":
					Trophies.unlock(16);
				case "Endless":
					Trophies.unlock(17);
			}
		}
	}
	*/

	public function award(callback:Void->Void)
	{
		if (!usedPractice && !cpuControlled)
		{
			// story mode shit.
			if (campaignMisses == 0 && songMisses == 0 && isStoryMode)
			{
				switch (SONG.song)
				{
					case "Tutorial":
						GameJoltAPI.getTrophy(178512, "gf");
					case "Dad Battle":
						GameJoltAPI.getTrophy(178513, "dad");						
					case "Free Me":
						GameJoltAPI.getTrophy(178514, "spookyGlitch");						
					case "Blammed":
						GameJoltAPI.getTrophy(178515, "pico");					
					case "Milf":
						GameJoltAPI.getTrophy(178516, "mom");				
					case "Horrifying Truth":
						GameJoltAPI.getTrophy(178517, "winterSpooky");
					case "Peppermints":
						GameJoltAPI.getTrophy(178518, "gf2");					
					case "Ron":
						GameJoltAPI.getTrophy(178519, "ron");
					case "Borrowed Motifs":
						GameJoltAPI.getTrophy(194374, "benandtess");					
				}
			}

			// real
			switch (SONG.song)
			{
				case "Remember My Name":
					GameJoltAPI.getTrophy(178520, "walart");					
				case "Dense":
					GameJoltAPI.getTrophy(178521, "matto");					
				case "Crackin Eggs":
					GameJoltAPI.getTrophy(178522, "alphred");					
				case "Doppelganger":
					GameJoltAPI.getTrophy(178523, "boyfriend");
				case "Too Fest":
					GameJoltAPI.getTrophy(178524, "nuckle");				
				case "Isolation":
					GameJoltAPI.getTrophy(178525, "lonely");					
				case "No Hard Feelings":
					GameJoltAPI.getTrophy(178526, "sonic");
				case "V":
					GameJoltAPI.getTrophy(178528, "spoon");	
				case "Endless":
					GameJoltAPI.getTrophy(178527, "jabbin");
				case "Manipulator":
					GameJoltAPI.getTrophy(194355, "fortnite-boots");
				case "Poster Boy":
					GameJoltAPI.getTrophy(194357, "tankman");
				case "Beef":
					GameJoltAPI.getTrophy(194358, "bootleg");
				case "Territory":
					GameJoltAPI.getTrophy(194359, "waltuh");
				case "Blow This Joint":
					GameJoltAPI.getTrophy(194360, "lucid");
				case "Huge Drama":
					GameJoltAPI.getTrophy(194899, "pyro");
				case "Borrowed Motifs":
					GameJoltAPI.getTrophy(200305, "nikku");
				case "Dont Lie":
					GameJoltAPI.getTrophy(200725, "hank");
				case "Test":
					GameJoltAPI.getTrophy(200306, "test");
			}

			if (PlayState.extremeMode)
			{
				GameJoltAPI.getTrophy(200410, "extreme");
			}
		}
		else
		{
			if (isStoryMode)
			{
				ResultsScreen.botplay = true;
			}
		}

		callOnLuas("onCallAwards", []);

		if (GameJoltAPI.isAwarding)
		{
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				callback();
			});
		}
		else
		{
			callback();
		}
	}

	public var lasChrBeforeAttack:String = "";
	public function attackAlert(window:Bool, cock:Bool = true, ?character:String = "bf-attack")
	{
		if (!inCutscene)
		{
			if (window)
			{
				lasChrBeforeAttack = boyfriend.curCharacter;

				alertAttackSpr = new FlxSprite().loadGraphic(Paths.image('alertAttack'));
				alertAttackSpr.visible = false;
				alertAttackSpr.cameras = [camOther];
				add(alertAttackSpr);

				attackMode = true;
				alertAttackSpr.visible = true;
				trace('attack is avalible!');
				FlxG.sound.play(Paths.sound('attackAlert'));
				if (cock)
				{
					FlxTween.tween(camHUD, {alpha: 0}, 0.5);
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						camHUD.alpha = 0;
					});
				}
				// var color:Int = boyfriend.color;
				triggerEventNote('Change Character', '0', character);
				// boyfriend.color = color;
				attackPress = true;
				canDance = false;
			}
			else
			{
				alertAttackSpr.visible = false;
				if (cock)
				{
					FlxTween.tween(camHUD, {alpha: 1}, 0.5);
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						camHUD.alpha = 1;
					});
				}
				// var color:Int = boyfriend.color;
				if (character == "bf-attack")
				{
					triggerEventNote('Change Character', '0', lasChrBeforeAttack);
				}
				else
				{
					triggerEventNote('Change Character', '0', character);
				}
				// boyfriend.color = color;
				canDance = true;
			}
		}
	}

	public function attack()
	{
		attackPress = false;
		alertAttackSpr.visible = false;
		FlxG.sound.play(Paths.sound('attack'));
		boyfriend.playAnim('attack', true);
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			remove(alertAttackSpr);
			attackAlert(false, true);
		});
	}

	public function changeRingCount(balls:Float)
	{
		ringCount = ringCount + balls;
	}

	public function updateComboHitboxes()
	{
		comboSpr.updateHitbox();
		comboBreakSpr.updateHitbox();
		comboText.updateHitbox();
		comboText.x = (comboSpr.x + comboSpr.width);
		comboText.y = (comboSpr.y + (comboSpr.height / 2));
		comboText.y -= 15;
	}

	public function ronPress()
	{
		FlxG.sound.play(Paths.sound('findDmitri'));
		ronPoster.visible = false;
		ClientPrefs.foundDmitri = true;
		ClientPrefs.saveSettings();
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			MusicBeatState.switchState(new UnlockedState('dmitri'));
		});
	}

	public function crt(?on:Bool = true)
	{
		if (!ClientPrefs.shaders)
		{
			return;
		}
		if (on)
		{
			/*
			filterMap = [
				"Scanline" => {
					filter: new ShaderFilter(new Scanline()),
				},
			];
			*/

			var sex:ShaderFilter = new ShaderFilter(new Scanline());
			filterMapHud.set('Scanline', sex);

			camHUDFilters = [];
			for (key in filterMapHud.keys())
			{
				camHUDFilters.push(filterMapHud.get(key));
			}

			camHUD.setFilters(camHUDFilters);
			camHUD.bgColor.alpha = 0;
		}
		else
		{
			// no filters
			filterMapHud.remove("Scanline");
			camHUDFilters = [];
			for (key in filterMapHud.keys())
			{
				camHUDFilters.push(filterMapHud.get(key));
			}
			camHUD.setFilters(camHUDFilters);
		}
	}

	public function fuckUpArrows(?val:Int = 90, ?time:Float = 0.75, ?together:Bool = true, ?player:Int = -1)
	{
		// fuck you lol

		// -1 for player means no player
		if (player == -1)
		{
			if (together)
			{
				for (i in 0...4)
					FlxTween.tween(playerStrums.members[i], {angle: playerStrums.members[i].angle + val}, time, {ease: FlxEase.circOut});
			}
			else
			{
				for (i in 0...4)
				{
					if (i < 2)
						FlxTween.tween(playerStrums.members[i], {angle: playerStrums.members[i].angle - val}, time, {ease: FlxEase.circOut});
					else
						FlxTween.tween(playerStrums.members[i], {angle: playerStrums.members[i].angle + val}, time, {ease: FlxEase.circOut});
				}
			}
		}
		else
		{
			if (player < 4)
			{
				FlxTween.tween(opponentStrums.members[player], {angle: val}, time, {ease: FlxEase.circOut});
			}
			else
			{
				FlxTween.tween(playerStrums.members[player], {angle: val}, time, {ease: FlxEase.circOut});
			}
		}
	}

	public function freeMeModchart()
	{
		var x:Array<Int> = [-200, -200, 200, 200, 200];
		var y:Int = 10;
		for (i in 0...4)
		{
			var L:FlxTween = FlxTween.tween(playerStrums.members[i], {x: playerStrums.members[i].x + x[i], y: playerStrums.members[i].y + y}, 3, {ease: FlxEase.elasticOut, type: PINGPONG});
			modchartTweens.set('Ltween' + Std.string(i), L);
		}
	}

	var angleShit:Float = 1.5;
	public function beatModchart(?time:Float = 1.5)
	{
		if (!ClientPrefs.screenShake)
		{
			return;
		}

		if (endingSong)
		{
			camHUD.angle = 0;
			camHUD.x = 0;
			return;
		}

		if (angleShit == 1.5)
		{
			angleShit = -1.5;
		}
		else
		{
			angleShit = 1.5;
		}

		var fullTime:Float = 0;
		switch (time)
		{
			case 1:
				fullTime = Conductor.crochet / 1000;
			case 1.5:
				fullTime = Conductor.crochet / 750;
			case 2:
				fullTime = Conductor.crochet / 500;
		}

		camHUD.angle = angleShit * 3;
		modchartTweens.set("beatModchartTweenTurn", FlxTween.tween(camHUD, {angle: 0}, fullTime, {ease: FlxEase.circOut}));
		modchartTweens.set("beatModchartTweenMove", FlxTween.tween(camHUD, {x: -angleShit * 8}, Conductor.crochet / 1000));
	}

	public function badWords()
	{
		var bad:FlxSprite = new FlxSprite().loadGraphic(Paths.image('badWords'));
		bad.cameras = [camOther];
		add(bad);
		FlxTween.tween(bad, {alpha: 0}, 3, {ease: FlxEase.cubeInOut});
		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			remove(bad);
			bad.destroy();
		});
	}

	var xTween:FlxTween;
	var xTween2:FlxTween;
	var xTween3:FlxTween;
	var xTween4:FlxTween;
	var hit:Bool = false;
	public function glitchNotes(?on:Bool = true)
	{
		var angles:Array<Int> = [];
		var alphas:Array<Float> = [];
		var x:Array<Int> = [];
		if (!hit)
		{
			for (i in 0...4)
			{
				var ranX:Int;
				var ranX2:Int;
				var ranAng:Int = FlxG.random.int(0, 359);
				var ranAlph:Float = FlxG.random.float(0.75, 1);
				if (i > 1)
				{
					ranX = FlxG.random.int(200, 250);
					x.push(ranX);
				}
				else
				{
					ranX2 = FlxG.random.int(-200, -250);
					x.push(ranX2);
				}
				alphas.push(ranAlph);
				angles.push(ranAng);
			}
			for (i in 0...4)
			{
				if (on)
				{
					FlxTween.tween(playerStrums.members[i], {angle: angles[i], alpha: alphas[i]}, 0.3, {ease: FlxEase.circOut});
				}
				else
				{
					FlxTween.tween(playerStrums.members[i], {angle: 0, alpha: 1}, 0.3, {ease: FlxEase.circOut});
				}
			}
			if (!on)
			{
				xTween.cancel();
				xTween2.cancel();
				xTween3.cancel();
				xTween4.cancel();
				for (i in 0...4)
				{
					x[i] = 0;
				}
			}
			else
			{
				xTween = FlxTween.tween(playerStrums.members[0], {x: playerStrums.members[0].x + x[0]}, 1.5, {ease: FlxEase.circOut, type: PINGPONG});
				xTween2 = FlxTween.tween(playerStrums.members[1], {x: playerStrums.members[1].x + x[1]}, 1.5, {ease: FlxEase.circOut, type: PINGPONG});
				xTween3 = FlxTween.tween(playerStrums.members[2], {x: playerStrums.members[2].x + x[2]}, 1.5, {ease: FlxEase.circOut, type: PINGPONG});
				xTween4 = FlxTween.tween(playerStrums.members[3], {x: playerStrums.members[3].x + x[3]}, 1.5, {ease: FlxEase.circOut, type: PINGPONG});
				modchartTweens.set('xTween', xTween);
				modchartTweens.set('xTween1', xTween2);
				modchartTweens.set('xTween2', xTween3);
				modchartTweens.set('xTween3', xTween4);
				makeVisual();
				new FlxTimer().start(12, function(tmr:FlxTimer)
				{
					xTween.cancel();
					xTween2.cancel();
					xTween3.cancel();
					xTween4.cancel();
					for (i in 0...4)
					{
						x[i] = 0;
						FlxTween.tween(playerStrums.members[i], {angle: 0, alpha: 1}, 0.3, {ease: FlxEase.circOut});
					}
					hit = false;
				});
			}
			hit = true;
		}
	}

	var sprGrp:FlxTypedGroup<FlxSprite>;
	var count:Int = 0;
	function makeVisual(?remove:Bool = false)
	{
		if (!remove)
		{
			count++;
			sprGrp = new FlxTypedGroup<FlxSprite>();
			add(sprGrp);
			var posX:Int = FlxG.random.int(0, Std.int(128 * 9));
			var posY:Int = FlxG.random.int(0, Std.int(72 * 9));
			var alpha:Int = FlxG.random.int(Std.int(0.75), 1);
			var amount:Int = FlxG.random.int(0, 1);
			var blend:Bool = FlxG.random.bool(50);
			for (i in 0...amount)
			{
				var shit:FlxSprite = new FlxSprite(posX, posY).makeGraphic(128, 72, FlxColor.WHITE);
				shit.alpha = alpha;
				shit.cameras = [camHUD];
				shit.blend = BlendMode.SUBTRACT;
				sprGrp.add(shit);
			}
		}
		if (count == 12)
		{
			health = 0;
		}
	}

	public function noteTweenP(data:Int)
	{
		var secThing:Int = Std.int(0.5);
			switch (data)
			{
				case 0:
					var L:FlxTween = FlxTween.tween(playerStrums.members[0], {angle: playerStrums.members[0].angle - 360}, secThing, {ease: FlxEase.circOut});
				case 1:
					var L:FlxTween = FlxTween.tween(playerStrums.members[1], {angle: playerStrums.members[1].angle - 360}, secThing, {ease: FlxEase.circOut});
				case 2:
					var L:FlxTween = FlxTween.tween(playerStrums.members[2], {angle: playerStrums.members[3].angle + 360}, secThing, {ease: FlxEase.circOut});
				case 3:
					var L:FlxTween = FlxTween.tween(playerStrums.members[3], {angle: playerStrums.members[3].angle + 360}, secThing, {ease: FlxEase.circOut});
			}
	}

	public function noteTweenO(data:Int, sussy:Bool)
	{
		var secThing:Int = Std.int(0.5);
		if (!sussy)
		{
			switch (data)
			{
				case 0:
					FlxTween.tween(opponentStrums.members[0], {angle: opponentStrums.members[0].angle - 360}, secThing, {ease: FlxEase.circOut});
				case 1:
					FlxTween.tween(opponentStrums.members[1], {angle: opponentStrums.members[1].angle - 360}, secThing, {ease: FlxEase.circOut});
				case 2:
					FlxTween.tween(opponentStrums.members[2], {angle: opponentStrums.members[3].angle + 360}, secThing, {ease: FlxEase.circOut});
				case 3:
					FlxTween.tween(opponentStrums.members[3], {angle: opponentStrums.members[3].angle + 360}, secThing, {ease: FlxEase.circOut});
			}
		}
	}

	public function swagCountdown()
	{
		var sex:Bool = true;

		var swagCounter:Int = 0;
		if(sex) 
		{
			startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ['three', 'two', 'one', 'go']);
				introAssets.set('silent', ['no-image', 'no-image', 'no-image', 'no-image']);
				introAssets.set("jabbin", ["three", "two", "one", "endless/hit it"]);
				introAssets.set('bf', ['three-bf', 'two-bf', 'one-bf', 'go-bf']);
				introAssets.set('pixel', ['pixelUI/ready-pixel', 'pixelUI/ready-pixel', 'pixelUI/set-pixel', 'pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var antialias:Bool = ClientPrefs.globalAntialiasing;
				if(isPixelStage) {
					introAlts = introAssets.get('pixel');
					antialias = false;
				}
				if(SONG.song == 'Free Me') 
				{
					introAlts = introAssets.get('silent');
				}
				if (SONG.song == "Endless")
				{
					introAlts = introAssets.get("jabbin");
				}
				if(curStage == 'mallEvil') {
					introAlts = introAssets.get('bf');
				}

				// head bopping for bg characters on Mall
				if(curStage == 'mall') {
					if(!ClientPrefs.lowQuality)
						upperBoppers.dance(true);
	
					bottomBoppers.dance(true);
					santa.dance(true);
				}

				switch (swagCounter)
				{
					case 0:
						if (!isSecret)
						{
							var pissFart:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
							pissFart.scrollFactor.set();
							pissFart.updateHitbox();
							if (PlayState.isPixelStage)
								pissFart.setGraphicSize(Std.int(pissFart.width * daPixelZoom));

							pissFart.screenCenter();
							pissFart.antialiasing = antialias;
							add(pissFart);
							countDownSprites.push(pissFart);
							FlxTween.tween(pissFart, {y: pissFart.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									countDownSprites.remove(pissFart);
									remove(pissFart);
									pissFart.destroy();
								}
							});
						}
					case 1:
						if (!isSecret)
						{
							var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
							ready.scrollFactor.set();
							ready.updateHitbox();

							if (PlayState.isPixelStage)
								ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

							ready.screenCenter();
							ready.antialiasing = antialias;
							add(ready);
							countDownSprites.push(ready);
							FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									countDownSprites.remove(ready);
									remove(ready);
									ready.destroy();
								}
							});
						}
					case 2:
						if (!isSecret)
						{
							var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
							set.scrollFactor.set();

							if (PlayState.isPixelStage)
								set.setGraphicSize(Std.int(set.width * daPixelZoom));

							set.screenCenter();
							set.antialiasing = antialias;
							add(set);
							countDownSprites.push(set);
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									countDownSprites.remove(set);
									remove(set);
									set.destroy();
								}
							});
						}
					case 3:
						if (!isSecret)
						{
							var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[3]));
							go.scrollFactor.set();

							if (PlayState.isPixelStage)
								go.setGraphicSize(Std.int(go.width * daPixelZoom));

							go.updateHitbox();

							go.screenCenter();
							go.antialiasing = antialias;
							add(go);
							countDownSprites.push(go);
							FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									countDownSprites.remove(go);
									remove(go);
									go.destroy();
								}
							});
						}
					case 4:
				}

				swagCounter += 1;
			}, 5);
		}
	}

	function easeFromString(?ease:String = '') {
		switch(ease.toLowerCase().trim()) {
			case 'backin': return FlxEase.backIn;
			case 'backinout': return FlxEase.backInOut;
			case 'backout': return FlxEase.backOut;
			case 'bouncein': return FlxEase.bounceIn;
			case 'bounceinout': return FlxEase.bounceInOut;
			case 'bounceout': return FlxEase.bounceOut;
			case 'circin': return FlxEase.circIn;
			case 'circinout': return FlxEase.circInOut;
			case 'circout': return FlxEase.circOut;
			case 'cubein': return FlxEase.cubeIn;
			case 'cubeinout': return FlxEase.cubeInOut;
			case 'cubeout': return FlxEase.cubeOut;
			case 'elasticin': return FlxEase.elasticIn;
			case 'elasticinout': return FlxEase.elasticInOut;
			case 'elasticout': return FlxEase.elasticOut;
			case 'expoin': return FlxEase.expoIn;
			case 'expoinout': return FlxEase.expoInOut;
			case 'expoout': return FlxEase.expoOut;
			case 'quadin': return FlxEase.quadIn;
			case 'quadinout': return FlxEase.quadInOut;
			case 'quadout': return FlxEase.quadOut;
			case 'quartin': return FlxEase.quartIn;
			case 'quartinout': return FlxEase.quartInOut;
			case 'quartout': return FlxEase.quartOut;
			case 'quintin': return FlxEase.quintIn;
			case 'quintinout': return FlxEase.quintInOut;
			case 'quintout': return FlxEase.quintOut;
			case 'sinein': return FlxEase.sineIn;
			case 'sineinout': return FlxEase.sineInOut;
			case 'sineout': return FlxEase.sineOut;
			case 'smoothstepin': return FlxEase.smoothStepIn;
			case 'smoothstepinout': return FlxEase.smoothStepInOut;
			case 'smoothstepout': return FlxEase.smoothStepInOut;
			case 'smootherstepin': return FlxEase.smootherStepIn;
			case 'smootherstepinout': return FlxEase.smootherStepInOut;
			case 'smootherstepout': return FlxEase.smootherStepOut;
		}
		return FlxEase.linear;
	}

	// makes cutscenes easier to manage :)
	public function makeCutscene(fileName:String, name:String)
	{
		var fullpath:String = "";
		if (Paths.currentModDirectory.length < 1)
			fullpath = 'mods/cutscenes/' + fileName + '.lua';
		else
			fullpath = 'mods/' + Paths.currentModDirectory + '/cutscenes/' + fileName + '.lua';

		if (!FileSystem.exists(fullpath))
		{
			fullpath = Paths.getPreloadPath("cutscenes/" + fileName + ".lua");
		}

		var hsPath:String = "";
		if (Paths.currentModDirectory.length < 1)
			hsPath = 'mods/cutscenes/' + fileName + '.hxs';
		else
			hsPath = 'mods/' + Paths.currentModDirectory + '/cutscenes/' + fileName + '.hxs';

		if (!FileSystem.exists(hsPath))
		{
			hsPath = Paths.getPreloadPath("cutscenes/" + fileName + ".hxs");
		}

		if (FileSystem.exists(hsPath))
		{
			scriptArray.push(new FunkinHscript(hsPath));
		}

		if (FileSystem.exists(fullpath))
		{
			luaArray.push(new FunkinLua(fullpath));
			trace('made cutscene at ' + fullpath);
		}
	}

	public function setUpLyricFile(file:Array<String>)
	{
		var timers:Array<Float> = [];
		var lyrics:Array<String> = [];
		var icons:Array<String> = [];
		var lasts:Array<Float> = [];

		for (i in 0...file.length)
		{
			var split:Array<String> = file[i].split("^^");
			lyrics.push(split[0]);
			icons.push(split[1]);
			timers.push(Std.parseFloat(split[2]));
			lasts.push(Std.parseFloat(split[3]));
		}

		for (i in 0...timers.length)
		{
			modchartTimers.set("lyricFileTimerStart" + i, new FlxTimer().start(timers[i], function(tmr:FlxTimer)
			{
				triggerEventNote("Lyrics", lyrics[i], icons[i]);
				modchartTimers.remove("lyricFileTimerStart");
			}));
		}

		for (i in 0...lasts.length)
		{
			modchartTimers.set("lyricFileTimerLast" + i, new FlxTimer().start(lasts[i] + timers[i], function(tmr:FlxTimer)
			{
				triggerEventNote("Lyrics", "remove", "face");
				modchartTimers.remove("lyricFileTimerLast");
			}));
		}
	}

	public function formatToPixel()
	{
		var pixelFont:String = Paths.font('pixel.otf');
		scoreTxt.font = pixelFont;
		scoreTxt.size = 16;
		artistNameText.font = pixelFont;
		artistNameText.size = 20;
		timeTxt.font = pixelFont;
		timeTxt.size = 28;
		songNameText.font = pixelFont;
		songNameText.size = 28;
		comboText.font = pixelFont;
		comboText.size = 32;
		comboText.y -= 15;
		botplayTxt.font = pixelFont;
		botplayTxt.size = 28;
	}

	// copy of formatToPixel
	public function formatToNormal()
	{
		var pixelFont:String = Paths.font('eras.ttf');
		scoreTxt.font = pixelFont;
		scoreTxt.size = 20;
		artistNameText.font = pixelFont;
		artistNameText.size = 24;
		timeTxt.font = pixelFont;
		timeTxt.size = 32;
		songNameText.font = pixelFont;
		songNameText.size = 32;
		comboText.font = pixelFont;
		comboText.size = 36;
		comboText.y += 10;
		botplayTxt.font = pixelFont;
		botplayTxt.size = 32;
	}

	public function makeWiggleEffect(type:String, effectType:String, speed:Float, waveFreq:Float, waveAmp:Float)
	{
		if (!ClientPrefs.shaders)
		{
			return;
		}
		var split:Array<String> = type.split('|');
		switch(split[0].toLowerCase())
		{
			case 'camera':
				var WE:WiggleEffect = new WiggleEffect();
				switch (effectType.toLowerCase())
				{
					case 'dreamy':
						WE.effectType = WiggleEffectType.DREAMY;
					case 'wavy':
						WE.effectType = WiggleEffectType.WAVY;
					case 'heatwavehorizontal':
						WE.effectType = WiggleEffectType.HEAT_WAVE_HORIZONTAL;
					case 'flag':
						WE.effectType = WiggleEffectType.FLAG;
					case 'heatwavevertical':
						WE.effectType = WiggleEffectType.HEAT_WAVE_VERTICAL;
				}
				WE.waveSpeed = speed;
				WE.waveFrequency = waveFreq;
				WE.waveAmplitude = waveAmp;
				WE.tag = split[1];

				var penis:ShaderFilter = new ShaderFilter(WE.shader);

				/*
				filterMap = [
					"Wiggle Shader" => {
						filter: penis,
					},
				];
				*/

				switch(split[1].toLowerCase())
				{
					case 'camgame':
						filterMapGame.set('Wiggle Effect', penis);
						camGameFilters = [];
						for (key in filterMapGame.keys())
						{
							camGameFilters.push(filterMapGame.get(key));
						}
						camGame.setFilters(camGameFilters);	
					case 'camhud':
						filterMapHud.set('Wiggle Effect', penis);
						camHUDFilters = [];
						for (key in filterMapHud.keys())
						{
							camHUDFilters.push(filterMapHud.get(key));
						}
						camHUD.setFilters(camHUDFilters);
					case 'camother':
						filterMapOther.set('Wiggle Effect', penis);
						camOtherFilters = [];
						for (key in filterMapOther.keys())
						{
							camOtherFilters.push(filterMapOther.get(key));
						}
						camOther.setFilters(camOtherFilters);
				}
				WiggleShaders.push(WE);
			case 'sprite':

				var WE:WiggleEffect = new WiggleEffect();
				switch (effectType.toLowerCase())
				{
					case 'dreamy':
						WE.effectType = WiggleEffectType.DREAMY;
					case 'wavy':
						WE.effectType = WiggleEffectType.WAVY;
					case 'heatwavehorizontal':
						WE.effectType = WiggleEffectType.HEAT_WAVE_HORIZONTAL;
					case 'flag':
						WE.effectType = WiggleEffectType.FLAG;
					case 'heatwavevertical':
						WE.effectType = WiggleEffectType.HEAT_WAVE_VERTICAL;
				}
				WE.waveSpeed = speed;
				WE.waveFrequency = waveFreq;
				WE.waveAmplitude = waveAmp;
				WE.tag = split[1];
				var peepee:Dynamic = null;
				if (modchartSprites.exists(split[1]))
				{
					peepee = modchartSprites.get(split[1]);
				}
				else
				{
					peepee = Reflect.getProperty(this, split[1]);
				}

				if (peepee == null)
				{
					// prevents crashes lets fucking gooooooooooo
					return;
				}

				peepee.shader = WE.shader;
				WiggleShaders.push(WE);
		}
	}

	public function moveWiggle(num:Float)
	{
		if (!ClientPrefs.shaders)
		{
			return;
		}
		for (i in 0...WiggleShaders.length)
		{
			// trace(":|");
			WiggleShaders[i].update(num);
		}
	}

	public function removeWiggleShader(ind:Int)
	{
		if (!ClientPrefs.shaders)
		{
			return;
		}
		if (WiggleShaders[ind] == null)
		{
			return;
		}
		WiggleShaders[ind].canUpdate = false;
		var WE:WiggleEffect = WiggleShaders[ind];
		switch (WE.tag.toLowerCase())
		{
			case "camgame":
				var cock:BitmapFilter = filterMapGame.get("Wiggle Effect");
				camGameFilters.remove(cock);
				camGame.setFilters(camGameFilters);
			case "camhud":
				var cock:BitmapFilter = filterMapHud.get("Wiggle Effect");
				camHUDFilters.remove(cock);
				camHUD.setFilters(camHUDFilters);
			case "camother":
				var cock:BitmapFilter = filterMapOther.get("Wiggle Effect");
				camOtherFilters.remove(cock);
				camOther.setFilters(camOtherFilters);
			default:
				var peepee:Dynamic = null;
				if (modchartSprites.exists(WE.tag))
				{
					peepee = modchartSprites.get(WE.tag);
				}
				else
				{
					peepee = Reflect.getProperty(this, WE.tag);
				}

				if (peepee == null)
				{
					// prevents crashes lets fucking gooooooooooo
					return;
				}
				peepee.shader = null;
		}
		WiggleShaders.remove(WiggleShaders[ind]);
	}

	public var addedShaders:Array<Array<Dynamic>> = [];
	public var addedBMShaders:Array<BitmapFilter> = [];
	public function addShader(type:String, arg:String, name:String)
	{
		if (!ClientPrefs.shaders)
		{
			return;
		}
		var shader:ShaderFilter = new ShaderFilter(new ChromAb());
		var toPush:Array<Dynamic> = [type, arg, name];
		switch (type)
		{
			case "camera":

				switch (name.toLowerCase())
				{
					case "grain":
						var grain:GrainFilter = new GrainFilter();
						shader = new ShaderFilter(grain.shader);
						toPush.push(grain);
					case "tiltshift" | "tilt":
						shader = new ShaderFilter(new Tiltshift());
					case "tv":
						var tv:TV = new TV();
						shader = new ShaderFilter(tv.shader);
						toPush.push(tv);
					case "vcr":
						var vcr:VCR = new VCR();
						shader = new ShaderFilter(vcr.shader);
						toPush.push(vcr);
					case "pixel" | "pixelate":
						var pixel:PixelateShader = new PixelateShader();
						shader = new ShaderFilter(pixel.shader);
						toPush.push(pixel);
				}

				switch (arg.toLowerCase())
				{
					case "game" | "camgame":
						camGameFilters.push(shader);
						camGame.setFilters(camGameFilters);
					case "hud" | "camhud":
						camHUDFilters.push(shader);
						camHUD.setFilters(camHUDFilters);
					case "other" | "camother":
						camOtherFilters.push(shader);
						camOther.setFilters(camOtherFilters);
						
				}
			case "dynamic" | "sprite" | "text" | "dy":

				switch (name.toLowerCase())
				{
					case "grain":
						var grain:GrainFilter = new GrainFilter();
						shader = new ShaderFilter(grain.shader);
						toPush.push(grain);
					case "tiltshift" | "tilt":
						shader = new ShaderFilter(new Tiltshift());
					case "tv":
						var tv:TV = new TV();
						shader = new ShaderFilter(tv.shader);
						toPush.push(tv);
					case "vcr":
						var vcr:VCR = new VCR();
						shader = new ShaderFilter(vcr.shader);
						toPush.push(vcr);
					case "pixel" | "pixelate":
						var pixel:PixelateShader = new PixelateShader();
						shader = new ShaderFilter(pixel.shader);
						toPush.push(pixel);
				}

				var thing:Dynamic = Reflect.getProperty(this, arg);
				if (modchartSprites.exists(arg))
				{
					thing = modchartSprites.get(arg);
				}
				if (thing == null)
				{
					// prevents crashing
					return;
				}
				thing.shader = shader;
		}
		toPush.push(shader);
		addedShaders.push(toPush);
	}

	// Each shader type has its own update function to avoid confusion with the code I guess :/
	public function updateAddedShaders(elapsed:Float)
	{
		if (!ClientPrefs.shaders)
		{
			return;
		}
		for (i in 0...addedShaders.length)
		{
			switch (addedShaders[i][2])
			{
				case "vcr" | "grain":
					addedShaders[i][3].update(elapsed);
			}
		}
	}

	// debug purposes
	public function returnShaderLength()
	{
		if (!ClientPrefs.shaders)
		{
			return;
		}
		var toSave:String = "";
		for (i in 0...addedShaders.length)
		{
			if (i > 0)
				toSave += "\n";

			for (j in 0...3)
				toSave += addedShaders[i][j];
		}
		TextFile.newFile(toSave, "shadersDebug");
	}

	public function removeShader(toRemove:Int = 0)
	{
		if (!ClientPrefs.shaders)
		{
			return;
		}
		var thing:Array<Dynamic> = addedShaders[toRemove];
		addedShaders.remove(thing);
	}

	public function setTvZoom(zoom:Float, pos:Int)
	{
		if (!ClientPrefs.shaders)
		{
			return;
		}
		if (addedShaders[pos][2] == "tv")
		{
			addedShaders[pos][3].setZoom(zoom);
		}
	}

	var trails:Array<FlxTrail> = [];
	public function spiritTrail(char:String)
	{
		if (!ClientPrefs.shaders)
		{
			return;
		}
		switch (char.toLowerCase())
		{
			case "dad":
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069); //nice
				insert(members.indexOf(dadGroup) - 1, evilTrail);
				trails.push(evilTrail);
			case "gf" | "girlfriend":
				var evilTrail = new FlxTrail(gf, null, 4, 24, 0.3, 0.069); //nice
				insert(members.indexOf(gfGroup) - 1, evilTrail);
				trails.push(evilTrail);
			case "bf" | "boyfriend":
				var evilTrail = new FlxTrail(boyfriend, null, 4, 24, 0.3, 0.069); //nice
				insert(members.indexOf(boyfriendGroup) - 1, evilTrail);
				trails.push(evilTrail);
		}
	}

	public function removeTrail(ind:Int)
	{
		if (!ClientPrefs.shaders)
		{
			return;
		}
		if (trails[ind] != null)
		{
			trails.remove(trails[ind]);
		}
	}

	public function insertToCharGroup(obj:Dynamic, char:String)
	{
		switch (char.toLowerCase())
		{
			case "dad":
				insert(members.indexOf(dadGroup) - 1, obj);
			case "gf" | "girlfriend":
				insert(members.indexOf(gfGroup) - 1, obj);
			case "bf" | "boyfriend":
				insert(members.indexOf(boyfriendGroup) - 1, obj);
		}
	}

	public function addToCharGroup(obj:Dynamic, char:String)
	{
		switch (char.toLowerCase())
		{
			case "dad":
				insert(members.indexOf(dadGroup) + 1, obj);
			case "gf" | "girlfriend":
				insert(members.indexOf(gfGroup) + 1, obj);
			case "bf" | "boyfriend":
				insert(members.indexOf(boyfriendGroup) + 1, obj);
		}
	}

	public function saveScores()
	{
		if (!usedPractice)
		{
			#if !switch
			var percent:Float = ratingPercent;
			if(Math.isNaN(percent)) percent = 0;
			if (!encoreMode)
				Highscore.saveScore(SONG.song, songScore, storyDifficulty, percent);
			else
				Highscore.saveEncoreScore(SONG.song, songScore, storyDifficulty, percent);

				var ratingF:Float = songScore / ((songHits + songMisses - ghostMisses) * 350);
			var ratingString:String = '';

			if (ratingF <= 0.5)
				ratingString = 'f';
			if (ratingF <= 0.7 && ratingF >= 0.5)
				ratingString = 'd';
			if (ratingF <= 0.8 && ratingF >= 0.7)
				ratingString = 'c';
			if (ratingF <= 0.9 && ratingF >= 0.8)
				ratingString = 'b';
			if (ratingF <= 0.99 && ratingF >= 0.9)
				ratingString = 'a';
			if (ratingF >= 1)
				ratingString = 's';

			if (PlayState.encoreMode)
				Highscore.saveEncoreSongRank(SONG.song, storyDifficulty, ratingString);
			else
				Highscore.saveSongRank(SONG.song, storyDifficulty, ratingString);
			#end
		}

		if(!usedPractice && storyPlaylist.length <= 0) 
		{
			if (!encoreMode)
				StoryMenuState.weekCompleted.set(WeekData.weeksList[storyWeek], true);
			else
				StoryEncoreState.weekEncoreCompleted.set(WeekData.weeksList[storyWeek], true);

			if (SONG.validScore)
			{
				Highscore.saveWeekScore(WeekData.getWeekFileName(), campaignScore, storyDifficulty);
			}

			FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
			FlxG.save.data.weekEncoreCompleted = StoryEncoreState.weekEncoreCompleted;
			FlxG.save.flush();
		}
	}

	public function changeStage(stage:String)
	{
		var file:String = Paths.getModFile("stages/" + stage + ".lua");
		if (!FileSystem.exists(file))
		{
			file = Paths.getPreloadPath("stages/" + stage + ".lua");
		}
		if (!FileSystem.exists(file))
		{
			return;
		}

		var fileh:String = null;
		if (FileSystem.exists(Paths.getModFile("stages/" + stage + ".hxs")))
		{
			fileh = Paths.getModFile("stages/" + stage + ".hxs");
		}
		if (FileSystem.exists(Paths.getPreloadPath("stages/" + stage + ".hxs")))
		{
			fileh = Paths.getPreloadPath("stages/" + stage + ".hxs");
		}

		if (luaArray[0].realName == currentStage)
		{
			removeLua(luaArray[0]);
			luaArray.insert(0, new FunkinLua(file));
		}
		if (luaArray[1].realName == currentStage)
		{
			removeLua(luaArray[1]);
			luaArray.insert(1, new FunkinLua(file));
		}

		if (scriptArray[0].realName == currentStage && fileh != "")
		{
			removeScript(scriptArray[0]);
			scriptArray.insert(0, new FunkinHscript(fileh));
		}
		if (scriptArray[1].realName == currentStage && fileh != null)
		{
			removeScript(scriptArray[1]);
			scriptArray.insert(1, new FunkinHscript(fileh));
		}

		var stageData:StageFile = StageData.getStageFile(stage);
		if(stageData == null) 
		{
			stageData = StageData.getDefaultFile();
		}
		else
		{
			var cs:Dynamic = stageData.cameraSpeed;
			if (cs == null)
			{
				stageData.cameraSpeed = 1;
			}
			if (stageData.cameraPositions == null)
			{
				stageData.cameraPositions = {
					dad: [0, 0],
					bf: [0, 0],
					gf: [0, 0]
				}
			}
		}

		currentStage = stage;

		camZoomEvent = true;
		defaultCamZoom = stageData.defaultZoom;
		if (!isPixelStage && stageData.isPixelStage)
		{
			isPixelStage = stageData.isPixelStage;
			triggerEventNote("Change UI", "", "");
		}
		if (isPixelStage && !stageData.isPixelStage)
		{
			isPixelStage = stageData.isPixelStage;
			triggerEventNote("Change UI", "", "");
		}
		boyfriend.x = stageData.boyfriend[0];
		boyfriend.y = stageData.boyfriend[1];
		gf.x = stageData.girlfriend[0];
		gf.y = stageData.girlfriend[1];
		dad.x = stageData.opponent[0];
		dad.y = stageData.opponent[1];

		cameraSpeed = stageData.cameraSpeed;
		dadCPos = stageData.cameraPositions.dad;
		gfCPos = stageData.cameraPositions.gf;
		bfCPos = stageData.cameraPositions.bf;

		stageMetaData = stageData;

		startCharacterPos(boyfriend);
		startCharacterPos(gf, true);
		startCharacterPos(dad);
		camZoomEvent = false;

		callOnLuas("onStageChange", [currentStage]);
	}

	public function reloadStageData(data:Dynamic)
	{
		if (Std.isOfType(data, String))
		{
			var stageData:StageFile = StageData.getStageFile(data);
			if (stageData == null) 
			{
				stageData = StageData.getDefaultFile();
			}
			else
			{
				var cs:Dynamic = stageData.cameraSpeed;
				if (cs == null)
				{
					stageData.cameraSpeed = 1;
				}
				if (stageData.cameraPositions == null)
				{
					stageData.cameraPositions = {
						dad: [0, 0],
						bf: [0, 0],
						gf: [0, 0]
					}
				}
			}

			currentStage = data;

			camZoomEvent = true;
			defaultCamZoom = stageData.defaultZoom;
			if (!isPixelStage && stageData.isPixelStage)
			{
				isPixelStage = stageData.isPixelStage;
				triggerEventNote("Change UI", "", "");
			}
			if (isPixelStage && !stageData.isPixelStage)
			{
				isPixelStage = stageData.isPixelStage;
				triggerEventNote("Change UI", "", "");
			}
			boyfriend.x = stageData.boyfriend[0];
			boyfriend.y = stageData.boyfriend[1];
			gf.x = stageData.girlfriend[0];
			gf.y = stageData.girlfriend[1];
			dad.x = stageData.opponent[0];
			dad.y = stageData.opponent[1];

			cameraSpeed = stageData.cameraSpeed;
			dadCPos = stageData.cameraPositions.dad;
			gfCPos = stageData.cameraPositions.gf;
			bfCPos = stageData.cameraPositions.bf;

			stageMetaData = stageData;

			startCharacterPos(boyfriend);
			startCharacterPos(gf, true);
			startCharacterPos(dad);
		}
		else
		{
			var stageData:StageFile = data;

			camZoomEvent = true;
			defaultCamZoom = stageData.defaultZoom;
			if (!isPixelStage && stageData.isPixelStage)
			{
				isPixelStage = stageData.isPixelStage;
				triggerEventNote("Change UI", "", "");
			}
			if (isPixelStage && !stageData.isPixelStage)
			{
				isPixelStage = stageData.isPixelStage;
				triggerEventNote("Change UI", "", "");
			}
			boyfriend.x = stageData.boyfriend[0];
			boyfriend.y = stageData.boyfriend[1];
			gf.x = stageData.girlfriend[0];
			gf.y = stageData.girlfriend[1];
			dad.x = stageData.opponent[0];
			dad.y = stageData.opponent[1];

			cameraSpeed = stageData.cameraSpeed;
			dadCPos = stageData.cameraPositions.dad;
			gfCPos = stageData.cameraPositions.gf;
			bfCPos = stageData.cameraPositions.bf;

			stageMetaData = stageData;

			startCharacterPos(boyfriend);
			startCharacterPos(gf, true);
			startCharacterPos(dad);
		}
	}

	public function greyScale()
	{
		var matrix:Array<Float> = [
			0.5, 0.5, 0.5, 0, 0,
			0.5, 0.5, 0.5, 0, 0,
			0.5, 0.5, 0.5, 0, 0,
			0,   0,   0, 1, 0,
		];

		var filter:BitmapFilter = new ColorMatrixFilter(matrix);
		return filter;
	}

	public function invert()
	{
		var matrix:Array<Float> = [
			-1,  0,  0, 0, 255,
			0, -1,  0, 0, 255,
			0,  0, -1, 0, 255,
			0,  0,  0, 1,   0,
		];

		var filter:BitmapFilter = new ColorMatrixFilter(matrix);
		return filter;
	}

	public function pauseState()
	{
		if (!paused)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			if(FlxG.sound.music != null) 
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			callOnLuas('onPause', []);
		}
		else
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			if (finishTimer != null && !finishTimer.finished)
				finishTimer.active = true;

			if(blammedLightsBlackTween != null)
				blammedLightsBlackTween.active = true;
			if(phillyCityLightsEventTween != null)
				phillyCityLightsEventTween.active = true;
			
			if(carTimer != null) carTimer.active = true;

			var chars:Array<Character> = [boyfriend, gf, dad];
			for (i in 0...chars.length) {
				if(chars[i].colorTween != null) {
					chars[i].colorTween.active = true;
				}
			}
			
			for (tween in modchartTweens) {
				tween.active = true;
			}
			for (timer in modchartTimers) {
				timer.active = true;
			}
			paused = false;
			callOnLuas('onResume', []);

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter(), true, songLength - Conductor.songPosition - ClientPrefs.noteOffset);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconP2.getCharacter());
			}
			#end
		}
	}

	public var ratingString:String;
	public var ratingPercent:Float;
	public function RecalculateRating() {
		setOnLuas('score', songScore);
		setOnLuas('misses', songMisses);
		setOnLuas('ghostMisses', songMisses);
		setOnLuas('hits', songHits);

		var ret:Dynamic = callOnLuas('onRecalculateRating', []);
		if(ret != FunkinLua.Function_Stop) {
			ratingPercent = songScore / ((songHits + songMisses - ghostMisses) * 350);
			if(!Math.isNaN(ratingPercent) && ratingPercent < 0) ratingPercent = 0;

			if(Math.isNaN(ratingPercent)) {
				ratingString = '?';
			} else if(ratingPercent >= 1) {
				ratingPercent = 1;
				if ((gf.curCharacter.startsWith("gf") || gf.curCharacter == "date-gf" || gf.curCharacter == "two-gf" || gf.curCharacter.startsWith("tess")) && gf.visible && SONG.song != "Horrifying Truth")
				{
					ratingString = ratingStuffTess[ratingStuffTess.length-1][0]; //Uses last string
				}
				else
				{
					ratingString = ratingStuff[ratingStuff.length-1][0]; //Uses last string
				}
			} else {
				if ((gf.curCharacter.startsWith("gf") || gf.curCharacter == "date-gf" || gf.curCharacter == "two-gf" || gf.curCharacter.startsWith("tess")) && gf.visible && SONG.song != "Horrifying Truth")
				{
					for (i in 0...ratingStuffTess.length-1) 
					{
						if(ratingPercent < ratingStuffTess[i][1]) 
						{
							ratingString = ratingStuffTess[i][0];
							break;
						}
					}
				}
				else
				{
					for (i in 0...ratingStuff.length-1) {
						if(ratingPercent < ratingStuff[i][1]) {
							ratingString = ratingStuff[i][0];
							break;
						}
					}
				}
			}

			setOnLuas('rating', ratingPercent);
			setOnLuas('ratingName', ratingString);
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	private function checkForAchievement(arrayIDs:Array<Int>):Int 
	{
		return -1;
	}
	#end

	var curLight:Int = 0;
	var curLightEvent:Int = 0;

	private function debugCheck()
	{
		// SHOULD BE 19 IN TOTAL.
		#if sys
		if (ClientPrefs.debugCheck && dbc < 20)
		{
			dbc += 1;
			File.saveContent("DEBUG_CHECK.txt", Std.string(dbc));
		}
		#end
	}
}
