package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

class Delete
{
	public static var downScroll:Bool = false;
	public static var middleScroll:Bool = false;
	public static var showFPS:Bool = true;
	public static var flashing:Bool = true;
	public static var globalAntialiasing:Bool = true;
	public static var noteSplashes:Bool = true;
	public static var lowQuality:Bool = false;
	public static var framerate:Int = 60;
	public static var swearFilter:Bool = false;
	public static var violence:Bool = true;
	public static var jumpscares:Bool = true;
	public static var camZooms:Bool = true;
	public static var hideHud:Bool = false;
	public static var noteOffset:Int = 0;
	public static var arrowHSV:Array<Array<Int>> = [[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]];
	public static var imagesPersist:Bool = false;
	public static var ghostTapping:Bool = true;
	public static var hideTime:Bool = false;
	public static var camMove:Bool = true;
	public static var doubShake:Bool = true;
	public static var bgSprite:String = 'starscape';
	public static var pauseMusic:String = 'breakfast';
	public static var closeSound:String = 'dialogueClose';
	public static var showComboSpr:Bool = true;
	public static var shaders:Bool = true;
	public static var dialogueVoices:Bool = true;
	public static var babyShitPiss:Bool = false;
	public static var justDont:Bool = true;
	public static var colorblind:String = 'Off';
	public static var customStrum:String = 'Off';
	public static var customBar:String = 'Default';
	public static var customRating:String = 'Default';
	public static var muteMiss:Bool = false;
	public static var ukFormat:Bool = false;
	public static var noStages:Bool = false;
	public static var contentWarnings:Bool = false;

	public static var defaultKeys:Array<FlxKey> = [
		A, LEFT,			//Note Left
		S, DOWN,			//Note Down
		W, UP,				//Note Up
		D, RIGHT,			//Note Right

		A, LEFT,			//UI Left
		S, DOWN,			//UI Down
		W, UP,				//UI Up
		D, RIGHT,			//UI Right

		R, NONE,			//Reset
		ENTER, Z,		//Accept
		BACKSPACE, ESCAPE,	//Back
		ENTER, ESCAPE,		//Pause
		SHIFT, NONE	//Emote (I just got demons, cumming inside me)
	];
	//Every key has two binds, these binds are defined on defaultKeys! If you want your control to be changeable, you have to add it on ControlsSubState (inside OptionsState)'s list
	public static var keyBinds:Array<Dynamic> = [
		//Key Bind, Name for ControlsSubState
		[Control.NOTE_LEFT, 'Left'],
		[Control.NOTE_DOWN, 'Down'],
		[Control.NOTE_UP, 'Up'],
		[Control.NOTE_RIGHT, 'Right'],

		[Control.UI_LEFT, 'Left '],		//Added a space for not conflicting on ControlsSubState
		[Control.UI_DOWN, 'Down '],		//Added a space for not conflicting on ControlsSubState
		[Control.UI_UP, 'Up '],			//Added a space for not conflicting on ControlsSubState
		[Control.UI_RIGHT, 'Right '],	//Added a space for not conflicting on ControlsSubState

		[Control.RESET, 'Reset'],
		[Control.ACCEPT, 'Accept'],
		[Control.BACK, 'Back'],
		[Control.PAUSE, 'Pause'],
		[Control.EMOTE, 'Attack']
	];
	public static var lastControls:Array<FlxKey> = defaultKeys.copy();

	public static function delete() {
		ClientPrefs.downScroll = downScroll;
		ClientPrefs.middleScroll = middleScroll;
		ClientPrefs.showFPS = showFPS;
		ClientPrefs.flashing = flashing;
		ClientPrefs.globalAntialiasing = globalAntialiasing;
		ClientPrefs.noteSplashes = noteSplashes;
		ClientPrefs.lowQuality = lowQuality;
		ClientPrefs.framerate = framerate;
		ClientPrefs.swearFilter = swearFilter;
		ClientPrefs.violence = violence;
		ClientPrefs.camZooms = camZooms;
		ClientPrefs.noteOffset = noteOffset;
		ClientPrefs.hideHud = hideHud;
		ClientPrefs.arrowHSV = arrowHSV;
		ClientPrefs.imagesPersist = imagesPersist;
		ClientPrefs.ghostTapping = ghostTapping;
		ClientPrefs.hideTime = hideTime;
		ClientPrefs.jumpscares = jumpscares;
		ClientPrefs.camMove = camMove;
		ClientPrefs.doubShake = doubShake;
		ClientPrefs.bgSprite = bgSprite;
		ClientPrefs.pauseMusic = pauseMusic;
		ClientPrefs.closeSound = closeSound;
		ClientPrefs.showComboSpr = showComboSpr;
		ClientPrefs.shaders = shaders;
		ClientPrefs.dialogueVoices = dialogueVoices;
		ClientPrefs.babyShitPiss = babyShitPiss;
		ClientPrefs.colorblind = colorblind;
		ClientPrefs.justDont = justDont;
		ClientPrefs.customStrum = customStrum;
		ClientPrefs.customBar = customBar;
		ClientPrefs.customRating = customRating;
		ClientPrefs.muteMiss = muteMiss;
		ClientPrefs.ukFormat = ukFormat;
		ClientPrefs.noStages = noStages;
		ClientPrefs.contentWarnings = contentWarnings;
	}
}