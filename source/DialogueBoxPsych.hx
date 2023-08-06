package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSubState;
import haxe.Json;
import haxe.format.JsonParser;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import openfl.utils.Assets;

using StringTools;

typedef FunnyDialogueFile = {
	var dialogue:Array<FunnyDialogueLine>;
}

typedef FunnyDialogueLine = {
	var portrait:Null<String>;
	var expression:Null<String>;
	var text:Null<String>;
	var boxState:Null<String>;
	var speed:Null<Float>;
	var events:Null<Array<String>>;
}

class DialogueBoxPsych extends FlxSpriteGroup
{
    var daFile:FunnyDialogueFile = null;
    var curDialogue:FunnyDialogueLine = null;

    public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;
	public var skipDialogueThing:Void->Void = null;
    public var backDialogueThing:Void->Void = null;

    // goofy ahh vars :skull:
    public var char:DialogueCharacter;
    public var box:FlxSprite;
    public var text:FlxTypeText;

    public var line:Int = 0;

    // for like....flexibility??
    public var boxGra:String = "normal";
    public var charGra:String = "bf";

    public var canPress:Bool = false;

	public var lePlayState:PlayState = null;

    public function new(file:FunnyDialogueFile, ?song:String = null, ps:PlayState)
    {
        super();

		if (ps != null)
		{
			lePlayState = ps;
		}

        var time:Float = 0.25;

        if(song != null && song != '') 
        {
			FlxG.sound.playMusic(Paths.music(song), 0);
			FlxG.sound.music.fadeIn(time / 2, 0, 1);
		}

        daFile = file;
        boxGra = daFile.dialogue[0].boxState;
        charGra = daFile.dialogue[0].portrait;

        char = new DialogueCharacter(0, 0, charGra);
        char.playAnim(daFile.dialogue[0].expression);
        char.alpha = 0;
        add(char);

        box = new FlxSprite().loadGraphic(Paths.dialogue("boxes/" + boxGra + ".png"));
        box.alpha = 0;
        box.screenCenter(X);
        box.y = (FlxG.height - box.height) - 25;
        add(box);

        reposChar();

        text = new FlxTypeText(box.x + 20, box.y + 20, Std.int(box.width - 20), "", 42);
		text.setFormat(Paths.font(DialogueManager.font), 42, 0xFFFFFFFF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF000000);
        text.sounds = [FlxG.sound.load(Paths.sound('dialogue'), 0.6)];
		add(text);

        doIntro(time);
        new FlxTimer().start(time, function(tmr:FlxTimer)
        {
            nextLine();
			canPress = true;
        });
    }

    var ended:Bool = false;

