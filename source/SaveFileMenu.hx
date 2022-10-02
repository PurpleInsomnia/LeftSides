package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxSave;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import sys.io.File;
import flixel.FlxCamera;
import flixel.ui.FlxButton;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class SaveFileMenu extends MusicBeatState
{
	var text:FlxText;
	var curSelected:Int = 0;
	var curFile:Int = 0;
	var canPress:Bool = true;

	// how may save files there are
	var list:Int = 8;

	public static var files:Array<String> = [];
	public static var iconArray:Array<SaveFileIcon> = [];
	public static var textArray:Array<FlxText> = [];

	var follow:FlxSprite;

	var fileGrp:FlxTypedGroup<Dynamic>;

	var follow0:Float;
	var followMax:Float;

	var followX:Array<Float> = [];

	var selector:FlxSprite;

	override public function create()
	{
		FlxG.sound.playMusic(Paths.music('saveFile'));

		canPress = true;
		var camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxCamera.defaultCameras = [camGame];

		curSelected = 0;
		curFile = 0;

		var emptyFiles:Bool = false;
		iconArray = [];
		followX = [];
		textArray = [];

		getFiles();

		var bg:FlxBackdrop = new FlxBackdrop(Paths.addFlxGraphic('saveFile/bg'), 1, 1, true, true, 0, 0);
		bg.screenCenter();
		bg.scrollFactor.set(1, 0);
		add(bg);
		bg.velocity.set(80, 45);

		var info:FlxText = new FlxText(0, 0, "Press LEFT or RIGHT to change files\nPress UP or Down to change the selected file's icon.\nPress ENTER to Make/Load the selected file.\nPress R to reset the selcted file\n", 32);
		info.setFormat(Paths.font('eras.ttf'), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		info.screenCenter(X);
		info.scrollFactor.set(0, 0);
		add(info);


		follow = new FlxSprite().makeGraphic(1, 1, 0x00000000);
		follow.screenCenter();
		add(follow);

		FlxG.camera.follow(follow, null, 1);


		// Haha make fun out of me for not organizing this crap LMAOOO
		followX.push(639.5 + (600 * 0));
		followX.push(639.5 + (600 * 1));
		followX.push(639.5 + (600 * 2));
		followX.push(639.5 + (600 * 3));
		followX.push(639.5 + (600 * 4));
		followX.push(639.5 + (600 * 5));
		followX.push(639.5 + (600 * 6));
		followX.push(639.5 + (600 * 7));

		selector = new FlxSprite().loadGraphic(Paths.image('saveFile/selector'));
		selector.screenCenter();
		selector.scrollFactor.set(0, 0);
		selector.y += 50;
		add(selector);

		FlxTween.tween(selector, {y: selector.y + 12.5}, 1, {type: PINGPONG, ease: FlxEase.sineInOut});

		fileGrp = new FlxTypedGroup<Dynamic>();
		add(fileGrp);

		for (i in 0...list)
		{
			var box:FlxSprite = new FlxSprite().loadGraphic(Paths.image('saveFile/box'));
			box.ID = i;
			box.screenCenter();
			box.x += (600 * i);

			var boxBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image('saveFile/boxBG'));
			boxBG.screenCenter();
			boxBG.ID = i;
			boxBG.x += (600 * i);
			fileGrp.add(boxBG);

			if (files[i] == 'empty')
			{
				var icon:SaveFileIcon = new SaveFileIcon();
				icon.load('empty');
				icon.screenCenter(X);
				icon.y = box.y;
				icon.x += (600 * i);
				icon.ID = i;
				fileGrp.add(icon);
				iconArray.push(icon);

				var text:FlxText = new FlxText(0, box.y + 150 + 25, '[EMPTY]', 16);
				text.setFormat(Paths.font('eras.ttf'), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				text.screenCenter(X);
				text.x += (600 * i);
				text.ID = i;
				textArray.push(text);
				fileGrp.add(text);
			}
			else
			{
				var icon:SaveFileIcon = new SaveFileIcon();
				icon.load(files[i]);
				icon.screenCenter(X);
				icon.y = box.y;
				icon.x += (600 * i);
				icon.ID = i;
				fileGrp.add(icon);
				iconArray.push(icon);

				var text:FlxText = new FlxText(0, box.y + 150 + 25, files[i], 16);
				text.setFormat(Paths.font('eras.ttf'), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				text.screenCenter(X);
				text.x += (600 * i);
				text.ID = i;
				textArray.push(text);
				fileGrp.add(text);
			}

			fileGrp.add(box);
		}

		for (i in 0...fileGrp.length)
		{
			fileGrp.members[i].y += 50;
			if (!ClientPrefs.lowQuality)
			{
				FlxTween.tween(fileGrp.members[i], {y: fileGrp.members[i].y - 12.5}, 1, {ease: FlxEase.sineInOut, type: PINGPONG});
			}
		}

		changeIcon(0);
		changeFile(0);

		super.create();
	}

	var isEmpty:Bool = false;
	override public function update(elapsed:Float)
	{
		if (controls.UI_LEFT_P && canPress)
		{
			changeFile(-1);
		}
		if (controls.UI_RIGHT_P && canPress)
		{
			changeFile(1);
		}
		if (controls.UI_UP_P && canPress)
		{
			changeIcon(-1);
		}
		if (controls.UI_DOWN_P && canPress)
		{
			changeIcon(1);
		}
		if (controls.ACCEPT && canPress)
		{
			canPress = false;
			if (isEmpty)
			{
				if (!files.contains(SaveFileIcon.list[curSelected]) && iconArray[curFile].name != 'EMPTY')
				{
					makeSave(SaveFileIcon.list[curSelected], curFile, curSelected);
				}
				else
				{
					if (iconArray[curFile].name != 'EMPTY')
						lime.app.Application.current.window.alert('Icon must be different to a already existing save', 'Error');
					else
						lime.app.Application.current.window.alert('Icon cannot be empty', 'Error');
				}
			}
			else
			{
				loadSave();
			}
		}
		if (controls.BACK && canPress)
		{
			FlxG.sound.music.stop();
			canPress = false;
			MusicBeatState.switchState(new options.OptionsState());
		}
		if (controls.RESET && canPress)
		{
			canPress = false;
			uSure();
		}
		super.update(elapsed);
	}

	function changeIcon(huh:Int)
	{
		if (huh != 0)
		{
			FlxG.sound.play(Paths.sound('saveFile/tilt'));

			curSelected += huh;

			if (curSelected < 0)
				curSelected = SaveFileIcon.list.length - 1;
			if (curSelected >= SaveFileIcon.list.length)
				curSelected = 0;

			iconArray[curFile].load(SaveFileIcon.list[curSelected]);
			textArray[curFile].text = SaveFileIcon.list[curSelected];
			textArray[curFile].screenCenter(X);
			textArray[curFile].x += (600 * curFile);
		}
	}

	var camFollowTween:FlxTween;
	function changeFile(huh:Int)
	{
		if (camFollowTween != null)
			camFollowTween.cancel();

		curFile += huh;

		if (huh != 0)
			FlxG.sound.play(Paths.sound('saveFile/tilt'));

		if (curFile < 0)
		{
			curFile = list - 1;
		}
		if (curFile >= list)
		{
			curFile = 0;
		}

		selector.visible = false;

		camFollowTween = FlxTween.tween(follow, {x: followX[curFile]}, 0.5, {ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
		{
			selector.visible = true;
		}});


		if (files[curFile] == 'empty')
			isEmpty = true;
		else
			isEmpty = false;
	}


	// I need to add a num so that you can have multiple saves with the same icon without the system getting confused.
	public static function makeSave(name:String, num:Int, pp:Int)
	{
		FlxG.sound.play(Paths.sound('saveFile/create'));
		var save:SaveFile = new SaveFile(name, iconArray[pp]);
		files.push(name);
		FlxG.camera.flash(0xFFFFFFFF, 1);

		var path:String = 'assets/data/saveData.leftSides';
		var file:Array<String> = CoolUtil.coolTextFile(path);

		file[0] = files[0] + '|0';

		for(i in 1...8)
		{
			if (file[i] == null)
				file[i] = 'funkin|0';
			else
				file[i] = files[i] + '|0';
		}

		file[num] = name + '|1';
		
		var content:String = file[0];

		for (i in 1...file.length)
		{
			content += '\n' + file[i];
		}
		trace('saved ' + file);
		File.saveContent(path, content);

		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxG.sound.music.stop();
			TitleState.curSaveFile = num;
			MusicBeatState.switchState(new TitleState());
		});
	}

	function loadSave()
	{
		FlxG.sound.play(Paths.sound('saveFile/load'));
		FlxG.camera.flash(0xFFFFFFFF, 1);

		var path:String = 'assets/data/saveData.leftSides';
		var file:Array<String> = CoolUtil.coolTextFile(path);

		file[0] = files[0] + '|0';

		for(i in 1...8)
		{
			if (file[i] == null)
				file[i] = 'funkin|0';
			else
				file[i] = files[i] + '|0';
		}

		if (file[curFile].contains(iconArray[curFile].name))
		{
			file[curFile] = files[curFile] + '|1';
		}
		else
		{
			file[curFile] = iconArray[curFile].name + '|1';
		}
		
		var content:String = file[0];

		for (i in 1...file.length)
		{
			content += '\n' + file[i];
		}
		trace('saved ' + file);
		File.saveContent(path, content);


		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			FlxG.sound.music.stop();
			TitleState.curSaveFile = curFile;
			MusicBeatState.switchState(new TitleState());
		});
	}

	function deleteSave()
	{
		FlxG.sound.music.stop();
		FlxG.mouse.visible = false;
		var file:Array<String> = CoolUtil.coolTextFile('assets/data/saveData.leftSides');

		file[curFile] = 'funkin|0';

		var content:String = file[0];
		for (i in 1...file.length)
		{
			content += '\n' + file[i];
		}

		File.saveContent('assets/data/saveData.leftSides', content);

		if (curFile != 0)
		{
			TitleState.curSaveFile = 0;
		}
		else
		{
			// finds the first active save file AFTER 0.
			for (i in 1...file.length)
			{
				if (!file[i].contains('funkin'))
				{
					TitleState.curSaveFile = i;
				}
			}
		}
		MusicBeatState.switchState(new TitleState());
	}

	function getFiles()
	{
		files = [];
		var file:Array<String> = CoolUtil.coolTextFile('assets/data/saveData.leftSides');
		for (i in 1...8)
		{
			if (file[i] == null || file[i].contains('funkin'))
				file[i] = 'empty';
		}
		for (i in 0...file.length)
		{
			var split:Array<String> = file[i].split('|');
			files.push(split[0]);
		}
	}

	var sBG:FlxSprite;
	var sText:FlxText;
	var sB:FlxButton;
	var nsB:FlxButton;
	function uSure()
	{
		FlxG.mouse.visible = true;

		sBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		sBG.alpha = 0.75;
		sBG.scrollFactor.set(0, 0);
		add(sBG);

		sText = new FlxText(0, 0, 'Are you sure that you want to\nreset this save file?\n', 42);
		sText.font = Paths.font('eras.ttf');
		sText.screenCenter();
		sText.y -= sText.height;
		sText.scrollFactor.set(0, 0);
		add(sText);

		sB = new FlxButton(0, 0, null, deleteSave);
		sB.loadGraphic(Paths.image('saveFile/yes'), true, 150, 75);
		sB.screenCenter();
		sB.x -= 150;
		add(sB);

		nsB = new FlxButton(0, 0, null, notSure);
		nsB.loadGraphic(Paths.image('saveFile/no'), true, 150, 75);
		nsB.screenCenter();
		nsB.x += 150;
		add(nsB);
	}

	function notSure()
	{
		FlxG.mouse.visible = false;
		remove(sBG);
		remove(sText);
		remove(sB);
		remove(nsB);
		canPress = true;
	}
}