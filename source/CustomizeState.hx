package;

import LoadingScreenState.LoadingMeta;
import LoadingScreenState.LoadingScreenMeta;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import sys.FileSystem;
import options.*;

using StringTools;

class CustomizeState extends MusicBeatState
{
    var fileList:Array<String> = ['Off', 'NOTE_assets', 'funkinNOTE_assets', "purpleinsomniaNOTE_assets", "breakingBadNOTE_assets"];
	var splashFileList:Array<String> = ["Off", "noteSplashes", "funkinNoteSplashes", "purpleinsomniaNoteSplashes", "breakingBad_noteSplashes"];
	var strumArray:Array<String> = ['Off', 'Left Sides Notes', "Funkin' Notes", "PurpleInsomnia Notes", "Breaking Bad Notes"];
	var directories:Array<String> = [Paths.mods(), Paths.getPreloadPath()];
    // I hate the sonic spikes tbh :/
	var barArray:Array<String> = ['Default', "Grid", "Foggy"];
	var ratingArray:Array<String> = ['Default', 'Funkin', "PurpleInsomnia"];

    var tess:Character;
    var ben:Character;

    var camGame:FlxCamera;
    var camHUD:FlxCamera;

    var topBar:FlxSprite;
    var botBar:FlxSprite;

    var curThing:Int = 0;
    var curMode:Int = 0;
    var curSelected:Array<Int> = [0, 0, 0];
    var theRead:Array<Array<String>> = [];

    var daStrum:FlxSprite;
    var daNote:FlxSprite;

    var modeTxt:FlxText;
    var selText:FlxText;

