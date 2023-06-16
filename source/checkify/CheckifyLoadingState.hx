package checkify;

#if DISCORD
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import sys.FileSystem;
import checkify.CheckifyPaths as CPaths;
import checkify.CheckifyPaths.CheckifyMeta;

class CheckifyLoadingState extends MusicBeatState
{
    // TO DO: Tell mfs using github api to learn the new soundtrack system.
    override function create()
    {
        #if DISCORD
        DiscordClient.changePresence("Loading Checkify Songs...", null);
        #end
        FlxG.sound.music.stop();

        var bg:FlxSprite = new FlxSprite().loadGraphic(CPaths.image("loadingBG"));
        add(bg);

        new FlxTimer().start(2, function(tmr:FlxTimer)
        {
            loadBS();
        });

        super.create();
    }

    function loadBS()
    {
        var songs:Array<Array<Dynamic>> = [];
        var data:CheckifyMeta = CheckifyPaths.loadMeta("ost");
        songs.push(["ost", CheckifyPaths.loadSongsFromData(data)]);

        var data:CheckifyMeta = CheckifyPaths.loadMeta("bonus");
        songs.push(["bonus", CheckifyPaths.loadSongsFromData(data)]);

        var data:CheckifyMeta = CheckifyPaths.loadMeta("encore");
        songs.push(["encore", CheckifyPaths.loadSongsFromData(data)]);

        var data:CheckifyMeta = CheckifyPaths.loadMeta("menu");
        songs.push(["menu", CheckifyPaths.loadSongsFromData(data)]);

        var data:CheckifyMeta = CheckifyPaths.loadMeta("insts");
        songs.push(["insts", CheckifyPaths.loadSongsFromData(data)]);

        var data:CheckifyMeta = CheckifyPaths.loadMeta("insts-encore");
        songs.push(["insts-encore", CheckifyPaths.loadSongsFromData(data)]);

        var data:CheckifyMeta = CheckifyPaths.loadMeta("exe");
        songs.push(["exe", CheckifyPaths.loadSongsFromData(data)]);

        var daModFile:Array<String> = [];
		if (FileSystem.exists("modsList.txt"))
		{
            var dmd:String = Paths.currentModDirectory;
			daModFile = CoolUtil.coolTextFile("modsList.txt");
            var modDirecs:Array<String> = [];
		    for (i in 0...daModFile.length)
		    {
			    var spl:Array<String> = daModFile[i].split("|");
			    modDirecs.push(spl[0]);
		    }
            for (i in 0...modDirecs.length)
            {
                if (FileSystem.exists("mods/" + modDirecs[i] + "/soundtracks/"))
                {
                    for (file in FileSystem.readDirectory("mods/" + modDirecs[i] + "/soundtracks/"))
                    {
                        if (FileSystem.isDirectory("mods/" + modDirecs[i] + "/soundtracks/" + file))
                        {
                            Paths.currentModDirectory = modDirecs[i];
                            var data:CheckifyMeta = CheckifyPaths.loadMeta(file);
                            songs.insert(0, [file, CheckifyPaths.loadSongsFromData(data), modDirecs[i]]);
                        }
                    }
                }
            }
            Paths.currentModDirectory = dmd;
		}

        MusicBeatState.switchState(new CheckifyState(songs));
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
    }
}