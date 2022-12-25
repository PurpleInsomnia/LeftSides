package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import sys.io.File;
import sys.FileSystem;

using StringTools;

class CreditsStateOLD extends MusicBeatState
{
	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var creditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link - BG Color
		['Left Sides Team'],
		['PurpleInsomnia', 'purpleinsomnia', 'Director, Lead Coder, Lead Artist/Animator, Lead Composer, Lead Charter, VA for Monster and [Upcoming Dlc Character]', 'https://www.youtube.com/channel/UCw1Q7T9zmJ5D3hMyhFh3lgA', 0xFFA130D0],
		['JustCam', 'cam', 'Charter for Cocoa and Senpai', '', 0xFF00EAFF],
		['nico_0716', 'nico', 'Charter for Guns', 'https://www.youtube.com/channel/UC54887rDEIZGpUXELibdSTQ', 0xFFFFFFFF],
		['Your Sour Toast', 'dmitri', 'V (New Mod Coming Soon?)', 'https://www.youtube.com/channel/UCZrlqAH631iOJuMuxPyJxLg', 0xFFFF0000],
		[''],
		['Special Thanks'],
		['You <3', 			'you', 			'Thanks For Being So Patient! ', 			'', 			0xFF454545],
		['Fan Artists', 'you', 'Amazing Fan Artwork!', '', 0xFF454545],
		[''],
		["HUGE FUCKING W's"],
		['HankKD7', 'thew', 'Showcased the mod', 'https://www.youtube.com/c/HankKD7', 0xFFFFFFFF],
		['samithew', 'thew',  'Showcased the mod', 'https://www.youtube.com/channel/UCgNfQP1rRIMQCAbhxSOo4WQ', 0xFFFFFFFF],
	];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('coolBg'));
		add(bg);

		FlxG.sound.playMusic(Paths.music('credits'));

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		// DLC SUPPORT!!!!!!
		getCreditJsons();

		// adding on to dlc support lol
		var moreCredits:Array<Dynamic> = [
			[''],
			['Psych Engine Team'],
			['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',					'https://twitter.com/Shadow_Mario_',	0xFF454545],
			['RiverOaken',			'riveroaken',		'Main Artist/Animator of Psych Engine',				'https://twitter.com/river_oaken',		0xFFC30085],
			[''],
			['Engine Contributors'],
			['SqirraRNG',			'gedehari',			'Chart Editor\'s Sound Waveform base',						'https://twitter.com/gedehari',			0xFFFF9300],
			['PolybiusProxy',		'polybiusproxy',	'.MP4 Video Loader Extension',								'https://twitter.com/polybiusproxy',	0xFFFFEAA6],
			['Keoiki',				'keoiki',			'Note Splash Animations',									'https://twitter.com/Keoiki_',			0xFFFFFFFF],
			['Smokey',				'smokey',			'Spritemap Texture Support',								'https://twitter.com/Smokey_5_',		0xFF4D5DBD],
			[''],
			["Funkin' Crew"],
			['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",				'https://twitter.com/ninja_muffin99',	0xFFF73838],
			['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",					'https://twitter.com/PhantomArcade3K',	0xFFFFBB1B],
			['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",					'https://twitter.com/evilsk8r',			0xFF53E52C],
			['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",					'https://twitter.com/kawaisprite',		0xFF6475F3]
		];

		for (i in 0...moreCredits.length)
			 creditsStuff.push(moreCredits[i]);

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
			}
		}

		var spikesFg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/spikesFG'));
		spikesFg.antialiasing = ClientPrefs.globalAntialiasing;
		spikesFg.screenCenter();
		add(spikesFg);

		FlxTween.tween(spikesFg, {x: spikesFg.x + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		bg.color = creditsStuff[curSelected][4];
		intendedColor = bg.color;
		changeSelection();

		add(new Acheivement(2, "You looked at all the cool\npeople in the credits menu!\n(you're in it)", 'credit'));

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.sound.music.stop();
			MusicBeatState.switchState(new MainMenuState());
		}
		if(controls.ACCEPT) {
			CoolUtil.browserLoad(creditsStuff[curSelected][3]);
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int = creditsStuff[curSelected][4];
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}


	// copied from WeekData.hx lmfao
	function getCreditJsons()
	{
		var disabledMods:Array<String> = [];
		var modsListPath:String = 'modsList.txt';
		var directories:Array<String> = [Paths.mods()];
		var originalLength:Int = directories.length;
		if(FileSystem.exists(modsListPath))
		{
			var stuff:Array<String> = CoolUtil.coolTextFile(modsListPath);
			for (i in 0...stuff.length)
			{
				var splitName:Array<String> = stuff[i].trim().split('|');
				if(splitName[1] == '0') // Disable mod
				{
					disabledMods.push(splitName[0]);
				}
				else // Sort mod loading order based on modsList.txt file
				{
					var path = haxe.io.Path.join([Paths.mods(), splitName[0]]);
					//trace('trying to push: ' + splitName[0]);
					if (sys.FileSystem.isDirectory(path) && !Paths.ignoreModFolders.exists(splitName[0]) && !disabledMods.contains(splitName[0]) && !directories.contains(path + '/'))
					{
						directories.push(path + '/');
						//trace('pushed Directory: ' + splitName[0]);
					}
				}
			}
		}
		for (i in 0...directories.length) {
			var file:String = directories[i] + 'data/credits.txt';
			if(FileSystem.exists(file)) {
				creditsStuff.push(['']);
				var list:Array<String> = CoolUtil.coolTextFile(file);
				for (i in 0...list.length)
				{
					var split:Array<String> = list[i].split('|');
					creditsStuff.push(split);
				}
			}
		}
	}
}
