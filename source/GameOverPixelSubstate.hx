package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.text.FlxText;

class GameOverPixelSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	var lePlayState:PlayState;

	var stupidCamera:FlxCamera;

	var retry:FlxSprite;

	public static var characterName:String = 'bf-pixel-ded';
	public static var deathSoundName:String = 'anime/die';
	public static var loopSoundName:String = 'gameOverPixel';
	public static var endSoundName:String = 'gameOverPixelEnd';

	public static var timeString:String;

	public static var string:Array<String> = [
		'Just keep up man...',
		"Don't smash your keyboard!",
		'Ok, wow.',
		'11/10 gameplay',
		'Mabye Stop Sucking?',
		'This says a lot about our society'
	];

	public static function setStrings(thing:Array<String>)
	{
		if (thing != null)
		{
			string = thing;
		}
		else
		{
			string = [
				'Just keep up man...',
				"Don't smash your keyboard!",
				'Ok, wow.',
				'11/10 gameplay',
				'Mabye Stop Sucking?',
				'This says a lot about our society'
			];
		}
	}

	public function new(state:PlayState)
	{
		lePlayState = state;
		state.setOnLuas('inGameOver', true);
		super();

		Conductor.songPosition = 0;

		stupidCamera = lePlayState.camOther;

		if (ClientPrefs.justDont)
		{
			makeJustDont();
		}

		bf = new Boyfriend(0, 0, characterName);
		bf.scale.set(6, 6);
		bf.scrollFactor.set();
		bf.screenCenter();
		add(bf);

		retry = new FlxSprite().loadGraphic(Paths.image('anime/retry'));
		retry.alpha = 0;
		retry.scrollFactor.set();
		retry.screenCenter();
		add(retry);

		bf.playAnim('death');

		FlxG.sound.play(Paths.sound('anime/die'));

		var exclude:Array<Int> = [];
	}

	var isDone:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		lePlayState.callOnLuas('onUpdate', [elapsed]);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (controls.BACK)
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

		if (bf.animation.curAnim.name == 'death')
		{
			if (bf.animation.curAnim.finished && !isDone)
			{
				isDone = true;
				coolStartDeath();
				lePlayState.callOnLuas('gameOverLoop', []);
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
		FlxG.sound.playMusic(Paths.music(loopSoundName), volume);
		FlxTween.tween(retry, {alpha: 1}, 0.75);
		FlxTween.tween(bf, {alpha: 0}, 0.25);
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
			FlxG.camera.fade(FlxColor.WHITE, 0.5, true);
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					MusicBeatState.resetState();
				});
				stupidCamera.fade(FlxColor.BLACK, 2, false);
			});
			lePlayState.callOnLuas('onGameOverConfirm', [true]);
		}
	}

	function makeJustDont()
	{
		var ranNum:Int = FlxG.random.int(0, 5);

		var text:FlxText = new FlxText(0, 0, string[ranNum], 48);
		text.font = Paths.font('pixel.otf');
		text.cameras = [stupidCamera];
		text.screenCenter(X);
		add(text);

		var text2:FlxText = new FlxText(0, 0, 'You HAD ' + timeString + ' left.', 32);
		text2.color = FlxColor.YELLOW;
		text2.font = Paths.font('pixel.otf');
		text2.y = text.y + text.height;
		text2.cameras = [stupidCamera];
		text2.screenCenter(X);
		add(text2);
	}
}
