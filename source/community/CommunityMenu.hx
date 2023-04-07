package community;

import flixel.graphics.FlxGraphic;
import flixel.ui.FlxButton;
import flixel.system.FlxSound;
import openfl.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

import flash.media.Sound;

using StringTools;

class CommunityMenu extends MusicBeatState
{
    public var curSelected:Int = 0;
    public var canPress:Bool = false;
    var bg:FlxSprite;
    var camFollow:FlxSprite;
    public var slider:CommunitySlider = null;
    var images:Array<FlxSprite> = [];
    var text:FlxText;

    var curSound:FlxSound = null;

    override function create()
    {
        canPress = true;

        // just in case.
        //CommunitySong.loadSongs();

        if (CommunitySong.accessed)
        {
            FlxG.sound.music.stop();

            camFollow = new FlxSprite().makeGraphic(1, 1, 0xFFFFFFFF);
            camFollow.screenCenter();
            add(camFollow);

            FlxG.camera.follow(camFollow, null, 1);

            add(new GridBackdrop());

            var rgbThingy:Array<Int> = CommunitySong.files[curSelected].color;
            
            bg = new FlxSprite().makeGraphic(1280, 720, 0xFFFFFFFF);
            bg.blend = BlendMode.DARKEN;
            bg.scrollFactor.set(0, 0);
            bg.color = FlxColor.fromRGB(rgbThingy[0], rgbThingy[1], rgbThingy[2]);
            add(bg);

            for (i in 0...CommunitySong.songs.length)
            {
                var songImage:FlxSprite = new FlxSprite().loadGraphic(Paths.getFlxGraphic("community/images/" + CommunitySong.songs[i] + ".png"));
                songImage.x += 1280 * i;
                add(songImage);
                images.push(songImage);
            }

            var spikes:FlxSprite = new FlxSprite().loadGraphic('community/spikes.png');
		    spikes.scrollFactor.set(0, 0);
		    add(spikes);
		    FlxTween.tween(spikes, {x: -1280}, 5, {type: LOOPING});

            text = new FlxText(0, 0, FlxG.width, 'Press SPACE to listen to the current song\nPress ENTER to download the Inst, Voices & Charting Info.', 24);
		    text.font = Paths.font('eras.ttf');
            text.alignment = CENTER;
            text.borderStyle = FlxTextBorderStyle.OUTLINE;
            text.borderColor = 0xFF000000;
		    text.scrollFactor.set(0, 0);
            text.updateHitbox();
            text.y = (FlxG.height - 64) - Std.int(text.height);
		    add(text);

            var button:FlxButton = new FlxButton(0, 0, "", function()
            {
                canPress = false;
                if (curSound != null)
                {
                    if (curSound.playing)
                    {
                        curSound.stop();
                    }
                }
                MusicBeatState.switchState(new CommunityContenders());
            });
            button.loadGraphic("community/poll.png", true, 128, 64);
            button.screenCenter(X);
            button.y = 10;
            add(button);

            change(0);
        }
        else
        {
            canPress = false;
            add(new FlxSprite().loadGraphic("community/no.png"));
        }
        super.create();
    }

    override function update(elapsed:Float)
    {
        if (canPress)
        {
            if (controls.UI_RIGHT_P)
            {
                change(-1);
            }
            if (controls.UI_LEFT_P)
            {
                change(1);
            }
            if (FlxG.keys.justPressed.SPACE)
            {
                if (slider != null)
                {
                    slider.end();
                }
                slider = new CommunitySlider(CommunitySong.files[curSelected].artist, CommunitySong.files[curSelected].title, this);
                add(slider);

                if (curSound != null)
                {
                    if (curSound.playing)
                    {
                        curSound.stop();
                    }
                }
                curSound = FlxG.sound.load(Sound.fromFile("community/songs/" + CommunitySong.songs[curSelected] + ".wav"), 1, false);
                curSound.play();
            }
            if (FlxG.keys.justPressed.ENTER)
            {
                // downloads assets.
                canPress = false;
                CommunitySong.download(CommunitySong.songs[curSelected], function()
                {
                    lime.app.Application.current.window.alert(CommunitySong.files[curSelected].downloadMessage, "Download Success!");
                    canPress = true;
                }, this);
            }
            text.screenCenter(X);
        }
        if (controls.BACK)
        {
            canPress = false;
            if (curSound != null)
            {
                if (curSound.playing)
                {
                    curSound.stop();
                }
            }
            FlxG.sound.play(Paths.sound("cancelMenu"));
            MusicBeatState.switchState(new TitleScreenState());
        }
        super.update(elapsed);
    }

