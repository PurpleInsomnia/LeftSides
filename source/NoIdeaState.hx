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
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import filters.*;

class NoIdeaState extends MusicBeatState
{
	var talkingText:FlxText;

	var theSprite:FlxSprite;

	var okBut:FlxButton;
	var noBut:FlxButton;

	var canPress:Bool = true;

	public static var diff:Int = 1;
	var vcr:VCR;

	override public function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		FlxG.mouse.visible = true;

		if (ClientPrefs.shaders)
		{
			var toAdd:Array<BitmapFilter> = [];
        	var tv:TV = new TV();
        	var filter1:ShaderFilter = new ShaderFilter(tv.shader);
        	vcr = new VCR();
        	var filter2:ShaderFilter = new ShaderFilter(vcr.shader);
        	toAdd.push(filter1);
        	toAdd.push(filter2);
        	FlxG.camera.setFilters(toAdd);
		}

		theSprite = new FlxSprite(0, -150).loadGraphic(Paths.image('talk/bgSprite'));
		theSprite.alpha = 0;
		add(theSprite);

		var eye:FlxSprite = new FlxSprite(0, -150).loadGraphic(Paths.image('talk/eye'));
		add(eye);

		FlxG.sound.playMusic(Paths.music('monstersTheme'));

		var username:String = CoolUtil.username();
		talkingText = new FlxText(0, 75, FlxG.width, "You have no idea what\nthose two have to bear with\nat home, " + username + '...\n...', 32);
		talkingText.font = Paths.font('vcr.ttf');
		talkingText.setFormat("VCR OSD Mono", 36, FlxColor.RED, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		talkingText.screenCenter();
		talkingText.alpha = 0;
		add(talkingText);

		FlxTween.tween(talkingText, {alpha: talkingText.alpha + 1}, 1, {ease: FlxEase.expoOut});
		FlxTween.tween(theSprite, {alpha: theSprite.alpha + 1}, 4, {ease: FlxEase.expoOut});

		new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			changeText("Cruel and heartbreaking events go on there.", 0);
		});
	}

	override function update(elapsed:Float) 
	{
		if (ClientPrefs.shaders)
		{
			vcr.update(elapsed);
		}
		super.update(elapsed);	
	}

	function changeText(text:String = 'No Text?', num:Int)
	{
		talkingText.alpha = 0;
		talkingText.text = text;
		talkingText.screenCenter();

		FlxTween.tween(talkingText, {alpha: talkingText.alpha + 1}, 1, {ease: FlxEase.expoOut});

		new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			if(num == 0)
			{
				changeText('That little blonde shit wanted to die..\nUntil she confessed her feelings.\nHe thought everything would be okay...\n...', 1);
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
				var check:Bool = StateManager.check("story-menu");
				if (!check)
				{
					MusicBeatState.switchState(new StoryMenuState());
				}
			}
		});
	}
}