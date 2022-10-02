import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import options.OptionsState;

using StringTools;

class SetControlsSubstate extends MusicBeatSubstate
{
	var bg:FlxSprite;

	var canPress:Bool = false;

	public function new()
	{
		super();

		FlxG.sound.play(Paths.sound('alert'));

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0.6;
		bg.scrollFactor.set();
		add(bg);

		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('controlAlert'));
		spr.scrollFactor.set();
		spr.alpha = 0;
		spr.y = 720;
		add(spr);

		FlxTween.tween(spr, {alpha: spr.alpha + 1, y: spr.y - 720}, 1, {ease: FlxEase.elasticOut});

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			canPress = true;
		});
	}

	override function update(elapsed:Float)
	{
		if(controls.ACCEPT && canPress) {
			FlxG.sound.play(Paths.sound('select'), 1);
			close();
			canPress = false;
			ClientPrefs.setControls = true;
			ClientPrefs.saveSettings();
			ClientPrefs.loadPrefs();
			SelectSongTypeState.freeplay = false;
			MusicBeatState.switchState(new SelectSongTypeState());

		}
		if (controls.BACK && canPress)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
			canPress = false;
			ClientPrefs.setControls = true;
			ClientPrefs.saveSettings();
			ClientPrefs.loadPrefs();
			MusicBeatState.switchState(new options.OptionsState());
		}
		super.update(elapsed);
	}
}