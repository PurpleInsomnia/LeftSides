package;

import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.Json;
import openfl.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

typedef WardrobeSection = {
    var sectionName:String;
    var chars:Array<WardrobeChar>;
}

typedef WardrobeChar = {
    var name:String;
    var description:String;
    var path:String;
    var unlock:String;
    var lock:String;
}

class WardrobeState extends MusicBeatState
{
    public var texts:Array<FlxText> = [];
    public var curSelected:Int = 0;
    public var curSelectedChar:Int = 0;
    public var chars:Array<String> = ["Ben", "Tess"];
    public var bg:FlxSprite;
    public var isChars:Bool = false;

    public var canPress:Bool = true;

    public var descText:FlxText;
    public var charText:FlxText;

    public var charFiles:Array<WardrobeSection> = [];
    public var ben:WardrobeCharacter = null;
    public var tess:WardrobeCharacter = null;

    override function create()
    {
        #if MODS_ALLOWED
        Paths.destroyLoadedImages(false);
        #end
        
        add(new GridBackdrop());

        bg = new FlxSprite().loadGraphic(Paths.image("freeplay/bg"));
        bg.blend = BlendMode.MULTIPLY;
        add(bg);

        for (i in 0...chars.length)
        {
            var cf:WardrobeSection = Json.parse(Paths.getTextFromFile("wardrobe/data/" + chars[i].toLowerCase() + ".json"));
            charFiles.push(cf);
        }

        ben = new WardrobeCharacter(0, 0, PlayState.customChars[0], true);
        ben.visible = false;
        editCharacterProperties(0, false);
        add(ben);

        tess = new WardrobeCharacter(0, 0, PlayState.customChars[1], false);
        tess.visible = false;
        editCharacterProperties(1, false);
        add(tess);

        trace("added characters! :)");

        var bottomBar:FlxSprite = new FlxSprite(0, 720 - 150).makeGraphic(1280, 720, 0xFF000000);
        add(bottomBar);

        var sideBar:FlxSprite = new FlxSprite().loadGraphic(Paths.wardrobe("images/side.png"));
        add(sideBar);

        for (i in 0...chars.length)
        {
            var text:FlxText = new FlxText(20, 0, sideBar.width - 40, chars[i], 24);
            text.setFormat(Paths.font("eras.ttf"), 24, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
            text.x = Std.int(sideBar.getGraphicMidpoint().x - (text.width / 2));
            if (i == 0)
            {
                text.y = Std.int(sideBar.getGraphicMidpoint().y - text.height);
            }
            if (i == 1)
            {
                text.y = Std.int(sideBar.getGraphicMidpoint().y + text.height);
            }
            add(text);
            texts.push(text);
        }

        charText = new FlxText(0, 0, 1280 - (sideBar.width + 20), "", 48);
        charText.font = Paths.font("eras.ttf");
        charText.alignment = CENTER;
        charText.y = 75;
        charText.x = sideBar.width + 20;
        charText.visible = false;
        add(charText);

        descText = new FlxText(sideBar.width + 20, bottomBar.y + 20, 1280 - (sideBar.width + 20), "", 24);
        descText.font = Paths.font("eras.ttf");
        descText.visible = false;
        add(descText);

        change(0);

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (canPress)
        {
            if (!isChars)
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
                    charText.visible = true;
                    descText.visible = true;
                    isChars = true;
                    switch (curSelected)
                    {
                        case 0:
                            texts[1].visible = false;
                            bg.color = 0xFFFF8A00;
                            curSelectedChar = CoolUtil.curSelectedChars[0];
                        case 1:
                            texts[0].visible = false;
                            bg.color = 0xFFB300FF;
                            curSelectedChar = CoolUtil.curSelectedChars[1];
                    }
                    changeChar(0);
                    new FlxTimer().start(0.1, function(tmr:FlxTimer)
                    {
                        canPress = true;
                    });
                }
                if (controls.BACK)
                {
                    canPress = false;
                    FlxG.sound.play(Paths.sound("cancelMenu"));
                    MusicBeatState.switchState(new FunnyFreeplayState());
                }
            }
            else
            {
                if (controls.UI_LEFT_P)
                {
                    changeChar(-1);
                }
                if (controls.UI_RIGHT_P)
                {
                    changeChar(1);
                }
                if (controls.ACCEPT)
                {
                    FlxG.sound.play(Paths.sound("confirmMenu"));
                    switch (curSelected)
                    {
                        case 0:
                            PlayState.customChars[0] = ben.curCharacter;
                        case 1:
                            PlayState.customChars[1] = tess.curCharacter;
                    }
                    ClientPrefs.saveSettings();
                }
                if (controls.BACK)
                {
                    canPress = false;
                    FlxG.sound.play(Paths.sound("cancelMenu"));
                    for (i in 0...texts.length)
                    {
                        texts[i].visible = true;
                    }
                    charText.visible = false;
                    descText.visible = false;
                    isChars = false;
                    bg.color = 0xFFFFFFFF;
                    new FlxTimer().start(0.1, function(tmr:FlxTimer)
                    {
                        canPress = true;
                        change(0, true);
                    });
                }
            }
        }
        super.update(elapsed);
    }

    function change(huh:Int, ?reload:Bool = false)
    {
        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }
        if (reload)
        {
            remove(ben);
            ben = new WardrobeCharacter(0, 0, PlayState.customChars[0], true);
            ben.visible = false;
            editCharacterProperties(0, false);
            add(ben);

            remove(tess);
            tess = new WardrobeCharacter(0, 0, PlayState.customChars[1], false);
            tess.visible = false;
            editCharacterProperties(1, false);
            add(tess);
        }

        curSelected += huh;
        if (curSelected > 1)
        {
            curSelected = 0;
        }
        if (curSelected < 0)
        {
            curSelected = 1;
        }

        for (i in 0...texts.length)
        {
            texts[i].alpha = 0.75;
            texts[i].text = chars[i];
        }
        texts[curSelected].alpha = 1;
        texts[curSelected].text = "> " + chars[curSelected];

        switch (curSelected)
        {
            case 0:
                ben.visible = true;
                tess.visible = false;
            case 1:
                tess.visible = true;
                ben.visible = false;
        }
    }

    function changeChar(huh:Int)
    {
        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

        curSelectedChar += huh;

        switch (curSelected)
        {
            case 0:
                if (curSelectedChar >= charFiles[0].chars.length)
                {
                    curSelectedChar = 0;
                }
                if (curSelectedChar < 0)
                {
                    curSelectedChar = charFiles[0].chars.length - 1;
                }

                remove(ben);
                ben = new WardrobeCharacter(0, 0, charFiles[0].chars[curSelectedChar].path, true);
                editCharacterProperties(0, true);
                add(ben);

                if (!ben.locked)
                {
                    descText.text = charFiles[0].chars[curSelectedChar].description;
                    charText.text = "< " + charFiles[0].chars[curSelectedChar].name + " >";
                }
                else
                {
                    descText.text = charFiles[0].chars[curSelectedChar].lock;
                    charText.text = "< ??? >";
                }
            case 1:
                if (curSelectedChar >= charFiles[1].chars.length)
                {
                    curSelectedChar = 0;
                }
                if (curSelectedChar < 0)
                {
                    curSelectedChar = charFiles[1].chars.length - 1;
                }

                remove(tess);
                tess = new WardrobeCharacter(0, 0, charFiles[1].chars[curSelectedChar].path, false);
                editCharacterProperties(1, true);
                add(tess);

                if (!tess.locked)
                {
                    descText.text = charFiles[1].chars[curSelectedChar].description;
                    charText.text = "< " + charFiles[1].chars[curSelectedChar].name + " >";
                }
                else
                {
                    descText.text = charFiles[1].chars[curSelectedChar].lock;
                    charText.text = "< ??? >";
                }
        }
    }

    public function editCharacterProperties(?char:Int = 0, ?selecting:Bool = true)
    {
        if (char == 0)
        {
            ben.scale.set(0.75, 0.75);
            ben.updateHitbox();
            ben.screenCenter();
            ben.x += 200;
            // checks unlocks
            var numToRead:Int = curSelectedChar;
            if (!selecting)
            {
                numToRead = CoolUtil.curSelectedChars[0];
            }
            var split:Array<String> = charFiles[0].chars[numToRead].unlock.split(":");
            switch (split[0])
            {
                case "song":
                    if (Highscore.getScore(split[1], 1) == 0)
                    {
                        ben.locked = true;
                    }
                case "songEncore":
                    if (Highscore.getEncoreScore(split[1], 1) == 0)
                    {
                        ben.locked = true;
                    }
                case "data":
                    if (!Reflect.getProperty(ClientPrefs, split[1]))
                    {
                        ben.locked = true;
                    }
                case "ss":
                    if (!ClientPrefs.completedSideStories.get(split[1]))
                    {
                        ben.locked = true;
                    }
                case "misc":
                    switch (split[1])
                    {
                        case "allSideStories":
                            var toCheck:Array<String> = [];
                            var isFinished:Array<Bool> = [];
                            for (ss in SideStorySelectState.storyList)
                            {
                                toCheck.push(ss[1]);
                            }
                            for (check in toCheck)
                            {
                                if (ClientPrefs.completedSideStories.get(check))
                                {
                                    isFinished.push(true);
                                }
                                else
                                {
                                    isFinished.push(false);
                                }
                            }
                            var canCont:Bool = true;
                            for (i in 0...isFinished.length)
                            {
                                if (!isFinished[i])
                                {
                                    canCont = false;
                                }
                            }
                            if (!canCont)
                            {
                                ben.locked = true;
                            }
                        case "ownSuggestedCostumes":
                            if (ClientPrefs.inventory[3][1] == 0)
                            {
                               ben.locked = true; 
                            }
                    }
            }
            if (ben.locked)
            {
                ben.color = 0xFF000000;
            }
        }
        if (char == 1)
        {
            tess.scale.set(0.75, 0.75);
            tess.updateHitbox();
            tess.screenCenter();
            tess.x += 200;
            // checks unlocks
            var numToRead:Int = curSelectedChar;
            if (!selecting)
            {
                numToRead = CoolUtil.curSelectedChars[1];
            }
            var split:Array<String> = charFiles[1].chars[numToRead].unlock.split(":");
            switch (split[0])
            {
                case "song":
                    if (Highscore.getScore(split[1], 1) == 0)
                    {
                        tess.locked = true;
                    }
                case "songEncore":
                    if (Highscore.getEncoreScore(split[1], 1) == 0)
                    {
                        tess.locked = true;
                    }
                case "data":
                    if (!Reflect.getProperty(ClientPrefs, split[1]))
                    {
                        tess.locked = true;
                    }
                case "ss":
                    if (!ClientPrefs.completedSideStories.get(split[1]))
                    {
                        tess.locked = true;
                    }
                case "misc":
                    switch (split[1])
                    {
                        case "allSideStories":
                            var toCheck:Array<String> = [];
                            var isFinished:Array<Bool> = [];
                            for (ss in SideStorySelectState.storyList)
                            {
                                toCheck.push(ss[1]);
                            }
                            for (check in toCheck)
                            {
                                if (ClientPrefs.completedSideStories.get(check))
                                {
                                    isFinished.push(true);
                                }
                                else
                                {
                                    isFinished.push(false);
                                }
                            }
                            var canCont:Bool = true;
                            for (i in 0...isFinished.length)
                            {
                                if (!isFinished[i])
                                {
                                    canCont = false;
                                }
                            }
                            if (!canCont)
                            {
                                tess.locked = true;
                            }
                        case "ownSuggestedCostumes":
                            if (ClientPrefs.inventory[3][1] == 0)
                            {
                               tess.locked = true; 
                            }
                    }
            }
            if (tess.locked)
            {
                tess.color = 0xFF000000;
            }
        }
    }
}

class WardrobeCharacter extends Character
{
    public var locked:Bool = false;
}