    override function create()
    {
        Paths.destroyLoadedImages();

        resetArrays();

		checkMods();
		checkForStrums();
		checkForBars();
		checkForRating();

        theRead = [strumArray, barArray, ratingArray];

        camGame = new FlxCamera();
        camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

        FlxG.camera.zoom = 0.85;

        var follow:FlxSprite = new FlxSprite().makeGraphic(2, 2);
        follow.screenCenter();
        follow.x += 640;
        add(follow);

        FlxG.camera.follow(follow, null, 1);

        var bg:FlxSprite = new FlxSprite(0, -100).makeGraphic(2560, 1440, 0xFF7F7F7F);
        add(bg);

        var floor:FlxSprite = new FlxSprite().loadGraphic(Paths.image("placeholderStage"));
        floor.y = 640;
        add(floor);

        // adds tess :)
        tess = new Character(0, 0, "gf-new", false);
        tess.screenCenter(X);
        tess.x += 640;
        tess.y = floor.y - Std.int(tess.height);
        add(tess);

        ben = new Boyfriend(0, 0, "bf-new");
        ben.screenCenter(X);
        ben.x += Std.int(ben.width) + 640;
        ben.y = floor.y - Std.int(ben.height - 100);
        add(ben);

        var daThing:String = "NOTE_assets";
        if (CustomStrum.strum != "")
        {
            daThing = CustomStrum.strum;
        }

        daStrum = new FlxSprite(0, 0);
        daStrum.frames = Paths.getSparrowAtlas(daThing);
        daStrum.animation.addByPrefix("static", "arrowUP", 24, true);
        daStrum.animation.addByPrefix("confirm", "up confirm", 24, false);
        daStrum.updateHitbox();
        daStrum.animation.play("static", true);
        daStrum.setGraphicSize(Std.int(daStrum.width * 0.7));
        daStrum.screenCenter();
        daStrum.x -= 320;
        daStrum.cameras = [camHUD];
        add(daStrum);

        daNote = new FlxSprite(0, 0);
        daNote.frames = Paths.getSparrowAtlas(daThing);
        daNote.animation.addByPrefix("note", "green0", 24, true);
        daNote.animation.play("note", true);
        daNote.setGraphicSize(Std.int(daNote.width * 0.7));
        daNote.x = daStrum.x;
        daNote.y = 720;
        daNote.cameras = [camHUD];
        add(daNote);

        startDaNote();

        topBar = new FlxSprite().loadGraphic(Paths.image('cinematicBars/' + ClientPrefs.customBar));
        topBar.flipY = true;
        topBar.y = -720 + 70;
        topBar.cameras = [camHUD];
        add(topBar);

        botBar = new FlxSprite().loadGraphic(Paths.image("cinematicBars/" + ClientPrefs.customBar));
        botBar.y = 720 - 70;
        botBar.cameras = [camHUD];
        add(botBar);

        modeTxt = new FlxText(25, 18, 780, "< CUSTOM STRUM >", 42);
        modeTxt.setFormat(Paths.font("vcr.ttf"), 42, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        modeTxt.cameras = [camHUD];
        add(modeTxt);

        selText = new FlxText(0, 720 - Std.int(modeTxt.height + 9), FlxG.width, "< Off >", 42);
        selText.setFormat(Paths.font("vcr.ttf"), 42, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        selText.cameras = [camHUD];
        selText.screenCenter(X);
        add(selText);

        changeThing(0);

        checkPrefs();

        changeBar(curSelected[1]);

        scrollCurSelected(curMode, 0);

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (controls.UI_LEFT_P)
        {
            switch(curThing)
            {
                case 0:
                    changeMode(-1);
                case 1:
                    switch(curMode)
                    {
                        case 0:
                            scrollCurSelected(curMode, -1);
                            changeStrum(curSelected[curMode]);
                        case 1:
                            scrollCurSelected(curMode, -1);
                            changeBar(curSelected[curMode]);
                        case 2:
                            scrollCurSelected(curMode, -1);
                            changeRating(curSelected[curMode]);
                    }
                    ClientPrefs.saveSettings();
            }
        }
        if (controls.UI_RIGHT_P)
        {
            switch(curThing)
            {
                case 0:
                    changeMode(1);
                case 1:
                    switch(curMode)
                    {
                        case 0:
                            scrollCurSelected(curMode, 1);
                            changeStrum(curSelected[curMode]);
                        case 1:
                            scrollCurSelected(curMode, 1);
                            changeBar(curSelected[curMode]);
                        case 2:
                            scrollCurSelected(curMode, 1);
                            changeRating(curSelected[curMode]);
                    }
                    ClientPrefs.saveSettings();
            }
        }
        if (controls.UI_UP_P)
        {
            changeThing(-1);
        }
        if (controls.UI_DOWN_P)
        {
            changeThing(1);
        }
        if (controls.BACK)
        {
            CustomFadeTransition.nextCamera = camHUD;
            MusicBeatState.switchState(new OptionsState());
        }
        selText.screenCenter(X);
        daStrum.updateHitbox();
        daStrum.screenCenter();
        daStrum.x -= 320;
        super.update(elapsed);
    }

    function changeRating(huh:Int)
    {
        ClientPrefs.customRating = ratingArray[huh];
    }

    function changeBar(huh:Int)
    {
        ClientPrefs.customBar = barArray[huh];
        if (huh > 1)
        {
            ClientPrefs.isCustomBar = true;
        }
        else
        {
            ClientPrefs.isCustomBar = false;
        }

        if (ClientPrefs.customBar != "Default")
        {
            topBar.loadGraphic(Paths.image('cinematicBars/' + ClientPrefs.customBar));
            topBar.flipY = true;
            topBar.y = -720 + 70;

            botBar.loadGraphic(Paths.image("cinematicBars/" + ClientPrefs.customBar));
            botBar.y = 720 - 70;
        }
        else
        {
            topBar.makeGraphic(1280, 720, 0xFF000000);
            topBar.flipY = true;
            topBar.y = -720 + 70;

            botBar.makeGraphic(1280, 720, 0xFF000000);
            botBar.y = 720 - 70;
        }
    }

    function changeStrum(huh:Int)
    {
        ClientPrefs.customStrum = strumArray[huh];

        if (strumArray[huh] != "Off")
        {
            CustomStrum.strum = fileList[huh];
            CustomStrum.splash = splashFileList[huh];
        }
        else
        {
            CustomStrum.strum = "";
            CustomStrum.splash = "";
        }

        var daThing:String = "NOTE_assets";
        if (CustomStrum.strum != "")
        {
            daThing = CustomStrum.strum;
        }

        daNote.frames = Paths.getSparrowAtlas(daThing);
        daNote.animation.addByPrefix("note", "green0", 24, true);
        daNote.animation.play("note", true);

        daStrum.frames = Paths.getSparrowAtlas(daThing);
        daStrum.animation.addByPrefix("static", "arrowUP", 24, true);
        daStrum.animation.addByPrefix("confirm", "up confirm", 24, false);
        daStrum.animation.play("static", true);
    }

    function scrollCurSelected(bruh:Int, huh:Int)
    {
        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

        curSelected[bruh] += huh;

        if (curSelected[bruh] >= theRead[bruh].length)
            curSelected[bruh] = 0;
        if (curSelected[bruh] < 0)
            curSelected[bruh] = theRead[bruh].length - 1;

        var cool:Int = curSelected[bruh];

        switch (bruh)
        {
            case 0:
                selText.text = "< " + strumArray[cool] + " >";
            case 1:
                selText.text = "< " + barArray[cool] + " >";
            case 2:
                selText.text = "< " + ratingArray[cool] + " >";
        }
    }

    function changeMode(huh:Int)
    {
        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }
        curMode += huh;

        if (curMode > 2)
            curMode = 0;
        if (curMode < 0)
            curMode = 2;

        switch (curMode)
        {
            case 0:
                modeTxt.text = "< CUSTOM STRUM >";
            case 1:
                modeTxt.text = "< CUSTOM BAR >";
            case 2:
                modeTxt.text = "< CUSTOM RATING >";
        }

        scrollCurSelected(curMode, 0);
    }

    function changeThing(huh:Int)
    {
        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }
        curThing += huh;

        if (curThing > 1)
            curThing = 0;
        if (curThing < 0)
            curThing = 1;

        switch (curThing)
        {
            case 0:
                modeTxt.alpha = 1;
                selText.alpha = 0.5;
            case 1:
                modeTxt.alpha = 0.5;
                selText.alpha = 1;
        }
    }

