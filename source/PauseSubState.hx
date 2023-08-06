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

using StringTools;

class PauseSubState extends MusicBeatSubstate
{
	var items:FlxTypedGroup<Alphabet>;
	// lmaaaaooooooooooo
	public static var itemPrefix:String = "";

	var spikes:FlxSprite;

	var menuItems:Array<String> = ['EASY', 'NORMAL', 'HARD', 'ONE SHOT', 'BACK'];
	var menuItemsOG:Array<String> = ['resume', 'restart', "options", 'health loss', "wardrobe", 'practice', 'botplay', 'exit'];
	
	var difficultyChoices = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var botplayText:FlxText;
	var hlText:FlxText;

	public static var transCamera:FlxCamera;

	public static var pauseString = "breakfast";
	public static var dadCol:FlxColor = 0xFFFFFFFF;
	public static var bfCol:FlxColor = 0xFFFFFFFF;


	var canPress:Bool = true;

	public function new(x:Float, y:Float, pc:String)
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

		var dadGra:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("pause/gradient"));
		dadGra.color = dadCol;
		dadGra.flipY = true;
		dadGra.alpha = 0;
		add(dadGra);

		var bfGra:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image("pause/gradient"));
		bfGra.color = bfCol;
		bfGra.alpha = 0;
		add(bfGra);

		FlxTween.tween(dadGra, {alpha: 0.75}, 0.25, {ease: FlxEase.sineOut});
		FlxTween.tween(bfGra, {alpha: 0.75}, 0.25, {ease: FlxEase.sineOut});

		var levelInfo:FlxText = new FlxText(0, 0, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		levelInfo.x = Std.int(FlxG.width - (levelInfo.width + 10));
		add(levelInfo);

		var blueballedTxt:FlxText = new FlxText(0, Std.int(levelInfo.height * 1), 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		blueballedTxt.x = Std.int(FlxG.width - (blueballedTxt.width + 10));
		add(blueballedTxt);

		practiceText = new FlxText(0, Std.int(levelInfo.height * 3), 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.updateHitbox();
		practiceText.x = Std.int(FlxG.width - (practiceText.width + 10));
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);

		hlText = new FlxText(0, Std.int(levelInfo.height * 2), 0, "Health Loss: " + PlayState.healthLoss, 32);
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
		hlText.alpha = 0;
		levelInfo.alpha = 0;

		FlxTween.tween(levelInfo, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(blueballedTxt, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(hlText, {alpha: 1}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.9});

		items = new FlxTypedGroup<Alphabet>();
		add(items);

		for (i in 0...menuItems.length)
		{
			var spr:Alphabet = new Alphabet(0, 0, menuItems[i], true, false, 0.05, 1, itemPrefix);
			spr.isMenuItem = true;
			spr.screenCenter(X);
			spr.forceX = spr.x;
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
					CustomFadeTransition.nextCamera = transCamera;
					HealthLossState.playstate = true;
					MusicBeatState.switchState(new HealthLossState());
				case "wardrobe":
					CustomFadeTransition.nextCamera = transCamera;
					MusicBeatState.switchState(new WardrobeState(true));
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
