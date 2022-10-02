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
import flash.display.BlendMode;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.ui.FlxButton;
import Achievements;
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
	
	var optionShit:Array<String> = ['story_mode', 'freeplay', 'credits', 'options', 'doodles'];

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

	public static var coolBeat:Int = 0;

	public static var saveFileName:String;

	var customStates:Array<String> = ['noState'];

	var splashText:FlxText;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

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
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.blend = BlendMode.DARKEN;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

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

		if (!FlxG.sound.music.playing)
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

		var versionShit:FlxText = new FlxText(12, FlxG.height - 84, 0, saveFileName, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Friday Night Funkin Left Sides v2.0", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

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

		var dlcButton:FlxButton = new FlxButton(0 + 370, 720 - 150, null, dlcPress);
		dlcButton.loadGraphic(Paths.image('dlcButton'), true, 150, 150);
		buttonGroup.add(dlcButton);

		var acButton:FlxButton = new FlxButton(150 + 370, dlcButton.y, null, clickTrophy);
		acButton.loadGraphic(Paths.image('trophyButton'), true, 150, 150);
		buttonGroup.add(acButton);

		var waButton:FlxButton = new FlxButton(300 + 370, dlcButton.y, null, clickWarn);
		waButton.loadGraphic(Paths.image('warningButton'), true, 150, 150);
		buttonGroup.add(waButton);

		if (ClientPrefs.week8Done)
		{
			var vButton:FlxButton = new FlxButton(450 + 370, dlcButton.y, null, voidThing);
			vButton.loadGraphic(Paths.image('theVoidButton'), true, 150, 150);
			buttonGroup.add(vButton);
		}
		else
		{
			var vButton:FlxButton = new FlxButton(450 + 370, dlcButton.y, null, lockedVoid);
			vButton.loadGraphic(Paths.image('lockedButton'), true, 150, 150);
			buttonGroup.add(vButton);
		}

		if (ClientPrefs.arcadeUnlocked)
		{
			// var arcButton:FlxButton = new FlxButton(600 + 370, dlcButton.y, null, arcade);
			// arcButton.loadGraphic(Paths.image('arcadeButton'), true, 150, 150);
			// add(arcButton);

			var arcButton:FlxButton = new FlxButton(600 + 370, dlcButton.y, null, lockedArcade);
			arcButton.loadGraphic(Paths.image('lockedButton'), true, 150, 150);
			buttonGroup.add(arcButton);
		}
		else
		{
			var arcButton:FlxButton = new FlxButton(600 + 370, dlcButton.y, null, lockedArcade);
			arcButton.loadGraphic(Paths.image('lockedButton'), true, 150, 150);
			buttonGroup.add(arcButton);
		}

		var soundTr:FlxButton = new FlxButton(750 + 370, dlcButton.y, '', soundtrack);
		soundTr.loadGraphic(Paths.image('stButton'), true, 150, 150);
		buttonGroup.add(soundTr);

		add(new Acheivement(0, "You got past the title screen! \n(woopie for you I guess?)", 'story', camAchievement));

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
				MusicBeatState.switchState(new TitleState());
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
										SelectSongTypeState.freeplay = true;
										MusicBeatState.switchState(new SelectSongTypeState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
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

	function clickTrophy()
	{
		if (!selectedSomethin)
		{
			selectedSomethin = true;
			MusicBeatState.switchState(new AchievementsMenu());
		}
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
			MusicBeatState.switchState(new VoidState());
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
			MusicBeatState.switchState(new DlcMenuState());
		}
	}

	function arcade()
	{
		if (!selectedSomethin)
		{
			selectedSomethin = true;
			FlxG.sound.music.stop();
			MusicBeatState.switchState(new SplashState());
		}
	}

	function lockedArcade()
	{
		persistentUpdate = false;
		openSubState(new LockedArcadeSubstate());
	}

	function soundtrack()
	{
		if (!selectedSomethin)
		{
			selectedSomethin = true;
			FlxG.sound.music.stop();
			MusicBeatState.switchState(new SoundtrackState());
		}
	}


	var menuChars:Array<String> = ['Story Mode', 'Freeplay', 'Credits', 'Options', 'Doodles'];
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
		menuCharSprs[curSelected].animation.play('idle');
		new FlxTimer().start(coolBeat, function(tmr:FlxTimer)
		{
			coolBeatHit();
		});
	}
}
