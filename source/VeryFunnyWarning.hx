package;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

class VeryFunnyWarning extends MusicBeatState
{
	var string = 'Hey! Thanks for taking time out of your day to play this mod!\n \nThis mod might not be for people who are sensitive to Blood, "Funny" (scary) Jpegs popping on Screen (so a jumpscare). This mod might also not be for you if you are sensitive to topics such as Suicide, Self Harm and/or Abuse.\n \nIf you need to, there is a "Content Warning" option in the Options Menu. (And if you want to) There is also a swear filter that you can turn on/off in the Options Menu.\nFLASHING LIGHTS are in this mod! HOWEVER they are turned off by default (you can turn it back on in the Options Menu)\n \nOh! And there are fourth wall breaks that involve YOUR' + " PC'S USERNAME!! You can turn this off in the options menu\n \nAlso if you are trying to avoid age restriction, mabye don't show the death screen in" + '"Free Me",,\n \nEnjoy! (Press Enter To Continue)\n- PurpleInsomnia (Director)\n';

	var canPress = true;

	var text:FlxText;

	override function create()
	{

		text = new FlxText(0, 0, FlxG.width, string, 24);
		text.setFormat(Paths.font("eras.ttf"), 24, 0xFFFFFFFF, CENTER, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		add(text);

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && canPress)
		{
			canPress = false;
			text.visible = false;
			FlxG.sound.play(Paths.sound('saveFile/create'));
			FlxG.save.data.warned = true;
			FlxG.save.flush();
			FlxG.camera.flash(0xFFFFFFFF, 1);
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new TitleState());
			});
		}

		super.update(elapsed);
	}
}