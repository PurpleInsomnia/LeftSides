package archive;

import sys.FileSystem;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class ArchiveState extends MusicBeatState
{
    var texts:FlxTypedGroup<FlxText>;
    var curSelected:Int = 0;
    var curTab:Int = 0;
    var curArray:Array<String> = [];
    var canPress:Bool = true;

    var menus:Array<String> = [
        "Notes",
        "Redacted Listings",
        "C:/"
    ];

    var submenus:Array<Array<String>> = [
        ["H.I.T", "Red Plant", "Prediction"],
        ["Amanda Anderson", "Hating Simulator Publishing Co.", "The Monster", "The Traitor"],
        ["pictures", "documents"]
    ];

    // specific arrays.
    var lists:Array<String> = [
        "Amanda Rose Anderson, the first born child of the well known Anderson family. Six years older than Tess Diana Anderson.\nHer father killed her with multiple stomps to the head, then making a henchman take the blame before fleeing LA with his wife and youngest up north.\n[GVMT thinks this is irrelevant, might archive this just incase.]",
        "'Double E' is resposnisble for the publish of the PS1 video game; 'Hating Simulator'.\n[GVMT thinks this has nothing to do with The Fallen Prisoners, but I suspect something else.]",
        "SENT TO EARTH: 1935\nPREY 'TAKEN OVER': 702\nPREY KILLED: 701\n \nThe Monster was sent to Earth in (Earth year) 1935 following the 'Incident involving the Wanted Kid' and the 'Massacre'. They landed somewhere in South Korea, progressing west. Currently in Northern California, they seem to be having trouble killing someone...odd for them...",
        "SENT TO EARTH: 1883\nPREY 'TAKEN OVER': 0\nPREY KILLED: 1\n \nThe Traitor was sent to Earth in 1883 after the 'Uprising of Galaxy 5'. He landed somewhere in the United States of America, pretty much staying there until he finds others like him...Glad we like to spread them out...The Monster is getting alarmingly close though..."
    ];
    var notes:Array<String> = [
        "The 'HUMAN INTERACTION TERMINAL' has been completed! Relied on human based interviews for some of the entries that have been redacted by the [GVMT Requests that I hide our race] Government but, at least I could add on to it myself. There have been weird breaches though...Not that " + CoolUtil.username() + " guy I chatted with but...something else....",
        "...Something bad is gonna happen. This red string-like plant has infected one of the [REDACTED]'s human test subjects...They went mad. Their flesh smelt horrible...They only made growling noises, but after a few days [DOCTER] declared them Brain Dead....But- they still had a pulse...Human pop culture calls this: 'Zombifacation'.\nI'm scared about if it's out there...festering...",
        "Dark World. Kids have to swim in waters with horrifying monsters.\nIs it the doing of 'The Monster'?"
    ];
    var filesys:Array<Array<String>> = [
        ["body.png", "poster.png"],
        ["HRL.txt"]
    ];
    
    override function create()
    {
        FlxG.sound.playMusic("theArchivesNeverLie", 1, true);

        texts = new FlxTypedGroup<FlxText>();
        add(texts);

        makeSelectors(menus);

        change();

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (canPress)
        {
            if (controls.ACCEPT)
            {
                switch (curTab)
                {
                    case 0:
                        switch (curSelected)
                        {
                            case 0:
                                curTab = 1;
                                makeSelectors(submenus[0]);
                            case 1:
                                curTab = 2;
                                makeSelectors(submenus[1]);
                            case 2:
                                curTab = 4;
                                makeSelectors(submenus[2]);
                        }
                    case 1:
                        curTab = 5;
                        displayText(notes[curSelected]);
                    case 2:
                        curTab = 6;
                        displayText(lists[curSelected]);
                        if (curSelected == 0)
                        {
                            FlxG.sound.music.pause();
                        }
                    case 4:
                        curTab = 7;
                        makeSelectors(filesys[curSelected]);
                    case 7:
                        var toOpen:String = curArray[curSelected];
                        if (toOpen.endsWith(".png"))
                        {
                            toOpen = "images/" + curArray[curSelected];
                            FileOpener.openFile(Paths.archives(toOpen));
                        }
                        if (toOpen.endsWith(".txt"))
                        {
                            toOpen = "data/" + curArray[curSelected];
                            FileOpener.openFile(Paths.archives(toOpen));
                        }
                }
            }
            if (controls.BACK)
            {
                FlxG.sound.play(Paths.sound("cancelMenu"));
                switch (curTab)
                {
                    case 0:
                        canPress = false;
                        FlxG.sound.music.stop();
                        MusicBeatState.switchState(new MonsterLairState());
                    case 1 | 2 | 3 | 4:
                        curTab = 0;
                        makeSelectors(menus);
                    case 5:
                        curTab = 1;
                        makeSelectors(submenus[0]);
                    case 6:
                        curTab = 2;
                        makeSelectors(submenus[1]);
                        if (curSelected == 0)
                        {
                            FlxG.sound.music.play();
                        }
                    case 7:
                        curTab = 4;
                        makeSelectors(submenus[2]);
                }
            }
            if (controls.UI_UP_P)
            {
                change(-1);
            }
            if (controls.UI_DOWN_P)
            {
                change(1);
            }
        }
        super.update(elapsed);
    }

    public function change(?huh:Int = 0)
    {
        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

        curSelected += huh;

        if (curSelected >= curArray.length)
        {
            curSelected = 0;
        }
        if (curSelected < 0)
        {
            curSelected = curArray.length - 1;
        }

        for (i in 0...curArray.length)
        {
            texts.members[i].text = curArray[i];
        }
        texts.members[curSelected].text = "> " + curArray[curSelected];
    }

    public function makeSelectors(array:Array<String>)
    {
        curArray = array;
        if (texts.members[0] != null)
        {
            texts.forEach(function(txt:FlxText)
            {
                texts.remove(txt);
            });
        }
        if (texts.members[0] != null)
        {
            texts.forEach(function(txt:FlxText)
            {
                texts.remove(txt);
            });
        }
        for (i in 0...array.length)
        {
            var text:FlxText = new FlxText(64, 72, 1280 - 64, array[i], 24);
            text.font = Paths.font("pixel.otf");
            text.y += Std.int(text.frameHeight * i);
            texts.add(text);
        }

        change(0);
    }

    public function displayText(text:String)
    {
        if (texts.members[0] != null)
        {
            texts.forEach(function(txt:FlxText)
            {
                texts.remove(txt);
            });
        }
        if (texts.members[0] != null)
        {
            texts.forEach(function(txt:FlxText)
            {
                texts.remove(txt);
            });
        }
        var text:FlxText = new FlxText(64, 72, 1280 - 64, text, 24);
        text.font = Paths.font("pixel.otf");
        texts.add(text);
    }
}