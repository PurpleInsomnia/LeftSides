package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.BlendMode;
import flixel.text.FlxText;

class Extras extends MusicBeatState
{
	var extras:Array<String> = ['How To Unlock V', 'How To Make DLC Packs', 'Terminal', 'All Terminal Questions'];

	var extrasGrp:FlxTypedGroup<Alphabet>;

	var canPress:Bool = true;

	var curSelected:Int = 0;

	override function create()
	{
		canPress = true;
		FlxG.sound.playMusic(Paths.music('extraHugs'), 1, true);

		if (!ClientPrefs.week8Done)
		{
			hmm();
		}
		else
		{
			makeEverythingElse();
		}

		super.create();
	}

	function hmm()
	{
		var bad:FlxText = new FlxText(0, 0, "Looks Like You Need To\nDo Week 5 Before\nProceeding...\n", 32);
		bad.font = Paths.font('vcr.ttf');
		bad.screenCenter();
		add(bad);
		FlxTween.tween(bad, {alpha: 0.5}, 1, {type: PINGPONG});
	}

	function makeEverythingElse()
	{
		// lmao :)
		var pp:GridBackdrop = new GridBackdrop();
		add(pp);
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('backdropSHADER'));
		bg.screenCenter();
		bg.color.brightness = 0.5;
		bg.blend = BlendMode.DARKEN;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		extrasGrp = new FlxTypedGroup<Alphabet>();
		add(extrasGrp);

		for (i in 0...extras.length)
		{
			var a:Alphabet = new Alphabet(0, 40, extras[i], true, false);
			a.screenCenter(X);
			a.y += 90 * i;
			a.ID = i;
			extrasGrp.add(a);
		}

		changeSelection(0);
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P && canPress && ClientPrefs.week8Done)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P && canPress && ClientPrefs.week8Done)
		{
			changeSelection(1);
		}
		if (controls.ACCEPT && canPress && ClientPrefs.week8Done)
		{
			canPress = false;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			switch(extras[curSelected])
			{
				case 'How To Unlock Dmitri':
					makeFile();
					canPress = true;
				case 'Terminal':
					FlxG.sound.music.stop();
					MusicBeatState.switchState(new ContentWarningTerminalState());
				case 'All Terminal Questions':
					makeTerminalFile();
					canPress = true;
				case 'How To Make DLC Packs':
					makeDlcFile();
					canPress = true;
			}
		}
		if (controls.BACK && canPress)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new options.OptionsState());
		}
		super.update(elapsed);
	}

	function changeSelection(huh:Int)
	{
		curSelected += huh;

		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		if (curSelected >= extras.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = extras.length - 1;

		extrasGrp.forEach(function(a:Alphabet)
		{
			if (a.ID == curSelected)
				a.alpha = 1;
			else
				a.alpha = 0.75;
		});
	}

	function makeFile()
	{
		TextFile.newFile("Okay, so there is a sprite on the left side of Pico's stage (Kinda a tan colour)\nThis sprite is clickable\nupon doing so you will be brought into the void menu\nand you can play it from there\n- PurpleInsomnia <3", "How to unlock V");
	}

	function makeDlcFile()
	{
		TextFile.newFile("This might be a little complicated BUT Dlc support will be better once V3 comes out..\n\nMake a new folder in the mods folder and name it (can be anything but it will be important)\nThen inside that folder, make a file called: ''[YOUR FOLDER NAME].leftSides''\nOn the first line of this new file put in: " + '"LEFTSIDESMODFILE"' + '\nThen on the second line, type in "LS[YOUR FOLDER NAME]LS".\nFinally (on a new line), You need a number. To make this number, you need to take the ' + "folder's name " + 'count how many letters are in it, then multiply it by 2\nAfter that use a basic psych engine mod json for names I guess.' + '\nThen get a PNG image that is 850 x 450 px and title it "bg" (You must put this in the same folder as the leftSides File)', 'How to make dlc packs');
	}

	function makeTerminalFile()
	{
		TextFile.newFile("Who is Ben?\nWho is Tess?\nWhat is Monster?\nWhat is Hating Simulator?\nWhat is the Void?\nWhat are you?\nWho are the Dearests?\nWho is the oldest Dearest daughter?\nWhat did Ben do in April?\nWho am I?\nWhat is on Ben's Arm?", "ALL TERMINAL QUESTIONS");
	}
}