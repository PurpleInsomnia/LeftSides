package;

import flixel.FlxG;
import flixel.FlxSprite;

class Trophies
{
    // values and shit.
    // [0] = Unlocked "bool". 0 for false & 1 for true.
    // [1] = Name
    // [2] = Icon
    // [3] = Description
    var trophies:Array<Dynamic> = [
        [0, "That's How You Do It!", "gf", "Complete the Tutorial without any combo breaks"],
        [0, "Underestimated.", "dad", "Complete the Week 1 without any combo breaks"],
        [0, "Still Scared Of Them?", "spooky", "Complete the Week 2 without any combo breaks"],
        [0, "Bullied em' Back!", "pico", "Complete the Week 3 without any combo breaks"],
        [0, "Still No.", "mom", "Complete the Week 4 without any combo breaks"],
        [0, "Well- That just happed.", "winterSpooky", "Complete the Week 5 without any combo breaks"],
        [0, "Happy Holidays!", "gf", "Complete the Week 6 without any combo breaks"],
        [0, "Epic Prank!", "ron", "Complete the Week 7 without any combo breaks"],
        [0, "Breaking It Down.", "walart", "Beat Walter White, Jesse Pinkman and Saul Goodman"],
        [0, "THERE AREN'T RAPPERS IN MISSIONS!!!", "matto", "Beat Matto"],
        [0, "Twenty-Three hours left.", "alphred", "Beat Fandub Eggman"],
        [0, "I've got you...faker?", "boyfriend", "Blueball a faker(?)"],
        [0, "Breaking It Down.", "mom", "Beat"],
    ];

    public static function unlock(id:Int)
    {
        if (trophies[id][0] != 1)
        {
            var trophy:Array<Dynamic> = trophies[id];

            trophy[0] = 1;

            trophies.insert(trophy);
        }
    }
    
    public static function save()
    {
        FlxG.save.data.unlockedTrophies = trophies;
        FlxG.save.flush();
    }

    public static function load()
    {
        if (FlxG.save.data.unlockedTrophies != null)
        {
            trophies = FlxG.save.data.unlockedTrophies;
        }
    }
}