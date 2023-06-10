package dlc;

import flixel.FlxG;
import flixel.FlxSprite;

class DlcTutorials extends MusicBeatState
{
    var playlistLink:String = "https://youtube.com/playlist?list=PLdbs4oebY0a603NxPtzv7kgUn7QPoVOPP";
    override function create()
    {
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("dlctut"));
        add(bg);

        super.create();
    }

    var canPress:Bool = true;
    override function update(elapsed:Float)
    {
        if (canPress)
        {
            if (controls.ACCEPT)
            {
                CoolUtil.browserLoad(playlistLink);
            }
            if (controls.BACK)
            {
                canPress = false;
                FlxG.sound.play(Paths.sound("cancelMenu"));
                MusicBeatState.switchState(new TitleScreenState());
            }
        }
        super.update(elapsed);
    }
}