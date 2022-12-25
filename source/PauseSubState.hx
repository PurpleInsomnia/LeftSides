package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import options.OptionsState;
import sys.FileSystem;

class PauseSubState extends MusicBeatSubstate
{
	var items:FlxTypedGroup<Alphabet>;

	var spikes:FlxSprite;

	var menuItems:Array<String> = ['EASY', 'NORMAL', 'HARD', 'ONE SHOT', 'BACK'];
	var menuItemsOG:Array<String> = ['resume', 'restart', "options", 'health loss', 'practice', 'botplay', 'exit'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var botplayText:FlxText;
	var hlText:FlxText;

	public static var transCamera:FlxCamera;

	public static var pauseString = "breakfast";


	var canPress:Bool = true;

	public function new(x:Float, y:Float)
	{
		super();
		menuItems = menuItemsOG;

		FlxG.mouse.visible = true;

		for (i in 0...CoolUtil.difficultyStuff.length) {
			var diff:String = '' + CoolUtil.difficultyStuff[i][0];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		if (!FileSystem.exists("assets/shared/music/pauseMusic/" + pauseString) && !FileSystem.exists("mods/music/pauseMusic/" + pauseString) && !FileSystem.exists("mods/" + Paths.currentModDirectory + "/music/pauseMusic/" + pauseString))
		{
			pauseString = "breakfast";
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music(pauseString), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		add(bg);
		bg.alpha = 0;
		FlxTween.tween(bg, {alpha: 0.5}, 1);

		var chars:FlxSprite = new FlxSprite().loadGraphic(Paths.image("pause/artwork"));
		chars.y = FlxG.height;
		add(chars);
		FlxTween.tween(chars, {y: 0}, 0.5, {ease: FlxEase.sineOut});

		var levelInfo:FlxText = new FlxText(0, 0, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		levelInfo.x = Std.int(FlxG.width - (levelInfo.width + 10));
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(0, 192 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		levelDifficulty.x = Std.int(FlxG.width - (levelDifficulty.width + 10));
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(0, 192 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		blueballedTxt.x = Std.int(FlxG.width - (blueballedTxt.width + 10));
		add(blueballedTxt);

		practiceText = new FlxText(0, 192 + 138, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.updateHitbox();
		practiceText.x = Std.int(FlxG.width - (practiceText.width + 10));
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);

		hlText = new FlxText(0, 192 + 101, 0, "Health Loss: " + PlayState.healthLoss, 32);
		hlText.scrollFactor.set();
		hlText.setFormat(Paths.font('vcr.ttf'), 32);
		hlText.updateHitbox();
		hlText.x = Std.int(FlxG.width - (hlText.width + 10));
		add(hlText);

		botplayText = new FlxText(0, FlxG.height - 40, 0, "BOTPLAY", 32);
		botplayText.scrollFactor.set();
		botplayText.setFormat(Paths.font('vcr.ttf'), 32);
		botplayText.updateHitbox();
		botplayText.x = Std.int(FlxG.width - (botplayText.width + 10));
		botplayText.visible = PlayState.cpuControlled;
		add(botplayText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		hlText.alpha = 0;
		levelInfo.alpha = 0;

		FlxTween.tween(levelInfo, {alpha: 1, y: 192}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(hlText, {alpha: 1, y: hlText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});

		items = new FlxTypedGroup<Alphabet>();
		add(items);

		for (i in 0...menuItems.length)
		{
			var spr:Alphabet = new Alphabet(0, 0, menuItems[i], true, false);
			spr.isMenuItem = true;
			spr.forceX = 25;
			spr.targetY = i;
			items.add(spr);
		}

		changeSelection();

		FlxG.sound.play(Paths.sound('pause'));

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		hlText.text = 'Health Loss: ' + PlayState.healthLoss;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP && canPress)
		{
			changeSelection(-1);
		}
		if (downP && canPress)
		{
			changeSelection(1);
		}

		if (accepted && canPress)
		{
			FlxG.mouse.visible = false;
			var daSelected:String = menuItems[curSelected];
			for (i in 0...difficultyChoices.length-1) {
				if(difficultyChoices[i] == daSelected) {
					var name:String = PlayState.SONG.song.toLowerCase();
					var poop = Highscore.formatSong(name, curSelected);
					PlayState.SONG = Song.loadFromJson(poop, name);
					PlayState.storyDifficulty = curSelected;
					CustomFadeTransition.nextCamera = transCamera;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
					PlayState.changedDifficulty = true;
					PlayState.cpuControlled = false;
					return;
				}
			} 

			switch (daSelected)
			{
				case "resume":
					FlxG.sound.play(Paths.sound('unpause'));
					close();
				case 'practice':
					PlayState.practiceMode = !PlayState.practiceMode;
					PlayState.usedPractice = true;
					practiceText.visible = PlayState.practiceMode;
				case "restart":
					CustomFadeTransition.nextCamera = transCamera;
					MusicBeatState.resetState();
					FlxG.sound.music.volume = 0;
				case 'health loss':
					MusicBeatState.switchState(new HealthLossState());
				case 'botplay':
					PlayState.cpuControlled = !PlayState.cpuControlled;
					PlayState.usedPractice = true;
					botplayText.visible = PlayState.cpuControlled;
				case "options":
					options();
				case "exit":
					OptionsState.playstate = false;
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					CustomFadeTransition.nextCamera = transCamera;
					if(PlayState.isStoryMode && !PlayState.isVoid) 
					{
						var check:Bool = StateManager.check("story-menu");
						if (!check)
						{
							if (!PlayState.encoreMode)
								MusicBeatState.switchState(new StoryMenuState());
							else
								MusicBeatState.switchState(new StoryEncoreState());
							FlxG.sound.playMusic(Paths.music('freakyMenu'));
						}
					}
					if(!PlayState.isStoryMode && PlayState.isVoid) 
					{
						MusicBeatState.switchState(new MonsterLairState());
					} 
					if(!PlayState.isStoryMode && !PlayState.isVoid)
					{
						var check:Bool = StateManager.check("freeplay");
						if (!check)
						{
							MusicBeatState.switchState(new FunnyFreeplayState());
							FlxG.sound.playMusic(Paths.music('freeplay'));
						}
					}
					PlayState.usedPractice = false;
					PlayState.changedDifficulty = false;
					PlayState.cpuControlled = false;
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollPause'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (i in 0...menuItems.length)
		{
			items.members[i].targetY = bullShit - curSelected;
			bullShit++;

			items.members[i].alpha = 0.75;

			if (items.members[i].targetY == 0)
			{
				items.members[i].alpha = 1;
			}
		}
	}

	function options()
	{
		OptionsState.playstate = true;
		CustomFadeTransition.nextCamera = transCamera;
		FlxG.sound.music.stop();
		MusicBeatState.switchState(new OptionsState());
	}
}
