package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flash.display.BlendMode;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.ui.FlxButton;
import editors.MasterEditorMenu;
import sys.FileSystem;

class ResultsSong extends MusicBeatState
{
	var scoreTxt:FlxText;

	public static var week:Int = 0;
	public static var curDifficulty:Int = 0;

	var ratingString:String;

	var enter:FlxSprite;

	var ratingSpr:FlxSprite;
	var ratingIcon:FlxSprite;

	var canPress:Bool = true;

	public static var song:String;

	public static var score:Int = 0;
	public static var gMiss:Int = 0;
	public static var hits:Int = 0;
	public static var misses:Int = 0;
	public static var highestCombo:Int = 0;

	public static var divNum:Int = 0;

	var rankText:FlxText;

	override public function create()
	{
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('results/bg'));
		add(bg);

		scoreTxt = new FlxText(0, 0, '', 32);
		scoreTxt.screenCenter();
		scoreTxt.alpha = 0;
		add(scoreTxt);

		if (hits > 0 && highestCombo == 0)
			scoreTxt.text = 'SONG SCORE: ' + score + '\n(NOTES HIT: ' + hits + ')\n(NOTES MISSED: ' + misses +')\n[PERFECT COMBO]\n...';
		else
			scoreTxt.text = 'SONG SCORE: ' + score + '\n(NOTES HIT: ' + hits + ')\n(NOTES MISSED: ' + misses +')\nHIGHEST COMBO: ' + highestCombo + '\n...';
		scoreTxt.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.screenCenter(X);
		scoreTxt.y = (0 + scoreTxt.height) + 15;

		rankText = new FlxText(0, 0, 'YOUR RANK IS', 32);
		rankText.y = scoreTxt.y + scoreTxt.height;
		rankText.alpha = 0;
		rankText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rankText.screenCenter(X);
		add(rankText);


		lime.app.Application.current.window.title = "Friday Night Funkin': Left Sides";
		


		var rating:Float;

		rating = score / ((hits + misses - gMiss) * 350);

		trace(rating);

		if (rating <= 0.5)
			ratingString = 'f';
		if (rating <= 0.7 && rating >= 0.5)
			ratingString = 'd';
		if (rating <= 0.8 && rating >= 0.7)
			ratingString = 'c';
		if (rating <= 0.9 && rating >= 0.8)
			ratingString = 'b';
		if (rating <= 0.99 && rating >= 0.9)
			ratingString = 'a';
		if (rating >= 1)
			ratingString = 's';

		FlxG.sound.playMusic(Paths.music('results'), 0.7);

		if (PlayState.encoreMode)
			Highscore.saveEncoreSongRank(song, curDifficulty, ratingString);
		else
			Highscore.saveSongRank(song, curDifficulty, ratingString);

		// actually making the sprites instead of doing math lmao.

		var didIt:FlxSprite = new FlxSprite().loadGraphic(Paths.image('results/youDidItFP'));
		didIt.y += -30;
		add(didIt);

		enter = new FlxSprite().loadGraphic(Paths.image('results/enter'));
		enter.y += 720;
		add(enter);

		if (ratingString == null)
			ratingString = 'bot';

		ratingSpr = new FlxSprite().loadGraphic(Paths.image('results/ratings/' + ratingString));
		ratingSpr.y = 720;
		add(ratingSpr);

		ratingIcon = new FlxSprite().loadGraphic(Paths.image('results/ratings/icon-' + ratingString));
		ratingIcon.y = -720;
		add(ratingIcon);

		FlxTween.tween(didIt, {y: 0}, 1, {ease: FlxEase.elasticOut});

		FlxG.sound.play(Paths.sound('alert'));

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			calculateShow();
		});

		new FlxTimer().start(34.28, function(tmr:FlxTimer)
		{
			if (canPress)
			{
				endBs();
			}
		});

		super.create();
	}

	override public function update(elapsed:Float)
	{
		if (canPress)
		{
			if (controls.ACCEPT)
			{
				endBs();
			}
		}

		super.update(elapsed);
	}

	public function endBs()
	{
		canPress = false;
		FlxG.sound.play(Paths.sound('select'));

		FlxG.sound.music.stop();

		FlxTween.tween(ratingSpr, {y: -720, alpha: 0}, 1, {ease: FlxEase.sineIn});
		FlxTween.tween(ratingIcon, {y: 720, alpha: 0}, 1, {ease: FlxEase.sineIn});

		FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
		{
			var check:Bool = StateManager.check("freeplay");
			if (!check)
			{
				MusicBeatState.switchState(new FunnyFreeplayState());
			}
		});
	}

	public function calculateShow()
	{
		FlxTween.tween(scoreTxt, {alpha: 1}, 1, {ease: FlxEase.elasticOut});
		FlxTween.tween(rankText, {alpha: 1}, 1, {ease: FlxEase.elasticOut});

		FlxG.sound.play(Paths.sound('alert'));

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			showRating();
		});
	}

	public function showRating()
	{
		switch (ratingString)
		{
			case 'f':
				FlxG.sound.play(Paths.sound('shitScore'));
			case 'd':
				FlxG.sound.play(Paths.sound('badScore'));
			case 's':
				FlxG.sound.play(Paths.sound('sRankSound'));
			case 'a' | 'b' | 'c':
				FlxG.sound.play(Paths.sound('alert'));
		}

		FlxTween.tween(ratingSpr, {y: 30}, 1, {ease: FlxEase.elasticOut});
		FlxTween.tween(ratingIcon, {y: 30}, 1, {ease: FlxEase.elasticOut});

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			canPress = true;
			FlxTween.tween(enter, {y: 0}, 1, {ease: FlxEase.elasticOut});
		});
	}
}