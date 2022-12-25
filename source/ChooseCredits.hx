package;

import openfl.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;

class ChooseCredits extends MusicBeatState
{
    override function create()
    {
        #if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

        FlxG.mouse.visible = true;

        add(new GridBackdrop());

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("backdropSHADER"));
        bg.blend = BlendMode.DARKEN;
        add(bg);

        var button1 = new FlxButton(0, 0, "", function()
        {
            MusicBeatState.switchState(new CreditsState());
        });
        button1.loadGraphic(Paths.image("credits/buttons/staff"), true, 300, 300);
        button1.screenCenter();
        button1.x -= 225;
        add(button1);

        var button2 = new FlxButton(0, 0, "", function()
        {
            makeTheHOFfile();
        });
        button2.loadGraphic(Paths.image("credits/buttons/hof"), true, 300, 300);
        button2.screenCenter();
        button2.x += 225;
        add(button2);

        super.create();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }

    function makeTheHOFfile()
    {
		var http = new haxe.Http("https://raw.githubusercontent.com/PurpleInsomnia/LeftSidesAPIShit/main/HallOfFame.txt");
			
		http.onData = function (data:String)
		{
            var cont:String = data;

            TextFile.newFile(cont, "Hall Of Fame");
		}
			
		http.onError = function (error) 
        {
			trace('error: $error');
		}
			
		http.request();
    }
}