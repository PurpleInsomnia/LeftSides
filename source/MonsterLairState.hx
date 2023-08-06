package;

#if DISCORD
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.system.FlxAssets.FlxShader;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import flixel.system.FlxAssets.FlxShader;
import flixel.tweens.FlxTween;
import haxe.Json;
import sys.FileSystem;
import filters.*;
import options.ContentWarningTerminalState;

typedef ListJson = {
    var listNames:Array<String>;
    var lists:Array<Array<String>>;
}

class MonsterLairState extends MusicBeatState
{
    var toDo:Array<String> = ["Songs", "Chat", "Terminal", "Shop", "Sound Test"];

    var songLists:Array<Array<String>> = [];

    var listNames:Array<String> = [];

    var termShit:Array<String> = ["Open Terminal", "All Questions"];

    var chatAsks:Array<String> = [
        "What Is Your Name?",
        "What Are You Doing With Ben?",
        "What Are You?",
        "Where were you banished to?",
        "Why were you in prison?",
        "Opinion On Humans?",
        "Are You A Liar?",
        "Do You Have Any Friends?",
        "Do You Have Any Enemys?",
        "What Do You Want?",
        "Sound Test?",
        "DEPTHS?",
        "Remnants Of Our World?",
        "Trance World?"
    ];

    var chatAnswers:Array<String> = [
        "I really have no name...so I just [TAKE] the name of the person's body that I'm in currently...You can call me [MONSTER]",
        "What I am doing? I want him out of his misery. I want out of my misery. It's not [FAIR] that he can live a normal life while I am stuck in his [HELLHOLE] of a mind.",
        "My [RACE] known as [*#au@^%#s] is feared across [MILLIONS] of galaxys...I was [BANISHED] by [LORD] after escaping [PRISON]...[THEY] are just [JEALOUS] of [MY] [POWER]",
        "Earth...I miss [T#A*!?]",
        "I single handedly [WIPED] out [SEVEN HUNDRED TWO] different planets of their inhabbitants...",
        "I hate humanity for what they are doing to this [SHITTY] world...What's gonna happen when the [EARTH] overpopulates? What's gonna happen when animals cease to exist? What's gonna happen when the air becomes unbreathable?",
        "[NO], I [AM NOT AM NOT AM NOT AM NOT] a liar...I [DO NOT LIE] about [EVERYTHING]...but I am [ALWAYS] [TRUTHFUL]",
        "...[FRIEND]...",
        "[TESS]...[LORD LORD LORD]...lots of [DISGUSTING] creatures that want to [TAKE] [AWAY] what I want...",
        "[THE UNIVERSE] to [%& *(%@#CT]",
        "I have hints I've gathered from this [HELLHOLE]:\n- OLD CD GAME\n- MOD PAGE DESCRIPTION\n...Goodluck " + CoolUtil.username() + " ...",
        "That child isn't ready for what lurks down there...",
        "...Ah...those four...R[?*!@], A[@#*], I[?**(] and V...\n...They don't stand a [CHANCE].\nNot with all those [ABOMINATIONS] running around...",
        "...[WANTED KID]...What's his name?...Rem Saikle?\nThe [REDACTED] Government put down a high price for his head.\nSuch a shame that [REDACTED]..."
    ];

    var welcomeMessages:Array<String> = [
        "Welcome..." + CoolUtil.username() + "...",
        "[YOU] made it!!"
    ];

    var text:FlxTypeText;

    var grp:FlxTypedGroup<Alphabet>;

    var curSelected:Int = 0;

    var monster:FlxSprite;

    var camGame:FlxCamera;
    var camFront:FlxCamera;

    var vcr:VCR;

    var currentArray:Array<String> = [];

    var canPress:Bool = true;
    var inDialogue:Bool = false;

    var random:Int = 0;

    var created:Bool = false;
    var noHoriz:Bool = true;

    var soundTestCodes:Array<Int> = [0, 0];

    override function create() 
    {
        #if desktop
        DiscordClient.changePresence("In 'The Monster's Lair'", null);
        #end
        random = FlxG.random.int(0, welcomeMessages.length - 1);
        noHoriz = true;

        var jsonFile:ListJson;
        if (FileSystem.exists(Paths.preloadFunny("data/MonsterLairLists.json")))
        {
            jsonFile = Json.parse(Paths.getTextFromFile("data/MonsterLairLists.json"));
        }
        else
        {
            jsonFile = {
                listNames: ["Void", "Dreams"],
                lists: [
                    ["No Song Bozo"],
                    ["No Song Bozo"]
                ]
            }
        }
        songLists = jsonFile.lists;
        listNames = jsonFile.listNames;

        if (Highscore.getWeekScore("week6", 1) > 0 || ClientPrefs.devMode)
        {
            toDo.push("Visit");
        }

        if (ClientPrefs.completedSideStories.get("visit") || ClientPrefs.devMode)
        {
            termShit.push("Archives");
        }

        PlayState.songPrefix = "";

        FlxG.sound.music.stop();
        FlxG.sound.playMusic(Paths.music("lair"));

		//camGame = new FlxCamera();
        camGame = new FlxCamera(0, 0, 600, FlxG.height, 1);
        camFront = new FlxCamera();
		camFront.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camFront);
		FlxCamera.defaultCameras = [camGame];

