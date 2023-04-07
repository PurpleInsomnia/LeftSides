package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

class TripleTroubleStatic extends FlxSprite
{
    public var parent:PlayState = null;

    public function new(parent:PlayState)
    {
        super();

        frames = Paths.getSparrowAtlas("triple-trouble/static");
        animation.addByPrefix("idle", "anim", 39, false);

        this.parent = parent;
    }

    public function start()
    {
        animation.play("idle", true);
        new FlxTimer().start(1, function(tmr:FlxTimer)
        {
            parent.remove(this);
            kill();           
        });
    }
}