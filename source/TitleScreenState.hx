package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import sys.FileSystem;
import flixel.util.FlxColor;
import lime.app.Application;
import haxe.Json;
#if desktop
import Discord.DiscordClient;
#end
import GameJolt.GameJoltAPI;

typedef TitleJson = {
	stopMusic:Bool,
	selectable:Array<String>
}

class TitleScreenState extends MusicBeatState
{
    var shitBalls:Array<String> = ["Start", "Load Save", "Credits", "Extras"];
    var callbacks:Array<Void->Void> = [];

    public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

    public static var curSaveFile:Int = 0;
	public static var sfn:String = '';

    public static var initialized:Bool = false;

    var grp:FlxTypedGroup<FlxSprite>;

    private static var curSelected:Int = 0;

	var canPress:Bool = true;

	var file:TitleJson;

    override function create()
    {
		WeekData.loadTheFirstEnabledMod();

		if (FileSystem.exists(Paths.getModFile("titleScreen.json")))
		{
			file = Json.parse(Paths.getTextFromFile("titleScreen.json"));
		}
		else
		{
			file = {
				stopMusic: false,
				selectable: ["Start", "Load Save", "Credits", "Extras"]
			}
		}

		shitBalls = file.selectable;

		//Gonna finish this later, probably

		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;

		if (!initialized)
		{
			PlayerSettings.init();
			loadData();
		}

		initialized = true;
		
		FlxG.mouse.visible = false;
		
		FlxG.mouse.load(Paths.image('leftMouse'));

        var spr:Backdrop = new Backdrop("title/bg", 1, 1, "HORIZONTAL", -1);
		spr.blend = openfl.display.BlendMode.MULTIPLY;
		spr.alpha = 0;
        add(spr);

		FlxTween.tween(spr, {alpha: 1}, 1);

        var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image("title/logo"));
        add(logo);

		FlxTween.tween(logo, {y: logo.y + 25}, 2, {type: PINGPONG, ease: FlxEase.sineInOut});

        grp = new FlxTypedGroup<FlxSprite>();
        add(grp);

        for (i in 0...shitBalls.length)
        {
            var button:FlxSprite = new FlxSprite();
            button.loadGraphic(Paths.image("title/" + shitBalls[i]), true, 1280, 720);
            button.animation.add("idle", [0], 1, true);
            button.animation.add("selected", [1], 1, true);
			button.ID = i;
			if (i != curSelected)
			{
				button.alpha = 0.75;
				button.x = 0;
			}
			else
			{
				button.x = -25;
			}
            grp.add(button);
        }

		callbacks = [startGame, loadSave, credits, extras];

		var versionShit:FlxText = new FlxText(12, FlxG.height - 84, 0, MainMenuState.saveFileName, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Friday Night Funkin Left Sides v3.0", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + MainMenuState.psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

        FlxG.sound.playMusic(Paths.music("title"), 1, false);

		Conductor.changeBPM(102);

		MainMenuState.coolBeat = Std.int(Conductor.crochet / 1000);

		changeSelection(0);

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (controls.UI_UP_P && canPress)
        {
            changeSelection(-1);
        }
        if (controls.UI_DOWN_P && canPress)
        {
            changeSelection(1);
        }
        if (controls.ACCEPT && canPress)
        {
            canPress = false;
			SaveFileMenu.title = false;
			FlxG.sound.play(Paths.sound("title/accept"));
            callbacks[curSelected]();
        }
        super.update(elapsed);
    }

	var moveTwn:FlxTween;
	var moveTwn2:FlxTween;
    function changeSelection(?huh:Int = 0)
    {
		if (moveTwn != null)
		{
			moveTwn.cancel();
		}
		if (moveTwn2 != null)
		{
			moveTwn2.cancel();
		}
        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("title/scroll"), 0.5);
        }

		var toBack:Int = 0;

        curSelected += huh;
		toBack = Std.int(curSelected + (huh * -1));
        if (curSelected >= shitBalls.length)
		{
            curSelected = 0;
			toBack = shitBalls.length - 1;
		}
        if (curSelected < 0)
		{
            curSelected = shitBalls.length - 1;
			toBack = 0;
		}

        for (i in 0...grp.length)
        {
            grp.members[i].animation.play("idle", true);
        }
        grp.members[curSelected].animation.play("selected", true);
		moveTwn = FlxTween.tween(grp.members[curSelected], {x: -25, alpha: 1}, 0.25);
		moveTwn2 = FlxTween.tween(grp.members[toBack], {x: 0, alpha: 0.75}, 0.25);
    }

    function doGoofyAhhTweens(sex:Int)
    {
		grp.forEach(function(spr:FlxSprite)
		{
			if (spr.ID != sex)
			{
				FlxTween.tween(spr, {x: 1280, alpha: 0}, 1);
			}
		});
    }

    function startGame()
    {
        doGoofyAhhTweens(curSelected);
        new FlxTimer().start(1, function(tmr:FlxTimer)
        {
			if (FlxG.save.data.warned)
			{
				if (!file.stopMusic)
				{
            		FlxG.sound.music.stop();
				}
            	MusicBeatState.switchState(new MainMenuState());
			}
			else
			{
				MusicBeatState.switchState(new VeryFunnyWarning());
			}
        });
    }

	function loadSave()
	{
		doGoofyAhhTweens(curSelected);
		SaveFileMenu.title = true;
        new FlxTimer().start(1, function(tmr:FlxTimer)
        {
			if (!file.stopMusic)
			{
            	FlxG.sound.music.stop();
			}
            MusicBeatState.switchState(new SaveFileMenu());
        });
	}

	function credits()
	{
		doGoofyAhhTweens(curSelected);
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			if (!file.stopMusic)
			{
            	FlxG.sound.music.stop();
			}
			MusicBeatState.switchState(new ChooseCredits());
		});
	}

	function extras()
	{
		if (!file.stopMusic)
		{
            FlxG.sound.music.stop();
		}
		MusicBeatState.switchState(new options.Extras());
	}

    public static function loadData()
    {
		var createdFile:Bool = false;
		var SaveFileName:String = 'funkin';

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
			initialized = false;
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

			trace("uhhhhhh");

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

			if (FlxG.save.data.weekCompleted != null)
			{
				StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
			}
			if (FlxG.save.data.weekEncoreCompleted != null)
			{
				StoryEncoreState.weekEncoreCompleted = FlxG.save.data.weekEncoreCompleted;
			}

			var split:Array<String> = ClientPrefs.preferedDimens.split(" x ");
			var toMod:Array<Int> = [Std.parseInt(split[0]), Std.parseInt(split[1])];
			FlxG.resizeWindow(toMod[0], toMod[1]);

			WindowControl.rePosWindow();

			Colorblind.changeMode();

			SideStorySelectState.load();

			FlxG.save.data.createdFile = createdFile;
			FlxG.save.flush();

			GameJoltAPI.connect();
			GameJoltAPI.authDaUser(ClientPrefs.gameJoltLogin[0], ClientPrefs.gameJoltLogin[1], false);

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
        }
    }
}