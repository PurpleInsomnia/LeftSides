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
import Achievements;
import editors.MasterEditorMenu;

using StringTools;

class VoidTextState extends MusicBeatState
{
	public static var string1:String = 'placeholder';
	public static var string2:String = 'placeholder_2';

	var strings:Array<String> = [string1, string2];
	var daWeirdText:FlxTypedGroup<AlphabetCool>;

	override function create()
	{
		daWeirdText = new FlxTypedGroup<AlphabetCool>();
		add(daWeirdText);

		strings = CoolUtil.coolTextFile(VoidState.textFileThing);
		
		new FlxTimer().start(5, function(tmr:FlxTimer)
		{
			var text1:AlphabetCool = new AlphabetCool(0, 720 - (70 * 3), 'Song Name: ' + strings[0], false, true);
			daWeirdText.add(text1);
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				var text2:AlphabetCool = new AlphabetCool(0, 720 - (70 * 2), 'Code Name: ' + strings[1], false, true);
				daWeirdText.add(text2);
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
					{
						LoadingState.loadAndSwitchState(new PlayState());
					});
				});
			});
		});	
	}
}
