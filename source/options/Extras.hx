package options;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.BlendMode;
import flixel.text.FlxText;

class Extras extends MusicBeatState
{
	var extras:Array<String> = ['How To Unlock V', 'How To Make DLC Packs', "How to make custom ui", "How to make custom side stories", "How to make custom menus", "How to make custom soundtracks", "Possible Planned DLC List"];

	var extrasGrp:FlxTypedGroup<Alphabet>;

	var canPress:Bool = true;

	var curSelected:Int = 0;

	override function create()
	{
		canPress = true;
		FlxG.sound.playMusic(Paths.music('extraHugs'), 1, true);
		makeEverythingElse();

		super.create();
	}

	function makeEverythingElse()
	{
		// lmao :)
		var pp:GridBackdrop = new GridBackdrop();
		add(pp);
		
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('backdropSHADER'));
		bg.screenCenter();
		bg.color.brightness = 0.5;
		bg.blend = BlendMode.DARKEN;
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		extrasGrp = new FlxTypedGroup<Alphabet>();
		add(extrasGrp);

		for (i in 0...extras.length)
		{
			var a:Alphabet = new Alphabet(0, 40, extras[i], true, false, 0.05, 0.5);
			a.screenCenter(X);
			a.y += 90 * i;
			a.ID = i;
			extrasGrp.add(a);
		}

