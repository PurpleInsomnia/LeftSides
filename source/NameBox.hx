package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;

class NameBox extends FlxSpriteGroup
{
    public var parent:Dynamic = null;
    public var input:FlxUIInputText = null;

    public static var playerName:String = "NAME";

    public function new(parent:Dynamic, callback:Void->Void)
    {
        super();

        FlxG.mouse.visible = true;

        if (parent != null)
        {
            this.parent = parent;
        }

        var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFF000000);
        bg.alpha = 0;
        add(bg);

        var box:FlxSprite = new FlxSprite().loadGraphic(Paths.image("nameBox"));
        box.screenCenter();
        add(box);

        var ttd:String = "NAME";
        if (FlxG.save.data.playerName != null)
        {
            ttd = FlxG.save.data.playerName;
        }
        input = new FlxUIInputText(0, 0, 320, ttd, 24, 0xFF000000, 0xFFFFFFFF);
        input.screenCenter();
        add(input);

        var button:FlxButton = new FlxButton(0, 0, null, function()
        {
            NameBox.playerName = input.text;
            NameBox.save();
            callback();
            if (parent != null)
            {
                parent.remove(this);
            }
            kill();
        });
        button.loadGraphic(Paths.image("nameConfirm"), true, 300, 150);
        button.scale.set(0.5, 0.5);
        button.updateHitbox();
        button.screenCenter();
        button.y = input.y + Std.int(input.height) + 10;
        add(button);

        FlxTween.tween(bg, {alpha: 0.5}, 1);

        forEach(function(spr:Dynamic)
        {
            spr.scrollFactor.set(0, 0);
        });
    }

    public static function check()
    {
        return FlxG.save.data.playerName;
    }

    public static function save()
    {
        FlxG.save.data.playerName = playerName;

        FlxG.save.flush();
    }

    public static function load()
    {
        if (FlxG.save.data.playerName != null)
        {
            playerName = FlxG.save.data.playerName;
        }
    }
}