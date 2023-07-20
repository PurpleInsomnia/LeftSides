package;

#if DISCORD
import Discord.DiscordClient;
#end
import PlayStateMeta.PlayStateMetaData;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import sys.FileSystem;
import haxe.Json;
import filters.*;

using StringTools;

typedef CustomFreeplayFile = {
    var songsToAdd:Array<String>;
    var unlockedAtScoreOf:Array<String>;
    var data:Array<Dynamic>;
}

class FunnyFreeplayState extends MusicBeatState
{
    var lists:Array<Array<FreeplaySong>> = [[], []];

    var bg:FlxSprite;
    var ratingSpr:FlxSprite;
    var songName:Alphabet;
    var weekName:Alphabet;
    var scoreBox:ScoreBox;

    var curList:Int = 0;
    private static var curSelected:Int = 0;
    var canPress:Bool = true;

    var recordGrp:FlxTypedGroup<Record>;
    var recordEncoreGrp:FlxTypedGroup<Record>;
    var crGrp:FlxTypedGroup<FlxSprite>;
    var crEncoreGrp:FlxTypedGroup<FlxSprite>;
    var iconGrp:FlxTypedGroup<HealthIcon>;
    var iconEncoreGrp:FlxTypedGroup<HealthIcon>;

    var camFollow:FlxSprite;

    var ca:ChromaticAberation;

    public var wardrobeSprite:FlxSprite;
    public var canWardrobe:Bool = false;

