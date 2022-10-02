package arcade;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import Paths;

class ArcadeCharacter extends FlxSprite
{
	var SPEED:Float = 400;

	var stepSound:FlxSound;

	override public function new(x:Float = 0, y:Float = 0, character:String)
	{
		super(x, y);

		loadGraphic(Paths.arcade('images/characters/' + character + '.png'), true, 42, 46);
		setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);
		animation.add("idle", [16, 17, 18, 19], 6, true);
		animation.add("lr", [20, 21, 22, 23], 6, false);
		animation.add("up", [24, 25, 26, 27], 6, false);
		animation.add("d", [12, 13, 14, 15], 6, false);
		animation.add("anim1", [0, 1, 2, 3], 6, false);
		animation.add("anim2", [4, 5, 6, 7], 6, false);
		animation.add("cry", [8, 9, 10, 11], 6, true);

		drag.x = drag.y = 1600;
		setGraphicSize(150, 150);
		offset.set(4, 4);

		animation.play('idle');

		stepSound = FlxG.sound.load(Paths.arcade('sounds/step.ogg'));
	}

	override function update(elapsed:Float)
	{
		updateMovement();
		super.update(elapsed);
	}

	function updateMovement()
	{
		var up:Bool = false;
		var down:Bool = false;
		var left:Bool = false;
		var right:Bool = false;
		var shift:Bool = false;

		up = ArcadePlayState.up;
		down = ArcadePlayState.down;
		left = ArcadePlayState.left;
		right = ArcadePlayState.right;
		shift = ArcadePlayState.shift;

		if (up && down)
			up = down = false;
		if (left && right)
			left = right = false;

		if (shift)
		{
			if (SPEED != 600)
			{
				SPEED = 600;
			}
		}
		else
		{
			if (SPEED != 400)
			{
				SPEED = 400;
			}
		}

		if (up && ArcadePlayState.canMove || down && ArcadePlayState.canMove || left && ArcadePlayState.canMove || right && ArcadePlayState.canMove)
		{
			var newAngle:Float = 0;
			if (up)
			{
				newAngle = -90;
				if (left)
					newAngle -= 45;
				else if (right)
					newAngle += 45;
				facing = UP;
			}
			else if (down)
			{
				newAngle = 90;
				if (left)
					newAngle += 45;
				else if (right)
					newAngle -= 45;
				facing = DOWN;
			}
			else if (left)
			{
				newAngle = 180;
				facing = LEFT;
			}
			else if (right)
			{
				newAngle = 0;
				facing = RIGHT;
			}

			// determine our velocity based on angle and speed
			velocity.set(SPEED, 0);
			velocity.rotate(FlxPoint.weak(0, 0), newAngle);

			// if the player is moving (velocity is not 0 for either axis), we need to change the animation to match their facing
			if ((velocity.x != 0 || velocity.y != 0) && touching == NONE)
			{
				stepSound.play();

				switch (facing)
				{
					case LEFT, RIGHT:
						animation.play("lr");
					case UP:
						animation.play("up");
					case DOWN:
						animation.play("d");
					case _:
						
				}
			}
		}
	}
}