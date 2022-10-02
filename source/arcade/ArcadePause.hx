package arcade;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import Paths;
import ArcadeState;

using StringTools;

class ArcadePause extends MusicBeatSubstate
{
	var list:Array<String> = ['Resume', 'Restart', 'Exit'];

	var items:FlxTypedGroup<FlxText>;

	var canPress:Bool = true;

	var curSelected:Int = 0;

	override function create()
	{
		var blackScreen:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFF000000);
		blackScreen.alpha = 0.75;
		add(blackScreen);


		items = new FlxTypedGroup<FlxText>();
		add(items);


		for (i in 0...list.length)
		{
			var text:FlxText = new FlxText(0, 128, list[i], 64);
			text.color = 0xFFFFFFFF;
			text.ID = i;
			text.font = Paths.font('sonic-cd-menu-font.ttf');
			text.screenCenter(X);
			text.y += 128 * i;
			add(text);
		}

		canPress = true;

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (controls.UI_UP_P && canPress)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(-1);
		}

		if (controls.UI_DOWN_P && canPress)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(1);
		}

		if (controls.ACCEPT && canPress)
		{
			canPress = false;
			switch (list[curSelected])
			{
				case 'Resume':
					close();
				case 'Restart':
					ArcadePlayState.curRoom = 0;
					close();
					FlxG.sound.music.stop();
					MusicBeatState.switchState(new ArcadePlayState());
				case 'Exit':
					FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.music('arcade/menu'));
					close();
					MusicBeatState.switchState(new ArcadeState());
			}
		}

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= items.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = items.length - 0;

		items.forEach(function(spr:FlxText)
		{
			if (spr.ID == curSelected)
			{
				spr.color = 0xFF00C9FF;
			}
			else
			{
				spr.color = 0xFFFFFFFF;
			}
		});
	}
}