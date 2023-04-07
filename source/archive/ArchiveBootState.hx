package archive;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class ArchiveBootState extends MusicBeatState
{
    override function create()
    {
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.archives("images/boot.png"));
        add(bg);

        new FlxTimer().start(5, function(tmr:FlxTimer)
        {
            remove(bg);
            FlxG.sound.play(Paths.archives("sounds/bootup.ogg"), 1, false, null, true, function()
            {
                MusicBeatState.switchState(new ArchiveState());
            });
        });


        super.create();
    }
}