    override function create()
    {
        #if desktop
        DiscordClient.changePresence("In The Freeplay Menu", null);
        #end
    	Paths.destroyLoadedImages();

        WeekData.loadTheFirstEnabledMod();

        var check:Bool = StateManager.check("freeplay");
        var blackOverlay:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		blackOverlay.scrollFactor.set();

        canPress = true;

        // make regular list
        WeekData.reloadWeekFiles(false);

        camFollow = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
        camFollow.screenCenter();
        add(camFollow);

        FlxG.camera.follow(camFollow, null, 1);

		for (i in 0...WeekData.weeksList.length) 
        {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
            var skip = weekIsLocked(i);
            if (ClientPrefs.devMode)
            {  
                skip = false;
            }
			for (j in 0...leWeek.songs.length) {
				if (!weekIsLocked(i))
				{
					leSongs.push(leWeek.songs[j][0]);
					leChars.push(leWeek.songs[j][1]);
				}
			}

			// WeekData is a bitch ass mother fucker

			WeekData.setDirectoryFromWeek(leWeek);
			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs) {
                if (!skip)
                {
				    var colors:Array<Int> = song[2];
				    if(colors == null || colors.length < 3) {
					    colors = [146, 113, 253];
				    }
                    var rs:String = "";
                    if (song[3] != null)
                    {
                        rs = song[3];
                    }
				    addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), leWeek.weekName, false, rs);
                }
			}
		}

        var allowVanilla:Bool = false;
        if (WeekData.weeksList[0] == "tutorial")
        {
            allowVanilla = true;
            if (Highscore.getScore("Milf", 1) != 0 || ClientPrefs.devMode)
            {
                addSong("Comfy Together", 69, "gf", FlxColor.fromRGB(115, 0, 165), "Pre-Week 4", false);
            }
            if (Highscore.getScore("Test", 1) != 0 || ClientPrefs.inventory[2][1] > 0 || ClientPrefs.devMode)
            {
                addSong("Test", 69, "bf-digital", FlxColor.fromRGB(255, 175, 0), "TEST", false);
            }

            // EXE :skull:
            if ((Highscore.getScore("Endless", 1) != 0 || ClientPrefs.inventory[2][1] > 0) || ClientPrefs.devMode)
            {
                addSong("Endless", 69, "jabbin", FlxColor.fromRGB(222, 126, 24), "EXE", false);
            }
            if ((Highscore.getScore("Doppelganger", 1) != 0 || ClientPrefs.inventory[2][1] > 0) || ClientPrefs.devMode)
            {
                addSong("Too Fest", 69, "nuckle", FlxColor.fromRGB(222, 126, 24), "EXE", false);
            }
        }

        WeekData.loadTheFirstEnabledMod();
        if (FileSystem.exists(Paths.getModFile("data/freeplay.json")))
        {
            var daFile:CustomFreeplayFile = Json.parse(Paths.getTextFromFile("data/freeplay.json"));
            for (i in 0...daFile.songsToAdd.length)
            {
                if (Highscore.getScore(daFile.unlockedAtScoreOf[i], 1) != 0)
                {
                    addSong(daFile.songsToAdd[i], daFile.data[i][0], daFile.data[i][1], Std.int(daFile.data[i][2]), daFile.data[i][3], daFile.data[i][4]);
                }
            }
        }

        // load encore shit.
        WeekData.reloadEncoreWeekFiles(false);

        for (i in 0...WeekData.weeksList.length) {
			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];
            var skip:Bool = weekIsLocked(i, true);
            if (ClientPrefs.devMode)
            {  
                skip = false;
            }
			for (j in 0...leWeek.songs.length) {
				if (!weekIsLocked(i, true))
				{
					leSongs.push(leWeek.songs[j][0]);
					leChars.push(leWeek.songs[j][1]);
				}
			}

			// WeekData is a bitch ass mother fucker

			WeekData.setDirectoryFromWeek(leWeek);
			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs) {
                if (!skip)
                {
				    var colors:Array<Int> = song[2];
				    if(colors == null || colors.length < 3) {
					    colors = [146, 113, 253];
				    }
                    var rs:String = "";
                    if (song[3] != null)
                    {
                        rs = song[3];
                    }
				    addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]), leWeek.weekName, true, rs);
                }
			}
		}

        if (!FlxG.sound.music.playing && !check)
		{
			FlxG.sound.playMusic(Paths.music('freeplay'));
		}

        var bd:Backdrop = new Backdrop("freeplay/grid", 0, 0, "HORIZONTAL", -1, 1);
        add(bd);

        bg = new FlxSprite().loadGraphic(Paths.image("freeplay/bg"));
        bg.scrollFactor.set(0, 0);
        bg.blend = BlendMode.MULTIPLY;
        add(bg);

        crGrp = new FlxTypedGroup<FlxSprite>();
        add(crGrp);

        recordGrp = new FlxTypedGroup<Record>();
        add(recordGrp);

        crEncoreGrp = new FlxTypedGroup<FlxSprite>();
        add(crEncoreGrp);

        recordEncoreGrp = new FlxTypedGroup<Record>();
        add(recordEncoreGrp);

        iconGrp = new FlxTypedGroup<HealthIcon>();
        add(iconGrp);

        iconEncoreGrp = new FlxTypedGroup<HealthIcon>();
        add(iconEncoreGrp);

        for (i in 0...lists[0].length)
        {

            var record:Record = new Record(lists[0][i].recordSuff);
            record.screenCenter();
            record.y = Std.int(FlxG.height - (record.height + 35));
            record.x += Std.int(500 * i);

            var centerRecord:FlxSprite = new FlxSprite(record.x, record.y).loadGraphic(Paths.image("freeplay/centerRecord"));
            crGrp.add(centerRecord);

            recordGrp.add(record);

            if (record.hideCenter)
            {
                centerRecord.loadGraphic(Paths.image("freeplay/centerNull"));
            }

            var icon:HealthIcon = new HealthIcon(lists[0][i].icon);
            icon.screenCenter();
            icon.y = (record.y + 150);
            icon.x += Std.int(500 * i);
            icon.scrollFactor.set(1, 1);
            iconGrp.add(icon);
            if (lists[0][i].weekName == "Send Off" && allowVanilla)
            {
                lists[0][i].color = CoolUtil.dominantColor(icon);
            }
            centerRecord.color = lists[0][i].color;
        }
        for (i in 0...lists[1].length)
        {
            var record:Record = new Record(lists[1][i].recordSuff);
            record.reload(true);
            record.screenCenter();
            record.y = Std.int(FlxG.height - (record.height + 35));
            record.x += Std.int(500 * i);

            var centerRecord:FlxSprite = new FlxSprite(record.x, record.y).loadGraphic(Paths.image("freeplay/centerRecord"));
            centerRecord.color = lists[1][i].color;
            crEncoreGrp.add(centerRecord);

            recordEncoreGrp.add(record);

            var icon:HealthIcon = new HealthIcon(lists[1][i].icon);
            icon.screenCenter();
            icon.y = (record.y + 150);
            icon.x += Std.int(500 * i);
            icon.scrollFactor.set(1, 1);
            iconEncoreGrp.add(icon);
        }

        if (PlayState.encoreMode)
        {
            for (i in 0...recordGrp.length)
            {
                recordGrp.members[i].visible = false;
                crGrp.members[i].visible = false;
            }
            for (i in 0...iconGrp.length)
            {
                iconGrp.members[i].visible = false;
            }
            curList = 1;
        }
        else
        {
            for (i in 0...recordEncoreGrp.length)
            {
                recordEncoreGrp.members[i].visible = false;
                crEncoreGrp.members[i].visible = false;
            }
            for (i in 0...iconEncoreGrp.length)
            {
                iconEncoreGrp.members[i].visible = false;
            }
            curList = 0;
        }

        songName = new Alphabet(0, 0, lists[curList][0].name, true, false);
        songName.screenCenter(X);
        songName.scrollFactor.set(0, 0);
        songName.forceX = songName.x;
        songName.y = Std.int(recordGrp.members[0].y - songName.height);
        add(songName);

        weekName = new Alphabet(0, 0, lists[curList][0].weekName, true, false, 0.05, 0.75);
        weekName.screenCenter(X);
        weekName.scrollFactor.set(0, 0);
        weekName.forceX = weekName.x;
        weekName.y = Std.int(songName.y - weekName.height);
        add(weekName);

        scoreBox = new ScoreBox();
        add(scoreBox);

        ratingSpr = new FlxSprite().loadGraphic(Paths.image("freeplay/ranks/bruh"));
        ratingSpr.scrollFactor.set(0, 0);
        ratingSpr.x = FlxG.width - 75;
        add(ratingSpr);

        wardrobeSprite = new FlxSprite().loadGraphic(Paths.image("freeplay/wardrobe"));
        wardrobeSprite.scrollFactor.set(0, 0);
        add(wardrobeSprite);

        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
        textBG.scrollFactor.set(0, 0);
		add(textBG);
		var leText:String = "Press RESET to Reset your Score and Accuracy. Press E to switch between regular and encore songs.";
        if (lists[1][0] == null)
        {
            leText = "Press RESET to Reset your Score and Accuracy.";
        }
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("eras.ttf"), 18, FlxColor.WHITE, CENTER);
		text.scrollFactor.set();
        text.screenCenter(X);
        textBG.setGraphicSize(FlxG.width, Std.int(text.height));
		add(text);

        if (ClientPrefs.shaders)
        {
            ca = new ChromaticAberation();
            ca.shader.intensity.value = [0.0];
            var filters:Array<BitmapFilter> = [new ShaderFilter(ca.shader)];
            FlxG.camera.setFilters(filters);
        }

        changeSelection(0);

        if (check)
		{
			add(blackOverlay);
            FlxG.sound.music.stop();
		}

        super.create();
    }

    override function closeSubState() {
		changeSelection();
		super.closeSubState();
	}

    override function update(elapsed:Float)
    {
        if (!ClientPrefs.lowQuality)
        {
            for (i in 0...recordGrp.length)
            {
                recordGrp.members[i].angle += 30 * elapsed;
                crGrp.members[i].angle += 30 * elapsed;
            }
            for (i in 0...recordEncoreGrp.length)
            {
                recordEncoreGrp.members[i].angle += 30 * elapsed;
                crEncoreGrp.members[i].angle += 30 * elapsed;
            }
        }
        if (FlxG.keys.justPressed.CONTROL && canWardrobe && canPress)
        {
            canPress = false;
            FlxG.sound.play(Paths.sound("confirmMenu"));
            MusicBeatState.switchState(new WardrobeState(false));
        }
        if (FlxG.keys.justPressed.E && canPress && lists[1][0] != null)
        {
            if (curList != 1)
            {
                curList = 1;
                PlayState.encoreMode = true;
                for (i in 0...recordGrp.length)
                {
                    recordGrp.members[i].visible = false;
                    crGrp.members[i].visible = false;
                }
                for (i in 0...iconGrp.length)
                {
                    iconGrp.members[i].visible = false;
                }
                for (i in 0...recordEncoreGrp.length)
                {
                    recordEncoreGrp.members[i].visible = true;
                    crEncoreGrp.members[i].visible = true;
                }
                for (i in 0...iconEncoreGrp.length)
                {
                    iconEncoreGrp.members[i].visible = true;
                }
            }
            else
            {
                curList = 0;
                PlayState.encoreMode = false;
                for (i in 0...recordGrp.length)
                {
                    recordGrp.members[i].visible = true;
                    crGrp.members[i].visible = true;
                }
                for (i in 0...iconGrp.length)
                {
                    iconGrp.members[i].visible = true;
                }
                for (i in 0...recordEncoreGrp.length)
                {
                    recordEncoreGrp.members[i].visible = false;
                    crEncoreGrp.members[i].visible = false;
                }
                for (i in 0...iconEncoreGrp.length)
                {
                    iconEncoreGrp.members[i].visible = false;
                }
            }
            FlxG.sound.play(Paths.sound("scrollMenu"));
            changeSelection(0);
        }

        if (controls.UI_LEFT_P && canPress)
        {
            changeSelection(-1);
        }
        if (controls.UI_RIGHT_P && canPress)
        {
            changeSelection(1);
        }

        if (controls.ACCEPT && canPress)
        {
            canPress = false;
            if (curList != 1)
            {
                FlxG.sound.play(Paths.sound('confirmStoryMenu'));

			    PlayState.funnyBarColour = lists[0][curSelected].color;

			    var songLowercase:String = Paths.formatToSongPath(lists[0][curSelected].name);
			    var poop:String = Paths.formatToSongPath(lists[0][curSelected].name);
			    #if MODS_ALLOWED
			    if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			    #else
			    if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			    #end
				    poop = songLowercase;
			    }
			    trace(poop);

			    PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			    PlayState.isStoryMode = false;
			    PlayState.isVoid = false;
			    PlayState.storyDifficulty = 1;

			    PlayState.storyWeek = lists[0][curSelected].week;
				MusicBeatState.switchState(new HealthLossState());
            }
            else
            {
                FlxG.sound.play(Paths.sound('confirmStoryMenu'));

			    PlayState.funnyBarColour = lists[1][curSelected].color;

			    var songLowercase:String = Paths.formatToSongPath(lists[1][curSelected].name);
			    var poop:String = Highscore.formatSong(songLowercase + "-encore", 1);
			    #if MODS_ALLOWED
			    if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			    #else
			    if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			    #end
				    poop = songLowercase;
			    }
			    trace(poop);

			    PlayState.SONG = Song.loadFromJson(poop, songLowercase);
			    PlayState.isStoryMode = false;
			    PlayState.isVoid = false;
			    PlayState.storyDifficulty = 1;

			    PlayState.storyWeek = lists[1][curSelected].week;
			    if (FlxG.keys.pressed.SHIFT)
			    {
				    LoadingState.loadAndSwitchState(new editors.ChartingState(true));
			    }
			    else
			    {
				    MusicBeatState.switchState(new HealthLossState());
			    }
            }
        }

        if (controls.BACK && canPress)
        {
            canPress = false;
            FlxG.sound.play(Paths.sound("cancelMenu"));
            PlayState.encoreMode = false;
            MusicBeatState.switchState(new MainMenuState());
            FlxG.sound.music.stop();
        }

        if (controls.RESET && canPress)
        {
            if (curList == 0)
			    openSubState(new ResetScoreSubState(lists[curList][curSelected].name, 1, lists[curList][curSelected].icon));
            else
                openSubState(new ResetEncoreScoreSubState(lists[curList][curSelected].name, 1, lists[curList][curSelected].icon));
			
            FlxG.sound.play(Paths.sound('scrollMenu'));
        }

        super.update(elapsed);
    }

    var camTween:FlxTween = null;
    var colorTween:FlxTween = null;
    public function changeSelection(?bruh:Int = 0)
    {
        if (camTween != null)
            camTween.cancel();
        if (colorTween != null)
            colorTween.cancel();

        curSelected += bruh;
        if (bruh != 0)
            FlxG.sound.play(Paths.sound("scrollMenu"));

        if (curSelected >= lists[curList].length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = lists[curList].length - 1;

        Paths.currentModDirectory = lists[curList][curSelected].folder;

        scoreBox.changeText(lists[curList][curSelected].name, getComposer(lists[curList][curSelected].name));
        scoreBox.scoreTxt.screenCenter(X);
        songName.changeText("< " + lists[curList][curSelected].name + " >", -1);
        songName.screenCenter(X);
        songName.forceX = songName.x;

        weekName.changeText(lists[curList][curSelected].weekName, -1);
        weekName.screenCenter(X);
        weekName.forceX = weekName.x;

        switch(curList)
        {
            case 0:
                for (i in 0...recordGrp.length)
                {
                    recordGrp.members[i].alpha = 0.5;
                    crGrp.members[i].alpha = 0;
                }
                for (i in 0...iconGrp.length)
                {
                    iconGrp.members[i].alpha = 0.5;
                }
                recordGrp.members[curSelected].alpha = 1;
                if (ClientPrefs.shaders)
                {
                    if (recordGrp.members[curSelected].chromAb)
                    {
                        ca.shader.intensity.value = [ca.max];
                    }
                    else
                    {
                        ca.shader.intensity.value = [0];
                    }
                }
                crGrp.members[curSelected].alpha = 1;
                iconGrp.members[curSelected].alpha = 1;
                camTween = FlxTween.tween(camFollow, {x: recordGrp.members[curSelected].getGraphicMidpoint().x}, 0.25, {ease: FlxEase.sineInOut});
                if (lists[0][curSelected].meta.wardrobeEnabled)
                {
                    canWardrobe = true;
                    wardrobeSprite.visible = true;
                }
                else
                {
                    canWardrobe = false;
                    wardrobeSprite.visible = false;
                }
            case 1:
                for (i in 0...recordEncoreGrp.length)
                {
                    recordEncoreGrp.members[i].alpha = 0.25;
                    crEncoreGrp.members[i].alpha = 0;
                }
                for (i in 0...iconEncoreGrp.length)
                {
                    iconEncoreGrp.members[i].alpha = 0.25;
                }
                recordEncoreGrp.members[curSelected].alpha = 1;
                if (ClientPrefs.shaders)
                {
                    if (recordEncoreGrp.members[curSelected].chromAb)
                    {
                        ca.shader.intensity.value = [ca.max];
                    }
                    else
                    {
                        ca.shader.intensity.value = [0];
                    }
                }
                crEncoreGrp.members[curSelected].alpha = 1;
                iconEncoreGrp.members[curSelected].alpha = 1;
                camTween = FlxTween.tween(camFollow, {x: recordGrp.members[curSelected].getGraphicMidpoint().x}, 0.25, {ease: FlxEase.sineInOut});
                if (lists[1][curSelected].meta.wardrobeEnabled)
                {
                    canWardrobe = true;
                    wardrobeSprite.visible = true;
                }
                else
                {
                    canWardrobe = false;
                    wardrobeSprite.visible = false;
                }
        }

        colorTween = FlxTween.color(bg, 0.5, bg.color, lists[curList][curSelected].color);

        changeRankSpr();
    }

    function changeRankSpr()
    {
        var funny:Int = 0;
        var toLoad:String = "bruh";
        if (!PlayState.encoreMode)
        {
            funny = Highscore.getSongRank(lists[curList][curSelected].name, 1);
        }
        else
        {
            funny = Highscore.getEncoreSongRank(lists[curList][curSelected].name, 1);
        }
        switch (funny)
        {
            case 10:
                toLoad = "s";
            case 8:
                toLoad = "a";
            case 6:
                toLoad = "b";
            case 4:
                toLoad = "c";
            case 2:
                toLoad = "d";
            case 1:
                toLoad = "f";
        }

        ratingSpr.loadGraphic(Paths.image("freeplay/ranks/" + toLoad));
        ratingSpr.x = FlxG.width - 75;
    }

    function getComposer(name:String):String
    {
		var artist:Array<String> = [];
		if (FileSystem.exists(Paths.txt(Paths.formatToSongPath(name) + '/composer')) || FileSystem.exists('mods/' + Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(name) + '/composer.txt'))
		{
			if (FileSystem.exists(Paths.txt(Paths.formatToSongPath(name) + '/composer')))
				artist = CoolUtil.coolTextFile(Paths.txt(Paths.formatToSongPath(name) + '/composer'));
			else
				artist = CoolUtil.coolTextFile('mods/' + Paths.currentModDirectory + '/data/' + Paths.formatToSongPath(name) + '/composer.txt');
		}
		else
		{
			artist = ['Unknown'];
		}
        return artist[0];
    }

    public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, weekName:String, ?encore:Bool = false, ?rs:String = "")
	{
        var metaFile:PlayStateMetaData = PlayStateMeta.loadFile(songName);
        if (!encore)
        {
		    lists[0].push(new FreeplaySong(songName, weekNum, songCharacter, color, weekName, rs, metaFile));
        }
        else
        {
            lists[1].push(new FreeplaySong(songName, weekNum, songCharacter, color, weekName, rs, metaFile));
        }
	}

	function weekIsLocked(weekNum:Int, ?encoreMode:Bool = false) 
    {
		var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[weekNum]);
        var leBool:Bool = true;
		if (leWeek.weekName.endsWith(" Encore") && encoreMode)
		{
			leBool = !StoryMenuState.weekCompleted.exists(WeekData.weeksList[weekNum].replace("Encore", ""));
		}
		else
		{
            if (!encoreMode)
            {
                leBool = (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
            }
            else
            {
			    leBool = (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryEncoreState.weekEncoreCompleted.exists(leWeek.weekBefore) || !StoryEncoreState.weekEncoreCompleted.get(leWeek.weekBefore)));
            }
		}
		return leBool;
	}
}

