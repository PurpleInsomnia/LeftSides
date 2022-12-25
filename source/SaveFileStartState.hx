package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import sys.io.File;

class SaveFileStartState extends MusicBeatState
{
	public static var text:FlxText;
	public static var curSelected:Int = 0;

	public static var iconArray:Array<SaveFileIcon> = [];

	public static var existingSaveData:Bool = false;

	public static var penis:FlxSprite;
	public static var sustext:FlxSprite;

	override function create()
	{
		iconArray = [];

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('saveFile/bgDark'));
		bg.alpha = 0.5;
		add(bg);

		FlxTween.tween(bg, {alpha: 1}, 1, {type: PINGPONG});

		var introText:FlxSprite = new FlxSprite().loadGraphic(Paths.image('saveFile/titleText'));
		introText.screenCenter(X);
		add(introText);

		var box:FlxSprite = new FlxSprite().loadGraphic(Paths.image('saveFile/box'));
		box.y += 75;
		box.screenCenter();

		var boxBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('saveFile/boxBG'));
		boxBG.y += 75;
		boxBG.screenCenter();
		add(boxBG);

		for (i in 0...SaveFileIcon.list.length)
		{
			var icon:SaveFileIcon = new SaveFileIcon();
			icon.load(SaveFileIcon.list[i]);
			icon.alpha = 0;
			icon.screenCenter(X);
			icon.y = box.y;
			add(icon);
			iconArray.push(icon);
		}

		text = new FlxText(0, (box.y + 150 + 25), SaveFileIcon.list[curSelected], 16);
		text.setFormat(Paths.font('eras.ttf'), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		text.screenCenter(X);
		add(text);

		add(box);

		penis = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
		penis.visible = false;
		add(penis);

		sustext = new FlxSprite().loadGraphic(Paths.image('saveFile/sussyText'));
		sustext.screenCenter();
		sustext.visible = false;
		add(sustext);

		changeIcon(0);

		super.create();
	}

	public static var canPress:Bool = true;
	public static var madeFile:Bool = false;
	public static var showed:Bool = false;
	override function update(elapsed:Float)
	{
		if (FlxG.keys.anyJustPressed([UP, W]) && canPress)
		{
			changeIcon(-1);
		}
		if (FlxG.keys.anyJustPressed([DOWN, S]) && canPress)
		{
			changeIcon(1);
		}
		if (FlxG.keys.anyJustPressed([ENTER, SPACE]) && canPress && !madeFile)
		{
			canPress = false;
			makeSave(SaveFileIcon.list[curSelected]);
			madeFile = true;
		}

		if (FlxG.keys.anyJustPressed([ENTER, SPACE]) && canPress && showed)
		{
			canPress = false;
			MusicBeatState.switchState(new TitleScreenState());
		}

		super.update(elapsed);
	}

	public static function changeIcon(huh:Int)
	{
		if (huh != 0)
			FlxG.sound.play(Paths.sound('saveFile/tilt'));

		curSelected += huh;

		if (curSelected < 0)
			curSelected = iconArray.length - 1;
		if (curSelected >= iconArray.length)
			curSelected = 0;

		for (i in 0...iconArray.length)
			iconArray[i].alpha = 0;

		iconArray[curSelected].alpha = 1;
		text.text = SaveFileIcon.list[curSelected];
		text.screenCenter(X);
	}

	public static function makeSave(name:String)
	{
		FlxG.sound.play(Paths.sound('saveFile/create'));
		var save:SaveFile = new SaveFile(name, iconArray[curSelected]);
		FlxG.camera.flash(0xFFFFFFFF, 1);
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			var path:String = 'assets/data/saveData.leftSides';
			File.saveContent(path, SaveFileIcon.list[curSelected] + '|1\nfunkin|0\nfunkin|0\nfunkin|0\nfunkin|0\nfunkin|0\nfunkin|0');
			TitleScreenState.curSaveFile = 0;
			TitleScreenState.initialized = false;
			trace('epic win!!');
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				FlxG.resetGame();
			});
		});
	}

	public static function SussyBaka()
	{
		canPress = true;
		penis.visible = true;
		sustext.visible = true;
		new FlxTimer().start(0.25, function(tmr:FlxTimer)
		{
			showed = true;
		});
	}
}