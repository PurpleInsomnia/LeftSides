package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.addons.text.FlxTypeText;
import flixel.addons.ui.FlxUIInputText;
import flixel.ui.FlxButton;
import flixel.FlxCamera;
import flixel.util.FlxTimer;
import flixel.system.FlxAssets.FlxShader;
#if desktop
import Discord.DiscordClient;
#end
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import filters.*;

using StringTools;

class TerminalState extends MusicBeatState
{
	var bg:FlxSprite;
	var text:FlxSprite;

	var curResponse:String;

	var ended:Bool = true;

	var wCam:FlxCamera;

	var ask:FlxUIInputText;

	var respond:FlxTypeText;

	var isSpooky:Bool = false;
	var isStoryTelling:Bool = false;

	var camGame:FlxCamera;

	var phrases:Array<String> = [
		'Who is Ben?', 
		'Who is Tess?',
		'What is Monster?', 
		'What is Hating Simulator?',
		'What is the Void?', 
		'What are you?', 
		'Who are the Dearests?',
		'Who is the oldest Dearest daughter?',
		'What did Ben do in april?',
		'Who am I?',
		"What is on Ben's Arm?",
		"Passcodes?",
		"Are they coming?"
	];

	var responses:Array<String> = [
		'Benjamin Morgan Warner (born: March 7, 2002 | age: 19 | sex: M) is known for being the boyfriend of Tess Dearest (Daughter of famous EX rockstar, Daddy Dearest and pop-star, Mommy Mearest) AND owning a youtube channel that focuses on giving middle or high schoolers helpful tips on all things English. Benjamin also works at his local subway with his girlfriend, just to get a little extra pocket money. He has been observed (by the public) as "Confident" and "Romantic". While his girlfriend usually describes him as a "Perfect Man". Both of his parents are deceased (His mother died most recently), making his homelife very lonely. This has since changed following his girlfriend moving in after some alegations about her father were proven to be true.',
		'Tess Diana Dearest (born: June 10, 2002 | age: 19 | sex: F) is mostly known for being the shy and respectable daughter of famous EX rockstar, Daddy Dearest and pop-star, Mommy Mearest. However she is ALSO known as the girlfriend of Benjamin Warner, Her best friend since kindergarden. Tess works at her local subway with her boyfriend while focusing on becoming a lawyer at the same time. Tess graduated both middle school and high school at the top of her class despite having 162 absences (stretched across six years). The public describes her as "Quiet, but very polite whenever she speaks". Her boyfriend describes her as "Literally ******* perfect in my book" and "Lifesaving". Some alegations about her father were recently proven to be true, causing her to happily move into her boyfriend' + "'s " + 'house. She chooses to disassociate with her parents, as they quote: "Mean nothing to me anymore"',
		"[REDACTED] is a [REDACTED] that is passed on through genetics (Patient Zero is [REDACTED], she started experiencing symptoms in her late teens, probably mid 1980s). It causes people to either dream, hear and sometimes hallucinate horrifying things. Eventually, [REDACTED] tries to convince the host to commit suicide. Rare cases of [REDACTED] try to convince the host to commit suicide before creating horrifying dreams/sounds/hallucinations. If suicide is failed, the special case [REDACTED] will carry on with its horrifying creations. [REDACTED] is uncurable, but can be reduced via treatment. [GIVE UP WHILE YOU HAVE THE CHANCE]",
		'Hating Simulator is a dating simulator published by [REDACTED] in 1991. The game consists of players finding their desired school mate, and dating them. The company that made the game, [REDACTED], decided to recall ALL in-store copys of the game just 2 days after release. The reason is unknown. Legends say that the game is haunted by the spirit of a [REDACTED] employee (who always had trouble with auditory and visual hallucinations). Using the a character called "Senpai" as a vessel to kill your character, over and over again. This was never proven to be true.',
		'Huh.....what are you talking about....?',
		'Not your business.',
		'The Dearests are a famous familly of [THREE]: Ex rockstar Daddy Dearest, pop-star Mommy Mearest, and their [SINGLE DAUGHTER]. The oldest being [REDACTED], and the youngest being Tess. Daddy has been accused of physically abusing his youngest daughter. While mommy only claims that she just picked on her. Tess has agreed to show photos of her bruises, cuts, etc. in a court of law as evidence.',
		'[REDACTED] is dead.',
		"[April 19, 2021. 9:55 AM] Benjamin Morgan Warner has been brought into the ER. His friend [UPDATE: now girlfriend] Tess Diana Dearest was going to wake up Benjamin for work (Benjamin was late, which made Tess extremely concerned) when she found him bleeding on his bed with deep cuts on both of his arms. It was an absolute miricale that Bemjamin surrvived.",
		"Newmaker? Where is my house? Where is the school?.....C'mon you got the reference, right?",
		'Ben reported his cutting behaviors to the social worker that came to his hospital bed. How he LOVED to slide the cold blade of his knife into his arms/legs. Tess now wanted to check in on him every day, to make sure he reduced or stopped cutting. As of now, about twice a month he tells Tess that he sliced his skin open. He is forever reminded of his [SICK] and [DISGUSTING] actions via the scars on his body.',
		"...",
		"Close the game " + CoolUtil.username() + ". Now."
	];

