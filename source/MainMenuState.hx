package;

import trophies.TrophiesState.TrophySelectState;
#if DISCORD
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
import flash.display.BlendMode;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.ui.FlxButton;
import editors.MasterEditorMenu;
import sys.FileSystem;
import openfl.display.BlendMode;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var funnyZoom:Float = 0.1;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var buttonGroup:FlxTypedGroup<FlxButton>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['story_mode', 'freeplay', 'options', 'doodles'];

	var magenta:FlxSprite;
	var spikes:FlxSprite;
	var coolTrans:FlxSprite;
	var arrowSpr:AttachedSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var miniBf:Boyfriend;
	var canDance:Bool = true;

	var blackScreen:FlxSprite;

	var isUsingCustomBg:Bool = false;

	var m:Bool = false;
	var o:Bool = false;
	var n:Bool = false;
	var s:Bool = false;
	var t:Bool = false;
	var e:Bool = false;
	var r:Bool = false;
	var v:Bool = false;
	var i:Bool = false;
	var d:Bool = false;
	var e2:Bool = false;
	var o2:Bool = false;

	var canEnter = false;

	public static var menuCharSprs:Array<FlxSprite> = [];

	var tip:FlxSprite;

	var thingTyped:Bool = false;

	public static var coolBeat:Float = 0;
	public static var daBeat:Int = 0;

	public static var saveFileName:String;

	var customStates:Array<String> = ['noState'];

	var splashText:FlxText;

	public var behindGroup:FlxTypedGroup<Dynamic>;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		WeekData.loadTheFirstEnabledMod();

		daBeat = 0;

		var check:Bool = StateManager.check("main-menu");
		var blackOverlay:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		blackOverlay.scrollFactor.set();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		options.OptionsState.playstate = false;

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		FlxG.mouse.visible = true;
		FlxG.mouse.load(Paths.image('leftMouse'));

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var ppSuck:GridBackdrop = new GridBackdrop();
		ppSuck.scrollFactor.set(0, yScroll * 2);
		add(ppSuck);

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('backdropSHADER'));
		bg.scrollFactor.set(0, 0);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.blend = BlendMode.DARKEN;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		behindGroup = new FlxTypedGroup<Dynamic>();
		add(behindGroup);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		// add(magenta);
		// magenta.scrollFactor.set();

		var coolSpike:FlxSprite = new FlxSprite().loadGraphic(Paths.image('whiteMenuSpikes'));
		coolSpike.blend = BlendMode.OVERLAY;
		coolSpike.alpha = 0.5;
		coolSpike.y = 0 - 720;
		add(coolSpike);

		FlxTween.tween(coolSpike, {y: coolSpike.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});

		Conductor.changeBPM(102);

		makeMenuChars();

		spikes = new FlxSprite().loadGraphic(Paths.image('menuSpikes'));
		spikes.screenCenter(Y);
		spikes.scrollFactor.set();
		spikes.antialiasing = ClientPrefs.globalAntialiasing;
		add(spikes);

		if (!FlxG.sound.music.playing && !check)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(-640, 20 + (i * 120));
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_assets');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		tip = new FlxSprite().loadGraphic(Paths.image('menuTip'));
		tip.x = 670;
		tip.y = Std.int((720 - 150) - (tip.height / 2));
		tip.scrollFactor.set();
		add(tip);

		new FlxTimer().start(3, function(tmr:FlxTimer)
		{
			FlxTween.tween(tip, {y: tip.y + 720}, 1.5, {ease: FlxEase.quadInOut});
		});

		buttonGroup = new FlxTypedGroup<FlxButton>();
		add(buttonGroup);

		var p2Button:FlxButton = new FlxButton(370, 720 - 150, null, function()
		{
			selectedSomethin = true;
			MusicBeatState.switchState(new twoplayer.TwoPlayerState());
		});
		p2Button.loadGraphic(Paths.image("2Player/button"), true, 150, 150);
		buttonGroup.add(p2Button);

		var troButton:FlxButton = new FlxButton(150 + 370, 720 - 150, null, function()
		{
			selectedSomethin = true;
			MusicBeatState.switchState(new TrophySelectState(true));
		});
		troButton.loadGraphic(Paths.image("trophyButton"), true, 150, 150);
		buttonGroup.add(troButton);

		var waButton:FlxButton = new FlxButton(300 + 370, 720 - 150, null, clickWarn);
		waButton.loadGraphic(Paths.image('warningButton'), true, 150, 150);
		buttonGroup.add(waButton);

		if (ClientPrefs.week8Done || ClientPrefs.devMode)
		{
			var vButton:FlxButton = new FlxButton(450 + 370, 720 - 150, null, voidThing);
			vButton.loadGraphic(Paths.image('theVoidButton'), true, 150, 150);
			buttonGroup.add(vButton);
		}
		else
		{
			var vButton:FlxButton = new FlxButton(450 + 370, 720 - 150, null, lockedVoid);
			vButton.loadGraphic(Paths.image('lockedButton'), true, 150, 150);
			buttonGroup.add(vButton);
		}

		var arcButton:FlxButton = new FlxButton(600 + 370, 720 - 150, null, sideClick);
		arcButton.loadGraphic(Paths.image('sideButton'), true, 150, 150);
		buttonGroup.add(arcButton);

		#if desktop
		var soundTr:FlxButton = new FlxButton(750 + 370, 720 - 150, '', soundtrack);
		soundTr.loadGraphic(Paths.image('stButton'), true, 150, 150);
		buttonGroup.add(soundTr);
		#end

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		blackScreen.scrollFactor.set();
		blackScreen.alpha = 0;
		add(blackScreen);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (!Achievements.achievementsUnlocked[achievementID][1] && leDate.getDay() == 5 && leDate.getHours() >= 18) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
			Achievements.achievementsUnlocked[achievementID][1] = true;
			giveAchievement();
			ClientPrefs.saveSettings();
		}
		#end

		new FlxTimer().start(coolBeat, function(tmr:FlxTimer)
		{
			coolBeatHit();
		});

		var unlocks:Array<Array<Dynamic>> = [];

		// get new unlocks for returning players
		if (Highscore.getWeekScore("week2", 1) > 0 && SideStorySelectState.storyList[0][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story "Halloween"', 0, 1]);
		}
		if (Highscore.getScore("Doppelganger", 1) > 0 && SideStorySelectState.storyList[1][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story "Saturday"', 1, 1]);
		}
		if (Highscore.getWeekScore("week6", 1) > 0 && SideStorySelectState.storyList[2][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story "Talking"', 2, 1]);
		}
		if (Highscore.getWeekScore("week3", 1) > 0 && SideStorySelectState.storyList[3][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story "Party Skippers"', 3, 1]);
		}
		if (Highscore.getWeekScore("week5", 1) > 0 && SideStorySelectState.storyList[4][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story "Happy"', 4, 1]);
		}
		if (!ClientPrefs.unlockedRestless && SideStorySelectState.storyList[5][2] != 1 && Highscore.getWeekScore("week5", 1) > 0)
		{
			ClientPrefs.unlockedRestless = true;
			ClientPrefs.saveSettings();
			unlocks.push(["SideStorySelectState", 'The Side Story "Restless"', 5, 1]);
		}
		if (Highscore.getWeekScore("week7", 1) > 0 && SideStorySelectState.storyList[6][2] != 1)
		{
			unlocks.push(["SideStorySelectState", 'The Side Story "Bump In"', 6, 1]);
		}
		if (ClientPrefs.week8Done && !ClientPrefs.newUnlocked)
		{
			unlocks.push(["OptionsState", "New Songs In Monster's Lair! (formerly THE VOID)", true]);
		}
		if (ClientPrefs.completedSideStories.get("happy") && !ClientPrefs.unlockedArchives)
		{
			ClientPrefs.unlockedArchives = true;
			ClientPrefs.saveSettings();
			unlocks.push(["Huh?", "The Archives. (Located in 'The Monster's Lair' near the 'Terminal'.)"]);
		}

		if (unlocks.length > 0 && unlocks[0] != null)
		{
			trace("Unlocking Somethin");
			add(blackOverlay);
			MusicBeatState.switchState(new UnlockState(unlocks));
		}

		if (check)
		{
			add(blackOverlay);
			FlxG.sound.music.stop();
		}

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	var achievementID:Int = 0;
	function giveAchievement() {
		add(new AchievementObject(achievementID, camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement ' + achievementID);
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleScreenState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					canDance = false;
					FlxTween.tween(menuCharSprs[curSelected], {x: menuCharSprs[curSelected].x * 2}, 1.5, {ease: FlxEase.quadInOut});
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					// if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					for (i in 0...buttonGroup.length)
						FlxTween.tween(buttonGroup.members[i], {y: 720 * 2}, 1.5, {ease: FlxEase.quadInOut, startDelay: 0.2 * i});

					tip.visible = false;

					FlxG.mouse.visible = false;

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0, y: 720}, 0.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										if (!ClientPrefs.setControls)
										{
											persistentUpdate = false;
											openSubState(new SetControlsSubstate());
											FlxTween.tween(blackScreen, {alpha: blackScreen.alpha + 1}, 0.5, {ease: FlxEase.quadInOut});
										}
										else
										{
											SelectSongTypeState.freeplay = false;
											MusicBeatState.switchState(new SelectSongTypeState());
											trace('here we funkin go!!!');
										}
									case 'freeplay':
										MusicBeatState.switchState(new FunnyFreeplayState());
										FlxG.sound.music.stop();
									case 'options':
										MusicBeatState.switchState(new options.OptionsState());
										FlxG.sound.music.stop();
									case 'doodles':
										MusicBeatState.switchState(new DoodlesState());
										FlxG.sound.music.stop();
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		if (FlxG.mouse.wheel != 0)
		{
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(FlxG.mouse.wheel * -1);
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.y = 0.15 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});

		for (i in 0...menuCharSprs.length)
		{
			menuCharSprs[i].visible = false;
		}
		menuCharSprs[curSelected].visible = true;
	}

	function clickWarn()
	{
		if (!selectedSomethin)
		{
			selectedSomethin = true;
			MusicBeatState.switchState(new VeryFunnyWarning());
		}
	}

	function voidThing()
	{
		if (!selectedSomethin)
		{
			selectedSomethin = true;
			MusicBeatState.switchState(new MonsterLairState());
		}
	}

	function lockedVoid()
	{
		if (!selectedSomethin)
		{
			selectedSomethin = true;
			persistentUpdate = false;
			openSubState(new LockedVoidSubstate());
		}
	}

	function dlcPress()
	{
		if (!selectedSomethin)
		{
			selectedSomethin = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new dlc.DlcMenuState());
		}
	}

	function soundtrack()
	{
		#if desktop
		if (!selectedSomethin)
		{
			selectedSomethin = true;
			FlxG.sound.music.stop();
			MusicBeatState.switchState(new checkify.CheckifyLoadingState());
		}
		#end
	}

	function sideClick()
	{
		if (!selectedSomethin)
		{
			selectedSomethin = true;
			FlxG.sound.music.stop();
			MusicBeatState.switchState(new SideStorySelectState());
		}
	}


	var menuChars:Array<String> = ['Story Mode', 'Freeplay', 'Options', 'Doodles'];
	function makeMenuChars()
	{
		menuCharSprs = [];
		for (i in 0...menuChars.length)
		{
			var menuChar:FlxSprite = new FlxSprite(0, 0);
			menuChar.scrollFactor.set();
			menuChar.frames = Paths.getSparrowAtlas('mainmenu/selectChars/' + menuChars[i]);
			menuChar.animation.addByPrefix('idle', menuChars[i], 24, false);
			menuChar.animation.play('idle');
			menuChar.antialiasing = ClientPrefs.globalAntialiasing;

			menuChar.screenCenter();
			menuChar.x += (menuChar.width / 2);
			menuChar.y += (menuChar.height / 4);

			menuCharSprs.push(menuChar);
			menuChar.visible = false;
			add(menuChar);
		}
	}

	override function closeSubState() {
		persistentUpdate = true;
		selectedSomethin = false;
		changeItem(0);
		super.closeSubState();
	}

	public static function coolBeatHit()
	{
		daBeat++;
		MusicBeatState.callOnHscripts("menuBeat", [daBeat]);
		menuCharSprs[curSelected].animation.play('idle');
		new FlxTimer().start(coolBeat, function(tmr:FlxTimer)
		{
			coolBeatHit();
		});
	}
}
