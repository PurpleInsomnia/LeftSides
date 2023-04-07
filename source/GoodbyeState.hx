package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class GoodbyeState extends MusicBeatState
{
    var canPress:Bool = true;

    override function create()
    {
        var goodbye:FlxSprite = new FlxSprite().loadGraphic(Paths.image("goodbye"));
        // precache
        goodbye.loadGraphic(Paths.image("goodbyeThanks"));
        goodbye.loadGraphic(Paths.image("goodbye"));
        add(goodbye);

        FlxG.sound.playMusic(Paths.music("goodbye"), 1, false);

        FlxTween.tween(goodbye, {y: ((goodbye.height - 720) * -1)}, 78.62, {onComplete: function(twn:FlxTween)
        {
            new FlxTimer().start(4.9, function(tmr:FlxTimer)
            {
                goodbye.loadGraphic(Paths.image("goodbyeThanks"));
                goodbye.y = 0;
            });
            FlxTween.tween(goodbye, {alpha: 0}, 4, {onComplete: function(twn:FlxTween)
            {
                FlxG.sound.music.stop();
                canPress = false;
                MusicBeatState.switchState(new CreditsState());
            }, startDelay: 5});
        }, startDelay: 5, ease: flixel.tweens.FlxEase.sineIn});

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (canPress && (controls.BACK || controls.ACCEPT))
        {
            canPress = false;
            FlxG.sound.play(Paths.sound("cancelMenu"));
            FlxG.sound.music.stop();
            MusicBeatState.switchState(new CreditsState());
        }
        super.update(elapsed);
    }
}