class FreeplaySong
{
	public var name:String = "";
	public var week:Int = 0;
	public var icon:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
    public var weekName:String = "";
    // record modifier bullshit.
    public var recordSuff:String = "";
    public var meta:PlayStateMetaData = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int, weekName:String, ?rs:String = "", metaFile:PlayStateMetaData)
	{
		this.name = song;
		this.week = week;
		this.icon = songCharacter;
		this.color = color;
        this.weekName = weekName;
		this.folder = Paths.currentModDirectory;
        this.meta = metaFile;
        recordSuff = rs;
		if(this.folder == null) this.folder = '';
	}
}

class Record extends FlxSprite
{
    public var suff:String = "";
    public var hideCenter:Bool = false;
    public var chromAb:Bool = false;
    public function new(?suff:String = "")
    {
        super();
        this.suff = suff;
        var thing:String = this.suff;
        var splitThing:Array<String> = [];
        if (thing.contains(":"))
        {
            splitThing = thing.split(":");

            this.suff = splitThing[0];

            for (i in 1...splitThing.length)
            {
                switch (Paths.formatToSongPath(splitThing[i]))
                {
                    case "hide-record":
                        hideCenter = true;
                    case "chromatic-aberation":
                        chromAb = true;
                }
            }
        }
        loadGraphic(Paths.image("freeplay/record" + this.suff));
    }

