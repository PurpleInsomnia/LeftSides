package;

import flash.net.FileFilter;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.text.FlxTypeText;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.utils.Assets;
import openfl.net.FileReference;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
#if sys
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

typedef EditingDialogueFile = {
	var dialogue:Array<EditingDialogueLine>;
}

typedef EditingDialogueLine = {
	var portrait:Null<String>;
	var expression:Null<String>;
	var text:Null<String>;
	var boxState:Null<String>;
	var speed:Null<Float>;
    var events:Null<Array<String>>;
}

class DialogueEditingState extends MusicBeatState
{
    var daFile:EditingDialogueFile = null;
    var curDialogue:EditingDialogueLine = null;

    // goofy ahh vars :skull:
    public var char:DialogueCharacter;
    public var box:FlxSprite;
    public var text:FlxTypeText;

    public var line:Int = 0;

    // for like....flexibility??
    public var boxGra:String = "normal";
    public var charGra:String = "bf";

    public var canPress:Bool = false;

    // for data.
    public var lines:Array<EditingDialogueLine> = [];

    public var camGame:FlxCamera;
    public var camFront:FlxCamera;

    public var fileNameThing:String = "";

    override function create()
    {
        // loads the default dialogue file.
        daFile = {
            dialogue: [
                {
                    portrait: "ben",
                    expression: "happy",
                    text: "coolswag./nmoment.",
                    boxState: "normal",
                    speed: 0.04,
                    events: []
                }
            ]
        }

        camGame = new FlxCamera(0, 0, 1280, 315);
        camFront = new FlxCamera();
		camFront.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camFront);
		FlxCamera.defaultCameras = [camGame];
        camFront.zoom = 0.75;
        camFront.y += 100;

        // using that for now.
        lines = daFile.dialogue;

        var time:Float = 0.01;

        boxGra = daFile.dialogue[0].boxState;
        charGra = daFile.dialogue[0].portrait;

        char = new DialogueCharacter(0, 0, charGra);
        char.playAnim(daFile.dialogue[0].expression);
        char.alpha = 0;
        char.cameras = [camFront];
        add(char);

        box = new FlxSprite().loadGraphic(Paths.dialogue("boxes/" + boxGra + ".png"));
        box.alpha = 0;
        box.screenCenter(X);
        box.y = (FlxG.height - box.height);
        box.cameras = [camFront];
        add(box);

        reposChar();

        text = new FlxTypeText(box.x + 20, box.y + 20, Std.int(box.width - 20), "", 42);
		text.setFormat(Paths.font(DialogueManager.font), 42, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        text.sounds = [FlxG.sound.load(Paths.sound('dialogue'), 0.6)];
        text.cameras = [camFront];
		add(text);

        makeHUDShit();

        doIntro(time);
        new FlxTimer().start(time, function(tmr:FlxTimer)
        {
            nextLine(true);
			canPress = true;
        });

        super.create();
    }

    public var dialogueInput:FlxUIInputText;
    public var portInput:FlxUIInputText;
    public var expInput:FlxUIInputText;
    public var boxInput:FlxUIInputText;
    public var eventInput:FlxUIInputText;
    public var speedInput:FlxUINumericStepper;

    public var blockInputOnFocus:Array<FlxUIInputText> = [];

