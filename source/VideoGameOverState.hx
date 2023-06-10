package;

import haxe.Json;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.display.BitmapData;
import sys.FileSystem;
import sys.io.File;

typedef VideoGameOverMeta = {
    var screenFlash:Array<Dynamic>;
    var deathSound:Array<Dynamic>;
    var loopMusic:Array<Dynamic>;
    var confirmSound:Array<Dynamic>;
}

class VideoGameOverState extends MusicBeatState
{
    public var daVid:String = "lol";
    public var canPress:Bool = false;
    public var meta:VideoGameOverMeta = null;
    public function new(vid:String)
    {
        daVid = vid;
        super();
    }

    override function create()
    {
        if (FileSystem.exists(Paths.preloadFunny("videos/gameover/" + daVid + ".json")))
        {
            meta = Json.parse(File.getContent(Paths.preloadFunny("videos/gameover/" + daVid + ".json")));
        }
        else
        {
            meta = {
                screenFlash: [true, "0xFFFFFFFF", 0.75],
                deathSound: [true, "fnf_loss_sfx", 2.25],
                loopMusic: [true, "gameOver"],
                confirmSound: [true, "gameOverEnd", 3]
            }
        }

        #if VIDEOS_ALLOWED
        (new FlxVideo(Paths.preloadFunny("videos/gameover/" + daVid + ".mp4"))).finishCallback = function()
        {
            var fullPath:String = Paths.preloadFunny("videos/gameover/");
            if (FileSystem.exists(Paths.preloadFunny("videos/gameover/" + daVid + ".png")))
            {
                fullPath += daVid + ".png";
            }
            else
            {
                fullPath += "retry.png";
            }

            var bitmap:BitmapData = BitmapData.fromFile(fullPath);
            add(new FlxSprite().loadGraphic(bitmap));

            var waitTime:Float = 1;
            if (meta.screenFlash[0])
            {
                waitTime = meta.screenFlash[2];
                FlxG.camera.flash(Std.parseInt(meta.screenFlash[1]), meta.screenFlash[2]);
            }

            if (meta.deathSound[0])
            {
                FlxG.sound.play(Paths.sound(meta.deathSound[1]));
                new flixel.util.FlxTimer().start(meta.deathSound[2], function(tmr:flixel.util.FlxTimer)
                {
                    canPress = true;
                    if (meta.loopMusic[0])
                    {
                        FlxG.sound.playMusic(Paths.music(meta.loopMusic[1]), true);
                    }
                });
            }
            else
            {
                new flixel.util.FlxTimer().start(waitTime, function(tmr:flixel.util.FlxTimer)
                {
                    canPress = true;
                });  
            }
        }
        #else
        var fullPath:String = Paths.preloadFunny("videos/gameover/");
        if (FileSystem.exists(Paths.preloadFunny("videos/gameover/" + daVid + ".png")))
        {
            fullPath += daVid + ".png";
        }
        else
        {
            fullPath += "retry.png";
        }

        var bitmap:BitmapData = BitmapData.fromFile(fullPath);
        add(new FlxSprite().loadGraphic(bitmap));

        var waitTime:Float = 1;
        if (meta.screenFlash[0])
        {
            waitTime = meta.screenFlash[2];
            FlxG.camera.flash(Std.parseInt(meta.screenFlash[1]), meta.screenFlash[2]);
        }

        if (meta.deathSound[0])
        {
            FlxG.sound.play(Paths.sound(meta.deathSound[1]));
            new flixel.util.FlxTimer().start(meta.deathSound[2], function(tmr:flixel.util.FlxTimer)
            {
                canPress = true;
                if (meta.loopMusic[0])
                {
                    FlxG.sound.playMusic(Paths.music(meta.loopMusic[1]));
                }
            });
        }
        else
        {
            new flixel.util.FlxTimer().start(waitTime, function(tmr:flixel.util.FlxTimer)
            {
                canPress = true;
            });  
        }
        #end

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (canPress && controls.BACK)
        {
            canPress = false;
            back();
        }
        if (canPress && controls.ACCEPT)
        {
            canPress = false;
            FlxG.sound.music.stop();
            var waitTime:Float = 0.0001;
            if (meta.confirmSound[0])
            {
                waitTime = meta.confirmSound[2];
                FlxG.sound.play(Paths.music(meta.confirmSound[1]));
            }
            FlxG.camera.fade(0xFF000000, waitTime, false, function()
            {
                MusicBeatState.switchState(new PlayState());
            });
        }
        super.update(elapsed);
    }

    function back()
    {
        PlayState.deathCounter = 0;
		PlayState.seenCutscene = false;

		if (PlayState.isStoryMode)
		{
			var check:Bool = StateManager.check("story-menu");
			if (!check)
			{
				MusicBeatState.switchState(new StoryMenuState());
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		}
		else
		{
			var check:Bool = StateManager.check("freeplay");
			if (!check)
			{
				MusicBeatState.switchState(new FunnyFreeplayState());
				FlxG.sound.playMusic(Paths.music('freeplay'));
			}
		}
    }
}