        var funny:FlxSprite = new FlxSprite().makeGraphic(600, FlxG.height, 0xFF232323);
        add(funny);

        grp = new FlxTypedGroup<Alphabet>();
        add(grp);

        if (ClientPrefs.shaders)
        {
            var toAdd:Array<BitmapFilter> = [];
            var tv:TV = new TV();
            var filter1:ShaderFilter = new ShaderFilter(tv.shader);
            vcr = new VCR();
            var filter2:ShaderFilter = new ShaderFilter(vcr.shader);
            var filter3:ShaderFilter = new ShaderFilter(new Scanline());
            toAdd.push(filter1);
            toAdd.push(filter2);
            toAdd.push(filter3);
            camGame.setFilters(toAdd);
        }

        currentArray = toDo;
        createAlphabetList();
        changeSelection(0);

        monster = new FlxSprite().loadGraphic(Paths.image("monsterLair/monster"));
        monster.x = 600;
        add(monster);

        var archSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image("monsterLair/arches"));
        add(archSpr);

        var tvSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image("monsterLair/tv"));
        add(tvSpr);

        var box:FlxSprite = new FlxSprite(600, 520).makeGraphic(680, 200, 0xFF0A0A0A);
        add(box);

        text = new FlxTypeText(610, box.y + 10, FlxG.width - 670, "", 24);
        text.font = Paths.font("eras.ttf");
		text.sounds = [FlxG.sound.load(Paths.sound('term/text'), 0.4)];
        add(text);

        reloadWelcomes();

        monster.cameras = [camFront];
        tvSpr.cameras = [camFront];
        archSpr.cameras = [camFront];
        box.cameras = [camFront];
        text.cameras = [camFront];

        created = true;

        PlayState.encoreMode = false;

        super.create();    
    }

    var changing:Bool = false;
    override function update(elapsed:Float)
    {
        if (ClientPrefs.shaders)
        {
            vcr.update(elapsed);
        }

        if (canPress && !inDialogue)
        {
            if (controls.UI_DOWN_P)
            {
                changeSelection(1);
            }
            if (controls.UI_UP_P)
            {
                changeSelection(-1);
            }
            if (controls.ACCEPT && noHoriz)
            {
                FlxG.sound.play(Paths.sound("confirmMenu"));
                if (currentArray == toDo && !changing)
                {
                    switch (toDo[curSelected])
                    {
                        case "Songs":
                            currentArray = listNames;
                        case "Chat":
                            currentArray = chatAsks;
                        case "Terminal":
                            currentArray = termShit;
                        case "Visit":
                            MusicBeatState.switchState(new SideStoryState(CoolUtil.coolTextFile("assets/side-stories/data/visit/dialogue.txt"), "visit", ""));
                            FlxG.sound.music.stop();
                            return;
                        case "Sound Test":
                            FlxG.sound.music.stop();
                            fade();
                            MusicBeatState.switchState(new SoundTestState());
                            return;
                        case "Shop":
                            FlxG.sound.music.stop();
                            fade();
                            MusicBeatState.switchState(new ShopState());
                            return;
                    }
                    curSelected = 0;
                    createAlphabetList();
                    changeSelection(0);
                    changing = true;
                }
                if (currentArray == listNames && !changing)
                {
                    currentArray = songLists[curSelected];
                    curSelected = 0;
                    createAlphabetList();
                    changeSelection(0);
                    changing = true;
                }
                var issl:Bool = false;
                for (i in 0...songLists.length)
                {
                    if (currentArray == songLists[i])
                    {
                        issl = true;
                    }
                }
                if (issl && !changing)
                {
                    if (Paths.formatToSongPath(currentArray[curSelected]) == "isolation")
                    {
                        MusicBeatState.switchState(new SideStoryState(CoolUtil.coolTextFile("assets/side-stories/data/isolation/dialogue.txt"), "isolation", ""));
                        FlxG.sound.music.stop();
                        return;
                    }
                    else
                    {
			            canPress = false;

			            var songLowercase:String = ""; 
                        songLowercase = Paths.formatToSongPath(currentArray[curSelected]);
			            var poop:String = 'normal';
			            #if MODS_ALLOWED
			            if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			            #else
			            if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			            #end
				            poop = songLowercase;
			            }

			            PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			            PlayState.isStoryMode = false;
			            PlayState.storyDifficulty = 1;

			            PlayState.storyWeek = 0;
			            PlayState.isVoid = true;

					    FlxG.sound.music.stop();
                        fade();
					    MusicBeatState.switchState(new HealthLossState());
                        changing = true;
                    }
                }
                if (currentArray == chatAsks && !changing)
                {
                    ask(curSelected);
                }
                if (currentArray == termShit && !changing)
                {
                    switch (termShit[curSelected])
                    {
                        case "Open Terminal":
					        FlxG.sound.music.stop();
                            changing = true;
                            canPress = false;
					        MusicBeatState.switchState(new ContentWarningTerminalState());
                        case "All Questions":
                            makeTerminalFile();
                        case "Archives":
                            FlxG.sound.music.stop();
                            changing = true;
                            canPress = false;
                            MusicBeatState.switchState(new archive.ArchiveBootState());
                    }
                }
            }
            if (controls.BACK && noHoriz)
            {
                FlxG.sound.play(Paths.sound("cancelMenu"));
                if (currentArray == toDo && !changing)
                {
                    FlxG.sound.music.stop();
                    fade();
                    MusicBeatState.switchState(new MainMenuState());
                }
                if (currentArray == listNames && !changing)
                {
                    currentArray = toDo;
                    createAlphabetList();
                    changeSelection(0);
                    changing = true;
                }
                for (i in 0...songLists.length)
                {
                    if (currentArray == songLists[i])
                    {
                        if (!changing)
                        {
                            currentArray = listNames;
                            createAlphabetList();
                            changeSelection(0);
                            changing = true;
                        }
                    }
                }
                if (currentArray == chatAsks && !changing)
                {
                    inDialogue = false;
                    currentArray = toDo;
                    createAlphabetList();
                    changeSelection(0);
                    reloadWelcomes();
                    changing = true;
                }
                if (currentArray == termShit && !changing)
                {
                    currentArray = toDo;
                    createAlphabetList();
                    changeSelection(0);
                    changing = true;
                }
            }
        }
        if (canPress && inDialogue)
        {
            if (controls.ACCEPT)
            {
                if (inDialogue)
                {
				    FlxG.sound.play(Paths.sound('term/accept'));
                    text.skip();
                }
            }
        }

        super.update(elapsed);
    }

    function changeSelection(huh:Int)
    {
        if (huh != 0)
            FlxG.sound.play(Paths.sound("scrollMenu"));

        curSelected += huh;

        if (curSelected >= currentArray.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = currentArray.length - 1;

		var bullShit:Int = 0;

		for (i in 0...currentArray.length)
		{
			grp.members[i].targetY = bullShit - curSelected;
			bullShit++;

			grp.members[i].alpha = 0.75;

			if (grp.members[i].targetY == 0)
			{
				grp.members[i].alpha = 1;
			}
		}
    }

    function createAlphabetList()
    {
        canPress = false;
        var array:Array<String> = currentArray;

        if (created)
        {
            for (i in 0...grp.length)
                grp.remove(grp.members[i]);
        }

        for (i in 0...array.length)
        {
            var scaleThing:Float = 1;
            if (currentArray == chatAsks)
            {
                scaleThing = 0.4;
            }
            if (currentArray == termShit)
            {
                scaleThing = 0.75;
            }
            if (currentArray == songLists[0] || currentArray == songLists[1])
            {
                scaleThing = 0.6;
            }
            var alpha:Alphabet = new Alphabet(0, 360, array[i], true, false, 0.05, scaleThing);
			alpha.isMenuItem = true;
            alpha.forceX = 50;
            alpha.targetY = i;
            grp.add(alpha);
        }
        new FlxTimer().start(0.01, function(tmr:FlxTimer)
        {
            canPress = true;
            changing = false;
        });
    }

    function ask(cool:Int = 0)
    {
        canPress = false;
        inDialogue = true;
        var toAns:String = chatAnswers[cool];
		text.resetText(toAns);
		text.start(0.04, true);
		text.completeCallback = function() {
			inDialogue = false;
		};
        new FlxTimer().start(0.01, function(tmr:FlxTimer)
        {
            canPress = true;
        });
    }

    function monsterText(text:String)
    {
        FlxG.sound.play(Paths.sound('term/accept'));
        this.text.resetText(text);
		this.text.start(0.04, true);
    }

    function reloadWelcomes()
    {
		FlxG.sound.play(Paths.sound('term/accept'));
        var toSay:String = "swagfart";
        toSay = welcomeMessages[random];
		text.resetText(toSay);
		text.start(0.04, true);
    }

    function fade()
    {
		camFront.fade(0xFF000000, 0.5, false);
    }

    function fadeIn()
    {
		camFront.fade(0xFF000000, 0.5, true);
    }

	function makeTerminalFile()
	{
		TextFile.newFile("Who is Ben?\nWho is Tess?\nWhat is Monster?\nWhat is Hating Simulator?\nWhat is the Void?\nWhat are you?\nWho are the Andersons?\nWho is the oldest Anderson daughter?\nWhat did Ben do in April?\nWho am I?\nWhat is on Ben's Arm?", "ALL TERMINAL QUESTIONS");
	}
}