		changeSelection(0);
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
			FlxG.sound.play(Paths.sound('confirmMenu'));
			switch(curSelected)
			{
				case 0:
					makeFile();
					canPress = true;
				case 1:
					makeDlcFile();
					canPress = true;
				case 2:
					makeUiFile();
					canPress = true;
				case 3:
					makeSideStoryFile();
					canPress = true;
				case 4:
					makeMenuFile();
					canPress = true;
				case 5:
					makeSoundFile();
					canPress = true;
				case 6:
					makeUpcomingFile();
					canPress = true;
			}
		}
		if (controls.BACK && canPress)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new TitleScreenState());
		}
		super.update(elapsed);
	}

	function changeSelection(huh:Int)
	{
		curSelected += huh;

		if (huh != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'));

		if (curSelected >= extras.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = extras.length - 1;

		extrasGrp.forEach(function(a:Alphabet)
		{
			if (a.ID == curSelected)
				a.alpha = 1;
			else
				a.alpha = 0.75;
		});
	}

	function makeFile()
	{
		TextFile.newFile("Okay, so there is a sprite on the left side of Pico's stage (Kinda a tan colour)\nThis sprite is clickable\nupon doing so you will be brought into the void menu\nand you can play it from there\n- PurpleInsomnia <3", "How to unlock V");
	}

	function makeDlcFile()
	{
		TextFile.newFile("This might be a little complicated BUT Dlc support will be better once V3 comes out..\n\nMake a new folder in the mods folder and name it (can be anything but it will be important)\nThen inside that folder, make a file called: ''[YOUR FOLDER NAME].leftSides''\nOn the first line of this new file put in: " + '"LEFTSIDESMODFILE"' + '\nThen on the second line, type in "LS[YOUR FOLDER NAME]LS".\nFinally (on a new line), You need a number. To make this number, you need to take the ' + "folder's name " + 'count how many letters are in it, then multiply it by 2\nAfter that use a basic psych engine mod json for names I guess.' + '\nThen get a PNG image that is 150 x 150 px and title it "icon" (You must put this in the same folder as the leftSides File)', 'How to make dlc packs');
	}

	function makeUiFile()
	{
		TextFile.newFile('~ CUSTOM STRUMS TUTORIAL ~\n \nIn the "mods/data" folder (or in your DLC' + "'s" + ' data foler) make a .txt file called "skinList.txt"\nInside here, you will enter your custom strum and splash like this:\n \n YOUR STRUM NAME FOR THE CUSTOMIZE MENU|THE FILE PATH FOR THE NOTES|THE FILE PATH FOR THE SPLASH\n \nThis should work.\n \n~ CUSTOM CINEMATIC BARS ~\n \nIn the "mods/data" folder (or in your DLC' + "'s" + ' data foler) make a .txt file called "barList.txt"\nIn here enter the name of your specified bar image that is in the "images/cinematicBars" folder\nThe bar MUST be 1280 x 720 pixels\n \n~ CUSTOM RATING SKINS ~\n \nIn the "mods/data" folder (or in your DLC' + "'s" + ' data foler) make a .txt file called "ratingList.txt"\nIn here enter the folder name for your specified rating skin (the folder MUST be placed inside "images/ratingPacks"). In this folder, put in your regular AND pixel variant of the raings: "sick", "good", "bad" and "shit".\n \nMake sure that if the DLC you are making is ONLY UI Stuff (Replacing Images, Stages, Songs, Sounds, Music, etc)\nThen be sure to either Remove the "weeks" folder OR put a file in your dlc directory titled "isAssetMod.leftSides"', "CUSTOM UI TUTORIAL");
	}

	function makeSideStoryFile()
	{
		TextFile.newFile('In the "mods" folder (or in your DLC' + "'s" + ' foler) make a new folder called "side-stories"\nin here, make a "images", "sounds", "music" and "data" folder as well\nTo make your side story visible in the menu, make a file and title it "sidestories.josn" (and put it in the side stories data folder), a template is avalible in the mods folder.', "Custom Side Stories");
	}

	function makeMenuFile()
	{
		TextFile.newFile('In the "mods" folder (or in your DLC' + "'s" + ' foler) make a new folder called "states".\nIn here will be your custom states...obviously.\n \nIf you want to change the menu, make a new file called "main-menu.hxs"\nIf you want to change the freeplay menu, make a new file called "freeplay.hxs"\nif you want to change the story menu, make a new file called "story-menu.hxs"\n \nThere you can use haxe/flixel to make your state.\n \nTo change states, call this function: "MusicBeatState.switchState(new INSERT WANTED STATE())". (DO NOT FORGET SEMICOLONS!!! :D)\n \nListed below are all the states you can call with MusicBeatState.\n
			MainMenuState\n
			FunnyFreeplayState\n
			OptionsState\n
			TitleState\n
			HealthLossState\n
			LoadingScreenState\n
			CustomState (note, you need to put a string of a new hscript (The ones listed earlier OR can be custom). EX. new CustomState(Paths.getModFile("states/my-new-state.hxs")) )\n
			StoryMenuState\n
			StoryEncoreState\n
			ChooseCreditsState\n
			CreditsState\n
			DoodlesState\n
			MonsterLairState\n
			DlcMenuState\n
			SelectSongTypeState\n
			SideStorySelectState\n
			SideStoryState\n
			MasterEditorMenu\n
			Thats all you really need.\n \nAnd if you want to open a reset score substate use "openSubState(new ResetScoreSubState("bopeebo", 1, "dad", 1))"\n \nAlso, you can open within the current script you are using. EX. addScript(Paths.getModFile("states/lol.hxs"))\n \nAnd if I want to close this script, I just need to call removeScript(1).\nRemember that the first script loaded is ALWAYS "0", the next is ALWAYS "1" so on so forth.\n \nYou can call "ClientPrefs" for options, "DiscordClient" for discord...\n \nIf you understand haxeflixel, you should go into the source code and enter "CustomState.hx" and find the class "StateHscript".\nWith that you can see everything that you can call. (And you could make a how to video too! :])', "How to make custom menus");
	}

	function makeSoundFile()
	{
		TextFile.newFile('In the "mods/data" folder (or in your DLC' + "'s" + ' data folder) make a .txt file called "soundtrack".\nIn this file put in something like this "FOLDERNAME|ALBUMNAME"\n \nAfter that, In the images folder, make a new folder called "soundtrack" then make a new folder in there, and name it the folder path on your .txt file.\n \nThen you can make a cover image, a bg image and the list of your tracks. (called tracks.txt).\n \n(If you are confused, look in "assets/images/soundtrack/LeftSides" for an example.)', "How to make custom soundtracks");
	}

	function makeUpcomingFile()
    {
		var http = new haxe.Http("https://raw.githubusercontent.com/PurpleInsomnia/LeftSidesAPIShit/main/PlannedDLC.txt");
			
		http.onData = function (data:String)
		{
            var cont:String = data;

            TextFile.newFile(cont, "Upcoming DLC");
		}
			
		http.onError = function (error) 
        {
			trace('error: $error');
		}
			
		http.request();
    }
}