    function resetArrays()
	{
		strumArray = ['Off', 'Left Sides Notes', "Funkin' Notes", "PurpleInsomia Notes"];
		fileList = ['Off', 'NOTE_assets', 'funkinNOTE_assets', "purpleinsomniaNOTE_assets"];
		splashFileList = ["Off", "noteSplashes", "funkinNoteSplashes", "purpleinsomniaNoteSplashes"];
		barArray = ['Default', "Grid", "Foggy"];
		ratingArray = ['Default', 'Funkin', "PurpleInsomnia"];
		directories = [Paths.mods(), Paths.getPreloadPath()];
	}

	function checkMods()
	{
		var modsListPath:String = 'modsList.txt';
		var originalLength:Int = directories.length;
		if(FileSystem.exists(modsListPath))
		{
			var stuff:Array<String> = CoolUtil.coolTextFile(modsListPath);
			for (i in 0...stuff.length)
			{
				var splitName:Array<String> = stuff[i].trim().split('|');
				if(splitName[1] == '0') // Disable mod
				{
					// pussy
				}
				else // Sort mod loading order based on modsList.txt file
				{
					var path = haxe.io.Path.join([Paths.mods(), splitName[0]]);
					//trace('trying to push: ' + splitName[0]);
					if (sys.FileSystem.isDirectory(path) && !Paths.ignoreModFolders.exists(splitName[0]) && splitName[1] == '1' && !directories.contains(path))
					{
						directories.push(path + '/');
					}
				}
			}
		}
	}

