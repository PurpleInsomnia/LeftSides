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
import Alphabet;
import flixel.util.FlxColor;
import lime.app.Application;

using StringTools;

class WhatsNewState extends MusicBeatState
{

	var changeLogGroup:FlxTypedGroup<Alphabet>;

	var changeLogFile:Array<String>;

	private static var curSelected:Int = 0;

	var changeLogText:Alphabet;

	override function create()
	{
		FlxG.sound.music.stop();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		// Yes this is a copy of MainMenuState, am I ashamed of it? No.

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('coolMenuBG'));
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		FlxG.sound.playMusic(Paths.music('changelog'));

		changeLogGroup = new FlxTypedGroup<Alphabet>();
		add(changeLogGroup);

		curSelected = 0;

		changeLogFile = CoolUtil.coolTextFile('Changelog.txt');
		for (i in 0...changeLogFile.length)
		{
			changeLogText = new Alphabet(0, (70 * i) + 30, changeLogFile[i], true, false);
			changeLogText.isMenuItem = true;
			changeLogText.screenCenter(X);
			changeLogText.forceX = changeLogText.x;
			// changeLogText.y += (100 * (i - (changeLogText.length / 2))) + 50;
			changeLogText.targetY = i;
			changeLogGroup.add(changeLogText);
		}
		

		super.create();
	}


	override function update(elapsed:Float)
	{

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}


		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.sound.music.stop();
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = changeLogFile.length - 1;
		if (curSelected >= changeLogFile.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in changeLogGroup.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.9;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}