package;

/*
#if DISCORD
import Discord.DiscordClient;
#end
*/
import flixel.addons.text.FlxTypeText;
import haxe.Json;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import GameJolt.GameJoltAPI;

using StringTools;

typedef ShopItem = {
    var name:String;
    var desc:String;
    var price:Int;
    var thanks:String;
    var nah:String;
    var tag:String;
}

class ShopState extends MusicBeatState
{
    // how many items the shop should have.
    public var items:Int = 4;

    // util
    public var curSelected:Int = 0;

    // camera follows.
    public var camFollow:FlxSprite;
    public var camFollower:FlxSprite;

    // group
    public var shopItems:Array<CoolShopItem> = [];

    // monster :o
    public var monster:FlxSprite;

    // text
    public var nameTxt:FlxText;
    public var speakTxt:FlxTypeText;
    public var infoTxt:FlxText;

    override function create()
    {
        FlxG.sound.playMusic(Paths.music("monstersShop"), 1, true);
        // originally wanted GJ shit here...didnt really work out tho.
        makeTheShit();
        super.create();
    }

    /**
     * Actually makes the menu instead of getting gamejolt shit. :)
     */
    public function makeTheShit()
    {
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.shop("images/bg.png"));
        add(bg);

        var bar1:FlxSprite = new FlxSprite().makeGraphic(1280, 120, 0xFF000000);
        add(bar1);

        infoTxt = new FlxText(20, 120, FlxG.width, "PRICE: 175\nAMOUNT OWNED: 0", 20);
        infoTxt.setFormat(Paths.font("vcr.ttf"), 20, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        add(infoTxt);

        nameTxt = new FlxText(0, 60, FlxG.width, "< Week Key >", 34);
        nameTxt.alignment = CENTER;
        nameTxt.font = Paths.font("vcr.ttf");
        nameTxt.screenCenter(X);
        nameTxt.y = 60 - Std.int(nameTxt.height / 2);
        add(nameTxt);

        monster = new FlxSprite().loadGraphic(Paths.shop("images/monster/default.png"));
        add(monster);

        var bar2:FlxSprite = new FlxSprite(0, 600).makeGraphic(1280, 120, 0xFF000000);
        add(bar2);

        speakTxt = new FlxTypeText(20, bar2.y + 10, 1280, "lol", 28);
        speakTxt.font = Paths.font("vcr.ttf");
        speakTxt.sounds = [FlxG.sound.load(Paths.sound('term/text'), 0.4)];
        add(speakTxt);

        for (i in 0...items)
        {
            var daData:ShopItem = Json.parse(Paths.getTextFromFile("shop/data/" + ClientPrefs.inventory[i][0] + ".json"));

            var coolItem:CoolShopItem = new CoolShopItem();
            coolItem.data = daData;
            switch (coolItem.data.tag)
            {
                case "secret-key" | "costume-box":
                    if (ClientPrefs.inventory[i][1] == 1)
                    {
                        coolItem.oos = true;
                    }
            }
            if (!coolItem.oos)
            {
                coolItem.loadGraphic(Paths.shop("images/icons/" + daData.tag + ".png"));
            }
            else
            {
                coolItem.loadGraphic(Paths.shop("images/icons/" + daData.tag + ".png"));
                coolItem.color = 0xFF101010;
            }
            coolItem.screenCenter();
            coolItem.x -= Std.int(coolItem.width + (coolItem.width / 2));
            coolItem.ID = i;
            coolItem.visible = false;
            add(coolItem);
            shopItems.push(coolItem);
            FlxTween.tween(coolItem, {y: coolItem.y + 21}, 1, {ease: FlxEase.sineInOut, type: PINGPONG});
        }
        change(0);
    }