	function checkForStrums()
	{
		for (i in 0...directories.length)
		{
			if (FileSystem.exists(directories[i] + 'data/skinList.txt'))
			{
				var list:Array<String> = CoolUtil.coolTextFile(directories[i] + 'data/skinList.txt');
				for (i in 0...list.length)
				{
					var split:Array<String> = list[i].split('|');
					strumArray.push(split[0]);
					if (split[1] == null)
					{
						lime.app.Application.current.window.alert('Please specify a file path by adding a "|" after your strum name.\nEXAMPLE: "My Strum|mystrumNOTE_assets|myStrumNoteSplashes"', "Error on strum file (line " + i + ")");
					}
					else
					{
						fileList.push(split[1]);
					}
					if (split[2] == null)
					{
						lime.app.Application.current.window.alert('Please specify a splash skin file path by adding a "|" after your strum file path.\nEXAMPLE: "My Strum|mystrumNOTE_assets|myStrumNoteSplashes"', "Error on strum file (line " + i + ")");
					}
					else
					{
						splashFileList.push(split[2]);
					}
				}
			}
		}
	}

	function checkForBars()
	{
		for (i in 0...directories.length)
		{
			if (FileSystem.exists(directories[i] + 'data/barList.txt'))
			{
				var list:Array<String> = CoolUtil.coolTextFile(directories[i] + 'data/barList.txt');
				for (i in 0...list.length)
				{
					barArray.push(list[i]);
				}
			}
		}
	}

	function checkForRating()
	{
		for (i in 0...directories.length)
		{
			if (FileSystem.exists(directories[i] + 'data/ratingList.txt'))
			{
				var list:Array<String> = CoolUtil.coolTextFile(directories[i] + 'data/ratingList.txt');
				for (i in 0...list.length)
				{
					ratingArray.push(list[i]);
				}
			}
		}
	}

    function checkPrefs()
    {
        var noS:Bool = true;
        var noB:Bool = true;
        var noR:Bool = true;

        for (i in 0...strumArray.length)
        {
            if (ClientPrefs.customStrum == strumArray[i])
            {
                curSelected[0] = i;
                noS = false;
            }
        }

        if (noS)
        {
            changeStrum(0);
        }

        for (i in 0...barArray.length)
        {
            if (ClientPrefs.customBar == barArray[i])
            {
                curSelected[1] = i;
                noB = false;
            }
        }

        if (noS)
        {
            changeBar(0);
        }

        for (i in 0...ratingArray.length)
        {
            if (ClientPrefs.customRating == ratingArray[i])
            {
                curSelected[2] = i;
                noR = false;
            }
        }

        if (noR)
        {
            changeRating(0);
        }
    }

    function startDaNote()
    {
        FlxTween.tween(daNote, {y: daStrum.y}, 1.5, {onComplete: function(twn:FlxTween)
        {
            daNote.y = 720;
            daStrum.animation.play("confirm", true);
            daStrum.centerOffsets();
		    daStrum.centerOrigin();
            daStrum.centerOrigin();
            daStrum.offset.x -= 13;
		    daStrum.offset.y -= 13;
            ben.playAnim("singUP", true, false, 0);
            spawnRating();
            new FlxTimer().start(1, function(tmr:FlxTimer)
            {
                ben.dance();
                daStrum.animation.play("static", true);
                startDaNote();
            });
        }});
    }

    function spawnRating()
    {
        var daRating:FlxSprite = new FlxSprite().loadGraphic(Paths.image('ratingPacks/' + ClientPrefs.customRating + '/sick'));
        daRating.y = 90;
        daRating.x = 1280 - Std.int(daRating.width);
        daRating.cameras = [camHUD];
        add(daRating);
        FlxTween.tween(daRating, {alpha: 0}, 1, {onComplete: function(twn:FlxTween)
        {
            remove(daRating);
        }});
    }
}

