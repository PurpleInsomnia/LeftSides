package;

#if DISCORD
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.BlendMode;

class SelectCharacterState extends MusicBeatState
{
    public var chars:Array<Array<String>> = [];
    public var piss:Array<Dynamic> = [];
    public var names:Array<String> = [];
    public var curSelected:Int = 0;
    public var coolText:FlxText = null;
    public var canPress:Bool = true;
    public var grp:FlxTypedGroup<FlxSprite>;
    public var camFollow:FlxSprite = null;

    public function new(chars:Array<Array<String>>, piss:Array<Dynamic>)
    {
        super();

        this.chars = chars;
        this.piss = piss;
    }

    override function create()
    {
        #if desktop
        DiscordClient.changePresence("Selecting A Character...", null);
        #end
    	Paths.destroyLoadedImages();

        camFollow = new FlxSprite().makeGraphic(1, 1);
        camFollow.screenCenter();
        add(camFollow);
        FlxG.camera.follow(camFollow, null, 1);

        var ppSuck:GridBackdrop = new GridBackdrop();
		ppSuck.scrollFactor.set(0, 0);
		add(ppSuck);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('backdropSHADER'));
		bg.scrollFactor.set(0, 0);
		bg.blend = BlendMode.DARKEN;
		add(bg);

        grp = new FlxTypedGroup<FlxSprite>();
        add(grp);

        for (i in 0...chars.length)
        {
            var char:FlxSprite = new FlxSprite().loadGraphic(Paths.image("select_char/" + chars[i][0]));
            char.screenCenter();
            char.x += Std.int(640 * i);
            char.ID = i;
            if (sys.FileSystem.exists(Paths.preloadFunny("images/select_char/" + chars[i][0] + ".txt")))
            {
                names.push(sys.io.File.getContent(Paths.preloadFunny("images/select_char/" + chars[i][0] + ".txt")));
            }
            else
            {
                names.push(chars[i][0]);
            }
            grp.add(char);
        }

        var bars:FlxSprite = new FlxSprite().loadGraphic(Paths.image("select_char/bars"));
        bars.scrollFactor.set(0, 0);
        add(bars);

        coolText = new FlxText(0, 0, 1280, names[curSelected], 28);
        coolText.scrollFactor.set(0, 0);
        coolText.alignment = CENTER;
        coolText.font = Paths.font("eras.ttf");
        coolText.updateHitbox();
        coolText.screenCenter(X);
        coolText.y = Std.int((720 - 70) + (coolText.height / 2));
        add(coolText);

        change();

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (canPress)
        {
            if (controls.UI_LEFT_P)
            {
                change(-1);
            }
            if (controls.UI_RIGHT_P)
            {
                change(1);
            }
            if (controls.ACCEPT)
            {
                canPress = false;
                FlxG.sound.play(Paths.sound("confirmMenu"));
                PlayState.songPrefix = chars[curSelected][1];
                // reload the song grrrrrrah!!!
                PlayState.SONG = Song.loadFromJson(piss[0], piss[1]);
                MusicBeatState.switchState(new HealthLossState());
            }
            if (controls.BACK)
            {
                canPress = false;
                FlxG.sound.play(Paths.sound("cancelMenu"));
                MusicBeatState.switchState(new FunnyFreeplayState());
            }
        }
        super.update(elapsed);

        coolText.text = "< " + names[curSelected] + " >";
        coolText.screenCenter(X);
    }

    public var camTwn:FlxTween = null;
    public function change(?huh:Int = 0)
    {
        curSelected += huh;

        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

        if (camTwn != null)
        {
            camTwn.cancel();
            camTwn = null;
        }

        if (curSelected >= chars.length)
        {
            curSelected = 0;
        }
        if (curSelected < 0)
        {
            curSelected = chars.length - 1;
        }

        grp.forEach(function(char:FlxSprite)
        {
            if (char.ID != curSelected)
            {
                char.color = 0xFF000000;
            }
            else
            {
                char.color = 0xFFFFFFFF;
                camTwn = FlxTween.tween(camFollow, {x: char.getGraphicMidpoint().x}, 0.5, {ease: FlxEase.circOut,
                    onComplete: function(twn:FlxTween)
                    {
                        camTwn = null;
                    }
                });
            }
        });
    }
}