    public function makeHUDShit()
    {
        var tabGroup:FlxTypedGroup<Dynamic> = new FlxTypedGroup<Dynamic>();
        add(tabGroup);

        var tabBox:FlxSprite = new FlxSprite().loadGraphic(Paths.dialogue("tabBox.png"));
        tabGroup.add(tabBox);

        dialogueInput = new FlxUIInputText(0, 25, Std.int(FlxG.width / 1.5), "coolswag", 16);
        dialogueInput.screenCenter(X);
        tabGroup.add(dialogueInput);
        blockInputOnFocus.push(dialogueInput);

        var tagText:FlxText = new FlxText(dialogueInput.x, dialogueInput.y, 0, "Dialogue: ", 16);
        tagText.x -= Std.int(tagText.width);
        tabGroup.add(tagText);

        var directions:FlxText = new FlxText(20, 20, tagText.x - 20, "- Press LEFT or RIGHT to change the line.\n- Press O to remove a line\n- Press P to add a line", 16);
        directions.setFormat(Paths.font("vcr.ttf"), 16, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        add(directions);

        portInput = new FlxUIInputText(0, 75, 320, "ben", 16);
        portInput.screenCenter(X);
        tabGroup.add(portInput);
        blockInputOnFocus.push(portInput);

        var tagText:FlxText = new FlxText(portInput.x, portInput.y, 0, "Portrait: ", 16);
        tagText.x -= Std.int(tagText.width);
        tabGroup.add(tagText);

        expInput = new FlxUIInputText(0, 125, 320, "happy", 16);
        expInput.screenCenter(X);
        tabGroup.add(expInput);
        blockInputOnFocus.push(expInput);

        var tagText:FlxText = new FlxText(expInput.x, expInput.y, 0, "Expression: ", 16);
        tagText.x -= Std.int(tagText.width);
        tabGroup.add(tagText);

        boxInput = new FlxUIInputText(0, 175, 320, "normal", 16);
        boxInput.screenCenter(X);
        tabGroup.add(boxInput);
        blockInputOnFocus.push(boxInput);

        var tagText:FlxText = new FlxText(boxInput.x, boxInput.y, 0, "Box: ", 16);
        tagText.x -= Std.int(tagText.width);
        tabGroup.add(tagText);

        eventInput = new FlxUIInputText(0, 225, 320, "", 16);
        eventInput.screenCenter(X);
        tabGroup.add(eventInput);
        blockInputOnFocus.push(eventInput);

        var tagText:FlxText = new FlxText(eventInput.x, eventInput.y, 0, "Event Name: ", 16);
        tagText.x -= Std.int(tagText.width);
        tabGroup.add(tagText);

        speedInput = new FlxUINumericStepper(320, 225, 0.005, 0.05, 0, 0.5, 3);
        speedInput.screenCenter(X);
        speedInput.x += 450;
        add(speedInput);

        var tagText:FlxText = new FlxText(speedInput.x, speedInput.y, 0, "Speed: ", 16);
        tagText.x -= Std.int(tagText.width);
        tabGroup.add(tagText);

        var button1:FlxButton = new FlxButton(0, 0, "SAVE", saveDialogue);
        button1.y = Std.int(tabBox.height - button1.height);
        button1.screenCenter(X);
        button1.x -= Std.int(button1.width / 2);
        tabGroup.add(button1);

        var button1:FlxButton = new FlxButton(0, 0, "LOAD", loadDialogue);
        button1.y = Std.int(tabBox.height - button1.height);
        button1.screenCenter(X);
        button1.x += Std.int(button1.width / 2);
        tabGroup.add(button1);
    }

    var finished:Bool = false;

    override function update(elapsed:Float)
    {
        var block:Bool = false;
        for (input in blockInputOnFocus)
        {
            if (input.hasFocus)
            {
                block = true;
            }
        }
        if (canPress && block)
        {
            if (FlxG.keys.justPressed.ANY)
            {
                text.skip();
                finished = true;
                FlxG.sound.play(reloadTextSounds());
                if (char.portExists(portInput.text) && char.curCharacter != portInput.text)
                {
                    charGra = portInput.text;
                    char.reloadCharacter(charGra);
                }
                if (char.daAnim != expInput.text && char.checkExpression(expInput.text))
                {
                    char.playAnim(expInput.text);
                }
                if (FileSystem.exists(Paths.dialogue("boxes/" + boxInput.text + ".png")) && boxInput.text != boxGra)
                {
                    boxGra = boxInput.text;
                    box.loadGraphic(Paths.dialogue("boxes/" + boxInput.text + ".png"));
                }
                if (lines[line].speed != speedInput.value)
                {
                    nextLine();
                }
            }
            if (FlxG.keys.justPressed.ENTER)
            {
                dialogueInput.text += "/n";
                text.text += "/n";
            }
        }
        if (canPress && !block)
		{
            if (controls.UI_LEFT_P)
            {
				if (line != 0)
				{
                    var newLine:EditingDialogueLine = {
                        portrait: portInput.text,
                        expression: expInput.text,
                        text: dialogueInput.text,
                        boxState: boxInput.text,
                        speed: speedInput.value,
                        events: eventInput.text.split(":")
                    }
                    lines.remove(lines[line]);
                    lines.insert(line, newLine);
                	line -= 1;
                	nextLine(true);
				}
                else
                {
                    var newLine:EditingDialogueLine = {
                        portrait: portInput.text,
                        expression: expInput.text,
                        text: dialogueInput.text,
                        boxState: boxInput.text,
                        speed: speedInput.value,
                        events: eventInput.text.split(":")
                    }
                    lines.remove(lines[line]);
                    lines.insert(line, newLine);
                	line = lines.length - 1;
                	nextLine(true);
                }
            }
            if (controls.UI_RIGHT_P)
            {
				if (line < lines.length - 1)
				{
                    var newLine:EditingDialogueLine = {
                        portrait: portInput.text,
                        expression: expInput.text,
                        text: dialogueInput.text,
                        boxState: boxInput.text,
                        speed: speedInput.value,
                        events: eventInput.text.split(":")
                    }
                    lines.remove(lines[line]);
                    lines.insert(line, newLine);
                    line += 1;
                	nextLine(true);
				}
                else
                {
                    var newLine:EditingDialogueLine = {
                        portrait: portInput.text,
                        expression: expInput.text,
                        text: dialogueInput.text,
                        boxState: boxInput.text,
                        speed: speedInput.value,
                        events: eventInput.text.split(":")
                    }
                    lines.remove(lines[line]);
                    lines.insert(line, newLine);
                	line = 0;
                	nextLine(true);
                }
            }
            if (controls.ACCEPT)
            {
                finished = false;
                nextLine();
            }
            if (controls.BACK)
            {
                canPress = false;
                FlxG.sound.play(Paths.sound("cancelMenu"));
                MusicBeatState.switchState(new editors.MasterEditorMenu());
            }
            if (FlxG.keys.justPressed.O)
            {
                lines.remove(lines[line]);
                line -= 1;
                if (line < 0)
                {
                    line = lines.length - 1;
                }
                if (lines[0] == null)
                {
                    lines.insert(0, {
                        portrait: "ben",
                        expression: "happy",
                        text: "coolswag.",
                        boxState: "normal",
                        speed: 0.04,
                        events: []
                    });
                }
                nextLine();
            }
            if (FlxG.keys.justPressed.P)
            {
                lines.insert(line + 1, {
                    portrait: "ben",
                    expression: "happy",
                    text: "coolswag.",
                    boxState: "normal",
                    speed: 0.04,
                    events: []
                });
                line += 1;
                nextLine(true);
            }
		}
        super.update(elapsed);

        if (finished)
        {
            var daOut:String = checkText(dialogueInput.text);
            text.text = daOut;
        }
    }

    public function doIntro(time:Float)
    {
        FlxTween.tween(char, {alpha: 1}, time);
        FlxTween.tween(box, {alpha: 1}, time);
    }

    public function nextLine(?loading:Bool = false)
    {
        finished = false;

        if (!loading)
        {
            var newLine:EditingDialogueLine = {
                portrait: portInput.text,
                expression: expInput.text,
                text: dialogueInput.text,
                boxState: boxInput.text,
                speed: speedInput.value,
                events: eventInput.text.split(":")
            }
            lines.remove(lines[line]);
            lines.insert(line, newLine);
        }
        curDialogue = lines[line];

        if (lines[line].boxState != boxGra)
        {
            boxGra = lines[line].boxState;
            box.loadGraphic(Paths.dialogue("boxes/" + boxGra + ".png"));
        }

        if (lines[line].portrait != charGra)
        {
            charGra = lines[line].portrait;
            char.reloadCharacter(charGra);
        }
        char.playAnim(lines[line].expression);
        reposChar();

        reloadTextSounds();

        dialogueInput.text = lines[line].text;
        portInput.text = lines[line].portrait;
        expInput.text = lines[line].expression;
        boxInput.text = lines[line].boxState;
        var daReal:String = "";
        if (lines[line].events != null)
        {
            for (i in 0...lines[line].events.length)
            {
                if (i != lines[line].events.length - 1)
                {
                    daReal += lines[line].events[i] + ":";
                }
                else
                {
                    daReal += lines[line].events[i];
                }
            }
        }
        eventInput.text = daReal;
        speedInput.value = lines[line].speed;

        var toType:String = checkText(lines[line].text);
		text.font = Paths.font(DialogueManager.font);
		text.color = Std.parseInt(DialogueManager.textColor);
        text.resetText(toType);
		text.start(lines[line].speed, true);

        // prevents that stupid ass double press thing for null text :skull:
        if (toType.length < 1 || toType == "")
        {
            finished = true;
        }
		text.completeCallback = function() {
			finished = true;
		};
    }

    public function reposChar()
    {
        char.y = Std.int(box.y - (char.height - 10));
        if (char.curCharacter.startsWith("bf") || char.curCharacter.startsWith("player") || char.curCharacter.startsWith("ben") || char.curCharacter.startsWith("gf") || char.curCharacter.startsWith("tess"))
        {
			char.x = Std.int((box.x + box.width) - (char.width + 10));
        }
        else
        {
            char.x = box.x + 10;
        }
        if (char.curCharacter.startsWith("center"))
        {
            char.screenCenter(X);
        }
    }

    public function reloadTextSounds()
    {
		var soundString = 'textSounds/' + curDialogue.portrait + 'Text';
        var soundRp:String = "";
		if (FileSystem.exists('assets/dialogue/' + soundString + '.ogg') && ClientPrefs.dialogueVoices || FileSystem.exists('mods/' + Paths.currentModDirectory + '/dialogue/' + soundString + '.ogg')  && ClientPrefs.dialogueVoices)
		{
			soundRp = soundString;
			if (curDialogue.portrait == 'senpai' && curDialogue.expression == 'angry')
			{
				soundRp = 'textSounds/angrysenpaiText';
			}
			if (curDialogue.portrait == 'dad' && curDialogue.expression == 'no')
			{
				soundRp = 'textSounds/dialogue';
			}
		}
		else
		{
			soundRp = 'textSounds/dialogue';

			// I have to do this in order to minimize the amount of MBs this mod has :/
			// If you have a better solution, contact me.

			if (ClientPrefs.dialogueVoices)
			{
				switch (curDialogue.portrait)
				{
					case 'spookeez':
						if (curDialogue.expression == 'skid-default' || curDialogue.expression == 'skid-bruh' || curDialogue.expression == 'skid-point' || curDialogue.expression == 'skid-sad')
						{
							soundRp = 'textSounds/skidText';
						}
						else
						{
							soundRp = 'textSounds/pumpText';
						}
					case 'hug':
						if (curDialogue.expression == 'bf')
						{
							soundRp = 'textSounds/bfText';
						}
						else
						{
							soundRp = 'textSounds/gfText';
						}
					case 'bf-christmas' | "ben":
						soundRp = 'textSounds/bfText';
					case 'gf-christmas' | "tess":
						soundRp = 'textSounds/gfText';
					case 'dad-christmas':
						soundRp = 'textSounds/dadText';
					case 'mom-christmas':
						soundRp = 'textSounds/momText'; 
					case 'bb':
						if (curDialogue.expression.startsWith('walt'))
						{
							soundRp = 'textSounds/waltText';
						}
						if (curDialogue.expression.startsWith('jesse'))
						{
							soundRp = 'textSounds/jesseText';
						}
				}
			}
		}

		// haha funny XDDDDDDDssssss!!!111//11/
		if (curDialogue.text == ' ' || curDialogue.text.length < 1)
			soundRp = 'textSounds/dialogue';

        text.sounds = [FlxG.sound.load(Paths.dialogue(soundRp + ".ogg"), 0.2)];
        return Paths.dialogue(soundRp + ".ogg");
    }

	// swear filter stuff lol
	// I am laughing really hard by writing "cum" in this list
	var badWords:Array<String> = ['Fuck', 'Shit', 'Bitch', 'Whore', 'Damn', 'Pussy', 'Dick', 'Cum', 'Twat', 'Wanker'];
	// AH HELL NAH, FUCKING "WANKER" :skull:
	var goodWords:Array<String> = ['!#$%', '$!#%', 'Female Dog', '$&%!', 'Darn', 'Cat', 'Jerky Stick', 'Nut', '#$%!', '!#$%!#'];
	// Nut :skull:
	function checkText(swagtext:String)
	{
		var editedText:String = swagtext;
        if (swagtext.contains(Std.string("\\n")) || swagtext.contains("/") || swagtext.contains("\\"))
        {
            // no need for that shit anymore :skull:
            editedText = editedText.replace("/n", "\n");
            editedText = editedText.replace(Std.string("\n"), "\n");
            editedText = editedText.replace(Std.string("\\n"), " ");
            editedText = editedText.replace("/", "");
			editedText = editedText.replace("\\", "");
        }
		if (swagtext.contains("[USERNAME]") || swagtext.contains("USERNAME"))
		{
			editedText = editedText.replace("USERNAME", CoolUtil.username());
			editedText = editedText.replace("[USERNAME]", CoolUtil.username());
		}
		if (ClientPrefs.swearFilter)
		{
			for (i in 0...badWords.length)
			{
				var badUp:String = badWords[i].toUpperCase();
				var goodUp:String = goodWords[i].toUpperCase();
				var badLow:String = badWords[i].toLowerCase();
				var goodLow:String = goodWords[i].toLowerCase();
				if (swagtext.contains(badWords[i]))
				{
					editedText = editedText.replace(badWords[i], goodWords[i]);
				}
				if (swagtext.contains(badUp))
				{
					editedText = editedText.replace(badUp, goodUp);
				}
				if (swagtext.contains(badLow))
				{
					editedText = editedText.replace(badLow, goodLow);
				}
			}
		}
		return editedText;
	}

    var _file:FileReference = null;
	function loadDialogue() {
		var jsonFilter:FileFilter = new FileFilter('JSON', 'json');
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onLoadComplete);
		_file.addEventListener(Event.CANCEL, onLoadCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file.browse([jsonFilter]);
	}

	function onLoadComplete(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);

		#if sys
		var fullPath:String = null;
		var jsonLoaded = cast Json.parse(Json.stringify(_file)); //Exploit(???) for accessing a private variable
		if(jsonLoaded.__path != null) fullPath = jsonLoaded.__path; //I'm either a genious or dangerously dumb

		if(fullPath != null) {
			var rawJson:String = File.getContent(fullPath);
			if(rawJson != null) {
				var loadedDialog:EditingDialogueFile = cast Json.parse(rawJson);
				if(loadedDialog.dialogue != null && loadedDialog.dialogue.length > 0) //Make sure it's really a dialogue file
				{
					var cutName:String = _file.name.substr(0, _file.name.length - 5);
					lines = loadedDialog.dialogue;
                    line = 0;
                    trace(lines[0]);
					nextLine(true);
                    trace("Successfully loaded file: " + cutName);
                    fileNameThing = cutName;
					_file = null;
					return;
				}
			}
		}
		_file = null;
		#else
		trace("File couldn't be loaded! You aren't on Desktop, are you?");
		#end
	}

	/**
		* Called when the save file dialog is cancelled.
		*/
	function onLoadCancel(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Cancelled file loading.");
	}

	/**
		* Called if there is an error while saving the gameplay recording.
		*/
	function onLoadError(_):Void
	{
		_file.removeEventListener(Event.SELECT, onLoadComplete);
		_file.removeEventListener(Event.CANCEL, onLoadCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
		_file = null;
		trace("Problem loading file");
	}

	function saveDialogue() {
        var dialogueFile:EditingDialogueFile = {
            dialogue: lines
        }
		var data:String = Json.stringify(dialogueFile, "\t");
		if (data.length > 0)
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
            if (fileNameThing == "")
            {
			    _file.save(data, "dialogue.json");
            }
            else
            {
                _file.save(data, fileNameThing + ".json");
            }
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved file.");
	}

	/**
		* Called when the save file dialog is cancelled.
		*/
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
		* Called if there is an error while saving the gameplay recording.
		*/
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving file");
	}
}