class CustomizeLoadingScreenState extends MusicBeatState
{
    public var canPress:Bool = true;
    public var curSelected:Int = 0;
    public var metas:Array<LoadingScreenState.LoadingScreenMeta> = [];

    public var camFollow:FlxSprite;
    public var loadingScreens:FlxTypedGroup<LoadingScreenSprite>;
    public var descText:FlxText;
    override function create()
    {
        var meta:LoadingScreenState.LoadingScreenMeta = haxe.Json.parse(sys.io.File.getContent("assets/images/loading/meta.json"));
        metas.push(meta);

        checkMods();

        camFollow = new FlxSprite().makeGraphic(1, 1);
        camFollow.screenCenter();
        add(camFollow);
        FlxG.camera.follow(camFollow, null, 1);

        var bd:Backdrop = new Backdrop("freeplay/grid", 0, 0, "HORIZONTAL", -1, 1);
        add(bd);

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("freeplay/bg"));
        bg.color = 0xFF3F3F3F;
        bg.scrollFactor.set(0, 0);
        bg.blend = openfl.display.BlendMode.MULTIPLY;
        add(bg);

        loadingScreens = new FlxTypedGroup<LoadingScreenSprite>();
        add(loadingScreens);

        var last:String = Paths.currentModDirectory;
        var j:Int = 0;
        for (i in 0...metas.length)
        {
            var nmd:String = "";
            if (metas[i].modDirectory != null)
            {
                nmd = metas[i].modDirectory;
            }
            Paths.currentModDirectory = nmd;
            for (met in metas[i].loadingScreens)
            {
                var scr:LoadingScreenSprite = new LoadingScreenSprite();
                scr.loadGraphic(Paths.image("loading/loadingScreens/" + met.path));
                scr.setGraphicSize(960, 540);
                scr.updateHitbox();
                scr.screenCenter();
                scr.x += 1010 * j;
                scr.init(metas[i], met);
                if (scr.unlocked)
                {
                    scr.ID = j;
                    j += 1;
                    loadingScreens.add(scr);
                }
            }
        }
        Paths.currentModDirectory = last;

        var topBar:FlxSprite = new FlxSprite();
        topBar.makeGraphic(1280, 720, 0xFF000000);
        topBar.y = -720 + 70;
        topBar.scrollFactor.set(0, 0);
        add(topBar);

        var botBar:FlxSprite = new FlxSprite();
        botBar.makeGraphic(1280, 720, 0xFF000000);
        botBar.y = 720 - 70;
        botBar.scrollFactor.set(0, 0);
        add(botBar);

