package comics;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import haxe.io.Bytes;
import sys.FileSystem;
import sys.io.File;

class ComicsMenu extends MusicBeatState
{
    var curComic:Int = 0;
    var canPress:Bool = true;
    var created:Bool = false;

    var bg:FlxSprite;

    var txtGrp:FlxTypedGroup<FlxText>;

    var colorArray:Array<Int>= [];
    var camFollow:FlxSprite;

    override function create()
    {
        #if ALLOW_GITHUB
        if (ComicsMeta.data != null)
        {
            created = true;
            createMenu();
        }
        else
        {
            noMenu();
        }
        #else
        noMenu();
        #end
        super.create();
    }

    override function update(elapsed:Float)
    {
        if (canPress)
        {
            if (created)
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
                    if (FileSystem.exists("comics/files/" + ComicsMeta.data.sections[curComic].name + ".pdf"))
                    {
                        lime.system.System.openFile("comics/files/" + ComicsMeta.data.sections[curComic].name + ".pdf");
                    }
                    else
                    {
                        var http = new haxe.Http("https://raw.githubusercontent.com/PurpleInsomnia/LeftSidesAPIShit/main/comics/" + ComicsMeta.data.sections[curComic].name + ".pdf");

                        http.onBytes = function(bytes:Bytes)
                        {
                            File.saveBytes("comics/files/" + ComicsMeta.data.sections[curComic].name + ".pdf", bytes);
                            lime.system.System.openFile("comics/files/" + ComicsMeta.data.sections[curComic].name + ".pdf");
                            canPress = true;
                        }

                        http.onError = function(msg)
                        {
                            trace(msg);
                            lime.app.Application.current.window.alert("An error has occured while downloading this comic. Check your connection and try again.", "Error Downloading Comic.");
                            canPress = true;
                        }

                        http.request();
                    }
                }
            }
            if (controls.BACK)
            {
                FlxG.sound.play(Paths.sound("cancelMenu"));
                canPress = false;
                MusicBeatState.switchState(new TitleScreenState());
            }
        }
        super.update(elapsed);
    }

    public function noMenu()
    {
        add(new FlxSprite().loadGraphic("comics/no.png"));
    }

    public function createMenu()
    {
        camFollow = new FlxSprite().makeGraphic(2, 2);
        camFollow.screenCenter();
        add(camFollow);
        FlxG.camera.follow(camFollow, null, 1);

        bg = new FlxSprite().loadGraphic("comics/bg.png");
        bg.scrollFactor.set(0, 0);
        add(bg);

        txtGrp = new FlxTypedGroup<FlxText>();
        add(txtGrp);
        
        for (i in 0...ComicsMeta.data.sections.length)
        {
            var text:String = "Issue 0";
            if (i < 10)
            {
                text += Std.string(i);
            }
            else
            {
                text = "Issue " + Std.string(i);
            }
            var daText:FlxText = new FlxText(0, 0, 1280, text + " - " + ComicsMeta.data.sections[i].name, 36);
            daText.font = Paths.font("eras.ttf");
            daText.updateHitbox();
            daText.x = 25;
            daText.y = 100;
            daText.y += Std.int((daText.height + 15) * i);
            daText.ID = i;
            txtGrp.add(daText);
        }

        change();
    }

    public function change(?huh:Int = 0)
    {
        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

        curComic += huh;

        if (curComic >= ComicsMeta.data.sections.length)
        {
            curComic = 0;
        }
        if (curComic < 0)
        {
            curComic = ComicsMeta.data.sections.length - 1;
        }

        txtGrp.forEach(function(txt:FlxText)
        {
            if (txt.ID == curComic)
            {
                txt.color = 0xFFFF7F00;
                camFollow.y = txt.y + Std.int(txt.height / 2);
            }
            else
            {
                txt.color = 0xFFFFFFFF;
            }
        });
    }
}