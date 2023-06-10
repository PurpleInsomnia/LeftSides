package trophies;

import dlc.DlcTrophies;
import haxe.ds.StringMap;
import GameJolt.GameJoltAPI;
import flixel.FlxG;

typedef TrophiesData = {
    var sectionName:String;
    var trophies:Array<TrophyData>;
}

typedef TrophyData = {
    var name:String;
    var desc:String;
    var icon:String;
}

class TrophyUtil
{
    #if (haxe >= "4.0.0")
    public static var trophies:Map<String, Bool> = new Map();
    #else
    public static var trophies:Map<String, Bool> = new Map(String, Bool);
    #end
    public static var trophiesData:TrophiesData = null;

    public static function award(name:String, noAlert:Bool)
    {
        var dlc:Int = 0;
        var exists:Bool = false;
        for (i in 0...trophiesData.trophies.length)
        {
            if (trophiesData.trophies[i].name == name && !exists)
            {
                exists = true;
            }
        }
        if (exists)
        {
            dlc = 1;
            if (!trophies.exists(name))
            {
                trophies.set(name, true);
            }
            else
            {
                trophies.remove(name);
                trophies.set(name, true);
            }
        }

        exists = false;
        DlcTrophies.getTrophies();
        if (DlcTrophies.data != null)
        {
            for (i in 0...DlcTrophies.data.trophies.length)
            {
                if (DlcTrophies.data.trophies[i].name == name && !exists)
                {
                    exists = true;
                }
            }
            if (exists)
            {
                dlc = 2;
                if (!DlcTrophies.trophies.exists(Paths.currentModDirectory + name))
                {
                    DlcTrophies.trophies.set(Paths.currentModDirectory + name, true);
                }
                else
                {
                    DlcTrophies.trophies.remove(Paths.currentModDirectory + name);
                    DlcTrophies.trophies.set(Paths.currentModDirectory + name, true);
                }
            }
        }
        save();

        if (dlc == 0)
        {
            return;
        }

        if (!noAlert)
        {
            var daData:TrophyData = null;
            if (dlc == 1)
            {
                for (i in 0...trophiesData.trophies.length)
                {
                    if (trophiesData.trophies[i].name == name)
                    {
                        daData = trophiesData.trophies[i];
                    }
                }
            }
            if (dlc == 2)
            {
                for (i in 0...DlcTrophies.data.trophies.length)
                {
                    if (DlcTrophies.data.trophies[i].name == name)
                    {
                        daData = DlcTrophies.data.trophies[i];
                    }
                }
            }
            GameJoltAPI.alert("trophy", daData);
        }
    }

    public static function save()
    {
        FlxG.save.data.dlcTrophies = DlcTrophies.trophies;
        FlxG.save.data.trophies = trophies;
    }

