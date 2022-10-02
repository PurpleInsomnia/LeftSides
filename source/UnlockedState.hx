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

using StringTools;

class UnlockedState extends MusicBeatState
{
	var bg:FlxSprite;

	var canPress:Bool = true;

	var unlockGraphic:String = 'penis sex';
	var unlockThing:String = "arcade";

	public function new(unlock:String)
	{
		super();
		unlockThing = unlock;
		switch(unlock)
		{
			case 'arcade':
				unlockGraphic = 'The Arcade In The Main Menu!';
			case 'dmitri':
				if (!ClientPrefs.week8Done)
				{
					unlockGraphic = 'A Song That Might Be Usefull Later ;)';
					unlockThing = "dmitriSecret";
				}
				else
				{
					unlockGraphic = "V's Song In The Void Menu!";
				}
			case 'void':
				if (!ClientPrefs.foundDmitri)
					unlockGraphic = 'The Void Menu In The Main Menu!';
				else
					unlockGraphic = "The Void Menu In The Main Menu!\n(V's song is already in there?)";
			case 'exe':
				unlockGraphic = 'a special song!';
		}
	}

	override public function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Unlocking Something...", null);
		#end

		FlxG.sound.music.stop();

		var text:FlxText = new FlxText(0, 0, FlxG.width, "You Have Unlocked:\n", 38);
		text.font = Paths.font("eras.ttf");
		text.alignment = CENTER;
		text.text += unlockGraphic + "\n";
		text.screenCenter(X);
		add(text);

		canPress = true;

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && canPress)
		{
			canPress = false;
			if (unlockThing != 'exe')
				FlxG.sound.play(Paths.sound('confirmMenu'));
			else
				FlxG.sound.play(Paths.sound('confirmEXE'));
			switch(unlockThing)
			{
				case 'arcade':
					ClientPrefs.arcadeUnlocked = true;
				case 'dmitri' | 'dmitriSecret':
					ClientPrefs.foundDmitri = true;
				case 'void' | 'voidDmitri':
					ClientPrefs.week8Done = true;
			}
			ClientPrefs.saveSettings();
			switch(unlockThing)
			{
				case 'arcade' | 'voidDmitri':
					MusicBeatState.switchState(new MainMenuState());
				case "void":
					MusicBeatState.switchState(new TessNeedsHelp());
				case 'dmitri':
					MusicBeatState.switchState(new VoidState());
				case "dmitriSecret":
					LoadingState.loadAndSwitchState(new PlayState());
				case 'exe':
					LoadSong('Too Slow');
			}
		}

		super.update(elapsed);
	}

	function LoadSong(song:String)
	{
		var songName:String = Paths.formatToSongPath(song);
		PlayState.isVoid = false;
		PlayState.SONG = Song.loadFromJson(songName, songName);
		PlayState.storyDifficulty = 1;
		// PlayState.storyWeek = 0;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			LoadingState.loadAndSwitchState(new PlayState());
		});
	}
}