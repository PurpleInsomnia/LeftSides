package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import filters.Scanline;

using StringTools;

class HealthLossState extends MusicBeatState
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var icon:HealthIcon;
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;
	var hText:Alphabet;
	var descText:FlxText;
	var alphaGroup:FlxTypedGroup<FlxSprite>;

	var diffSpr:FlxSprite;

	var curSelected:Int = 1;

	public static var preferedHL:Int = 1;

	override public function create()
	{
		curSelected = preferedHL;
		bg = new FlxSprite().loadGraphic(Paths.image('healthloss/bg'));
		bg.scrollFactor.set();
		add(bg);

		var text:Alphabet = new Alphabet(0, 45, "Health Loss Settings", true);
		text.x = 128;
		text.forceX = text.x;
		alphabetArray.push(text);
		add(text);

		alphaGroup = new FlxTypedGroup<FlxSprite>();
		add(alphaGroup);

		for (i in 0...5)
		{
			var suck:FlxSprite = new FlxSprite(64, Std.int(45 + text.height)).loadGraphic(Paths.image('healthloss/' + i));
			suck.y += 85 * i;
			suck.ID = i;
			alphaGroup.add(suck);
		}

		diffSpr = new FlxSprite().loadGraphic(Paths.image("healthloss/diff/" + curSelected));
		diffSpr.scale.set(2, 2);
		diffSpr.updateHitbox();
		diffSpr.screenCenter();
		diffSpr.x += 64;
		add(diffSpr);

		descText = new FlxText(0, 0, 'sussybaka', 32);
		descText.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.screenCenter(X);
		descText.y = FlxG.height - Std.int(descText.height);
		add(descText);
		updateOptions();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if(controls.UI_UP_P) 
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			updateOptions(-1);
		}
		if (controls.UI_DOWN_P)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			updateOptions(1);
		}
		if(controls.ACCEPT) {
			switch(curSelected)
			{
				case 0:
					PlayState.healthLoss = 0.0475 / 6;
				case 1:
					PlayState.healthLoss = 0.0475;
				case 2:
					PlayState.healthLoss = 0.0475 * 2.275;
				case 3:
					PlayState.healthLoss = 2;
				case 4:
					PlayState.healthLoss = 0.0005;
			}
			preferedHL = curSelected;
			ClientPrefs.saveSettings();
			FlxG.sound.play(Paths.sound('confirmMenu'), 1);
			FlxG.sound.music.stop();
			MusicBeatState.switchState(new LoadingScreenState());
		}
		super.update(elapsed);
	}

	function updateOptions(?huh:Int = 0) 
	{
		curSelected += huh;

		if (curSelected > 4)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 4;

		alphaGroup.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
			{
				spr.alpha = 1;
			}
			else
			{
				spr.alpha = 0.5;
			}
		});

		switch(curSelected)
		{
			case 0:
				descText.text = 'Less health is lost whenver you miss a note';
			case 1:
				descText.text = 'No changes in the amount of health lost';
			case 2:
				descText.text = 'More health is lost whenever you miss a note';
			case 3:
				descText.text = 'Instant blue balls on miss';
			case 4:
				descText.text = 'Lose 0.05% of your health everytime you miss a note';
		}
		descText.screenCenter(X);

		diffSpr.loadGraphic(Paths.image("healthloss/diff/" + curSelected));
		diffSpr.scale.set(2, 2);
		diffSpr.updateHitbox();
		diffSpr.screenCenter();
		diffSpr.x += 64;
	}
}