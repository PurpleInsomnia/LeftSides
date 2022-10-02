package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import editors.MasterEditorMenu;
import openfl.Assets;
import sys.FileSystem;
import flixel.util.FlxTimer;

class ErrorScreenState extends FlxState
{
	var bg:FlxSprite;

	override public function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('error'));
		add(bg);

		FlxG.sound.playMusic(Paths.sound('error'));

		FlxG.camera.flash(FlxColor.WHITE, 0.5);

		new FlxTimer().start(21.35, function(tmr:FlxTimer)
		{
			glitchOut();
		});

		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	function glitchOut()
	{
		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound('errorGlitch'));
		bg.loadGraphic(Paths.image('errorGlitch'));

		new FlxTimer().start(2.66, function(tmr:FlxTimer)
		{
			Sys.exit(0);
		});
	}
}