package dlc;

import flixel.FlxG;
import haxe.ds.StringMap;

class DlcInventory
{
    public static var inventory:StringMap<InventoryList> = new StringMap<InventoryList>();

    public static function addToInventory(huh:String)
    {
        if (!inventory.exists(Paths.currentModDirectory))
        {
            inventory.set(Paths.currentModDirectory, new InventoryList());
            inventory.get(Paths.currentModDirectory).set(huh, 1);
        }
        else
        {
            if (inventory.get(Paths.currentModDirectory).exists(huh))
            {
                var cool:Int = inventory.get(Paths.currentModDirectory).get(huh);
                inventory.get(Paths.currentModDirectory).remove(huh);
                inventory.get(Paths.currentModDirectory).set(huh, inventory.get(Paths.currentModDirectory).get(huh) + 1);
            }
            else
            {
                inventory.get(Paths.currentModDirectory).set(huh, 1);
            }
        }

        FlxG.save.data.dlcInventory = inventory;

        FlxG.save.flush();
    }

    public static function getInventoryData(huh:String)
    {
        var ret:Int = 0;
        if (inventory.exists(Paths.currentModDirectory))
        {
            if (inventory.get(Paths.currentModDirectory).exists(huh))
            {
                inventory.get(Paths.currentModDirectory).get(huh);
            }
        }
        return ret;
    }

    public static function load()
    {
        if (FlxG.save.data.dlcInventory != null)
        {
            inventory = FlxG.save.data.dlcInventory;
        }
    }
}

class InventoryList extends StringMap<Int>
{
    public function new()
    {
        super();
    }
}