    var moveTween:FlxTween = null;
    var colorTween:FlxTween = null;
    function change(huh:Int)
    {
        if (huh != 0)
        {
            FlxG.sound.play(Paths.sound("scrollMenu"));
        }

        curSelected += huh;

        if (curSelected >= CommunitySong.songs.length)
        {
            curSelected = 0;
        }
        if (curSelected < 0)
        {
            curSelected = CommunitySong.songs.length - 1;
        }

        if (moveTween != null)
        {
            moveTween.cancel();
        }
        moveTween = FlxTween.tween(camFollow, {x: images[curSelected].getGraphicMidpoint().x, y: images[curSelected].getGraphicMidpoint().y}, 1, {ease: FlxEase.sineInOut});
        if (colorTween != null)
        {
            colorTween.cancel();
        }
        var rgbThingy:Array<Int> = CommunitySong.files[curSelected].color;
        colorTween = FlxTween.color(bg, 1, bg.color, FlxColor.fromRGB(rgbThingy[0], rgbThingy[1], rgbThingy[2]));
    }
}

class CommunitySlider extends FlxTypedGroup<Dynamic>
{
    var parent:CommunityMenu = null;

    public function new(artist:String, title:String, parent:CommunityMenu)
    {
        super();

        this.parent = parent;

        var songInfo = new FlxTypedGroup<FlxSprite>();
		add(songInfo);

		var songNameText = new FlxText(10, 200, 0, "", 32);
		songNameText.setFormat(Paths.font('eras.ttf'), 32, FlxColor.WHITE, LEFT);
		songNameText.text = title;
        songNameText.y -= 16;
        songNameText.scrollFactor.set(0, 0);
        songNameText.updateHitbox();

		var artistNameText = new FlxText(10, 200, 0, "", 24);
		var daColour:Int = 0xFFFFFFFF;
		switch (CommunitySong.files[parent.curSelected].artist)
		{
			case "purpleinsomnia" | "PurpleInsomnia" | "PURPLEINSOMNIA":
				daColour = 0xFFC100FF;
		}
		artistNameText.setFormat(Paths.font('eras.ttf'), 24, daColour, LEFT);
		artistNameText.text = CommunitySong.files[parent.curSelected].artist;
        artistNameText.y += 16;
        artistNameText.scrollFactor.set(0, 0);
        artistNameText.updateHitbox();

        var songIcon:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.getFlxGraphic(CommunitySong.songIcons[parent.curSelected]));

		if (songNameText.width > artistNameText.width)
		{
			var blackInfo:FlxSprite = new FlxSprite(0, 150).makeGraphic(1, 150, 0xFF000000);
			blackInfo.setGraphicSize(Std.int(songNameText.width + 305), 150);
            blackInfo.updateHitbox();
            blackInfo.scrollFactor.set(0, 0);
			songInfo.add(blackInfo);

            songIcon.x = Std.int(blackInfo.width - 150);
            songIcon.y = 150;
            songIcon.scrollFactor.set(0, 0);
		}
		else
		{
			var blackInfo:FlxSprite = new FlxSprite(0, 150).makeGraphic(1, 150, 0xFF000000);
			blackInfo.setGraphicSize(Std.int(songNameText.width + 305), 150);
            blackInfo.updateHitbox();
            blackInfo.scrollFactor.set(0, 0);
			songInfo.add(blackInfo);

            songIcon.x = Std.int(blackInfo.width - 150);
            songIcon.y = 150;
            songIcon.scrollFactor.set(0, 0);
		}

		songInfo.add(songNameText);
		songInfo.add(artistNameText);
        songInfo.add(songIcon);

        songInfo.forEach(function(spr:FlxSprite)
        {
            spr.x -= 600;
            FlxTween.tween(spr, {x: spr.x + 600}, 1, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
            {
                FlxTween.tween(spr, {x: spr.x - 600}, 1, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
                {
                    end();
                }, startDelay: 1});
            }});
        });
    }

    public function end()
    {
        parent.remove(this);
        parent.slider = null;
        kill();
    }
}