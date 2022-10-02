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
import flixel.ui.FlxButton;

class TheShadowTalks extends MusicBeatState
{
	var talkingText:FlxText;

	var theSprite:FlxSprite;

	var okBut:FlxButton;
	var noBut:FlxButton;

	var canPress:Bool = true;

	public static var diff:Int = 1;

	override public function create()
	{
		FlxG.mouse.visible = true;

		theSprite = new FlxSprite().loadGraphic(Paths.image('talk/bgSprite'));
		theSprite.alpha = 0;
		add(theSprite);

		var eye:FlxSprite = new FlxSprite().loadGraphic(Paths.image('talk/eye'));
		add(eye);


		var username:String = 'user';
		#if desktop
		username = Sys.environment()["USERNAME"];
		#else
		username = Sys.environment()["USER"];
		#end
		talkingText = new FlxText(0, 0, 'Hello.... ' + username, 32);
		talkingText.font = Paths.font('vcr.ttf');
		talkingText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		talkingText.screenCenter(X);
		talkingText.alpha = 0;
		add(talkingText);

		okBut = new FlxButton(0, 720 - 175, null, accept);
		okBut.loadGraphic(Paths.image('talk/yes'), true, 150, 150);
		okBut.x = okBut.x + okBut.width;
		okBut.alpha = 0;
		add(okBut);

		noBut = new FlxButton(1280, 720 - 175, null, back);
		noBut.loadGraphic(Paths.image('talk/no'), true, 150, 150);
		noBut.x = noBut.x - noBut.width * 2;
		noBut.alpha = 0;
		add(noBut);

		FlxTween.tween(talkingText, {alpha: talkingText.alpha + 1}, 1, {ease: FlxEase.expoOut});
		FlxTween.tween(theSprite, {alpha: theSprite.alpha + 1}, 4, {ease: FlxEase.expoOut});

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			changeText("That blondie is asleep right now...\n...\nAnd I'm right on time for his nightmare...\n...");
		});
	}

	var isShowing:Bool = false;
	function changeText(text:String = 'No Text?')
	{
		talkingText.alpha = 0;
		talkingText.text = text;
		talkingText.screenCenter(X);

		FlxTween.tween(talkingText, {alpha: talkingText.alpha + 1}, 1, {ease: FlxEase.expoOut});

		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if(!isShowing)
			{
				isShowing = true;
				showButtons();
				changeText('I think I need a friend to\n"tag" along....\nDo you want to?\n...');
			}
		});
	}

	function showButtons()
	{
		FlxTween.tween(okBut, {alpha: okBut.alpha + 1}, 1, {ease: FlxEase.expoOut});
		FlxTween.tween(noBut, {alpha: noBut.alpha + 1}, 1, {ease: FlxEase.expoOut});
	}

	function accept()
	{
		if (canPress)
		{
			FlxG.mouse.visible = false;
			FlxG.sound.play(Paths.sound('pressWarning'));
			loadShit();
		}
	}

	function back()
	{
		if (canPress)
		{
			lime.app.Application.current.window.alert('Lets Try That Again...', 'No Going Back');
		}
	}

	function loadShit()
	{
		canPress = false;
		PlayState.isVoid = false;
		PlayState.SONG = Song.loadFromJson('nightmare', 'nightmare');
		PlayState.storyDifficulty = 1;
		// PlayState.storyWeek = 0;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			if (!ClientPrefs.contentWarnings)
				LoadingState.loadAndSwitchState(new PlayState());
			else
				MusicBeatState.switchState(new ContentWarningState(['Blood', 'Self Harm References']));
		});
	}
}