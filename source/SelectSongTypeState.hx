#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import openfl.display.BlendMode;

class SelectSongTypeState extends MusicBeatState
{
	var bg:FlxSprite;
	var curSelected:Int = 0;

	var items:FlxTypedGroup<FlxSprite>;

	var choices:Array<String> = ['Normal', 'Encore'];

	var selector:AttachedSprite;

	public static var freeplay:Bool = false;

	var canPress:Bool = true;

	override public function create()
	{
		canPress = true;
		#if desktop
		DiscordClient.changePresence("Selecting Song Type", null);
		#end

		add(new GridBackdrop());

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('backdropSHADER'));
		bg.blend = BlendMode.DARKEN;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		selector = new AttachedSprite();
		selector.loadGraphic(Paths.image('songType/selector'));
		selector.xAdd = -25;
		selector.yAdd = -25;
		add(selector);

		items = new FlxTypedGroup<FlxSprite>();
		add(items);

		for (i in 0...choices.length)
		{
			var choice:FlxSprite = new FlxSprite().loadGraphic(Paths.image('songType/' + choices[i]));
			choice.screenCenter();
			choice.ID = i;
			if (i == 0)
			{
				choice.y -= 150;
			}
			else
			{
				choice.y += 150;
			}
			items.add(choice);
		}

		add(new FlxSprite().loadGraphic(Paths.image('songType/info')));

		selector.sprTracker = items.members[curSelected];

		changeSelection(0);

		super.create();
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
			if (curSelected == 1)
				PlayState.encoreMode = true;
			else
				PlayState.encoreMode = false;

			FlxG.sound.play(Paths.sound('confirmMenu'));
			if (freeplay)
			{
				if (curSelected == 1)
				{	
					MusicBeatState.switchState(new FreeplayEncoreState());
				}
				else
				{
					MusicBeatState.switchState(new FreeplayState());
				}
			}
			else
			{
				if (curSelected == 1)
				{
					MusicBeatState.switchState(new StoryEncoreState());
				}
				else
				{
					MusicBeatState.switchState(new StoryMenuState());
				}
			}
		}
		if (controls.BACK)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		super.update(elapsed);
	}

	function changeSelection(huh:Int)
	{
		curSelected += huh;

		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		if (curSelected > 1)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = 1;

		items.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
			{
				spr.alpha = 1;
				selector.sprTracker = spr;
			}
			else
			{
				spr.alpha = 0.6;
			}
		});
	}
}