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

class NoIdeaState extends MusicBeatState
{
	var talkingText:FlxText;

	var theSprite:FlxSprite;

	var okBut:FlxButton;
	var noBut:FlxButton;

	var canPress:Bool = true;

	public static var diff:Int = 1;

	override public function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		FlxG.mouse.visible = true;

		theSprite = new FlxSprite().loadGraphic(Paths.image('talk/bgSprite'));
		theSprite.alpha = 0;
		add(theSprite);

		var eye:FlxSprite = new FlxSprite().loadGraphic(Paths.image('talk/eye'));
		add(eye);

		FlxG.sound.playMusic(Paths.music('monstersTheme'));

		var username:String = CoolUtil.username();
		talkingText = new FlxText(0, 0, "You have no idea what\nthose two have to bear with\nat home, " + username + '...\n...', 32);
		talkingText.font = Paths.font('vcr.ttf');
		talkingText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		talkingText.screenCenter(X);
		talkingText.alpha = 0;
		add(talkingText);

		FlxTween.tween(talkingText, {alpha: talkingText.alpha + 1}, 1, {ease: FlxEase.expoOut});
		FlxTween.tween(theSprite, {alpha: theSprite.alpha + 1}, 4, {ease: FlxEase.expoOut});

		new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			changeText("Cruel and heartbreaking events go on there.", 0);
		});
	}

	function changeText(text:String = 'No Text?', num:Int)
	{
		talkingText.alpha = 0;
		talkingText.text = text;
		talkingText.screenCenter(X);

		FlxTween.tween(talkingText, {alpha: talkingText.alpha + 1}, 1, {ease: FlxEase.expoOut});

		new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			if(num == 0)
			{
				changeText('That little blonde shit wanted to die..\nUntil she confessed her feelings.\nHe though everything would be okay...\n...', 1);
			}
			if (num == 1)
			{
				changeText('He is lying...\n...', 2);
			}
			if (num == 2)
			{
				changeText("You'll find out soon.....", 3);
			}
			if (num == 3)
			{
				FlxG.sound.music.stop();
				MusicBeatState.switchState(new TitleStateScary());
			}
		});
	}
}