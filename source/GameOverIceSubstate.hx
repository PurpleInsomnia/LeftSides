package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.text.FlxText;
import flixel.FlxSprite;

class GameOverIceSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var countdownText:FlxText;

	var stageSuffix:String = "";

	var lePlayState:PlayState;

	var red:FlxSprite;
	var jumpscareSpr:FlxSprite;
	var canPress:Bool = true;

	public static var characterName:String = 'bf';
	public static var deathSoundName:String = 'monster/bf_freezes';
	public static var loopSoundName:String = 'gameOverIce';
	public static var endSoundName:String = 'gameOverIceEnd';

	public static function resetVariables() {
		characterName = 'bf-blueballed';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	public function new(state:PlayState)
	{
		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		FlxG.camera.zoom = 1;

		Conductor.songPosition = 0;

		// bf = new Boyfriend(x, y, characterName);
		// add(bf);

		var death:FlxSprite = new FlxSprite().loadGraphic(Paths.image('monster/iced'));
		death.scrollFactor.set();
		death.screenCenter();
		add(death);

		var stupidStatic:FlxSprite = new FlxSprite();
		stupidStatic.frames = Paths.getSparrowAtlas('static');
		stupidStatic.antialiasing = ClientPrefs.globalAntialiasing;
		stupidStatic.animation.addByPrefix('idle', 'idle', 24, true);
		stupidStatic.animation.play('idle');
		stupidStatic.scrollFactor.set();
		stupidStatic.screenCenter();

		add(stupidStatic);

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);

		// bf.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		new FlxTimer().start(3.42, function(tmr:FlxTimer)
		{
			var startedDeath:Bool = false;
			if (!startedDeath)
			{
				coolStartDeath();
				startedDeath = true;
				lePlayState.callOnLuas('gameOverLoop', []);
			}
		});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// FlxG.camera.x = red.x;
		// FlxG.camera.y = red.y;

		lePlayState.callOnLuas('onUpdate', [elapsed]);

		if (controls.ACCEPT && canPress)
		{
			endBullshit();
		}

		if (controls.BACK && canPress)
		{
			FlxG.sound.music.stop();
			PlayState.deathCounter = 0;
			PlayState.seenCutscene = false;

			MusicBeatState.switchState(new NoEscapeState());

			lePlayState.callOnLuas('onGameOverConfirm', [false]);
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
		lePlayState.callOnLuas('onUpdatePost', [elapsed]);
	}

	override function beatHit()
	{
		super.beatHit();
		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			lePlayState.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