        descText = new FlxText(0, botBar.y + 4, FlxG.width, "lol", 24);
        descText.setFormat(Paths.font("vcr.ttf"), 24, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        descText.scrollFactor.set();
        descText.screenCenter(X);
        add(descText);

        var hint:FlxText = new FlxText(0, 0, 1280, "Press [ACCEPT] to select a loading screen!", 18);
        hint.setFormat(Paths.font("vcr.ttf"), 18, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        hint.y += Std.int(hint.height) + 9;
        hint.scrollFactor.set();
        hint.screenCenter(X);
        add(hint);

        change(0);

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (controls.UI_LEFT_P && canPress)
        {
            change(-1);
        }
        if (controls.UI_RIGHT_P && canPress)
        {
            change(1);
        }
        if (controls.ACCEPT && canPress)
        {
            canPress = false;
            FlxG.sound.play(Paths.sound("confirmMenu"));
            LoadingScreenState.loadingScreenMeta = loadingScreens.members[curSelected].meta;
            LoadingScreenState.loadingScreen = loadingScreens.members[curSelected].data;

            FlxG.save.data.loadingScreenMetas = [LoadingScreenState.loadingScreenMeta, LoadingScreenState.loadingScreen];
            FlxG.save.flush();

            new FlxTimer().start(0.01, function(tmr:FlxTimer)
            {
                canPress = true;
            });
        }
        if (controls.BACK && canPress)
        {
            canPress = false;
            FlxG.sound.play(Paths.sound("cancelMenu"));
            MusicBeatState.switchState(new options.OptionsState());
        }
        super.update(elapsed);

        descText.screenCenter(X);
    }

    var camTwn:FlxTween = null;
    function change(?huh:Int = 0)
    {
        if (camTwn != null)
        {
            camTwn.cancel();
            camTwn = null;
        }

        curSelected += huh;

        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

        if (curSelected >= loadingScreens.length)
        {
            curSelected = 0;
        }
        if (curSelected < 0)
        {
            curSelected = loadingScreens.length - 1;
        }

        loadingScreens.forEach(
            function(spr:LoadingScreenSprite)
            {
                if (spr.ID == curSelected)
                {
                    spr.alpha = 1;
                    camTwn = FlxTween.tween(camFollow, {x: spr.getGraphicMidpoint().x - 185}, 0.5, {ease: FlxEase.circOut,
                        onComplete: function(twn:FlxTween)
                        {
                            camTwn = null;
                        }
                    });
                    descText.text = spr.data.desc;
                }
                else
                {
                    spr.alpha = 0.5;
                }
            }
        );
    }

    var directories:Array<String> = [];
    function checkMods()
	{
		var modsListPath:String = 'modsList.txt';
		var originalLength:Int = directories.length;
		if(FileSystem.exists(modsListPath))
		{
			var stuff:Array<String> = CoolUtil.coolTextFile(modsListPath);
			for (i in 0...stuff.length)
			{
				var splitName:Array<String> = stuff[i].trim().split('|');
				var path = haxe.io.Path.join([Paths.mods(), splitName[0]]);
				//trace('trying to push: ' + splitName[0]);
				if (sys.FileSystem.isDirectory(path) && !Paths.ignoreModFolders.exists(splitName[0]) && !directories.contains(path))
				{
                    directories.push(path + "/");
					if (FileSystem.exists(path + "/images/loading/meta.json"))
                    {
                        var newMeta:LoadingScreenState.LoadingScreenMeta = haxe.Json.parse(sys.io.File.getContent(path + "/images/loading/meta.json"));
                        metas.push(newMeta);
                    }
				}
			}
		}
	}
}

class LoadingScreenSprite extends FlxSprite
{
    public var unlocked:Bool = false;
    public var meta:LoadingScreenMeta = null;
    public var data:LoadingMeta = null;

    public function new()
    {
        super();
    }

    public function init(meta:LoadingScreenMeta, data:LoadingMeta)
    {
        this.meta = meta;
        this.data = data;

        switch (data.unlock)
        {
            case "song":
                if (Highscore.getScore(data.unlockArgs[0], 1) > 0)
                {
                    unlocked = true;
                }
            case "song-encore":
                if (Highscore.getEncoreScore(data.unlockArgs[0], 1) > 0)
                {
                    unlocked = true;
                }
            case "week":
                if (Highscore.getWeekScore(data.unlockArgs[0], 1) > 0)
                {
                    unlocked = true;
                }
            case "shop-item":
                if (ClientPrefs.newInventory.exists(data.path))
                {
                    if (ClientPrefs.newInventory.get(data.path) == 1)
                    {
                        unlocked = true;
                    }
                }
                else
                {
                    if (meta.modDirectory != null)
                    {
                        if (dlc.DlcInventory.inventory.exists(meta.modDirectory))
                        {
                            if (dlc.DlcInventory.inventory.get(meta.modDirectory).exists(data.path))
                            {
                                if (dlc.DlcInventory.inventory.get(meta.modDirectory).get(data.path) == 1)
                                {
                                    unlocked = true;
                                }
                            }
                        }
                    }
                }
            default:
                unlocked = true;
        }
    }
}