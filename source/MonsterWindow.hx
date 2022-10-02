import flixel.FlxG;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import flixel.group.FlxGroup.FlxTypedGroup;

class MonsterWindow extends FlxTypedGroup<Dynamic>
{
	var lePlayState:Dynamic;

	public function new(x:Int, y:Int)
	{
		super();

		var curState:Dynamic = FlxG.state;
		lePlayState = curState;

		var box:FlxSprite = new FlxSprite(x, y).loadGraphic(Paths.image('monster/errorBox'));
		box.setGraphicSize(Std.int(box.width * 2), Std.int(box.height * 2));
		add(box);

		var ok:FlxButton = new FlxButton(x, Std.int(y + (66 * 2)), '', okieDokie);
		ok.loadGraphic(Paths.image('monster/ok'), false);
		ok.setGraphicSize(Std.int(ok.width * 2), Std.int(ok.height * 2));
		ok.x = Std.int(box.getGraphicMidpoint().x - (ok.width / 2));
		ok.y -= Std.int(ok.height / 2);
		add(ok);

		FlxG.camera.shake(0.05, 0.25);
		FlxG.sound.play(Paths.sound('monster/popUp'));
	}

	public function okieDokie()
	{
		FlxG.sound.play(Paths.sound('monster/popClose'));
		FlxG.camera.shake(0.025, 0.25);
		if (!lePlayState.closedTabs)
		{
			lePlayState.closedTabs = true;
		}
		remove(this);
		kill();
	}
}