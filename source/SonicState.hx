package;

import flixel.FlxG;
import flixel.FlxSprite;
import filters.VCR;

class SonicState extends MusicBeatState
{
    var vcr:VCR;

    override function create()
    {
        vcr = new VCR();

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.shop("images/sonic.png"));
        bg.shader = vcr.shader;
        add(bg);

        super.create();
    }

    override function update(elapsed:Float)
    {
        vcr.update(elapsed);

        if (controls.BACK)
        {
            MusicBeatState.switchState(new MainMenuState());
        }

        super.update(elapsed);
    }
}