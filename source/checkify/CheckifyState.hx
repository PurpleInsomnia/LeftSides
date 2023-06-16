package checkify;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import checkify.CheckifyPaths as CPaths;

class CheckifyState extends MusicBeatState
{
    public var songLists:Array<Array<Dynamic>> = [];

    public static var vocals:FlxSound = null;

    public var canPress:Bool = true;
    public var curSelected:Int = 0;
    public var camFollow:FlxSprite;
    public var camFollowPos:FlxSprite;
    public var overlay:CheckifyOverlay;

    public function new(lists:Array<Array<Dynamic>>, ?lastSelected:Int = 0)
    {
        this.songLists = lists;
        curSelected = lastSelected;
        super();
    }

    var coolalbum:FlxTypedGroup<CheckifyAlbum>;
    override function create()
    {
        #if DISCORD
        Discord.DiscordClient.changePresence("Listening To Checkify.", null);
        #end
        persistentUpdate = persistentDraw = true;
        FlxG.autoPause = false;

        camFollow = new FlxSprite().makeGraphic(2, 2, 0xFF000000);
        camFollow.screenCenter(X);
        add(camFollow);
        camFollowPos = new FlxSprite().makeGraphic(2, 2, 0xFF000000);
        camFollowPos.screenCenter(X);
        add(camFollowPos);
        FlxG.camera.follow(camFollow, null, 1);

        coolalbum = new FlxTypedGroup<CheckifyAlbum>();
        add(coolalbum);
        for (i in 0...songLists.length)
        {
            var direc:String = "";
            if (songLists[i][2] != null)
            {
                direc = songLists[i][2];
            }
            var album:CheckifyAlbum = new CheckifyAlbum(0, 360, songLists[i][0], songLists[i][1], direc);
            album.ID = i;
            album.y += Std.int(300 * i);
            coolalbum.add(album);
        }

        overlay = new CheckifyOverlay();
        overlay.scrollFactor.set(0, 0);
        add(overlay);

        change();

        super.create();
    }

    override function update(elapsed:Float)
    {
        var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollow.setPosition(FlxMath.lerp(camFollow.x, camFollowPos.x, lerpVal), FlxMath.lerp(camFollow.y, camFollowPos.y, lerpVal));

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
                if (!FlxG.sound.music.playing)
                {
                    FlxG.sound.play(Paths.sound("confirmMenu"));
                }
                persistentUpdate = false;
                openSubState(new CheckifyAlbumState(coolalbum.members[curSelected].details, curSelected, songLists));
            }
            if (controls.BACK)
            {
                canPress = false;
                FlxG.autoPause = true;
                FlxG.sound.play(Paths.sound("cancelMenu"));
                MusicBeatState.switchState(new MainMenuState());
            }
        }
        super.update(elapsed);
    }

    public function change(?huh:Int = 0)
    {
        curSelected += huh;

        if (huh != 0)
        {
            // mutes the scroll sound when music is playing.
            if (!FlxG.sound.music.playing)
            {
                FlxG.sound.play(Paths.sound("scrollMenu"));
            }
        }

        if (curSelected >= songLists.length)
        {
            curSelected = 0;
        }
        if (curSelected < 0)
        {
            curSelected = songLists.length - 1;
        }

        coolalbum.forEach(function(spr:CheckifyAlbum)
        {
            if (spr.ID == curSelected)
            {
                spr.box.color = 0xFF002F;
                camFollowPos.y = 360 + Std.int(300 * curSelected);
            }
            else
            {
                spr.box.color = 0xFF2F2F2F;
            }
        });
    }

    override function closeSubState() 
    {
        persistentUpdate = true;
        FlxG.camera.follow(camFollow, null, 1);
		canPress = true;
		change(0);
		super.closeSubState();
	}
}

class CheckifyAlbum extends FlxSpriteGroup
{
    public var details:Array<Dynamic> = [];
    public var box:FlxSprite = null;
    public function new(x:Int, y:Int, name:String, details:Array<Dynamic>, ?direc:String = "")
    {
        super();

        this.details = details;

        box = new FlxSprite(x, y).loadGraphic(CPaths.image("album/box"));
        add(box);

        var cover:FlxSprite = new FlxSprite().loadGraphic(CPaths.getAlbumArt(name, direc));
        cover.x = x + 75;
        cover.y = y + 25;
        add(cover);

        var nameThing:FlxText = new FlxText(cover.x + cover.width + 20, cover.y + Std.int(cover.height / 2), 1280 - 270, details[0][4], 28);
        nameThing.font = Paths.font("eras.ttf");
        nameThing.updateHitbox();
        nameThing.y -= Std.int(nameThing.height / 2);
        nameThing.scrollFactor.set(0, 0);
        add(nameThing);
    }
}

class CheckifyOverlay extends FlxSpriteGroup
{
    public function new()
    {
        super();

        var box:FlxSprite = new FlxSprite().loadGraphic(CPaths.image("overlay/box"));
        box.updateHitbox();
        box.scrollFactor.set(0, 0);
        add(box);

        var icon:SaveFileIcon = new SaveFileIcon();
        icon.load(TitleScreenState.saveIconThing);
        icon.setGraphicSize(300, 300);
        icon.updateHitbox();
        icon.scrollFactor.set(0, 0);
        icon.y = box.getGraphicMidpoint().y - 150;
        icon.x += 150;
        add(icon);

        var greetingTime:String = "Hello";
        #if desktop
        var leDate = Date.now();
        if (leDate.getHours() >= 0 && leDate.getHours() < 12)
        {
            greetingTime = "Good Morning";
        }
        if (leDate.getHours() >= 12 && leDate.getHours() < 18)
        {
            greetingTime = "Good Afternoon";
        }
        if (leDate.getHours() >= 18)
        {
            greetingTime = "Good Evening";
        }
        #end
        var greetingUsername:String = NameBox.playerName;
        var greetingText:FlxText = new FlxText(icon.x + icon.width + 20, icon.getGraphicMidpoint().y, 1280 - 170, "" + greetingTime + ", " + greetingUsername, 32);
        greetingText.font = Paths.font("eras.ttf");
        greetingText.updateHitbox();
        greetingText.scrollFactor.set(0, 0);
        add(greetingText);
    }
}