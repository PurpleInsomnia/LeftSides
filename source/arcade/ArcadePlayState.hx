package arcade;

import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import flixel.addons.text.FlxTypeText;
import filters.Scanline;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;

using StringTools;

class ArcadePlayState extends MusicBeatState
{
	public static var curStory:String = 'worstDay';

	var character:ArcadeCharacter;

	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;

	public static var curRoom:Int = 0;

	public static var canMove:Bool = false;

	var doors:FlxTypedGroup<UnlockedDoor>;

	var lockedDoors:FlxTypedGroup<LockedDoor>;

	var cutscenes:FlxTypedGroup<CutsceneItem>;

	var characters:FlxTypedGroup<ArcadeCharacter>;

	public static var camHud:FlxCamera;
	public static var camGame:FlxCamera;

	// controls
	public static var up:Bool = false;
	public static var down:Bool = false;
	public static var left:Bool = false;
	public static var right:Bool = false;
	public static var shift:Bool = false;
	public static var accept:Bool = false;

	public static var swagDialogue:FlxTypeText;

	var inCutscene:Bool = false;

	var demoSpr:FlxSprite;

	public static var doof:FlxSprite;

	public static var doofGroup:FlxTypedGroup<Dynamic>;

	public var filters:Array<BitmapFilter> = [];
	public var filterMap:Map<String, {filter:BitmapFilter, ?onUpdate:Void->Void}>;

	override function create()
	{
		// ogmo 3 :|
		// BTW this is like my FIRST TIME using ogmo 3.
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHud = new FlxCamera();
		camHud.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHud);

		FlxCamera.defaultCameras = [camGame];

