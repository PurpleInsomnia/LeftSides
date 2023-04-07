package;

#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import sys.FileSystem;

using StringTools;

class SoundtrackState extends MusicBeatState
{
	var soundtrackList:Array<String> = ['LeftSides', 'VoidSongs', 'Encore', "Menu Music", "Exe"];
	var soundtrackNames:Array<String> = ['Left Sides: Story Soundtrack', 'Left Sides: Bonus Songs', 'Left Sides: ENCORE REMIXES', "Left Sides: Menu Music", "Left Sides: EXE Extension"];
	var tracklist:Array<String> = [];

	var directories:Array<String> = [];
	var loadedDirectories:Array<String> = [];

	var stGroup:FlxTypedGroup<FlxSprite>;
	var trackGroup:FlxTypedGroup<FlxText>;
	var curSelected:Int = 0;
	var curSelectedTrack:Int = 0;

	var canPress:Bool = true;

	var isTrack:Bool = false;

	var bg:FlxSprite;

	var InstSound:FlxSound = null;
	var VocalSound:FlxSound = null;

	var nameText:FlxText;

	var record:FlxSprite;

	var follow:FlxSprite;
	var followY:Array<Float> = [];

	override public function create()
	{
		var camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxCamera.defaultCameras = [camGame];

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Soundtrack Menu", null);
		#end

		directories = [];
		loadedDirectories = [];
		followY = [];

		getDirectories();

		FlxG.autoPause = false;
		isTrack = false;
		bg = new FlxSprite().loadGraphic(Paths.image('achievements/bg'));
		bg.screenCenter();
		bg.scrollFactor.set(0, 0);
		add(bg);

		follow = new FlxSprite().makeGraphic(1, 1, 0x00000000);
		follow.screenCenter();
		add(follow);

		FlxG.camera.follow(follow, null, 1);

		stGroup = new FlxTypedGroup<FlxSprite>();
		add(stGroup);

		// dlc support lol
		for (i in 0...directories.length)
		{
			if (FileSystem.exists(directories[i] + '/data/soundtrack.txt'))
			{
				var thing:Array<String> = CoolUtil.coolTextFile(directories[i] + '/data/soundtrack.txt');
				// so that the thing can actually LOAD.
				loadedDirectories.push(directories[i]);
				for (j in 0...thing.length)
				{
					var daSplit:Array<String> = thing[j].split("|");
					soundtrackList.push(daSplit[0]);
					soundtrackNames.push(daSplit[1]);
				}
			}
		}

		var get:Int = 0; 
		for (i in 0...soundtrackList.length)
		{
			if (i > 2)
			{
				Paths.currentModDirectory = loadedDirectories[get].replace('mods/', '');
				get++;
			}
			var cover:FlxSprite = new FlxSprite();
			var name:String = 'soundtrack/' + soundtrackList[i] + '/cover';
			var file:Dynamic;
			if (i < 3)
				file = Paths.image(name);
			else
				file = Paths.image(name);

			cover.loadGraphic(file);

			cover.ID = i;
			cover.screenCenter();
			cover.y += 475 * i;
			stGroup.add(cover);

			for (i in 0...soundtrackList.length)
			{
				followY.push(follow.y + (475 * i));
			}
		}

		nameText = new FlxText(0, 0, '', 28);
		nameText.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		nameText.screenCenter(X);
		nameText.scrollFactor.set(0, 0);
		add(nameText);

		changeSelection(0, false);

		super.create();
	}

	var moveTween:FlxTween;
	override public function update(elapsed:Float)
	{
		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP && canPress && isTrack)
		{
			changeSelectionTrack(-1, false);
		}
		if (downP && canPress && isTrack)
		{
			changeSelectionTrack(1, true);
		}
		if (upP && canPress && !isTrack)
		{
			changeSelection(-1, false);
		}
		if (downP && canPress && !isTrack)
		{
			changeSelection(1, true);
		}

