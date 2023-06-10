package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.BlendMode;
import flixel.text.FlxText;
import CoolUtil.CompletionData;

class Extras extends MusicBeatState
{
	var extras:Array<String> = ["Custom DLC API", "Completion Checklist"];

	var extrasGrp:FlxTypedGroup<Alphabet>;

	var canPress:Bool = true;

	var curSelected:Int = 0;

	override function create()
	{
		canPress = true;
		FlxG.sound.playMusic(Paths.music('extraHugs'), 1, true);
		makeEverythingElse();

		super.create();
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
			var a:Alphabet = new Alphabet(0, 40, extras[i], true, false, 0.05, 0.95);
			a.screenCenter(X);
			a.y += 90 * i;
			a.ID = i;
			extrasGrp.add(a);
		}

		changeSelection(0);
	}

	override function update(elapsed:Float)
	{
		if (controls.UI_UP_P && canPress)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P && canPress)
		{
			changeSelection(1);
		}
		if (controls.ACCEPT && canPress)
		{
			canPress = false;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			switch(curSelected)
			{
				case 0:
					CoolUtil.browserLoad("https://github.com/PurpleInsomnia/LeftSides/wiki");
					canPress = true;
				case 1:
					add(new CompletionChecklistMenu(this, function()
					{
						canPress = true;
					}));
			}
		}
		if (controls.BACK && canPress)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new TitleScreenState());
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
}

class CompletionChecklistMenu extends FlxSpriteGroup
{
	public var parent:Extras = null;
	public var callback:Void->Void = null;
	public var canPress:Bool = true;

	public function new(parent:Extras, callback:Void->Void)
	{
		super();

		this.parent = parent;
		this.callback = callback;

		var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFF000000);
		bg.alpha = 0.5;
		add(bg);

		var box:FlxSprite = new FlxSprite().makeGraphic(980, 460, 0xFF000000);
		box.screenCenter();
		add(box);

		var data:CompletionData = CoolUtil.getCompletionStatus();

		var fullAssString:String = "Songs Completed: " + data.songs + "\nWeek 'S' Ranks: "+ data.sRanks + "\nSide Stories Read: "+ data.sideStories + "\nCostumes Unlocked: " + data.costumes + "\nTrophies Unlocked: " + data.trophies;
		var dopeAssText:FlxText = new FlxText(box.x + 10, box.y + 10, 960, fullAssString, 24);
		dopeAssText.font = Paths.font("eras.ttf");
		add(dopeAssText);

		var fs:String = "Completion Status: ";
		var per:Int = Std.int((data.gotten / data.toGet100) * 100);
		fs += "" + per + "%";
		var finalText:FlxText = new FlxText(box.x + 10, (box.y + 10) + Std.int(dopeAssText.height) + 10, 960, fs, 32);
		finalText.font = Paths.font("eras.ttf");
		if (per == 100)
		{
			finalText.color = 0xFFFF9F00;
		}
		add(finalText);

		var theSillies:FlxSprite = new FlxSprite();
		theSillies.frames = Paths.getSparrowAtlas("completionSillies");
		theSillies.animation.addByPrefix("idle", "LOOP", 24, true);
		theSillies.animation.play("idle", true);
		theSillies.x = Std.int(box.x + box.width) - 300;
		theSillies.y = Std.int(box.y + box.height) - 300;
		add(theSillies);
	}

	override function update(elapsed:Float)
	{
		if (canPress)
		{
			if (FlxG.keys.justPressed.ESCAPE)
			{
				canPress = false;
				callback();
				parent.remove(this);
				kill();
			}
		}
		super.update(elapsed);
	}
}