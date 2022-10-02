import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxCamera;
#if desktop
import Discord.DiscordClient;
#end

class UpcomingState extends MusicBeatState
{
	var canPress:Bool = true;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Getting Thanked By The Devs", null);
		#end

		canPress = true;
		add(new Backdrop('upcomingBG'));

		add(new FlxSprite().loadGraphic(Paths.image('upcoming')));

		FlxG.sound.playMusic(Paths.music('simpleBreakfast'), 1, true);

		new Acheivement(20, 'Thanks Lol', 'benntess');

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && canPress)
		{
			canPress = false;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			FlxG.sound.music.stop();
			TextFile.newFile("come to freeplay if u think that your fester then me!!1!\n\n- Nuckle", "fest");
			MusicBeatState.switchState(new TitleState());
		}

		super.update(elapsed);
	}
}