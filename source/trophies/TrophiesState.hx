package trophies;

#if DISCORD
import Discord.DiscordClient;
#end
import trophies.TrophyUtil.TrophiesData;
import dlc.DlcTrophies;
import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;
import sys.FileSystem;

class TrophySelectState extends MusicBeatState
{
    public static var lastModDirectory:String = "";

    public var toSelect:Array<String> = [""];
    var bg:FlxSprite;

    var funny:FlxTypedGroup<FlxSprite>;
    var txt:FlxTypedGroup<FlxText>;

    var camFollow:FlxSprite;

    public var curSelected:Int = 0;

    public function new(reload:Bool)
    {
        super();
        if (reload)
        {
            lastModDirectory = Paths.currentModDirectory;
        }
    }

    override function create()
    {
        #if desktop
        DiscordClient.changePresence("Browsing Trophy Lists", null);
        #end
        Paths.currentModDirectory = "";

        var folders:Array<String> = Paths.getModDirectories();
        for (folder in folders)
        {
            if (FileSystem.exists("mods/" + folder + "/trophies/data.json"))
            {
                if (lastModDirectory == folder)
                {
                    toSelect.insert(0, folder);
                }
                else
                {
                    toSelect.push(folder);
                }
            }
        }

        camFollow = new FlxSprite().makeGraphic(2, 2, 0xFFFFFFFF);
        camFollow.screenCenter();
        add(camFollow);
        FlxG.camera.follow(camFollow, null, 1);

        add(new GridBackdrop());

        bg = new FlxSprite().loadGraphic(Paths.image("backdropSHADER"));
        bg.blend = BlendMode.DARKEN;
        bg.scrollFactor.set(0, 0);
        add(bg);

        var blackThing:FlxSprite = new FlxSprite().makeGraphic(540, 720, 0xFF000000);
        blackThing.scrollFactor.set(0, 0);
        add(blackThing);

        funny = new FlxTypedGroup<FlxSprite>();
        add(funny);
        txt = new FlxTypedGroup<FlxText>();
        add(txt);

        for (i in 0...toSelect.length)
        {
            Paths.currentModDirectory = toSelect[i];
            var daIcon:FlxSprite = new FlxSprite().loadGraphic(Paths.image("achievements/cover"));
            daIcon.screenCenter();
            daIcon.x = 10;
            daIcon.y += Std.int(150 * i);
            daIcon.ID = i;
            funny.add(daIcon);

            var sectionName:String = "";
            if (toSelect[i] == "")
            {
                sectionName = TrophyUtil.trophiesData.sectionName;
            }
            else
            {
                var daData:TrophiesData = DlcTrophies.getTrophyFromDirectory(toSelect[i]);
                sectionName = daData.sectionName;
            }

            var daText:FlxText = new FlxText(160, daIcon.y, 440, sectionName, 24);
            daText.font = Paths.font("eras.ttf");
            daText.updateHitbox();
            daText.ID = i;
            daText.y = daIcon.y + (75 - Std.int(daText.height / 2));
            txt.add(daText);
        }

        camFollow.y = funny.members[funny.length - 1].getGraphicMidpoint().y;

        change(0);

        super.create();
    }

    public var canPress:Bool = true;
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
                canPress = false;
                FlxG.sound.play(Paths.sound("confirmMenu"));
                var dlc:Bool = false;
                var data:TrophiesData = TrophyUtil.trophiesData;
                if (toSelect[curSelected] != "")
                {
                    dlc = true;
                    data = DlcTrophies.getTrophyFromDirectory(toSelect[curSelected]);
                }
                #if desktop
                DiscordClient.changePresence("Checking Trophies For: (" + toSelect[curSelected] + ")", null);
                #end
                MusicBeatState.switchState(new TrophiesState(dlc, data));
            }
            if (controls.BACK)
            {
                canPress = false;
                FlxG.sound.play(Paths.sound("cancelMenu"));
                Paths.currentModDirectory = lastModDirectory;
                MusicBeatState.switchState(new MainMenuState());
            }
        }
        super.update(elapsed);
    }

    var camTween:FlxTween = null;
    function change(huh:Int)
    {
        if ((curSelected + huh) < 0 || (curSelected + huh) >= toSelect.length)
        {
            // do nothing
        }
        else
        {
            curSelected += huh;
        }

        Paths.currentModDirectory = toSelect[curSelected];

        funny.forEach(function(spr:FlxSprite)
        {
            if (spr.ID != curSelected)
            {
                spr.alpha = 0.5;
            }
            else
            {
                spr.alpha = 1;
            }
        });
        txt.forEach(function(spr:FlxText)
        {
            if (spr.ID != curSelected)
            {
                spr.alpha = 0.5;
            }
            else
            {
                spr.alpha = 1;
            }
        });

        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

        if (camTween != null)
        {
            camTween.cancel();
        }
        var daY:Float = funny.members[curSelected].y + 75;
        camTween = FlxTween.tween(camFollow, {y: daY}, 1, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
        {
            camTween = null;
        }});

        bg.loadGraphic(Paths.image("backdropSHADER"));
    }
}

