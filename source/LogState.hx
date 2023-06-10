package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import haxe.Json;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import filters.GrainFilter;

typedef LogFile = {
    var lines:Array<LogLine>;
}

typedef LogLine = {
    var text:String;
    var name:String;
    var textColour:String;
}

class LogState extends MusicBeatState
{
    var file:LogFile;

    var camFollow:FlxSprite;

    var curLine:Int = -1;

    var textGrp:FlxTypedGroup<FlxTypeText>;

    var vcr:GrainFilter;

    var canPress:Bool = true;

    override function create()
    {
        camFollow = new FlxSprite().makeGraphic(1, 1, 0x00FFFFFF);
        camFollow.screenCenter(X);
        add(camFollow);
        FlxG.camera.follow(camFollow, null, 1);

        file = Json.parse(Paths.getTextFromFile(PathsL.data("log.json")));

        textGrp = new FlxTypedGroup<FlxTypeText>();
        add(textGrp);

        startDialogue();

        if (ClientPrefs.shaders)
        {
            var toAdd:Array<BitmapFilter> = [];
            vcr = new GrainFilter();
            var filter1:ShaderFilter = new ShaderFilter(vcr.shader);
            toAdd.push(filter1);
            FlxG.camera.setFilters(toAdd);
        }

        FlxG.sound.playMusic(PathsL.music("static"), 1, true);

        super.create();
    }

    var ended:Bool = false;

    override function update(elapsed:Float)
    {
        if (ClientPrefs.shaders)
        {
            vcr.update(elapsed);
        }
        if (controls.ACCEPT && ended && canPress)
        {
            if (curLine != 24)
            {
                startDialogue();
                ended = false;
                canPress = false;
                new FlxTimer().start(0.001, function(tmr:FlxTimer)
                {
                    canPress = true;
                });
            }
            else
            {
                close();
            }
        }
        if (controls.ACCEPT && !ended && canPress)
        {
            ended = true;
            textGrp.members[curLine].skip();
            canPress = false;
            new FlxTimer().start(0.001, function(tmr:FlxTimer)
            {
                canPress = true;
            });
        }
        super.update(elapsed);
    }

    function startDialogue()
    {
        curLine += 1;
        var text:FlxTypeText = new FlxTypeText(25, 0, FlxG.width - 25, "", 24);
        text.font = Paths.font("vcr.ttf");
        text.color = Std.parseInt(file.lines[curLine].textColour);
        text.sounds = [FlxG.sound.load(PathsL.sound('dialogue'), 0.6)];
        if (ClientPrefs.flashing)
        {
            text.showCursor = true;
        }
        text.screenCenter(Y);
        if (textGrp.length > 0)
        {
            if (ClientPrefs.flashing)
                textGrp.members[textGrp.length - 1].showCursor = false;

            text.y = textGrp.members[textGrp.length - 1].y;
            text.y += 150;
        }
        textGrp.add(text);

        if (curLine != 24)
        {
            FlxTween.tween(camFollow, {y: text.y}, 1, {ease: FlxEase.sineInOut});
        }
        else
        {
            camFollow.y = text.y;
            text.screenCenter(X);
            for (i in 0...textGrp.length - 1)
            {
                textGrp.members[i].visible = false;
            }
            FlxG.sound.music.volume = 5;
        }

        text.resetText(file.lines[curLine].name + ": " + file.lines[curLine].text);
		text.start(0.04, true);
		text.completeCallback = function() {
			ended = true;
		};
    }

    function close()
    {
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.fadeOut(0, 1);
		}
		FlxG.camera.fade(0xFF000000, 1, false, function()
		{
            if (FlxG.sound.music != null)
			    FlxG.sound.music.stop();
                
			MusicBeatState.switchState(new SoundTestState());
		});
    }
}

class PathsL
{
	public static function image(key:String)
	{
		return "assets/side-stories/images/" + key + ".png"; 
	}

	public static function sound(key:String)
	{
		return "assets/side-stories/sounds/" + key + ".ogg";
	}

	public static function music(key:String)
	{
		return "assets/side-stories/music/" + key + ".ogg";
	}

	public static function data(key:String)
	{
		return "side-stories/data/" + key;
	}
}