		map = new FlxOgmo3Loader(Paths.arcade(curStory + '/level.ogmo'), Paths.arcade(curStory + '/' + curRoom + '.json'));
		var group1:FlxGroup = map.loadDecals("decor", Paths.arcade(curStory + '/images'));
		add(group1);
		walls = map.loadTilemap(Paths.arcade(curStory + '/images/' + curRoom + '.png'), "walls");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, ANY);
		walls.setTileProperties(3, ANY);
		walls.setTileProperties(4, ANY);
		walls.setTileProperties(5, ANY);
		walls.setTileProperties(6, ANY);
		walls.setTileProperties(7, ANY);
		walls.setTileProperties(8, ANY);
		walls.setTileProperties(9, ANY);
		walls.setTileProperties(10, ANY);
		add(walls);

		var curChar:String = 'ben';
		switch(curStory)
		{
			case 'worstDay':
				curChar = 'ben';
			case 'upset':
				curChar = 'tess';
			case 'attempt':
				curChar = 'ben';
		}

		doors = new FlxTypedGroup<UnlockedDoor>();
		add(doors);

		lockedDoors = new FlxTypedGroup<LockedDoor>();
		add(lockedDoors);

		cutscenes = new FlxTypedGroup<CutsceneItem>();
		add(cutscenes);

		characters = new FlxTypedGroup<ArcadeCharacter>();
		add(characters);

		doofGroup = new FlxTypedGroup<Dynamic>();
		doofGroup.cameras = [camHud];
		add(doofGroup);

		character = new ArcadeCharacter(0, 0, curChar);
		var group2:FlxGroup = map.loadDecals("upperDecor", Paths.arcade(curStory + '/images'));
		add(group2);
		map.loadEntities(placeEntities, "entities");
		characters.add(character);

		FlxG.camera.follow(character, TOPDOWN, 1);

		doof = new FlxSprite().loadGraphic(Paths.arcade('images/box.png'));
		doof.y = 720 - Std.int(doof.height);
		doof.screenCenter(X);
		doof.visible = false;
		doofGroup.add(doof);

		demoSpr = new FlxSprite().loadGraphic(Paths.arcade('images/demo.png'));
		demoSpr.cameras = [camHud];
		add(demoSpr);

		crt();

		FlxG.camera.fade(FlxColor.BLACK, 0.5, true, canMove = true);

		super.create();
	}

	function placeEntities(entity:EntityData)
	{
		var x:Int = entity.x;
		var y:Int = entity.y;

		switch(entity.name)
		{
			case 'character':
				character.setPosition(x, y);
			case 'openableDoor':
				doors.add(new UnlockedDoor(x, y, entity.values.room));
			case 'lockedDoor':
				lockedDoors.add(new LockedDoor(x, y, entity.values.text));
			case 'cutscene':
				cutscenes.add(new CutsceneItem(x, y, entity.values.name, entity.values.otherString));
				
		}
	}

	public static var dialogueEnded:Bool = false;
	public static var isEnding:Bool = false;
	public static var dialogueStarted:Bool = false;
	var escape:Bool = false;
	var isPaused = false;
	override function update(elapsed:Float)
	{
		FlxG.collide(character, walls);
		FlxG.overlap(character, doors, onOpenableDoor);
		FlxG.overlap(character, lockedDoors, onLockedDoor);
		FlxG.overlap(character, cutscenes, onCutsceneOverlap);

		if (isPaused)
		{
			canMove = false;
		}

		down = FlxG.keys.anyPressed([DOWN, S]);
		up = FlxG.keys.anyPressed([UP, W]);
		left = FlxG.keys.anyPressed([LEFT, A]);
		right = FlxG.keys.anyPressed([RIGHT, D]);
		shift = FlxG.keys.anyPressed([SHIFT, X]); 
		accept = controls.ACCEPT;
		escape = FlxG.keys.anyJustPressed([ESCAPE, BACKSPACE]);

		if(accept && !isPaused)
		{
			if (dialogueEnded)
			{
				// FlxG.sound.play(Paths.arcade('sounds/accept.ogg'));
				if (!isEnding)
				{
					isEnding = true;

					swagDialogue.resetText('');
					doof.visible = false;

					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						doofGroup.remove(swagDialogue);
						if (!inCutscene)
						{
							canMove = true;
						}
					});
				}
			}
			else if (dialogueStarted)
			{
				swagDialogue.skip();
			}
		}

		if (escape && !isPaused)
		{
			isPaused = true;
			persistentUpdate = false;
			openSubState(new ArcadePause());
		}

		super.update(elapsed);
	}

	function onOpenableDoor(character:Character, door:UnlockedDoor)
	{
		if (canMove)
		{
			canMove = false;
			FlxG.sound.play(Paths.arcade('sounds/doorOpen.ogg'));
			curRoom = door.roomNum;
			camHud.fade(FlxColor.BLACK, 0.33, false, reload);
		}
	}

	function onLockedDoor(character:Character, door:LockedDoor)
	{
		if (controls.ACCEPT && canMove)
		{
			canMove = false;
			door.displayMessage(door.message);
		}
	}

	function onCutsceneOverlap(character:Character, cutscene:CutsceneItem)
	{
		if (canMove)
		{
			canMove = false;
			cutscene.start(cutscene.name, cutscene.otherString);
			cutscenes.remove(cutscene);
		}
	}

	function reload()
	{
		MusicBeatState.resetState();
	}

	public static function startDialogue(text:String)	
	{
		doof.visible = true;
		dialogueEnded = false;
		isEnding = false;
		swagDialogue = new FlxTypeText(doof.x + 16, doof.y + 16, Std.int(FlxG.width * 0.6) - 32, "", 32);
		swagDialogue.font = Paths.font('pixel.otf');
		swagDialogue.sounds = [FlxG.sound.load(Paths.arcade('sounds/text.ogg'), 0.6)];
		doofGroup.add(swagDialogue);
		swagDialogue.resetText(text);
		swagDialogue.start(0.04, true);
		dialogueStarted = true;
		swagDialogue.completeCallback = function() {
			dialogueEnded = true;
		}
	}

	public function crt(?on:Bool = true)
	{
		if (on)
		{
			filterMap = [
				"Scanline" => {
					filter: new ShaderFilter(new Scanline()),
				},
			];

			for (key in filterMap.keys())
			{
				filters.push(filterMap.get(key).filter);
			}

			camHud.setFilters(filters);
			camHud.bgColor.alpha = 0;
		}
		else
		{
			// no filters
			filters = [];
			camHud.setFilters(filters);
		}
	}
}