    override function update(elapsed:Float)
    {
        if (canPress)
		{
			if (ended)
			{
				if (FlxG.keys.justPressed.ENTER)
				{
					ended = false;
					line++;
                    FlxG.sound.play(Paths.sound("dialogueClose"));
					if (line >= daFile.dialogue.length)
					{
						doOutro();
					}
					else
					{
                        nextDialogueThing();
						nextLine();
					}
				}
			}
			else
			{
				if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SHIFT)
				{
					ended = true;
					text.skip();
                    skipDialogueThing();
                    FlxG.sound.play(Paths.sound("dialogueClose"));
				}
			}
			if (FlxG.keys.justPressed.ESCAPE)
			{
                text.skip();
                FlxG.sound.play(Paths.sound("dialogueSkip"));
				doOutro();
			}

            if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.BACKSPACE)
            {
				if (line != 0)
				{
                	FlxG.sound.play(Paths.sound("dialogueClose"));
                	line -= 1;
                	backDialogueThing();
                	nextLine();
				}
            }
		}
        super.update(elapsed);

		if (char.animJson != null)
        {
            if (char.animation.curAnim != null && !char.animJson.loops && char.animation.finished && !ended)
            {
                char.animation.play("idle", true);
            }
        }
    }

    public function doIntro(time:Float)
    {
        FlxTween.tween(char, {alpha: 1}, time);
        FlxTween.tween(box, {alpha: 1}, time);
    }

    public function doOutro()
    {
        canPress = false;
		FlxG.sound.music.fadeOut(0.5, 0);
        FlxTween.tween(char, {alpha: 0}, 0.5);
        FlxTween.tween(box, {alpha: 0}, 0.5);
        FlxTween.tween(text, {alpha: 0}, 0.5);
        new FlxTimer().start(0.5, function(tmr:FlxTimer)
        {
			lePlayState.callOnLuas("dialogueCompleted", []);
            finishThing();
        });
    }

    public function nextLine()
    {	
        curDialogue = daFile.dialogue[line];
        if (daFile.dialogue[line].boxState != boxGra)
        {
            boxGra = daFile.dialogue[line].boxState;
            box.loadGraphic(Paths.dialogue("boxes/" + boxGra + ".png"));
        }

        if (daFile.dialogue[line].portrait != charGra)
        {
            charGra = daFile.dialogue[line].portrait;
            char.reloadCharacter(charGra);
        }
        char.playAnim(daFile.dialogue[line].expression);
		reposChar();

        reloadTextSounds();

		if (daFile.dialogue[line].events != null)
		{
			if (daFile.dialogue[line].events[0] != null)
        	{
				if (daFile.dialogue[line].events[0] != "")
				{
            		for (event in daFile.dialogue[line].events)
            		{
                		if (lePlayState != null)
						{
							var daSplit:Array<String> = event.split(":");
							var daValues:Array<Dynamic> = [];
							for (i in 1...daSplit.length)
							{
								daValues.push(daSplit[i]);
							}
							lePlayState.callOnLuas("onDialogueEventTrigger", [daSplit[0], daValues]);
						}
            		}
				}
        	}
		}

        var toType:String = checkText(daFile.dialogue[line].text);
		text.font = Paths.font(DialogueManager.font);
		text.color = Std.parseInt(DialogueManager.textColor);
        text.resetText(toType);
		text.start(daFile.dialogue[line].speed, true);

        // prevents that stupid ass double press thing for null text :skull:
        if (toType.length < 1 || toType == "")
        {
            ended = true;
        }
		text.completeCallback = function() {
			ended = true;
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

		if (char.meta != null)
		{
			switch (char.meta.position.toLowerCase())
			{
				case "right":
					char.x = Std.int((box.x + box.width) - (char.width + 10));
				case "left":
					char.x = box.x + 10;
				case "center":
					char.screenCenter(X);
			}
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
            editedText = editedText.replace(Std.string("\\n"), "\n");
            editedText = editedText.replace("/n", "\n");
			editedText = editedText.replace("\\", "\n");
			editedText = editedText.replace("/", " ");
        }
		if (swagtext.contains("[USERNAME]") || swagtext.contains("USERNAME"))
		{
			editedText = editedText.replace("USERNAME", CoolUtil.username());
			editedText = editedText.replace("[USERNAME]", CoolUtil.username());
		}
		if (swagtext.contains("[PLAYERNAME]") || swagtext.contains("PLAYERNAME"))
		{
			editedText = editedText.replace("PLAYERNAME", NameBox.playerName);
			editedText = editedText.replace("[PLAYERNAME]", NameBox.playerName);
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

    public static function loadDialogue(path:String):FunnyDialogueFile
    {
		if (FileSystem.exists(path.replace(".json", ".txt")))
		{
			var theData:Array<FunnyDialogueLine> = [];
			var raw:Array<String> = CoolUtil.coolTextFile(path.replace(".json", ".txt"));
			for (i in 0...raw.length)
			{
				var split:Array<String> = raw[i].split("|");
				if (split[4] == null)
				{
					split[4] = "normal";
				}
				if (split[5] == null)
				{
					split[5] = "0.05";
				}
				if (split[6] == null)
				{
					split[6] = "";
				}
				var line:FunnyDialogueLine = {
					portrait: split[1],
					expression: split[2],
					text: split[3],
					boxState: split[4],
					speed: Std.parseFloat(split[5]),
					events: split[6].split(":")
				}
				theData.push(line);
			}
			var json:FunnyDialogueFile = {
				dialogue: theData
			}
			return cast json;
		}
        #if MODS_ALLOWED
		var rawJson = File.getContent(path);
		#else
		var rawJson = Assets.getText(path);
		#end
		return cast Json.parse(rawJson);
    }
}