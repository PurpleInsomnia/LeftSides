package community;

import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

using StringTools;

class CommunityContenders extends MusicBeatState
{
    override function create()
    {
        add(new FlxSprite("community/pollBG.png"));

        var string:String = "Current Contenders:\n" + CommunitySong.contenderFile.songs[0] + "\n" + CommunitySong.contenderFile.songs[1] + "\n" + CommunitySong.contenderFile.songs[2] + "\n" + CommunitySong.contenderFile.songs[3] + "\n \nLast Month's Winner(s): " + CommunitySong.contenderFile.lastWinner + "\nPoll Status: " + CommunitySong.contenderFile.status.toUpperCase();
        var text:FlxText = new FlxText(64, 144, 640, string, 32);
        text.font = Paths.font("eras.ttf");
        text.borderStyle = FlxTextBorderStyle.OUTLINE;
        text.borderColor = 0xFF000000;
        add(text);

        var linkButton:FlxButton = new FlxButton(0, 0, "", function()
        {
            CoolUtil.browserLoad(CommunitySong.contenderFile.link);
        });
        linkButton.loadGraphic("community/linkButton.png", true, 320, 320);
        linkButton.screenCenter(Y);
        linkButton.x = 640 + 160;
        add(linkButton);

        super.create();
    }

    override function update(elapsed:Float)
    {
        if (controls.BACK)
        {
            FlxG.sound.play(Paths.sound("cancelMenu"));
            MusicBeatState.switchState(new CommunityMenu());
        }
        super.update(elapsed);
    }
}