    var canPress:Bool = true;
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
                if (shopItems[curSelected].oos)
                {
                    oos(shopItems[curSelected]);
                    return;
                }
                if (ClientPrefs.points >= shopItems[curSelected].data.price || ClientPrefs.devMode)
                {
                    confirmPurchase(shopItems[curSelected].data.tag, shopItems[curSelected].data.price, shopItems[curSelected]);
                }
                else
                {
                    Ifunds();
                }
            }
            if (controls.BACK)
            {
                FlxG.sound.music.stop();
                canPress = false;
                FlxG.sound.play(Paths.sound("cancelMenu"));
                MusicBeatState.switchState(new MonsterLairState());
            }
        }
        super.update(elapsed);

        nameTxt.screenCenter(X);

        infoTxt.text = "PRICE: " + shopItems[curSelected].data.price + "LSP\nAMOUNT OWNED: " + ClientPrefs.inventory[curSelected][1] + "\n \nLSP BALANCE: " + ClientPrefs.points + "\nPress ENTER to purchase.";
    }

    public function change(cool:Int)
    {
        if (cool != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

        curSelected += cool;

        if (curSelected >= items)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = items - 1;

        for (i in 0...shopItems.length)
        {
            shopItems[i].visible = false;
        }
        shopItems[curSelected].visible = true;

        nameTxt.text = "< " + shopItems[curSelected].data.name + " >";
        if (shopItems[curSelected].oos)
        {
            nameTxt.text = "< " + shopItems[curSelected].data.name + " (OUT OF STOCK) >";
        }

        var exp:String = "default";
        switch (shopItems[curSelected].data.tag)
        {
            case "secret-key":
                exp = "bruh";
        }
        if (!shopItems[curSelected].oos)
        {
            startText(shopItems[curSelected].data.desc, exp);
        }
        else
        {
            startText("Out of [STOCK]...", "default");
        }
    }

    public function oos(huh:CoolShopItem)
    {
        FlxG.sound.play(Paths.sound("cancelMenu"));
        startText(huh.data.nah, "bruh");
    }

    public function Ifunds()
    {
        FlxG.sound.play(Paths.sound("cancelMenu"));
        startText("You don't have enough points " + CoolUtil.username() + ".", "default");
    }

    public function confirmPurchase(item:String, price:Int, huh:CoolShopItem)
    {
        canPress = false;
        startText(huh.data.thanks, "thank");

        FlxG.sound.play(Paths.shop("sounds/purchase.ogg"), 1, false, null, true, function()
        {
            canPress = true;
        });

        if (!ClientPrefs.devMode)
        {
            ClientPrefs.points -= price;
            ClientPrefs.saveSettings();
        }

        if (item == "secret-key" || item == "costume-box")
        {
            huh.oos = true;
            huh.color = 0xFF101010;
        }

        var toSave:String = "";
        for (i in 0...ClientPrefs.inventory.length)
        {
            if (ClientPrefs.inventory[i][0] == item)
            {
                toSave += ClientPrefs.inventory[i][0] + ":" + Std.string(ClientPrefs.inventory[i][1] + 1);
            }
            else
            {
                toSave += ClientPrefs.inventory[i][0] + ":" + Std.string(ClientPrefs.inventory[i][1]);
            }
            if (i != ClientPrefs.inventory.length - 1)
            {
                toSave += "|";
            }
        }

        var sussy:Array<String> = toSave.split("|");
        var fullPush:Array<Array<Dynamic>> = [];
        for (i in 0...sussy.length)
        {
            var dyna:Array<String> = sussy[i].split(":");
            var toPush:Array<Dynamic> = [dyna[0]];
            toPush.push(Std.parseInt(dyna[1]));
            fullPush.push(toPush);
        }
        ClientPrefs.inventory = fullPush;
        ClientPrefs.saveSettings();

        if (item == "secret-key")
        {
            MusicBeatState.switchState(new UnlockState([["Lol", "All Secret Songs within the freeplay and lair menu!"]]));
        }
        if (item == "costume-box")
        {
            MusicBeatState.switchState(new UnlockState([["Lol", "A lot of costumes in the 'Wardrobe Menu'!"]]));
        }
    }

    public function startText(tt:String, exp:String)
    {
        monster.loadGraphic(Paths.shop("images/monster/" + exp + ".png"));
        var real:String = tt;
        real = real.replace("USERNAME", CoolUtil.username());
		real = real.replace("[USERNAME]", CoolUtil.username());
        speakTxt.resetText(real);
        speakTxt.start(0.04, true);
    }
}

class CoolShopItem extends FlxSprite
{
    public var data:ShopItem = null;
    public var oos:Bool = false;

    public function new()
    {
        super();
    }
}