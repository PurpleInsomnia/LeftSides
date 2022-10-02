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
import flixel.ui.FlxButton;

class PauseSubState extends MusicBeatSubstate
{
	var items:FlxTypedGroup<FlxSprite>;

	var spikes:FlxSprite;

	var menuItems:Array<String> = ['EASY', 'NORMAL', 'HARD', 'ONE SHOT', 'BACK'];
	var menuItemsOG:Array<String> = ['resume', 'restart', 'health loss', 'practice', 'botplay', 'exit'];
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var botplayText:FlxText;
	var hlText:FlxText;

	public static var transCamera:FlxCamera;

	public function new(x:Float, y:Float)
	{
		super();
		menuItems = menuItemsOG;

		for (i in 0...CoolUtil.difficultyStuff.length) {
			var diff:String = '' + CoolUtil.difficultyStuff[i][0];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('BACK');

		pauseMusic = new FlxSound().loadEmbedded(Paths.music(ClientPrefs.pauseMusic), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite(-1280, -720).loadGraphic(Paths.image("pause/grid"));
		bg.alpha = 0;
		bg.scrollFactor.set();
		FlxTween.tween(bg, {x: 0, y: 0}, 20, {type: LOOPING});
		add(bg);

		spikes = new FlxSprite().loadGraphic(Paths.image('pause/right'));
		spikes.scrollFactor.set();
		add(spikes);

		var paused:FlxSprite = new FlxSprite(0, -720).loadGraphic(Paths.image('pause/paused'));
		paused.scrollFactor.set();
		add(paused);

		var levelInfo:FlxText = new FlxText(20, 0, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 192 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedTxt:FlxText = new FlxText(20, 192 + 64, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		practiceText = new FlxText(20, 192 + 138, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);

		hlText = new FlxText(20, 192 + 101, 0, "Health Loss: " + PlayState.healthLoss, 32);
		hlText.scrollFactor.set();
		hlText.setFormat(Paths.font('vcr.ttf'), 32);
		hlText.updateHitbox();
		add(hlText);

		botplayText = new FlxText(20, FlxG.height - 40, 0, "BOTPLAY", 32);
		botplayText.scrollFactor.set();
		botplayText.setFormat(Paths.font('vcr.ttf'), 32);
		botplayText.updateHitbox();
		botplayText.visible = PlayState.cpuControlled;
		add(botplayText);

		blueballedTxt.alpha = 0;
		levelDifficulty.alpha = 0;
		hlText.alpha = 0;
		levelInfo.alpha = 0;

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 192}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: blueballedTxt.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(hlText, {alpha: 1, y: hlText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});

		items = new FlxTypedGroup<FlxSprite>();
		add(items);

		for (i in 0...menuItems.length)
		{
			var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pause/text/' + menuItems[i]));
			spr.ID = i;
			spr.scrollFactor.set();
			items.add(spr);
		}

		FlxTween.tween(paused, {y: paused.y + 720}, 1, {ease: FlxEase.quintOut});

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

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
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
				case "exit":
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;
					CustomFadeTransition.nextCamera = transCamera;
					if(PlayState.isStoryMode && !PlayState.isVoid) 
					{
						if (!PlayState.encoreMode)
							MusicBeatState.switchState(new StoryMenuState());
						else
							MusicBeatState.switchState(new StoryEncoreState());
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
					}
					if(!PlayState.isStoryMode && PlayState.isVoid) 
					{
						MusicBeatState.switchState(new VoidState());
					} 
					if(!PlayState.isStoryMode && !PlayState.isVoid) 
					{
						if (!PlayState.encoreMode)
							MusicBeatState.switchState(new FreeplayState());
						else
							MusicBeatState.switchState(new FreeplayEncoreState());
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
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

		items.forEach(function(spr:FlxSprite)
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
	}

	function stageToggle()
	{
		ClientPrefs.noStages = !ClientPrefs.noStages;
		CustomFadeTransition.nextCamera = transCamera;
		MusicBeatState.resetState();
		FlxG.sound.music.volume = 0;
	}
}
