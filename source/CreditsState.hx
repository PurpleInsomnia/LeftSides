package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import sys.FileSystem;
import haxe.Json;

typedef CreditsFile = {
    var sections:Array<CreditsSection>;
}

typedef CreditsSection = {
    var name:String;
    var subsections:Array<CreditsSubsection>;
}

typedef CreditsSubsection = {
    var title:String;
    var people:Array<Array<String>>;
}

class CreditsState extends MusicBeatState
{
    var file:CreditsFile;

    var icon:FlxSprite;
    var text:FlxText;

    var grp:FlxTypedGroup<Dynamic>;

    var camFollow:FlxSprite;
    var camFollowPos:FlxSprite;

    var toSelect:Array<Array<Dynamic>> = [];
    var subsecs:Array<Alphabet> = [];

    var curSelected:Int = 0;

    override function create()
    {
        if (FileSystem.exists(Paths.preloadFunny("data/credits.json")))
        {
            file = Json.parse(Paths.getTextFromFile("data/credits.json"));
        }
        else
        {
            file = {
                sections: [
                    {
                        name: "NO FILE",
                        subsections: [
                            {
                                title: "NO FILE",
                                people: [["NO FILE", "you", "", "NO FILE EXISTS IN THE DATA FOLDER TITLED: " + '"credits.json"']]
                            }
                        ]
                    }
                ]
            }
        }

        camFollow = new FlxSprite().makeGraphic(1, 1);
        camFollow.screenCenter();
        add(camFollow);

        camFollowPos = new FlxSprite().makeGraphic(1, 1);
        camFollowPos.screenCenter();
        add(camFollowPos);

        FlxG.camera.follow(camFollowPos, null, 1);

		var ppSuck:GridBackdrop = new GridBackdrop();
		ppSuck.scrollFactor.set(0, 0);
		add(ppSuck);

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('backdropSHADER'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.blend = openfl.display.BlendMode.DARKEN;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

        grp = new FlxTypedGroup<Dynamic>();
        add(grp);

        for (i in 0...file.sections.length)
        {
            var alpha:Alphabet = new Alphabet(0, 0, file.sections[i].name, true, false);
            alpha.screenCenter();
            if (grp.length != 0)
                alpha.y += 90 * grp.length;

            grp.add(alpha);
            addSection(i);
        }

        var box:FlxSprite = new FlxSprite(0, FlxG.height - 150).makeGraphic(FlxG.width, 150, 0xFF000000);
        box.scrollFactor.set(0, 0);
        add(box);

        icon = new FlxSprite(0, box.y).loadGraphic(Paths.image("credits/purpleinsomnia"));
        icon.scrollFactor.set(0, 0);
        add(icon);

        text = new FlxText(150, box.y + 10, FlxG.width - 150, "penis fart fart lmao", 24);
        text.font = Paths.font("eras.ttf");
        text.scrollFactor.set(0, 0);
        add(text);

        changeSelection(0);

        // 1.5 bc I made it too quiet DX
        FlxG.sound.playMusic(Paths.music("movingOn"), 1.5, true);

        super.create();
    }

    var canLink:Bool = false;
    override function update(elapsed:Float)
    {
        var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

        if (controls.UI_UP_P)
        {
            changeSelection(-1);
        }
        if (controls.UI_DOWN_P)
        {
            changeSelection(1);
        }
        if (controls.ACCEPT && canLink)
        {
            if (toSelect[curSelected][1] != "")
            {
                CoolUtil.browserLoad(toSelect[curSelected][1]);
            }
            else
            {
                lime.app.Application.current.window.alert("Social link either doesn't exist, or it was pretty hard to find.", "ERROR");
            }
        }
        if (controls.BACK)
        {
            FlxG.sound.music.stop();
            FlxG.sound.play(Paths.sound("cancelMenu"));
            MusicBeatState.switchState(new TitleScreenState());
        }
        super.update(elapsed);
    }

    function changeSelection(?huh:Int = 0)
    {
        if (huh != 0)
            FlxG.sound.play(Paths.sound("scrollMenu"));

        curSelected += huh;
        if (curSelected >= toSelect.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = toSelect.length - 1;

        if (toSelect[curSelected][2] != null && toSelect[curSelected][3] != null && toSelect[curSelected][4] != null)
        {
            icon.visible = true;
            text.visible = true;
            icon.loadGraphic(Paths.image("credits/" + toSelect[curSelected][2]));
            var lmao:String = Std.string(toSelect[curSelected][4]);
            text.text = lmao.toUpperCase() + ": " + toSelect[curSelected][3];
        }
        else
        {
            icon.visible = false;
            text.visible = false;
        }

        if (toSelect[curSelected][1] != null)
        {
            canLink = true;
        }
        else
        {
            canLink = false;
        }

        for (i in 0...toSelect.length)
        {
            toSelect[i][0].alpha = 0.25;
            if (i == curSelected)
            {
                toSelect[i][0].alpha = 1;
            }
        }

        if (toSelect[curSelected][2] != null)
            camFollow.y = toSelect[curSelected][0].y + (Std.int(90 / 2) + 90);
        else
            camFollow.y = toSelect[curSelected][0].y + Std.int(90 / 2);
    }

    function addSection(huh:Int)
    {
        for (i in 0...file.sections[huh].subsections.length)
        {
            var alpha:Alphabet = new Alphabet(0, 0, file.sections[huh].subsections[i].title, true, false, 0.5, 0.75);
            alpha.screenCenter();
            alpha.y += 90 * grp.length;
            grp.add(alpha);
            toSelect.push([alpha]);
            subsecs.push(alpha);
            addSubsection(file.sections[huh].subsections[i], i);
        }
    }

    function addSubsection(subsection:CreditsSubsection, huh:Int)
    {
        for (i in 0...subsection.people.length)
        {
            var alpha:Alphabet = new Alphabet(0, 0, subsection.people[i][0], false, false, 0.5, 0.75);
            alpha.screenCenter();
            alpha.y += 90 * (grp.length - 1);
            grp.add(alpha);
            toSelect.push([alpha, subsection.people[i][2], subsection.people[i][1], subsection.people[i][3], subsection.people[i][0]]);
        }
    }
}