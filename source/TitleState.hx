package;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxGame;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import sys.FileSystem;
import sys.io.File;
import TitleLua;

using StringTools;

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var assetsGroup:FlxGroup;
	var logoSpr:FlxSprite;

	public var musicString:String = 'freakyMenu';

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var easterEggEnabled:Bool = false; //Disable this to hide the easter egg
	var easterEggKeyCombination:Array<FlxKey> = [FlxKey.B, FlxKey.B]; //bb stands for bbpanzu cuz he wanted this lmao
	var lastKeysPressed:Array<FlxKey> = [];

	#if (haxe >= "4.0.0")
	public var modchartTweens:Map<String, FlxTween> = new Map();
	public var modchartSprites:Map<String, ModchartSpriteTitle> = new Map();
	public var modchartTimers:Map<String, FlxTimer> = new Map();
	public var modchartSounds:Map<String, FlxSound> = new Map();
	#else
	public var modchartTweens:Map<String, FlxTween> = new Map<String, FlxTween>();
	public var modchartSprites:Map<String, ModchartSpriteTitle> = new Map<String, Dynamic>();
	public var modchartTimers:Map<String, FlxTimer> = new Map<String, FlxTimer>();
	public var modchartSounds:Map<String, FlxSound> = new Map<String, FlxSound>();
	#end

	// lua shit :)
	var luaArray:Array<TitleLua>;
	public var canPress:Bool = true;
	public var customBeat:Bool = false;
	public var modchartGroup:FlxTypedGroup<ModchartSpriteTitle>;
	private var luaDebugGroup:FlxTypedGroup<DebugLuaTextTitle>;
	private var preventLuaRemove:Bool = false;

	public static var curSaveFile:Int = 0;
	public static var sfn:String = '';

	override public function create():Void
	{
		luaArray = [];

		#if (polymod && !html5)
		if (sys.FileSystem.exists('mods/')) {
			var folders:Array<String> = [];
			for (file in sys.FileSystem.readDirectory('mods/')) {
				var path = haxe.io.Path.join(['mods/', file]);
				if (sys.FileSystem.isDirectory(path)) {
					folders.push(file);
				}
			}
			if(folders.length > 0) {
				polymod.Polymod.init({modRoot: "mods", dirs: folders});
			}
		}

		WeekData.loadTheFirstEnabledMod();

		//Gonna finish this later, probably
		#end

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());


		// Acheivement.loadShit();

		// DEBUG BULLSHIT

		var createdFile:Bool = false;
		var SaveFileName:String = 'funkin';

		swagShader = new ColorSwap();
		super.create();

		if (FileSystem.exists('assets/data/saveData.leftSides'))
		{
			var pushed:String = 'funkin';
			var text:Array<String> = CoolUtil.coolTextFile('assets/data/saveData.leftSides');
			// Shit for other save files
			for (i in 0...text.length)
			{
				var split:Array<String> = text[i].split('|');
				if (split[1] == '1')
				{
					pushed = split[0];
					curSaveFile = i;
					createdFile = true;
					SaveFileName = split[0];
				}
			}
		}
		

		if (!createdFile)
		{
			MusicBeatState.switchState(new SaveFileStartState());
		}
		else
		{
			var SaveSuff:String = '';
			switch (curSaveFile)
			{
				case 1:
					SaveSuff = '_1';
				case 2:
					SaveSuff = '_2';
				case 3:
					SaveSuff = '_3';
				case 4:
					SaveSuff = '_4';
				case 5:
					SaveSuff = '_5';
				case 6:
					SaveSuff = '_6';
				case 7:
					SaveSuff = '_7';
			}
			trace(SaveSuff);

			// need to call this because yes.
			if (initialized)
			{
				ClientPrefs.saveSettings();
				Highscore.saveEverything();
				Acheivement.saveAllDates();
				FlxG.save.data.weekCompleted = StoryMenuState.weekCompleted;
				FlxG.save.data.weekEncoreCompleted = StoryEncoreState.weekEncoreCompleted;
				FlxG.save.close();
			}

			if (curSaveFile == 0)
			{
				FlxG.save.bind('funkin', 'ninjamuffin99');
			}
			else
			{
				FlxG.save.bind('funkin' + SaveSuff, 'ninjamuffin99');
			}

			sfn = 'funkin' + SaveSuff;

			MainMenuState.saveFileName = 'SAVE FILE ICON = ' + SaveFileName + ' | SAVE FILE SLOT = ' + curSaveFile;
			ClientPrefs.loadPrefs();

			Highscore.load();
			Acheivement.loadDates();

			if (FlxG.save.data.weekCompleted != null)
			{
				StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
			}
			if (FlxG.save.data.weekCompleted != null)
			{
				StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
			}

			Colorblind.changeMode();

			FlxG.save.data.createdFile = createdFile;
			FlxG.save.flush();

			modchartGroup = new FlxTypedGroup<ModchartSpriteTitle>();
			add(modchartGroup);

			#if LUA_ALLOWED
			luaDebugGroup = new FlxTypedGroup<DebugLuaTextTitle>();
			add(luaDebugGroup);
			#end

			var doPush:Bool = false;
			var luaFile:String;
			luaFile = 'data/title.lua';


			// WeekData is a fuckin PUSSY Lmao
			if (FileSystem.exists('modsList.txt'))
			{
				var list:Array<String> = CoolUtil.coolTextFile('modsList.txt');
				var foundAtTop:Bool = false;
				for (i in 0...list.length)
				{
					var split:Array<String> = list[i].split('|');
					if (split[1] == '1' && !foundAtTop)
					{
						Paths.currentModDirectory = split[0];
						foundAtTop = true;
					}
				}
			}

			if(FileSystem.exists('mods/' + Paths.currentModDirectory + '/' + luaFile) && !doPush) {
				luaFile = 'mods/' + Paths.currentModDirectory + '/' + luaFile;
				doPush = true;
			} else {
				luaFile = Paths.getPreloadPath(luaFile);
				if(FileSystem.exists(luaFile) && !doPush) {
					doPush = true;
				}
			}

			if (doPush)
			{
				luaArray.push(new TitleLua(luaFile));
			}

			trace(FlxG.save.data.warned);	

			FlxG.mouse.visible = false;
			#if FREEPLAY
			MusicBeatState.switchState(new FreeplayState());
			#elseif CHARTING
			MusicBeatState.switchState(new ChartingState());
			#else
			#if desktop
			if (ClientPrefs.discord)
			{
				DiscordClient.initialize();
				Application.current.onExit.add (function (exitCode) {
					DiscordClient.shutdown();
				});
			}
			#end
			if (FlxG.save.data.warned == null || FlxG.save.data.warned == false)
			{
				MusicBeatState.switchState(new VeryFunnyWarning());
			}
			else
			{
				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					startIntro();
				});
			}
			#end
		}
	}

	public var bgSprite:FlxSprite;
	public var bgGlow:FlxSprite;
	public var logoBl:FlxSprite;
	public var gfDance:FlxSprite;
	public var danceLeft:Bool = false;
	public var titleText:FlxSprite;
	public var swagShader:ColorSwap = null;

	function startIntro()
	{
		if (!initialized)
		{
			callOnLuas('onStartIntro', [true]);
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
				
			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();

			if(FlxG.sound.music == null) {
				FlxG.sound.playMusic(Paths.music(musicString));

				// FlxG.sound.music.fadeIn(4, 0, 0.7);
			}
		}
		else
		{
			callOnLuas('onStartIntro', [false]);
		}

		Conductor.changeBPM(102);

		MainMenuState.coolBeat = Std.int(Conductor.crochet / 1000);

		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// bg.antialiasing = ClientPrefs.globalAntialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		bgSprite = new FlxSprite().loadGraphic(Paths.image('titleScreen/night'));
		bgSprite.updateHitbox();
		bgSprite.screenCenter();
		bgSprite.alpha = 0;
		add(bgSprite);

		FlxTween.tween(bgSprite, {alpha: bgSprite.alpha + 1}, 0.6);
		

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();
		// logoBl.screenCenter();
		// logoBl.color = FlxColor.BLACK;

		swagShader = new ColorSwap();
		if(!FlxG.save.data.psykaEasterEgg || !easterEggEnabled) {
			gfDance = new FlxSprite(0, 0).loadGraphic(Paths.image('titleScreen/bfandgf'));
		}
		else //Psyka easter egg
		{
			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.04);
			gfDance.frames = Paths.getSparrowAtlas('psykaDanceTitle');
			gfDance.animation.addByIndices('danceLeft', 'psykaDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'psykaDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		assetsGroup = new FlxGroup();
		assetsGroup.visible = false;
		add(assetsGroup);

		// blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		// credGroup.add(blackScreen);

		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		assetsGroup.add(gfDance);
		gfDance.shader = swagShader.shader;
		assetsGroup.add(logoBl);
		//logoBl.shader = swagShader.shader;

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		assetsGroup.add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		logoSpr = new FlxSprite(0, FlxG.height * 0.4).loadGraphic(Paths.image('titlelogo'));
		add(logoSpr);
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.55));
		logoSpr.updateHitbox();
		logoSpr.screenCenter(X);
		logoSpr.antialiasing = ClientPrefs.globalAntialiasing;

		// FlxTween.tween(logoSpr, {y: logoSpr.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		FlxTween.tween(titleText, {y: titleText.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		if (initialized)
			skipIntro();
		else
			initialized = true;

		callOnLuas('onStartIntroPost', []);

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		callOnLuas('onUpdate', [elapsed]);
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}

		// EASTER EGG

		if (!transitioning && skippedIntro)
		{
			if(pressedEnter && canPress)
			{
				callOnLuas('onEnter', []);
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(FlxColor.WHITE, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				FlxTween.tween(logoBl, {x: logoBl.x - (logoBl.width * 2)}, 1.5, {ease: FlxEase.quadInOut});
				FlxTween.tween(titleText, {x: titleText.x + 1280}, 1.5, {ease: FlxEase.quadInOut});

				transitioning = true;
				// FlxG.sound.music.stop();

				var dontWarn:Bool;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					if (musicString != 'freakyMenu')
					{
						FlxG.sound.music.stop();
					}
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (pressedEnter && !skippedIntro && canPress)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		callOnLuas('onUpdatePost', [elapsed]);

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		setOnLuas('curBeat', [curBeat]);
		callOnLuas('onBeatHit', []);

		if(logoBl != null) 
			logoBl.animation.play('bump');

		/*
		if(gfDance != null) {
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		
		}
		*/

		if(!closedState || !customBeat) 
		{
			switch (curBeat)
			{
				/*
				case 1:
					createCoolText(['PurpleInsomnia'], 45);
				// credTextShit.visible = true;
				*/
				case 3:
					addMoreText('PurpleInsomnia', 45);
					addMoreText('Presents', 45);
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 4:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 5:
					createCoolText(['This is a mod to'], -60);
				case 7:
					addMoreText('This game right below lol', -60);
					logoSpr.visible = true;
				// credTextShit.text += '\nNewgrounds';
				case 8:
					deleteCoolText();
					logoSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 9:
					createCoolText(['The Real Deal']);
				// credTextShit.visible = true;
				case 11:
					addMoreText('Is Here');
				// credTextShit.text += '\nlmao';
				case 12:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 13:
					addMoreText('Left Sides');
				// credTextShit.visible = true;
				case 14:
					addMoreText('2');
				// credTextShit.text += '\nNight';
				case 15:
					addMoreText('Lets Funkin Go'); // credTextShit.text += '\nFunkin';

				case 16:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	public function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(logoSpr);

			FlxG.camera.flash(FlxColor.WHITE, 1);
			remove(credGroup);
			assetsGroup.visible = true;
			remove(bgSprite);
			skippedIntro = true;
		}

		callOnLuas('onSkip', []);
	}

	public function getControl(key:String) {
		var pressed:Bool = Reflect.getProperty(controls, key);
		//trace('Control result: ' + pressed);
		return pressed;
	}

	public function callOnLuas(event:String, args:Array<Dynamic>):Dynamic {
		var returnVal:Dynamic = TitleLua.Function_Continue;
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			var ret:Dynamic = luaArray[i].call(event, args);
			if(ret != TitleLua.Function_Continue) {
				returnVal = ret;
			}
		}
		#end
		return returnVal;
	}

	public function setOnLuas(variable:String, arg:Dynamic) {
		#if LUA_ALLOWED
		for (i in 0...luaArray.length) {
			luaArray[i].set(variable, arg);
		}
		#end
	}

	public function addTextToDebug(text:String) {
		#if LUA_ALLOWED
		luaDebugGroup.forEachAlive(function(spr:DebugLuaTextTitle) {
			spr.y += 20;
		});
		luaDebugGroup.add(new DebugLuaTextTitle(text, luaDebugGroup));
		#end
	}

	public function removeLua(lua:TitleLua) {
		if(luaArray != null && !preventLuaRemove) {
			luaArray.remove(lua);
		}
	}
}
