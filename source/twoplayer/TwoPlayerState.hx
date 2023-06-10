package twoplayer;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.ui.FlxButton;

class TwoPlayerState extends MusicBeatState
{
    public static var tpm:Bool = false;

    var canPress:Bool = true;
    var st:FlxText = null;
    override function create()
    {
        #if DISCORD
        Discord.DiscordClient.changePresence("Multiplayer Menu", null);
        #end

        add(new GridBackdrop());
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("2Player/bg"));
        bg.color = flixel.util.FlxColor.fromRGB(FlxG.random.int(150, 255), FlxG.random.int(150, 255), FlxG.random.int(150, 255));
        bg.blend = openfl.display.BlendMode.MULTIPLY;
        add(bg);

        var init:FlxButton = new FlxButton(0, 0, null, function()
        {
            if (canPress)
            {
                canPress = false;
                add(new TwoPlayerInit(controls, function()
                {
                    canPress = true;
                }));
            }
        });
        init.loadGraphic(Paths.image("2Player/init"), true, 300, 300);
        init.screenCenter();
        init.x -= 300;
        add(init);

        var off:FlxButton = new FlxButton(0, 0, null, function()
        {
            if (TwoPlayerState.tpm)
            {
                TwoPlayerState.tpm = false;
            }
        });
        off.loadGraphic(Paths.image("2Player/off"), true, 300, 300);
        off.screenCenter();
        off.x += 300;
        add(off);

        st = new FlxText(0, 0, 1280, "", 32);
        st.font = Paths.font("eras.ttf");
        st.borderColor = 0xFF000000;
        st.borderStyle = OUTLINE;
        st.alignment = CENTER;
        add(st);

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (controls.BACK && canPress)
        {
            canPress = false;
            FlxG.sound.play(Paths.sound("cancelMenu"));
            MusicBeatState.switchState(new MainMenuState());
        }
        super.update(elapsed);

        if (TwoPlayerState.tpm)
        {
            st.color = 0xFF00FF00;
            st.text = "MULTIPLAYER ENABLED";
        }
        else
        {
            st.color = 0xFFFF0000;
            st.text = "MULTIPLAYER DISABLED";
        }
        st.updateHitbox();
        st.screenCenter();
        st.y = 25;
    }
}

class TwoPlayerInit extends FlxSpriteGroup
{
    var callback:Void->Void;

    var poi:PlayerInputCheck;
    var pti:PlayerInputCheck;

    var pocp:Bool = true;
    var ptcp:Bool = true;

    var controls:Controls;

    public function new(controls:Controls, callback:Void->Void)
    {
        super();

        this.callback = callback;
        this.controls = controls;

        poi = new PlayerInputCheck(0, 0, "1");
        add(poi);

        pti = new PlayerInputCheck(640, 0, "2");
        add(pti);
    }

    override function update(elapsed:Float)
    {
        if (pocp)
        {
            if (controls.BACK)
            {
                pocp = false;
                callback();
                kill();
            }
            if (FlxG.keys.anyJustPressed([UP, NUMPADONE]) && !poi.on)
            {
                pocp = false;
                poi.turnOn();
                new flixel.util.FlxTimer().start(1, function(tmr:flixel.util.FlxTimer)
                {
                    pocp = true;
                });
            }
        }
        if (ptcp && !pti.on)
        {
            if (FlxG.keys.anyJustPressed([W, K]))
            {
                ptcp = false;
                pti.turnOn();
            }
        }
        if (poi.on && pti.on && controls.ACCEPT && pocp)
        {
            FlxG.sound.play(Paths.sound("confirmMenu"));
            pocp = false;
            ptcp = false;
            TwoPlayerState.tpm = true;
            callback();
            kill();
        }
        super.update(elapsed);
    }
}

class PlayerInputCheck extends FlxSprite
{
    public var on:Bool = false;
    public var player:String = "0";
    public function new(x:Int, y:Int, player:String)
    {
        super(x, y);

        this.player = player;

        loadGraphic(Paths.image("2Player/check/" + player), true, 640, 720);
        animation.add("idle", [0], 1, true);
        animation.add("on", [1], 1, true);
        animation.play("idle");
    }

    public function turnOn()
    {
        on = true;
        animation.play("on");
        FlxG.sound.play(Paths.sound("confirmMenu"));
    }
}