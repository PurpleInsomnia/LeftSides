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
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import editors.MasterEditorMenu;

using StringTools;

class NoEscapeState extends MusicBeatState
{
	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("NO ESCAPE", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('noEscape'));
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		FlxG.sound.playMusic(Paths.music('safe'));

		FlxG.sound.music.fadeIn(4, 0, 0.7);
	}
	
	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				FlxG.sound.music.stop();
				MusicBeatState.switchState(new TitleScreenState());
			});
		}
		if (controls.BACK)
		{
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				FlxG.sound.music.stop();
				MusicBeatState.switchState(new TitleScreenState());
			});
		}
	}
}
