package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;

class GameOverSonicSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var gameOverSpr:FlxSprite;

	var stageSuffix:String = "";

	var lePlayState:PlayState;

	private static var curDifficulty:Int = 1;

	var exe:Int = 0;

	var isStarted:Bool = false;

	public static var characterName:String = 'bf-sonic-anims';
	public static var deathSoundName:String = 'sonicDEATH';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEndSonic';

	public static function resetVariables() {
		characterName = 'bf-sonic-anims';
		deathSoundName = 'sonicDEATH';
		loopSoundName = 'gameOverSonic';
		endSoundName = 'gameOverEndSonic';
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
	{
		state.setOnLuas('inGameOver', true);
		lePlayState = state;
		super();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, characterName);
		add(bf);
		bf.screenCenter(X);

		gameOverSpr = new FlxSprite().loadGraphic(Paths.image('sonic/gameOver'));
		gameOverSpr.visible = false;
		gameOverSpr.screenCenter();
		add(gameOverSpr);

		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('dies');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);

		// FlxG.camera.follow(camFollowPos, LOCKON, 1);
		// updateCamera = true;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lePlayState.callOnLuas('onUpdate', [elapsed]);
		if(updateCamera) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 0.6, 0, 1);
			camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));
		}

		if (controls.ACCEPT)
		{
			if (exe != 5)
				endBullshit();
		}

		if (controls.BACK)
		{
			if (exe != 5)
			{
				FlxG.sound.music.stop();
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;

				if (PlayState.isStoryMode)
				{
					MusicBeatState.switchState(new StoryMenuState());
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
				}
				else
				{
					MusicBeatState.switchState(new FreeplayState());
					FlxG.sound.playMusic(Paths.music('freeplay'));
				}

				lePlayState.callOnLuas('onGameOverConfirm', [false]);
			}
		}

		if (bf.animation.curAnim.name == 'dies')
		{
			if (bf.animation.curAnim.finished)
			{
				if (exe != 5)
				{
					if (!isStarted)
					{
						coolStartDeath();
						bf.startedDeath = true;
						lePlayState.callOnLuas('gameOverLoop', []);
					}
				}
				else
				{
					if (PlayState.curSongShit != 'too-slow')
						tooSlow();
					else
					{
						coolStartDeath();
						bf.startedDeath = true;
						lePlayState.callOnLuas('gameOverLoop', []);
					}
				}
			}
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
		isStarted = true;
		gameOverSpr.visible = true;
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
	}


	function tooSlow()
	{
		var stupidStatic:FlxSprite = new FlxSprite();
		stupidStatic.frames = Paths.getSparrowAtlas('sonic/static');
		stupidStatic.antialiasing = ClientPrefs.globalAntialiasing;
		stupidStatic.animation.addByPrefix('idle', 'idle', 24, true);
		stupidStatic.setGraphicSize(1280, 720);
		stupidStatic.animation.play('idle');
		stupidStatic.screenCenter();

		add(stupidStatic);

		FlxG.sound.play(Paths.sound('exe/staticJump'));

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			remove(stupidStatic);
		});

		var songLowercase:String = Paths.formatToSongPath('too-slow');
		var poop:String = 'normal';
		#if MODS_ALLOWED
		if(!sys.FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !sys.FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
		#else
		if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
		#end
			poop = songLowercase;
			curDifficulty = 1;
			trace('Couldnt find file');
		}
		trace(poop);

		PlayState.SONG = Song.loadFromJson(poop, songLowercase);
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 1;

		LoadingState.loadAndSwitchState(new PlayState());
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.WHITE, 2.3, false, function()
				{
					MusicBeatState.resetState();
				});
			});
			lePlayState.callOnLuas('onGameOverConfirm', [true]);
		}
	}
}
