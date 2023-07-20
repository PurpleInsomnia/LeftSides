package;

import GameJolt.GameJoltAPI;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;

class GitarooPause extends MusicBeatState
{
	var replayButton:FlxSprite;
	var cancelButton:FlxSprite;

	var replaySelect:Bool = false;

	public function new():Void
	{
		super();
	}

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var ohmy:FlxSprite = new FlxSprite();
		ohmy.frames = Paths.getSparrowAtlas("pause/ohmy");
		ohmy.animation.addByPrefix("ohmy", "idle", 24, true);
		add(ohmy);
		ohmy.animation.play("ohmy");

		FlxG.sound.playMusic(Paths.music("ohmy"));

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			GameJoltAPI.getTrophy(200321, "ohmy");
		});

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			MusicBeatState.switchState(new PlayState());
		}
		if (controls.BACK)
		{
			PlayState.usedPractice = false;
			PlayState.changedDifficulty = false;
			PlayState.seenCutscene = false;
			PlayState.deathCounter = 0;
			PlayState.cpuControlled = false;
			MusicBeatState.switchState(new MainMenuState());
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		super.update(elapsed);
	}
}
