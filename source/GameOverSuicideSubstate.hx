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

class GameOverSuicideSubstate extends MusicBeatSubstate
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
	public static var deathSoundName:String = 'monster/bf_kills_himself';
	public static var loopSoundName:String = 'gameOverSuicide';
	public static var endSoundName:String = 'gameOverEndSuicide';

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

		var death:FlxSprite = new FlxSprite().loadGraphic(Paths.image('bfSuicide'));
		death.scrollFactor.set();
		death.screenCenter();
		add(death);

		red = new FlxSprite().loadGraphic(Paths.image('redVG'));
		red.screenCenter();
		red.scrollFactor.set();
		red.alpha = 0;
		add(red);

		jumpscareSpr = new FlxSprite().loadGraphic(Paths.image('bozo'));
		jumpscareSpr.visible = false;
		jumpscareSpr.scrollFactor.set();
		add(jumpscareSpr);

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
				dumbTimer();
				doLoop();
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

		if (curBeat % 8 == 0)
		{
		}
		if (curBeat % 8 == 3)
		{
			FlxTween.tween(red, {alpha: 0}, 1);
		}
		//FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function coolStartDeath(?volume:Float = 1):Void
	{
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
		add(new Acheivement(19, "You did it\nYou Killed Yourself", "spookyGlitch"));
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			#if desktop
			remove(countdownText);
			#end
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 7, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			lePlayState.callOnLuas('onGameOverConfirm', [true]);
		}
	}

	public function jumpscare()
	{
		#if desktop
		canPress = false;
		FlxG.switchState(new ErrorScreenState());
		#end
	}

	public function dumbTimer()
	{
		#if desktop
		countdownText = new FlxText(0, 0, '10', 32);
		countdownText.screenCenter(X);
		countdownText.scrollFactor.set();
		add(countdownText);
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			countdownText.text = '9';
			countdownText.screenCenter(X);
		});
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			countdownText.text = '8';
			countdownText.screenCenter(X);
		});
		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			countdownText.text = '7';
			countdownText.screenCenter(X);
		});
		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			countdownText.text = '6';
			countdownText.screenCenter(X);
		});
		new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			countdownText.text = '5';
			countdownText.color = FlxColor.RED;
			FlxG.sound.play(Paths.sound('monster/timerWarn'));
			countdownText.screenCenter(X);
		});
		new FlxTimer().start(6, function(tmr:FlxTimer)
		{
			countdownText.text = '4';
			countdownText.screenCenter(X);
		});
		new FlxTimer().start(7, function(tmr:FlxTimer)
		{
			countdownText.text = '3';
			countdownText.screenCenter(X);
		});
		new FlxTimer().start(8, function(tmr:FlxTimer)
		{
			countdownText.text = '2';
			countdownText.screenCenter(X);
		});
		new FlxTimer().start(9, function(tmr:FlxTimer)
		{
			countdownText.text = '1';
			countdownText.screenCenter(X);
		});
		new FlxTimer().start(10, function(tmr:FlxTimer)
		{
			countdownText.text = '0';
			countdownText.screenCenter(X);
		});
		new FlxTimer().start(11, function(tmr:FlxTimer)
		{
			remove(countdownText);
			if (!isEnding)
			{
				jumpscare();
			}
		});
		#end
	}

	function doLoop()
	{
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			FlxTween.tween(red, {alpha: 1}, 0.5);
		});
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxTween.tween(red, {alpha: 0}, 0.5);
			doLoop();
		});
	}
}
