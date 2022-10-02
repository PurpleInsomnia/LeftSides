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
import flixel.FlxCamera;
import flixel.text.FlxText;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxPoint;
	var camFollowPos:FlxObject;
	var updateCamera:Bool = false;

	var stageSuffix:String = "";

	var lePlayState:PlayState;

	var stupidCamera:FlxCamera;

	public static var characterName:String = 'bf-blueballed';
	public static var deathSoundName:String = 'fnf_loss_sfx';
	public static var loopSoundName:String = 'gameOver';
	public static var endSoundName:String = 'gameOverEnd';

	public static var timeString:String;

	public static var string:Array<String> = [
		'Just keep up man...',
		"Don't smash your keyboard!",
		'Ok, wow.',
		'11/10 gameplay',
		'Mabye Stop Sucking?',
		'This says a lot about our society'
	];

	public static var iconName:String;

	public static function setStrings(thing:Array<String>, ?icon:String)
	{
		if (icon != null)
		{
			iconName = icon;
		}
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

	public static function resetVariables() {
		characterName = 'bf-blueballed';
		deathSoundName = 'fnf_loss_sfx';
		loopSoundName = 'gameOver';
		endSoundName = 'gameOverEnd';
	}

	public function new(x:Float, y:Float, camX:Float, camY:Float, state:PlayState)
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

		bf = new Boyfriend(x, y, characterName);
		add(bf);

		camFollow = new FlxPoint(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y);

		FlxG.sound.play(Paths.sound(deathSoundName));
		Conductor.changeBPM(100);
		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');

		var exclude:Array<Int> = [];

		camFollowPos = new FlxObject(0, 0, 1, 1);
		camFollowPos.setPosition(FlxG.camera.scroll.x + (FlxG.camera.width / 2), FlxG.camera.scroll.y + (FlxG.camera.height / 2));
		add(camFollowPos);
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

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			if(bf.animation.curAnim.curFrame == 12)
			{
				FlxG.camera.follow(camFollowPos, LOCKON, 1);
				updateCamera = true;
			}

			if (bf.animation.curAnim.finished)
			{
				coolStartDeath();
				bf.startedDeath = true;
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

		if (bf.startedDeath)
			bf.playAnim('deathLoop');

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
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music(endSoundName));
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
		var ranNum:Int = FlxG.random.int(0, string.length - 1);

		var text:FlxText = new FlxText(0, 90, FlxG.width, string[ranNum], 36);
		text.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.cameras = [stupidCamera];
		text.screenCenter(X);
		add(text);

		var icon:HealthIcon = new HealthIcon(iconName);
		icon.scale.set(0.6, 0.6);
		icon.y -= 10;
		icon.cameras = [stupidCamera];
		icon.screenCenter(X);
		add(icon);
		icon.animation.curAnim.curFrame = 2;

		var text2:FlxText = new FlxText(0, FlxG.height - 40, 'You HAD ' + timeString + ' left.', 32);
		text2.color = FlxColor.YELLOW;
		text2.font = Paths.font('vcr.ttf');
		text2.y = text.y + text.height;
		text2.cameras = [stupidCamera];
		text2.screenCenter(X);
		add(text2);
	}
}
