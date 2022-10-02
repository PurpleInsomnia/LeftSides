package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBoxUndertale extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';
	var curEvent:String = '';
	var eventString = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;
	public var skipDialogueThing:Void->Void = null;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	public function new(dialogueList:Array<String>)
	{
		super();

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		var daSong:String = PlayState.SONG.song.toLowerCase();
		trace(daSong);
		if (daSong == 'lazybones')
			FlxG.sound.playMusic(Paths.sound('muscle'), 0.25);

		box = new FlxSprite(0, 0);
		
		var hasDialog = false;

		hasDialog = true;
		box.frames = Paths.getSparrowAtlas('undertale/box');
		box.animation.addByPrefix('sans', 'sans0', 24);
		box.animation.addByPrefix('sans1', 'sans1', 24);
		box.animation.addByPrefix('sans2', 'sans2', 24);
		box.animation.addByPrefix('sans3', 'sans3', 24);
		box.animation.addByPrefix('pap', 'pap0', 24);
		box.animation.addByPrefix('pap1', 'pap1', 24);
		box.animation.addByPrefix('pap2', 'pap2', 24);
		box.animation.addByPrefix('pap3', 'pap3', 24);
		box.animation.addByPrefix('bf', 'bf0', 24);
		box.animation.addByPrefix('bf1', 'bf1', 24);
		box.animation.addByPrefix('bf2', 'bf2', 24);
		box.animation.addByPrefix('bf3', 'bf3', 24);
		box.animation.addByPrefix('gf', 'gf0', 24);
		box.animation.addByPrefix('gf1', 'gf1', 24);
		box.animation.addByPrefix('gf2', 'gf2', 24);

		if (dialogueList != null)
			this.dialogueList = dialogueList;
		else
			this.dialogueList = [':sans3:Hey buddy, it looks like you forgot to code in the dialogue file..', ':sans2:That must be embarrasing.', ':bf3:lol imagine'];
		
		if (!hasDialog)
			return;
		add(box);

		box.screenCenter(X);
		box.screenCenter(Y);
		box.y = box.y + Std.int(box.height);

		handSelect = new FlxSprite(1042, 590).loadGraphic(Paths.getPath('images/weeb/pixelUI/hand_textbox.png', IMAGE));
		handSelect.setGraphicSize(Std.int(handSelect.width * PlayState.daPixelZoom * 0.9));
		handSelect.updateHitbox();
		handSelect.visible = false;
		add(handSelect);

		swagDialogue = new FlxTypeText(box.x + Std.int(64*4), box.y + 16, Std.int(FlxG.width * 0.6) - Std.int(64 * 4), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);

		startDialogue();
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;

	override function update(elapsed:Float)
	{
		if(PlayerSettings.player1.controls.ACCEPT)
		{
			if (dialogueEnded)
			{
				remove(dialogue);
				if (dialogueList[1] == null && dialogueList[0] != null)
				{
					if (!isEnding)
					{
						isEnding = true;	

						FlxG.sound.music.fadeOut(1, 0);

						new FlxTimer().start(0.5, function(tmr:FlxTimer)
						{
							finishThing();
							kill();
						});
					}
				}
				else
				{
					dialogueList.remove(dialogueList[0]);
					startDialogue();
				}
			}
			else if (dialogueStarted)
			{
				swagDialogue.skip();
				
				if(skipDialogueThing != null) {
					skipDialogueThing();
				}
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText('* ' + dialogueList[0]);
		if (curCharacter.startsWith('sans'))
		{
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('undertale/sansText'), 0.6)];
			swagDialogue.font = Paths.font('comic.ttf');
		}
		if (curCharacter.startsWith('pap'))
		{
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('undertale/papText'), 0.6)];
			swagDialogue.font = Paths.font('pap.TTF');
		}
		if (curCharacter.startsWith('bf'))
		{
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('undertale/bfText'), 0.6)];
			swagDialogue.font = Paths.font('pixel.otf');
		}
		if (curCharacter.startsWith('gf'))
		{
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('undertale/gfText'), 0.6)];
			swagDialogue.font = Paths.font('pixel.otf');
		}
		swagDialogue.start(0.04, true);
		swagDialogue.completeCallback = function() {
			dialogueEnded = true;
		};

		box.visible = true;

		handSelect.visible = false;
		dialogueEnded = false;
		switch (curEvent)
		{
			case 'playMusic':
				FlxG.sound.playMusic(Paths.sound('undertale/' + eventString), 0.25);
			case 'playSound':
				FlxG.sound.play(Paths.sound('undertale/' + eventString));
			case 'rimshot':
				box.visible = false;
				FlxG.sound.play(Paths.sound('undertale/rimshot'));
		}

		box.animation.play(curCharacter, true);

		if(nextDialogueThing != null) {
			nextDialogueThing();
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		if (splitName.length == 3)
		{
			curCharacter = splitName[1];
			curEvent = '';
			eventString = '';
			dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
		}
		if (splitName.length == 4)
		{
			curCharacter = splitName[1];
			curEvent = splitName[2];
			eventString = '';
			dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[2].length + 3).trim();
		}
		if (splitName.length == 5)
		{
			curCharacter = splitName[1];
			curEvent = splitName[2];
			eventString = splitName[3];
			dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[2].length + splitName[3].length + 4).trim();
		}
	}
}