		if (controls.BACK && canPress && !isTrack)
		{
			if (FlxG.sound.music.playing)
				FlxG.sound.music.stop();
			if (VocalSound != null)
				VocalSound.stop();
			// FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.autoPause = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.BACK && canPress && isTrack)
		{
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				isTrack = false;
			});
			bg.loadGraphic(Paths.image('achievements/bg'));
			removeTracks();
			nameText.visible = true;
			stGroup.visible = true;
			follow.y = followY[curSelected];
			FlxG.sound.play(Paths.sound('cancelMenu'));
		}

		if (controls.ACCEPT && canPress && !isTrack)
		{
			if (moveTween != null)
			{
				moveTween.cancel();
			}
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				isTrack = true;
			});
			follow.screenCenter();
			stGroup.visible = false;
			nameText.visible = false;
			createTracks(curSelected);
		}
		if (controls.ACCEPT && canPress && isTrack)
		{
			loadMusic(curSelectedTrack);
		}
	}

	function removeTracks()
	{
		remove(trackGroup);
	}

	function loadMusic(music:Int)
	{
		// self insert hahahahahahahahaahhaahahahhaha
		composerSlide(tracklist[music]);
		if (FlxG.sound.music.playing)
			FlxG.sound.music.stop();
		if (VocalSound != null)
			VocalSound.stop();
			
		// inst is FlxSound.music?? Idk, but if I try to play 2 sounds simutaneously it just crashes. :/
		if (curSelected == 0 || curSelected == 1 || curSelected > 3)
		{
				FlxG.sound.playMusic(Paths.inst(tracklist[music]), 1, true);
				FlxG.sound.music.pause();
				VocalSound = FlxG.sound.load(Paths.voices(tracklist[music]), 1, true);
				resyncVocals();
		}
		if (curSelected == 2)
		{
			FlxG.sound.playMusic(Paths.instEncore(tracklist[music]), 1, true);
			FlxG.sound.music.pause();
			VocalSound = FlxG.sound.load(Paths.voicesEncore(tracklist[music]), 1, true);
			resyncVocals();
		}
		if (curSelected == 3)
		{
			var path:String = "assets/music/" + tracklist[music] + ".ogg";
			if (FileSystem.exists(Paths.getModFile("music/" + tracklist[music] + ".ogg")))
			{
				FlxG.sound.playMusic(Paths.music(tracklist[music]), 1, true);
			}
			else
			{
				FlxG.sound.playMusic(path, 1, true);
			}
		}
		playMusic2(music);
	}

	function playMusic2(music:Int)
	{
		if (FlxG.sound.music.playing)
			FlxG.sound.music.stop();
		if (VocalSound != null)
			VocalSound.stop();
		// inst is FlxSound.music?? Idk, but if I try to play 2 sounds simutaneously it just crashes. :/
		if (curSelected == 0 || curSelected == 1 || curSelected > 3)
		{
				FlxG.sound.playMusic(Paths.inst(tracklist[music]), 1, true);
				FlxG.sound.music.pause();
				VocalSound = FlxG.sound.load(Paths.voices(tracklist[music]), 1, true);
				resyncVocals();
		}
		if (curSelected == 2)
		{
			FlxG.sound.playMusic(Paths.instEncore(tracklist[music]), 1, true);
			FlxG.sound.music.pause();
			VocalSound = FlxG.sound.load(Paths.voicesEncore(tracklist[music]), 1, true);
			resyncVocals();
		}
		if (curSelected == 3)
		{
			var path:String = "assets/music/" + tracklist[music] + ".ogg";
			if (FileSystem.exists(Paths.getModFile("music/" + tracklist[music] + ".ogg")))
			{
				FlxG.sound.playMusic(Paths.music(tracklist[music]), 1, true);
			}
			else
			{
				FlxG.sound.playMusic(path, 1, true);
			}
		}

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Listening To: " + tracklist[music].toUpperCase(), null);
		#end
	}

	function createTracks(type:Int)
	{
		trackGroup = new FlxTypedGroup<FlxText>();
		add(trackGroup);
		tracklist = [];
		tracklist = CoolUtil.coolTextFile('assets/images/soundtrack/' + soundtrackList[type] + '/tracks.txt');
		if (FileSystem.exists('mods/' + Paths.currentModDirectory + '/images/soundtrack/' + soundtrackList[type] + '/tracks.txt'))
		{
			tracklist = CoolUtil.coolTextFile('mods/' + Paths.currentModDirectory + '/images/soundtrack/' + soundtrackList[type] + '/tracks.txt');
		}

		bg.loadGraphic(Paths.image('soundtrack/' + soundtrackList[type] + '/bg'));
		if (bg.width != FlxG.width)
		{
			bg.setGraphicSize(FlxG.width, Std.int(bg.height));
		}
		if (bg.height != FlxG.height)
		{
			bg.setGraphicSize(Std.int(bg.width), FlxG.height);
		}

		// numbers that caluculates list length
		var num:Int = 0;
		var maxNum:Int = 0;
		var multNum:Int = 2;
		var toRead:Array<String> = tracklist;
		if (FileSystem.exists('assets/images/soundtrack/' + soundtrackList[type] + '/tracksToDisplay.txt'))
		{
			toRead = CoolUtil.coolTextFile('assets/images/soundtrack/' + soundtrackList[type] + '/tracksToDisplay.txt');
		}
		if (FileSystem.exists('mods/' + Paths.currentModDirectory + '/images/soundtrack/' + soundtrackList[type] + '/tracksToDisplay.txt'))
		{
			toRead = CoolUtil.coolTextFile('mods/' + Paths.currentModDirectory + '/images/soundtrack/' + soundtrackList[type] + '/tracksToDisplay.txt');
		}
		for (i in 0...toRead.length)
		{
			var textSizeThing:Float = 42;
			// Idk why, but the default is ten.
			if (toRead.length > 10)
			{
				textSizeThing = 42 - (toRead.length / 2);
			}
			var daTrack:FlxText = new FlxText(20, Std.int(textSizeThing * i) + 20, 1280, toRead[i], Std.int(textSizeThing));
			daTrack.setFormat(Paths.font('eras.ttf'), Std.int(textSizeThing), FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if (daTrack.y > Std.int(FlxG.height - daTrack.height))
			{
				// just using these for longer soundtrack lists *COUGH COUGH* STORY SOUNDTRACK *COUGH COUGH*
				if (maxNum == 0)
					maxNum = i;
				
				if (i == Std.int(maxNum * multNum))
				{
					num = 0;
					multNum++;
				}
				daTrack.y = (textSizeThing * num) + 20;
				daTrack.x = Std.int(100 * multNum);
				num += 1;
			}
			daTrack.ID = i;
			// daTrack.y += Std.int(daTrack.height + (daTrack.height / 4)) * i;
			trackGroup.add(daTrack);
		}
		changeSelectionTrack(0, false);
	}

	function changeSelectionTrack(huh:Int = 0, down:Bool = false)
	{
		curSelectedTrack += huh;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		if (curSelectedTrack >= tracklist.length)
		{
			curSelectedTrack = 0;
		}
		if (curSelectedTrack < 0)
		{
			curSelectedTrack = tracklist.length - 1;
		}

		var bullShit:Int = 0;

		trackGroup.forEach(function(spr:FlxText)
		{
			if (spr.ID == curSelectedTrack)
				spr.alpha = 1;
			else
				spr.alpha = 0.5;
		});
	}

	function changeSelection(huh:Int = 0, down:Bool = false)
	{
		if (moveTween != null)
			moveTween.cancel();

		curSelected += huh;

		FlxG.sound.play(Paths.sound('scrollMenu'));

		if (curSelected >= soundtrackList.length)
		{
			curSelected = 0;
		}
		if (curSelected < 0)
		{
			curSelected = soundtrackList.length - 1;
		}

		stGroup.forEach(function(spr:FlxSprite)
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

		if (curSelected > 3)
		{
			var pathNum:Int = curSelected - 4;
			Paths.currentModDirectory = loadedDirectories[pathNum].replace('mods/', '');
		}

		nameText.text = soundtrackNames[curSelected];
		nameText.screenCenter(X);

		moveTween = FlxTween.tween(follow, {y: followY[curSelected]}, 0.5, {ease: FlxEase.sineOut});
	}

	function resyncVocals():Void
	{
		VocalSound.pause();

		FlxG.sound.music.play();
		
		Conductor.songPosition = FlxG.sound.music.time;
		VocalSound.time = Conductor.songPosition;
		VocalSound.play();
	}

	override function stepHit()
	{
		super.stepHit();
		if (VocalSound.time > Conductor.songPosition + 20 || VocalSound.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

	}

	function getDirectories()
	{
		var modsListPath:String = 'modsList.txt';
		var originalLength:Int = directories.length;
		if(FileSystem.exists(modsListPath))
		{
			var stuff:Array<String> = CoolUtil.coolTextFile(modsListPath);
			for (i in 0...stuff.length)
			{
				var splitName:Array<String> = stuff[i].trim().split('|');
				if(splitName[1] == '0') // Disable mod
				{
					// pussy
				}
				else // Sort mod loading order based on modsList.txt file
				{
					var path = haxe.io.Path.join([Paths.mods(), splitName[0]]);
					//trace('trying to push: ' + splitName[0]);
					if (sys.FileSystem.isDirectory(path) && !Paths.ignoreModFolders.exists(splitName[0]) && splitName[1] == '1' && !directories.contains(path))
					{
						directories.push(path);
						('pushed Directory: ' + path);
					}
				}
			}
		}
	}

	var scrollText:FlxText = null;
	var peepee:FlxTween = null;
	var peepee2:FlxTween = null;
	var poopoo:FlxTimer = null;
	function composerSlide(name)
	{
		if (peepee != null)
		{
			peepee.cancel();
		}
		if (poopoo != null)
		{
			poopoo.cancel();
		}
		if (peepee2 != null)
		{
			peepee2.cancel();
		}
		// LMFAOOOOOOOOOOO
		if (scrollText != null)
		{
			remove(scrollText);
		}
		var songName:String = name;
		var artist:String = 'NO ARTIST';
		var toAdd:String = " ~ ";
		if (curSelected == 0 || curSelected == 1 || curSelected > 3)
		{
			if (FileSystem.exists('assets/data/' + Paths.formatToSongPath(name) + '/composer.txt'))
			{
				var file:Array<String> = CoolUtil.coolTextFile('assets/data/' + Paths.formatToSongPath(name) + '/composer.txt');
				artist = file[0];
			}
			if (FileSystem.exists(Paths.getModFile('data/' + Paths.formatToSongPath(name) + '/composer.txt')))
			{
				var file:Array<String> = CoolUtil.coolTextFile('mods/data/' + Paths.formatToSongPath(name) + '/composer.txt');
				artist = file[0];
			}
		}
		if (curSelected == 2)
		{
			if (FileSystem.exists('assets/data/' + Paths.formatToSongPath(name) + '/composer.txt'))
			{
				var file:Array<String> = CoolUtil.coolTextFile('assets/data/' + Paths.formatToSongPath(name) + '/composer.txt');
				artist = file[0];
			}
			if (FileSystem.exists(Paths.getModFile('data/' + Paths.formatToSongPath(name) + '/composer.txt')))
			{
				var file:Array<String> = CoolUtil.coolTextFile(Paths.getModFile('mods/data/' + Paths.formatToSongPath(name) + '/composer.txt'));
				artist = file[0];
			}
			if (FileSystem.exists('assets/data/' + Paths.formatToSongPath(name) + '/composer-encore.txt'))
			{
				var file:Array<String> = CoolUtil.coolTextFile('assets/data/' + Paths.formatToSongPath(name) + '/composer-encore.txt');
				artist = file[0];
			}
			if (FileSystem.exists(Paths.getModFile('data/' + Paths.formatToSongPath(name) + '/composer-encore.txt')))
			{
				var file:Array<String> = CoolUtil.coolTextFile(Paths.getModFile('data/' + Paths.formatToSongPath(name) + '/composer-encore.txt'));
				artist = file[0];
			}
			toAdd = ' (ENCORE) ~ ';
		}
		if (curSelected == 3)
		{
			if (FileSystem.exists("assets/images/soundtrack/" + soundtrackList[3] + "/artists.txt"))
			{
				var file:Array<String> = CoolUtil.coolTextFile("assets/images/soundtrack/" + soundtrackList[3] + "/artists.txt");
				for (i in 0...file.length)
				{
					var split:Array<String> = file[i].split("|");
					if (songName == split[2])
					{
						songName = split[0];
						artist = split[1];
					}
				}
			}
			if (FileSystem.exists(Paths.getModFile("images/soundtrack/" + soundtrackList[3] + "/artists.txt")))
			{
				var file:Array<String> = CoolUtil.coolTextFile("assets/images/soundtrack/" + soundtrackList[3] + "/artists.txt");
				for (i in 0...file.length)
				{
					var split:Array<String> = file[i].split("|");
					if (songName == split[3])
					{
						songName = split[0];
						artist = split[1];
					}
				}
			}
		}
		scrollText = new FlxText(50, 50, songName + toAdd + artist, 42);
		scrollText.setFormat(Paths.font('vcr.ttf'), 42, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
		scrollText.x -= scrollText.width;
		scrollText.alpha = 0.5;
		scrollText.scrollFactor.set(0, 0);
		add(scrollText);
		peepee = FlxTween.tween(scrollText, {x: scrollText.x + scrollText.width, alpha: 1}, 1, {ease: FlxEase.sineOut, onComplete: function(twn:FlxTween)
		{
			poopoo = new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				peepee2 = FlxTween.tween(scrollText, {x: scrollText.x - scrollText.width, alpha: 0}, 1, {ease: FlxEase.sineIn});
			});
		}});
	}
}