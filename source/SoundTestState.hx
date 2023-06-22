package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;
import GameJolt.GameJoltAPI;

class SoundTestState extends MusicBeatState
{
    var num1:Int = 0;
    var num2:Int = 0;

    var curCode:Int = 0;

    var canPress:Bool = true;

    var txt1:FlxText;
    var txt2:FlxText;

    override function create()
    {
        txt1 = new FlxText(0, 0, Std.string(num1), 56);
        txt1.font = Paths.font("vcr.ttf");
        txt2 = new FlxText(0, 0, Std.string(num2), 56);
        txt2.font = Paths.font("vcr.ttf");

        txt1.screenCenter();
        txt1.x -= Std.int(txt1.width * 1.5);

        txt2.screenCenter();
        txt2.x += Std.int(txt2.width * 1.5);

        add(txt1);
        add(txt2);

        changeTxt(0);

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (controls.UI_UP_P && canPress)
        {
            changeInd(-1);
        }
        if (controls.UI_DOWN_P && canPress)
        {
            changeInd(1);
        }
        if (controls.UI_LEFT_P && canPress)
        {
            changeTxt(-1);
        }
        if (controls.UI_RIGHT_P && canPress)
        {
            changeTxt(1);
        }
        if (controls.ACCEPT && canPress)
        {
            FlxG.sound.play(Paths.sound("confirmMenu"));
            if (num1 == 20 && num2 == 2)
            {
                FileOpener.openFile("assets/codes/code.png");
            }
            if (num1 == 3 && num2 == 7)
            {
                TextFile.newFile("1ST - ADD EVERY SINGLE NUMBER IN TESS' BIRTHDATE TOGETHER.\n2ND - THE DAY OF THE MONTH HE TRIED TO KILL HIMSELF.", "CLOSER");
            }
            if (num1 == 11 && num2 == 19)
            {
                CoolUtil.browserLoad("https://www.youtube.com/watch?v=WLbcpJTHbKE&lc=Ugxkyck-yxgmyl4U0sR4AaABAg");
            }
            if (num1 == 20 && num2 == 25)
            {
                MusicBeatState.switchState(new LogState());
            }
            if (num1 == 12 && num2 == 25)
            {
                canPress = false;
                playSong("Endless");
            }
            canPress = false;
            new FlxTimer().start(0.001, function(tmr:FlxTimer)
            {
                canPress = true;
            });
        }
        if (controls.BACK && canPress)
        {
            canPress = false;
            FlxG.sound.play(Paths.sound("cancelMenu"));
            MusicBeatState.switchState(new MonsterLairState());
        }
        super.update(elapsed);
    }

    function changeTxt(huh:Int)
    {
        if (huh != 0)
            FlxG.sound.play(Paths.sound("scrollMenu"));

        curCode += huh;

        if (curCode >= 2)
            curCode = 0;
        if (curCode < 0)
            curCode = 1;

        switch (curCode)
        {
            case 0:
                txt1.alpha = 1;
                txt2.alpha = 0.5;
            case 1:
                txt1.alpha = 0.5;
                txt2.alpha = 1;
        }
    }

    function changeInd(huh:Int)
    {
        if (huh != 0)
            FlxG.sound.play(Paths.sound("scrollMenu"));

        switch (curCode)
        {
            case 0:
                num1 += huh;
                if (num1 >= 51)
                    num1 = 0;
                if (num1 < 0)
                    num1 = 50;
            case 1:
                num2 += huh;
                if (num2 >= 51)
                    num2 = 0;
                if (num2 < 0)
                    num2 = 50;
        }

        txt1.text = Std.string(num1);
        txt2.text = Std.string(num2);
    }

    function fade()
    {
		FlxG.camera.fade(0xFFFFFFFF, 0.5, false);
    }

    function playSong(song:String)
    {
        var songLowercase:String = Paths.formatToSongPath(song);
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
		MusicBeatState.switchState(new HealthLossState());
    }
}