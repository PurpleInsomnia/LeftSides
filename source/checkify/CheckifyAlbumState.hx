package checkify;

import flash.media.Sound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

class CheckifyAlbumState extends MusicBeatSubstate
{
    public var data:Array<Dynamic> = [];
    public var txtGrp:FlxTypedGroup<FlxText>;

    public var curSelected:Int = 0;
    public var lastSel:Int = 0;
    public var lastList:Array<Array<Dynamic>> = [];
    public var canPress:Bool = false;
    public var camFollow:FlxSprite;
    public function new(data:Array<Dynamic>, selected:Int, lastThing:Array<Array<Dynamic>>)
    {
        super();

        this.data = data;
        lastSel = selected;
        lastList = lastThing;
        doCreate();
    }

    function doCreate()
    {
        camFollow = new FlxSprite(0, 20).makeGraphic(2, 2, 0xFF000000);
        camFollow.screenCenter(X);
        add(camFollow);
        FlxG.camera.follow(camFollow, null, 1);

        var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFF000000);
        bg.scrollFactor.set(0, 0);
        add(bg);

        txtGrp = new FlxTypedGroup<FlxText>();
        add(txtGrp);
        for (i in 0...data.length)
        {
            var txt:FlxText = new FlxText(20, 20, 1280 - 20, data[i][2] + " ~ " + data[i][3], 20);
            txt.font = Paths.font("eras.ttf");
            txt.updateHitbox();
            txt.x = 20;
            txt.y = 20 + Std.int(txt.height * i) + 5;
            txt.ID = i;
            txtGrp.add(txt);
        }

        change();

        new FlxTimer().start(0.01, function(tmr:FlxTimer)
        {
            canPress = true;
        });

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (canPress)
        {
            if (controls.UI_UP_P)
            {
                change(-1);
            }
            if (controls.UI_DOWN_P)
            {
                change(1);
            }
            if (controls.ACCEPT)
            {
                loadSong(data[curSelected]);
            }
            if (controls.BACK)
            {
                canPress = false;
                close();
            }
        }
        super.update(elapsed);
    }

    public function change(?huh:Int = 0)
    {
        curSelected += huh;

        if (curSelected >= data.length)
        {
            curSelected = 0;
        }
        if (curSelected < 0)
        {
            curSelected = data.length - 1;
        }

        txtGrp.forEach(function(txt:FlxText)
        {
            if (txt.ID == curSelected)
            {
                txt.color = 0xFFFF002F;
                camFollow.y = txt.y + Std.int(txt.height / 2);
            }
            else
            {
                txt.color = 0xFFFFFFFF;
            }
        });
    }

    var instSound:Sound = null;
    var vocalSound:Sound = null;
    public function loadSong(toGet:Array<Dynamic>)
    {
        #if DISCORD
        Discord.DiscordClient.changePresence("Listening To Checkify: " + toGet[2] + " ~ " + toGet[3], null);
        #end
        FlxG.sound.music.stop();
        if (CheckifyState.vocals != null)
        {
            CheckifyState.vocals.stop();
            CheckifyState.vocals = null;
        }
        instSound = Sound.fromFile(toGet[0]);
        FlxG.sound.playMusic(instSound, 0, CheckifyData.data.loop);
        if (toGet[1] != null)
        {
            vocalSound = (Sound.fromFile(toGet[1]));
            CheckifyState.vocals = FlxG.sound.load(vocalSound, 0, CheckifyData.data.loop);
            CheckifyState.vocals.play();

            CheckifyState.vocals.pause();
            FlxG.sound.music.play();

            Conductor.songPosition = FlxG.sound.music.time;
            CheckifyState.vocals.time = Conductor.songPosition;
            CheckifyState.vocals.play();
        }
        loadSong2(toGet);
    }

    public function loadSong2(toGet:Array<Dynamic>)
    {
        FlxG.sound.music.stop();
        if (CheckifyState.vocals != null)
        {
            CheckifyState.vocals.stop();
            CheckifyState.vocals = null;
        }
        FlxG.sound.playMusic(instSound, 1, CheckifyData.data.loop);
        if (toGet[1] != null)
        {
            CheckifyState.vocals = FlxG.sound.load(vocalSound, 1, CheckifyData.data.loop);
            CheckifyState.vocals.play();

            CheckifyState.vocals.pause();
            FlxG.sound.music.play();

            Conductor.songPosition = FlxG.sound.music.time;
            CheckifyState.vocals.time = Conductor.songPosition;
            CheckifyState.vocals.play();
        }
    }
}