package;

import flixel.FlxG;
import flixel.FlxBasic;

class SaveFile extends FlxBasic
{
	public var name:String = 'PLAYER';
	public var icon:SaveFileIcon;

	// save data stuff :(
	public var foundDmitri:Bool = false;
	public var week8Done:Bool = false;
	public var arcadeUnlocked:Bool = false;

	public function new(name:String, icon:SaveFileIcon)
	{
		super();

		this.name = name;
		this.icon = icon;
	}

	public function save()
	{
		FlxG.save.data.foundDmitri = ClientPrefs.foundDmitri;
		FlxG.save.data.week8Done = ClientPrefs.week8Done;
		FlxG.save.data.arcadeUnlocked = ClientPrefs.arcadeUnlocked;
	}

	public function load()
	{
		if (FlxG.save.data.foundDmitri != null)
			ClientPrefs.foundDmitri = FlxG.save.data.foundDmitri;
		if (FlxG.save.data.week8Done != null)
			ClientPrefs.week8Done = FlxG.save.data.week8Done;
		if (FlxG.save.data.arcadeUnlocked != null)
			ClientPrefs.arcadeUnlocked = FlxG.save.data.arcadeUnlocked;
	}
}