    public static function load()
    {
        trophiesData = {
            sectionName: "Left Sides",
            trophies: [
                {
                    name: "That's How You Do It!",
                    desc: "Complete the Tutorial without any combo breaks.",
                    icon: "gf"
                },
                {
                    name: "Underestimated.",
                    desc: "Complete Week 1 without any combo breaks.",
                    icon: "dad"
                },
                {
                    name: "Still Scared Of Them?",
                    desc: "Complete Week 2 without any combo breaks.",
                    icon: "spookyGlitch"
                },
                {
                    name: "Bully 'em Back!",
                    desc: "Complete Week 3 without any combo breaks.",
                    icon: "pico"
                },
                {
                    name: "Pay Up!",
                    desc: "Complete Week 4 without any combo breaks.",
                    icon: "mom"
                },
                {
                    name: "Well- That Just Happend.",
                    desc: "Complete Week 5 without any combo breaks.",
                    icon: "winterSpooky"
                },
                {
                    name: "Happy Holidays!",
                    desc: "Complete Week 6 without any combo breaks.",
                    icon: "gf2"
                },
                {
                    name: "Epic Prank!!!",
                    desc: "Complete Week 7 without any combo breaks.",
                    icon: "ron"
                },
                {
                    name: "Happy Birthday, Tess!",
                    desc: "Complete Week 8 without any combo breaks.",
                    icon: "benandtess"
                },
                {
                    name: "Stay Out Of MY Teritory.",
                    desc: "Beat 'Remember My Name'",
                    icon: "walart"
                },
                {
                    name: "MILLIONS TO ONE!!!",
                    desc: "Beat 'Dense'",
                    icon: "matto"
                },
                {
                    name: "You Have Twenty-Three Hours...",
                    desc: "Beat 'Crackin Eggs'",
                    icon: "alphred"
                },
                {
                    name: "I've found you, FAKER!(?)",
                    desc: "Beat 'Doppelganger'",
                    icon: "boyfriend"
                },
                {
                    name: "You Played Almost An Hour Or Two...For This?",
                    desc: "Beat 'Too Fest'",
                    icon: "nuckle"
                },
                {
                    name: "The Cure",
                    desc: "Beat 'Isolation'",
                    icon: "lonely"
                },
                {
                    name: "How Did We Get Here, Anyways?",
                    desc: "Beat 'No Hard Feelings'",
                    icon: "sonic"
                },
                {
                    name: "The Fun Never Ends!",
                    desc: "Beat 'Endless'",
                    icon: "jabbin"
                },
                {
                    name: "Hello? Hi.",
                    desc: "Beat 'V'",
                    icon: "spoon"
                },
                {
                    name: "Exposed.",
                    desc: "Beat 'Manipulator'\n(You were NOT a fucking prostitiute at 11 years old. Shut the fuck up, manipulative cunt.)\n(Faking tourettes and stutters for attention ass bitch.)",
                    icon: "fortnite-boots"
                },
                {
                    name: "Heh, Pretty Good!",
                    desc: "Beat 'Poster Boy'",
                    icon: "tankman"
                },
                {
                    name: "Virgin Center Sides, Chad Left Sides",
                    desc: "Beat 'Beef'",
                    icon: "bootleg"
                },
                {
                    name: "This Is The Moment That Walt Became Heisenberg",
                    desc: "Beat 'Territory'",
                    icon: "waltuh"
                },
                {
                    name: "GRRRRRRRAHH. RATIOOOOOOO!!!!",
                    desc: "Beat 'Blow This Joint'",
                    icon: "lucid"
                },
                {
                    name: "August 27th, 2022",
                    desc: "Beat 'Huge Drama'\n(Good job Pyro! You managed to make through the entire song without loading any big booty fem fat TF2 mods!)",
                    icon: "pyro"
                },
                {
                    name: "Misinput.",
                    desc: "It was a misinput. Missin-CALM DOWN! YOU CALM THE FUCK DOWN! IT WAS A MISINPUT",
                    icon: "misinput"
                },
                {
                    name: "Dress Up Party.",
                    desc: "Unlock all outfits.",
                    icon: "wardrobe"
                },
                {
                    name: "Our Past Can Hurt.",
                    desc: "Read All Side Stories.",
                    icon: "side-story"
                },
                {
                    name: "Our Past Can [NO LONGER] Hurt...",
                    desc: "Complete Every Song. (Including The Encore Remixes)",
                    icon: "microphone"
                },
                {
                    name: "Smells Like Perfection.",
                    desc: "Achieve an 'S' Rank For Every Week",
                    icon: "s"
                },
                {
                    name: "Origin Stories.",
                    desc: "100% The Game.",
                    icon: "100"
                }
            ]
        }
        DlcTrophies.getTrophies();
        if (FlxG.save.data.trophies != null)
        {
            trophies = FlxG.save.data.trophies;
        }
        if (FlxG.save.data.dlcTrophies != null)
        {
            DlcTrophies.trophies = FlxG.save.data.dlcTrophies;
        }
    }
    /*
    public static function getGJ()
    {
        for (i in 0...trophiesData.trophies.length)
        {
            var daId:Int = 0;
            switch (i)
            {
                case 0:
                    daId = 178512;
                case 1:
                    daId = 178513;
                case 2:
                    daId = 178514;
                case 3:
                    daId = 178515;
                case 4:
                    daId = 178516;
                case 5:
                    daId = 178517;
                case 6:
                    daId = 178518;
                case 7:
                    daId = 178519;
                case 8:
                    daId = 178520;
                case 9:
                    daId = 178521;
                case 10:
                    daId = 178522;
                case 11:
                    daId = 178523;
                case 12:
                    daId = 178524;
                case 13:
                    daId = 178525;
                case 14:
                    daId = 178526;
                case 15:
                    daId = 178527;
                case 16:
                    daId = 178528;
                case 17:
                    daId = 178530;
                case 18:
                    daId = 178529;
                case

            }
            var ach:Bool = GameJolt.GameJoltAPI.checkTrophy(daId, true, trophiesData.trophies[i].name);
            if (ach)
            {
                if (trophies.exists(trophiesData.trophies[i].name))
                {
                    trophies.remove(trophiesData.trophies[i].name);
                }
                trophies.set(trophiesData.trophies[i].name, true);
            }
        }
    }
    */
}