class TrophiesState extends MusicBeatState
{
    public var dlc:Bool = false;

    public var curSelected:Int = 0;
    public var camFollow:FlxSprite;

    var grp:FlxTypedGroup<FlxSprite>;
    var locks:Array<Bool> = [];

    var white:FlxSprite;
    var daBigIcon:FlxSprite;
    var titleText:FlxText;
    var descText:FlxText;

    var data:TrophiesData;

    var goofyNumber:Float = 0;

    public function new(dlc:Bool, data:TrophiesData)
    {
        super();
        this.dlc = dlc;
        this.data = data;
    }

    override function create()
    {
        camFollow = new FlxSprite().makeGraphic(2, 2, 0xFFFFFFFF);
        camFollow.screenCenter();
        add(camFollow);
        FlxG.camera.follow(camFollow, null, 1);

        add(new GridBackdrop());

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("backdropSHADER"));
        bg.blend = BlendMode.DARKEN;
        bg.scrollFactor.set(0, 0);
        add(bg);

        grp = new FlxTypedGroup<FlxSprite>();
        add(grp);

        for (i in 0...data.trophies.length)
        {
            var icon:FlxSprite = new FlxSprite().loadGraphic(Paths.image("achievements/" + data.trophies[i].icon));
            var locked:Bool = false;
            if (dlc)
            {
                if (!DlcTrophies.trophies.exists(Paths.currentModDirectory + data.trophies[i].name))
                {
                    locked = true;
                }
            }
            else
            {
                if (!TrophyUtil.trophies.exists(data.trophies[i].name))
                {
                    locked = true;
                }
            }
            locks.push(locked);
            if (locked)
            {
                icon.loadGraphic(Paths.image("achievements/locked"));
            }
            icon.setGraphicSize(150, 150);
            icon.updateHitbox();
            icon.x = 175;
			icon.screenCenter(Y);
			icon.y += (160 * i);
			icon.ID = i;
            grp.add(icon);
        }
        trace("what?");

        var bbb:FlxSprite = new FlxSprite(750, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		bbb.alpha = 0.62;
		bbb.scrollFactor.set(0, 0);
		add(bbb);

		white = new FlxSprite(750, 0).makeGraphic(FlxG.width, 3, 0xFFFFFFFF);
		white.scrollFactor.set(0, 0);
		add(white);

		daBigIcon = new FlxSprite(0, 150).loadGraphic(Paths.image("achievements/" + data.trophies[0].icon));
		daBigIcon.setGraphicSize(300, 300);
        daBigIcon.updateHitbox();
		daBigIcon.x = 750 + 175;
		daBigIcon.scrollFactor.set(0, 0);
		add(daBigIcon);

		titleText = new FlxText(775, daBigIcon.y, FlxG.width - 775, data.trophies[0].name, 42);
		titleText.font = Paths.font("eras.ttf");
        titleText.updateHitbox();
		titleText.scrollFactor.set(0, 0);
		titleText.y += daBigIcon.height;
		add(titleText);

		white.y = (titleText.y + titleText.height) + 5;

		descText = new FlxText(800, white.y + 50, FlxG.width - 800, data.trophies[0].desc, 24);
		descText.font = Paths.font("eras.ttf");
		descText.scrollFactor.set(0, 0);
		add(descText);

        change(0);

        super.create();
    }

    var canPress:Bool = true;
    override function update(elapsed:Float)
    {
        var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollow.setPosition(FlxMath.lerp(camFollow.x, camFollow.x, lerpVal), FlxMath.lerp(camFollow.y, goofyNumber, lerpVal));
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
            if (controls.BACK)
            {
                canPress = false;
                FlxG.sound.play(Paths.sound("cancelMenu"));
                MusicBeatState.switchState(new TrophySelectState(false));
            }
        }
        super.update(elapsed);
    }

    public function change(huh:Int)
    {
        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

        curSelected += huh;

        if (curSelected >= data.trophies.length)
        {
            curSelected = 0;
        }
        if (curSelected < 0)
        {
            curSelected = data.trophies.length - 1;
        }

        grp.forEach(function(spr:FlxSprite)
        {
            spr.alpha = 0.5;
            if (spr.ID == curSelected)
            {
                spr.alpha = 1;
                goofyNumber = spr.getGraphicMidpoint().y;
            }
        });

        if (!locks[curSelected])
        {
            daBigIcon.loadGraphic(Paths.image("achievements/" + data.trophies[curSelected].icon));
        }
        else
        {
            daBigIcon.loadGraphic(Paths.image("achievements/locked"));
        }
		daBigIcon.setGraphicSize(300, 300);
        daBigIcon.updateHitbox();
        daBigIcon.y = 75;
		daBigIcon.x = 750 + 115;

        if (!locks[curSelected])
        {
            titleText.text = data.trophies[curSelected].name;
        }
        else
        {
            titleText.text = "???";
        }
        titleText.updateHitbox();
        titleText.y = daBigIcon.y;
        titleText.y += daBigIcon.height;

        white.y = (titleText.y + titleText.height) + 5;

        descText.text = data.trophies[curSelected].desc;
        descText.y = white.y + 50;
    }
}