	var response2:Array<String> = [
		'Sorry?',
		'No info avalible',
		"I beg your pardon?"
	];

	var spookyResponses:Array<String> = [
		'Help Me ' + CoolUtil.username() + '. Remember that time he had Tess over a few weeks after his mommy died? He excused himself to go to the restroom......Twently LONG AND PAINFUL minutes he was in there...his arms in thighs now gushing blood from the [DISGUSTING] wounds he inflicted upon himself. All because of what? He missed his mommy? And Tess was SO clueless...she never knew that one month later he would try to kill himself. Ben is truly a sick individual, and' + " dosen't " + 'even want to get help. Instead he vents EVERYTHING to that bitch who was nearly starved to death every. Single. Painful. Month. Of her life ever since she was eight years old. And yet she still thinks that EVERYTHING her father did to her, is SOMEHOW her fault. What is wrong with them ' + CoolUtil.username() + "?" + ' What the fuck is wrong with them? What the fuck is wrong with them? What the fuck is wrong with them?',
		'No Skipping ' + CoolUtil.username() + '.'
	];

	// HOLY FUCK HOW DID I WRITE ALL OF THAT?!?!

	var canExit:Bool = true;

	override public function create()
	{
		#if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Terminal", null);
		#end

		FlxG.sound.playMusic(Paths.music('terminal'));


		bg = new FlxSprite().loadGraphic(Paths.image('term/bg'));
		add(bg);

		respond = new FlxTypeText(16, 16, FlxG.width - 24, '', 24);
		respond.sounds = [FlxG.sound.load(Paths.sound('term/text'), 0.4)];
		add(respond);

		var x:FlxButton = new FlxButton(0, 0, '', x);
		x.loadGraphic(Paths.image('term/x'), true, 16, 16);
		add(x);

		var crt:FlxSprite = new FlxSprite().loadGraphic(Paths.image('term/crt'));
		add(crt);

		ask = new FlxUIInputText(0, FlxG.height - 32, FlxG.width, 'ASK?', 16);
		add(ask);

		isSpooky = false;
		isStoryTelling = false;

		FlxG.mouse.visible = true;

		super.create();
	}

	var field:String;
	override function update(elapsed:Float)
	{
		if (controls.ACCEPT && !ended)
		{
			if (!isSpooky)
			{
				FlxG.sound.play(Paths.sound('term/skip'));
				respond.skip();
			}
			else
			{
				skipText();
			}
		}
		field = ask.text.toUpperCase();
		if (FlxG.keys.anyJustPressed([ENTER]) && ended || FlxG.keys.anyJustPressed([ENTER]) && respond.text == '')
		{
			if (!isSpooky)
			{
				FlxG.sound.play(Paths.sound('term/accept'));
				for (i in 0...phrases.length)
				{
					if (field == phrases[i].toUpperCase())
					{
						correctString(i);
					}
				}
				if (field.contains('FUCK') || field.contains('SHIT') || field.contains('DICK') || field.contains('PUSSY') || field.contains('PISS') || field.contains('WHORE'))
				{
					swag('Please watch your language.');
				}
				if (field.contains(';)'))
				{
					swag('Ummmm......');
				}
				switch (field)
				{
					case 'HI' | 'HELLO':
						swag('Hello :)');
				}
			}
			else
			{
				if (!isStoryTelling)
					MusicBeatState.switchState(new TitleScreenState());
			}
		}
		super.update(elapsed);
	}

	function correctString(string:Int)
	{
		curResponse = responses[string];
		if (string != 10)
			startText();
		else
			cuttingText();
	}

	function unknown()
	{
		var rn:Int = FlxG.random.int(0, 2);
		curResponse = response2[rn];
		startText();
	}

	function swag(txt:String)
	{
		curResponse = txt;
		startText();
	}

	function startText()
	{
		ended = false;
		respond.resetText(curResponse);
		respond.start(0.04, true);
		respond.completeCallback = function() {
			ended = true;
		};
	}

	function cuttingText()
	{
		FlxG.sound.music.stop();
		ended = false;
		respond.resetText(curResponse);
		respond.start(0.045, true);
		respond.completeCallback = function() {
			canExit = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				isSpooky = true;
				isStoryTelling = true;
				spooky();
			});
		};
	}

	function spooky()
	{
		ended = false;
		var res:String = spookyResponses[0];
		respond.resetText(res);
		respond.start(0.04, true);
		respond.completeCallback = function() {
			new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				MusicBeatState.switchState(new HelpState());
			});
		};
	}

	function skipText()
	{
		var res:String = spookyResponses[1];
		respond.resetText(res);
		respond.start(0.04, true);
		respond.completeCallback = function() {
			new FlxTimer().start(3, function(tmr:FlxTimer)
			{
				spooky();
			});
		};
	}

	function x()
	{
		if (canExit)
		{
			FlxG.sound.music.stop();
			MusicBeatState.switchState(new MonsterLairState());
		}
	}
}