    public function reload(?encore:Bool = false)
    {
        if (!encore)
        {
            loadGraphic(Paths.image("freeplay/record" + suff));
        }
        else
        {
            loadGraphic(Paths.image("freeplay/recordEncore" + suff));
        }
    }
}

class ScoreBox extends FlxTypedGroup<Dynamic>
{
    public var scoreTxt:FlxText;

    public function new(?score:Int = 0, ?composer:String = "unknown")
    {
        super();
        var box:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 75, 0xFF000000);
        box.alpha = 0.6;
        box.scrollFactor.set(0, 0);
        add(box);
        var acc:Float = Math.floor(1 * 100);

        scoreTxt = new FlxText(0, 15, FlxG.width, "BEST SCORE: " + score + "\nCOMPOSED BY: " + composer + "\nACCURACY: " + acc + "%\n", 16);
        scoreTxt.font = Paths.font("eras.ttf");
        scoreTxt.alignment = CENTER;
        scoreTxt.updateHitbox();
        scoreTxt.screenCenter(X);
        scoreTxt.scrollFactor.set(0, 0);
        add(scoreTxt);
    }

    public function changeText(score:String, composer:String)
    {
        var hmm:Int = 0;
        if (!PlayState.encoreMode)
            hmm = Highscore.getScore(score, 1);
        else
            hmm = Highscore.getEncoreScore(score, 1);

        var r:Float;
        if (!PlayState.encoreMode)
            r = Highscore.getRating(score, 1);
        else
            r = Highscore.getEncoreRating(score, 1);
        var acc:Float = Math.floor(r * 100);
        
        scoreTxt.text = "BEST SCORE: " + hmm + "\nCOMPOSED BY: " + composer + "\nACCURACY: " + acc + "\n";
        scoreTxt.updateHitbox();
        scoreTxt.screenCenter(X);
    }
} 