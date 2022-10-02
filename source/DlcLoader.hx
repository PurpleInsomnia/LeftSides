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
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import openfl.Assets;
import sys.FileSystem;
import flixel.util.FlxTimer;

class DlcLoader extends MusicBeatState
{
	var bg:FlxSprite;
	var loadingBar:FlxSprite;

	var loadingText:FlxText;

	var percent:Int = 0;

	override public function create()
	{

		percent = 0;

		trace(DlcMenuState.modsList.length);

		bg = new FlxSprite().loadGraphic(Paths.image('dlcBG'));
		bg.alpha = 0.5;
		add(bg);

		loadingBar = new FlxSprite();
		loadingBar.loadGraphic(Paths.image('dlcLoadBar'));
		loadingBar.setGraphicSize(Std.int(loadingBar.width), 50);
		loadingBar.x = -1280;
		loadingBar.y = 720 - loadingBar.height;
		add(loadingBar);

		loadingText = new FlxText(0, 0, 'LOADING DLC FILES.... ' + percent + '%', 24);
		loadingText.y = loadingBar.y - loadingText.height;
		add(loadingText);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startLoading();
		});

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (percent <= 99)
			loadingBar.x = -1280 * (percent / 100) * -1 + -1280;
		// I think this should make it accurate lmfao
		
		super.update(elapsed);
	}

	function startLoading()
	{
		var ranNum:Int = FlxG.random.int(10, 25);
		// FlxTween.tween(loadingBar, {x: 0}, ranNum, {ease: FlxEase.sineOut});
		continueLoading();
	}

	function continueLoading()
	{
		var ranNum:Float = FlxG.random.float(0.05 * DlcMenuState.modsList.length, 0.25 * DlcMenuState.modsList.length);
		var num2:Int = FlxG.random.int(1, 5);
		new FlxTimer().start(Std.int(ranNum), function(tmr:FlxTimer)
		{
			percent = percent + num2;
			if (percent >= 100)
			{
				doneText();
			}
			else
			{
				updateText(percent);
				continueLoading();
			}
		});
	}

	function updateText(num:Int)
	{
		loadingText.text = 'LOADING DLC FILES... ' + num + '%';
	}

	function doneText()
	{
		loadingBar.x = 0;
		loadingText.text = 'LOADING COMPLETED!!! 100%';
		MusicBeatState.switchState(new MainMenuState());
	}
}