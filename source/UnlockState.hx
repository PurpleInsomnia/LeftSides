package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;

class UnlockState extends MusicBeatState
{
	/* KEY: Class to get, Display Name for State, variable, value to set to

		Example for side stories:

		new UnlockState([["SideStorySelectState", "Coolswag", 0, 1]]);

		Class, Display, Story to get, value to set.

	*/
	var items:Array<Array<Dynamic>> = [];

	var canPress:Bool = false;
	var label:FlxSprite;
	var box:FlxSprite;
	var itemTxt:FlxText;

	public function new(items:Array<Array<Dynamic>>)
	{
		super();

		this.items = [];
		this.items = items;

		// place holder incase the list's length is 1
		if (items.length == 1)
			this.items.push([""]);
	}

	override function create()
	{
		canPress = false;

		var lx:Float = 0;
		label = new FlxSprite().loadGraphic(Paths.image("unlock/congrats"));
		label.screenCenter();
		lx = label.x;
		label.x = -300;
		add(label);

		var bx:Float = 0;
		box = new FlxSprite().loadGraphic(Paths.image("unlock/box"));
		box.screenCenter();
		bx = box.x;
		box.x = FlxG.width;
		add(box);

		label.y = (box.y - label.height) + 20;

		itemTxt = new FlxText(bx + 10, box.y + 40, bx + box.height, "", 24);
		itemTxt.font = Paths.font("eras.ttf");
		for (i in 0...items.length)
		{
			if (items[i][1] != null)
			{
				itemTxt.text += items[i][1] + "\n";
			}
		}
		itemTxt.text += " \nPress your ACCEPT key to continue";
		itemTxt.alpha = 0;
		add(itemTxt);

		FlxTween.tween(label, {x: lx}, 0.5);
		FlxTween.tween(box, {x: bx}, 0.5);

		FlxTween.tween(itemTxt, {alpha: 1}, 0.5, {startDelay: 0.25, onComplete: function(twn:FlxTween)
		{
			canPress = true;
		}});

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && canPress)
		{
			FlxG.sound.play(Paths.sound("confirmMenu"));
			canPress = false;
			accept();
		}
		super.update(elapsed);
	}

	public function accept()
	{
		for (i in 0...items.length)
		{
			if (items[i][0] == "SideStorySelectState")
			{
				SideStorySelectState.storyList[items[i][2]][2] = items[i][3];
				SideStorySelectState.save();
			}
			if (items[i][0] == "OptionsState")
			{
				ClientPrefs.newUnlocked = items[i][2];
				ClientPrefs.saveSettings();
			}
		}

		FlxTween.tween(label, {x: FlxG.width, alpha: 0}, 0.5);
		FlxTween.tween(box, {x: -box.height, alpha: 0}, 0.5);
		FlxTween.tween(itemTxt, {y: -32, alpha: 0}, 0.5, {onComplete: function(twn:FlxTween)
		{
			var check:Bool = StateManager.check("main-menu");
			if (!check)
			{
				MusicBeatState.switchState(new MainMenuState());
			}
		}});
	}
}