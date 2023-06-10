package editors;

#if DISCORD
import Discord.DiscordClient;
#end
import flixel.group.FlxGroup.FlxTypedGroup;
import FunkinHscript;
import FunkinLua;
import Song.SwagSong;
import StageData.StageFile;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.BlendMode;
import sys.FileSystem;

using StringTools;

/**
 * I call this a "stage editor" at least. :/
 */
class StageEditorState extends PlayState
{
    public var name:String = "";
    public var playstate:Bool = false;
    public var daScript:Dynamic = null;
    public var daShaderScript:Dynamic = null;
    public var daData:StageFile = null;
    public var daSong:SwagSong = null;

    // hud shit.
    public var input:FlxUIInputText;
    public var spriteDD:FlxUIDropDownMenuCustom;
    public var snapToButton:FlxButton;
    public var seHudGrp:FlxSpriteGroup;
    var camFollowLol:FlxSprite;
    public var extendedMenu:ExtendedStageEditorMenu = null;

    // dynamics
    public var curSprite:Dynamic = null;
    public var cst:FlxTween = null;
    public var csc:FlxColor = 0xFFFFFFFF;
    public var csn:String = "";

    public function new(stage:String, song:SwagSong, ?playstate:Bool = true)
    {
        super();

        name = stage;
        daSong = song;
        this.playstate = playstate;
    }

    override public function create()
    {
        createBullshit();
        return;
        super.create();
    }

    public function createBullshit()
    {
        if (!playstate)
        {
            #if MODS_ALLOWED
		    Paths.destroyLoadedImages(false);
		    #end
        }
        FlxG.sound.playMusic(Paths.music('breakfast'), 0.5);

        #if desktop
        DiscordClient.changePresence("Stage Editor", name);
        #end

        FlxG.resizeWindow(1280, 720);
		WindowControl.rePosWindow();

        camGame = new FlxCamera();
		camShader = new FlxCamera();
		camVideo = new FlxCamera();
		camBars = new FlxCamera();
		camHUD = new FlxCamera();
		camInfo = new FlxCamera();
		camOther = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camBars.bgColor.alpha = 0;
		camInfo.bgColor.alpha = 0;
		camVideo.bgColor.alpha = 0;
		camShader.bgColor.alpha = 0;
		camOther.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camShader);
		FlxG.cameras.add(camVideo);
		FlxG.cameras.add(camBars);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camInfo);
		FlxG.cameras.add(camOther);

        FlxCamera.defaultCameras = [camGame];
        CustomFadeTransition.nextCamera = camOther;

        daData = StageData.getStageFile(name);
        if(daData == null) 
        {
			daData = StageData.getDefaultFile();
		}
        else
		{
			var cs:Dynamic = daData.cameraSpeed;
			if (cs == null)
			{
				daData.cameraSpeed = 1;
			}
			if (daData.cameraPositions == null)
			{
				daData.cameraPositions = {
					dad: [0, 0],
					bf: [0, 0],
					gf: [0, 0]
				}
			}
		}

        switch (name)
		{
            case 'stage':
                var bg:BGSprite = new BGSprite('fnf/stageback', -600, -200);
				add(bg);

				var stageFront:BGSprite = new BGSprite('fnf/stagefront', -650, 600);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				add(stageFront);
			case 'limo': //Week 4
				var suffix:String = '';
				var suffixReal = '';

				if (daSong.song == 'Satin Panties' || daSong.song == 'Dance Interstate')
				{
					suffix = 'SUNSET';
					suffixReal = 'Real';
					if (daSong.song == "Dance Interstate")
                    {
						suffixReal = "Realer";
                    }
					var shader = new BGSprite('limo/sunsetShader', 0, 0, 0, 0);
					shader.blend = BlendMode.MULTIPLY;
					shader.cameras = [camShader];
					add(shader);
				}

				var skyBG = new BGSprite('limo/limoSunset' + suffixReal, -120 - 3936, -150, 0.1, 0.1);
				add(skyBG);

				modchartTweens.set('limoSunsetMove', FlxTween.tween(skyBG, {x: -120}, 150, {type: LOOPING}));
				// modchartTweens.get('limoSunsetMove').active = false;

				limo = new BGSprite('limo/limoDrive' + suffix, -120, 550, 1, 1, ['Limo stage'], true);
                add(limo);

			case 'mallEvil': //Week 5 - Winter Horrorland
				var bg:BGSprite = new BGSprite('christmas/evilBG', -400, -500, 0.2, 0.2);
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:BGSprite = new BGSprite('christmas/evilTree', 300, -300, 0.2, 0.2);
				add(evilTree);

				var evilSnow:BGSprite = new BGSprite('christmas/evilSnow', -200, 700);
				add(evilSnow);

				var evilSnow2:BGSprite = new BGSprite('christmas/evilSnow', -200 - 2624, 700);
				add(evilSnow2);
        }

        var gfVersion:String = daSong.player3;
		if(gfVersion == null || gfVersion.length < 1) 
        {
			switch (name)
			{
				case 'limo':
					gfVersion = 'gf-car';
				case 'mall':
					gfVersion = 'gf-christmas';
				case 'mallEvil':
					gfVersion = 'speakers';
				case 'school' | 'schoolEvil':
					gfVersion = 'gf-pixel';
				default:
					gfVersion = 'gf';
			}
			daSong.player3 = gfVersion;
		}

        boyfriendGroup = new FlxSpriteGroup(daData.boyfriend[0], daData.boyfriend[1]);
		dadGroup = new FlxSpriteGroup(daData.opponent[0], daData.opponent[1]);
		gfGroup = new FlxSpriteGroup(daData.girlfriend[0], daData.girlfriend[1]);

        add(gfGroup);
        add(dadGroup);
        add(boyfriendGroup);

        gf = new Character(0, 0, gfVersion);
        gf.scrollFactor.set(0.95, 0.95);
        gf.x += gf.positionArray[0];
		gf.y += gf.positionArray[1];
        gfGroup.add(gf);

        dad = new Character(0, 0, daSong.player2);
        dad.x += dad.positionArray[0];
		dad.y += dad.positionArray[1];
        dadGroup.add(dad);

        boyfriend = new Boyfriend(0, 0, daSong.player1);
        boyfriend.x += boyfriend.positionArray[0];
		boyfriend.y += boyfriend.positionArray[1];
        boyfriendGroup.add(boyfriend);

        switch (name)
        {
            case "stage":
				if(!ClientPrefs.lowQuality) 
				{
					var light:BGSprite = new BGSprite("fnf/light", -600, -200, 0.9, 0.9);
					light.setGraphicSize(Std.int(light.width * 1.1));
					light.updateHitbox();
					light.alpha = 0.25;
					light.blend = BlendMode.ADD;
					light.inFront = true;
                    light.isLightSource = true;
					add(light);
					var light2:BGSprite = new BGSprite("fnf/light", -600, -200, 0.9, 0.9);
					light2.setGraphicSize(Std.int(light2.width * 1.1));
					light2.updateHitbox();
					light2.alpha = 0.25;
					light2.flipX = true;
					light2.blend = BlendMode.ADD;
					light2.inFront = true;
                    light2.isLightSource = true;
					add(light2);

					var floorLight:BGSprite = new BGSprite('fnf/stagefrontLIGHTS', -650, 600);
					floorLight.setGraphicSize(Std.int(floorLight.width * 1.1));
					floorLight.updateHitbox();
					floorLight.alpha = 0.25;
					floorLight.blend = BlendMode.ADD;
					floorLight.inFront = true;
					add(floorLight);


					var stageCurtains:BGSprite = new BGSprite('fnf/stagecurtains', -700, -300, 1.3, 1.3);
					//stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 1.1));
					stageCurtains.updateHitbox();
					stageCurtains.inFront = true;
					add(stageCurtains);
				}
        }

        if (daSong.player2 == gfVersion)
        {
            gf.visible = false;
        }

        // check stage file.
        var luaFile:String = "";
        if (!PlayState.encoreMode)
		{
			luaFile = 'stages/' + name + '.lua';
		}
		else
		{
			luaFile = 'stages/encore/' + name + '.lua';
		}

		if (!PlayState.encoreMode)
		{
			if(FileSystem.exists(Paths.modFolders(luaFile))) 
			{
				luaFile = Paths.modFolders(luaFile);
				daScript = new FunkinLua(luaFile, this);
			}
			else 
			{
				luaFile = Paths.getPreloadPath(luaFile);
				if(FileSystem.exists(luaFile)) 
				{
					daScript = new FunkinLua(luaFile, this);
				}
			}
		}
		else
		{
			if(FileSystem.exists(Paths.modFolders(luaFile))) 
			{
				luaFile = Paths.modFolders(luaFile);
				daScript = new FunkinLua(luaFile, this);
			}
			if (FileSystem.exists(Paths.getPreloadPath(luaFile)))
			{
				luaFile = Paths.getPreloadPath(luaFile); 
				daScript = new FunkinLua(luaFile, this);
			}
			if (FileSystem.exists(Paths.modFolders("stages/" + name + ".lua")))
			{
				luaFile = Paths.modFolders("stages/" + name + ".lua");
				daScript = new FunkinLua(luaFile, this);
			}
			if (FileSystem.exists(Paths.getPreloadPath("stages/" + name + ".lua")))
			{
				luaFile = Paths.getPreloadPath("stages/" + name + ".lua");
				daScript = new FunkinLua(luaFile, this);
			}
		}

		if (!PlayState.encoreMode)
		{
			if (FileSystem.exists(Paths.modFolders("stages/" + name + ".hxs")))
			{
				daScript = new FunkinHscript(Paths.modFolders("stages/" + name + ".hxs"));
			}
			else
			{
				if (FileSystem.exists(Paths.getPreloadPath("stages/" + name + ".hxs")))
				{
					daScript = new FunkinHscript(Paths.getPreloadPath("stages/" + name + ".hxs"));
				}
			}
		}
		else
		{
			if (FileSystem.exists(Paths.modFolders("stages/encore/" + name + ".hxs")))
			{
				daScript = new FunkinHscript(Paths.modFolders("stages/" + name + ".hxs"));
			}
			else
			{
				if (FileSystem.exists(Paths.getPreloadPath("stages/encore/" + name + ".hxs")))
				{
					daScript = new FunkinHscript(Paths.getPreloadPath("stages/" + name + ".hxs"));
				}
			}
		}
        if (daScript == null)
        {
            daScript = new FunkinLua(Paths.getPreloadPath("stages/dad.lua"));
        }

        if (FileSystem.exists(Paths.preloadFunny("stages/shaders/" + name + ".lua")))
        {
            daShaderScript = new FunkinLua(Paths.preloadFunny("stages/shaders/" + name + ".lua"));
        }
        else
        {
            if (FileSystem.exists(Paths.preloadFunny("stages/shaders/" + name + ".hxs")))
            {
                daShaderScript = new FunkinHscript(Paths.preloadFunny("stages/shaders/" + name + ".hxs"));
            }
        }
        FlxG.camera.zoom = daData.defaultZoom;

        camFollowLol = new FlxSprite(0, 0).makeGraphic(2, 2);
        camFollowLol.screenCenter();
        camFollowLol.blend = openfl.display.BlendMode.ADD;
        add(camFollowLol);
        FlxG.camera.follow(camFollowLol);

        var topBar:FlxSprite = new FlxSprite().makeGraphic(1280, 70, 0xFF000000);
        topBar.cameras = [camHUD];
        add(topBar);

        var bBar:FlxSprite = new FlxSprite().makeGraphic(1280, 70, 0xFF000000);
        bBar.cameras = [camHUD];
        bBar.y = 720 - 70;
        add(bBar);

        daScript.call("onCreatePost", []);
        if (daShaderScript != null)
        {
            daShaderScript.call("onCreatePost", []);
        }

        seHudGrp = new FlxSpriteGroup();
        seHudGrp.cameras = [camOther];
        add(seHudGrp);
        makeHUD();

        FlxG.mouse.defaultCamera = camOther;
        FlxG.mouse.visible = true;

        boyfriend.dance();
        dad.dance();
        gf.dance();
    }

    var snapChar:Int = 0;
    var debugText:FlxText;
    var blockInputOnFocus:Array<FlxUIInputText> = [];
    public function makeHUD()
    {
        input = new FlxUIInputText(10, 0, 620, name, 24, 0xFFFFFFFF, 0xFF5F5F5F);
        input.updateHitbox();
        input.y = Std.int(710 - input.height);
        blockInputOnFocus.push(input);
        seHudGrp.add(input);

        var label:FlxText = new FlxText(10, 0, FlxG.width - 20, "(PRESS [R] TO RELOAD) Stage Name:", 18);
        label.font = Paths.font("eras.ttf");
        label.updateHitbox();
        label.y = Std.int(input.y - label.height);
        seHudGrp.add(label);

        snapToButton = new FlxButton(0, 0, "Snap Camera.", function()
        {
            var chars:Array<String> = ["dad", "bf", "gf"];
            cameraPositionSet(chars[snapChar]);
            snapChar += 1;
            if (snapChar >= chars.length)
            {
                snapChar = 0;
            }
        });
        snapToButton.x = 640;
        snapToButton.scale.set(1.2, 1.2);
        snapToButton.updateHitbox();
        snapToButton.y = Std.int(input.y + input.height) - Std.int(snapToButton.height / 2);
        seHudGrp.add(snapToButton);

        var coolArray:Array<String> = getAllSprites();
        spriteDD = new FlxUIDropDownMenuCustom(1280 - 150, 35, FlxUIDropDownMenuCustom.makeStrIdLabelArray(coolArray, false), function(pressed:String)
        {
            // clears all data for the last curSprite.
            csn = pressed;
            if (cst != null)
            {
                cst.cancel();
            }

            if (!modchartSprites.exists(pressed))
            {
                // zaza?!
            }
            else
            {
                if (curSprite != null)
                {
                    curSprite.color = csc;
                }
                curSprite = modchartSprites.get(pressed);
                curSprite.color = 0xFFFFFFFF;
                csc = curSprite.color;
                cst = FlxTween.color(curSprite, 1.5, curSprite.color, 0xFFFF7700, {type: PINGPONG, ease: FlxEase.sineInOut, onComplete: function(twn:FlxTween)
                {
                    curSprite.color = csc;
                }});
            }
        });
        seHudGrp.add(spriteDD);

        var label2:FlxText = new FlxText(10, 0, FlxG.width - 20, "Current Sprite: ", 18);
        label2.font = Paths.font("eras.ttf");
        label2.updateHitbox();
        label2.y = spriteDD.y;
        label2.x = spriteDD.x - Std.int(label2.width);
        seHudGrp.add(label2);

        debugText = new FlxText(10, 10, 0, "Camera Pos: [" + camFollowLol.x + ", " + camFollowLol.y + "]", 18);
        debugText.font = Paths.font("eras.ttf");
        debugText.borderStyle = OUTLINE;
        debugText.borderColor = 0xFF000000;
        seHudGrp.add(debugText);

        if (gf.visible)
        {
            cameraPositionSet("gf");
        }
        else
        {
            cameraPositionSet("dad");
        }
    }

    public var canPress:Bool = true;
    public var updateUI:Bool = true;
    override public function update(elapsed:Float)
    {
        updateState(elapsed);
        if (updateUI)
        {
            updateBullshit(elapsed);
        }
        return;
        super.update(elapsed);
    }

    public var block:Bool = false;
    public function updateState(elapsed:Float)
    {
        daScript.call("onUpdate", [elapsed]);
        if (daShaderScript != null)
        {
            daShaderScript.call("onUpdate", [elapsed]);
        }
        daScript.call("onUpdatePost", [elapsed]);
        if (daShaderScript != null)
        {
            daShaderScript.call("onUpdatePost", [elapsed]);
        }

        dad.update(elapsed);
        gf.update(elapsed);
        boyfriend.update(elapsed);

        var coolArray:Array<String> = getAllSprites();
        for (i in 0...coolArray.length)
        {
            if (modchartSprites.exists(coolArray[i]))
            {
                if (coolArray[i] != csn)
                {
                    modchartSprites.get(coolArray[i]).color = 0xFFFFFFFF;
                }
            }
        }

        block = false;
        for (input in blockInputOnFocus)
        {
            if (input.hasFocus)
            {
                block = true;
            }
        }
        if (extendedMenu != null)
        {
            extendedMenu.update(elapsed);
        }
        if (block)
        {
            FlxG.sound.muteKeys = [];
			FlxG.sound.volumeDownKeys = [];
			FlxG.sound.volumeUpKeys = [];
            if(FlxG.keys.justPressed.ENTER) 
            {
				for (input in blockInputOnFocus)
                {
                    input.hasFocus = false;
                }
			}
        }

        if (canPress && !block)
        {
            if (FlxG.keys.justPressed.R)
            {
                canPress = false;
                name = input.text;
                FlxG.switchState(new StageEditorState(name, daSong, playstate));
            }
            if (FlxG.keys.justPressed.ESCAPE)
            {
                FlxG.mouse.defaultCamera = null;
                FlxG.sound.muteKeys = TitleScreenState.muteKeys;
		        FlxG.sound.volumeDownKeys = TitleScreenState.volumeDownKeys;
		        FlxG.sound.volumeUpKeys = TitleScreenState.volumeUpKeys;
                canPress = false;

                var split:Array<String> = ClientPrefs.preferedDimens.split(" x ");
				var toMod:Array<Int> = [Std.parseInt(split[0]), Std.parseInt(split[1])];
				FlxG.resizeWindow(toMod[0], toMod[1]);
				WindowControl.rePosWindow();

                if (playstate)
                {
                    MusicBeatState.switchState(new PlayState());
                }
                else
                {
                    MusicBeatState.switchState(new editors.MasterEditorMenu());
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
                }
            }
            if (FlxG.keys.justPressed.SPACE)
            {
                canPress = false;
                updateUI = false;
                extendedMenu = new ExtendedStageEditorMenu(this, function()
                {
                    new FlxTimer().start(0.001, function(tmr:FlxTimer)
                    {
                        canPress = true;
                    });
                    updateUI = true;
                    extendedMenu = null;
                });
                add(extendedMenu);
            }
            // lol funny camera.
            var move:Float = 500 * elapsed;
            if (FlxG.keys.pressed.SHIFT)
            {
                move *= 4;
            }
            if (FlxG.keys.pressed.UP)
            {
                camFollowLol.y -= move; 
            }
            if (FlxG.keys.pressed.DOWN)
            {
                camFollowLol.y += move; 
            }
            if (FlxG.keys.pressed.LEFT)
            {
                camFollowLol.x -= move; 
            }
            if (FlxG.keys.pressed.RIGHT)
            {
                camFollowLol.x += move; 
            }

            if (curSprite != null)
            {
                var moveLol:Float = 1;
                if (FlxG.keys.pressed.SHIFT)
                {
                    moveLol = 10;
                }
                if (FlxG.keys.pressed.CONTROL)
                {
                    moveLol = 100;
                }
                if (FlxG.keys.justPressed.W)
                {
                    curSprite.y -= moveLol;
                }
                if (FlxG.keys.justPressed.S)
                {
                    curSprite.y += moveLol;
                }
                if (FlxG.keys.justPressed.A)
                {
                    curSprite.x -= moveLol;
                }
                if (FlxG.keys.justPressed.D)
                {
                    curSprite.x += moveLol;
                }
            }

            var daZoom:Float = 0.05;
            if (FlxG.keys.pressed.SHIFT)
            {
                daZoom = 0.1;
            }
            if (FlxG.keys.justPressed.Q)
            {
                FlxG.camera.zoom -= daZoom;
            }
            if (FlxG.keys.justPressed.E)
            {
                FlxG.camera.zoom += daZoom;
            }
        }

        debugText.text = "Camera Position: [" + Std.int(camFollowLol.x) + ", " + Std.int(camFollowLol.y) + "]
        \nCamera Zoom: [" + FlxG.camera.zoom + "]
        \n[Arrow Keys]: Move Camera | [WASD]: Move Sprite | [ESC]: Exit | [SPACE]: EXTEND MENU";
        if (curSprite != null)
        {
            debugText.text = "Camera Position: [" + Std.int(camFollowLol.x) + ", " + Std.int(camFollowLol.y) + "]
            \nCamera Zoom: [" + FlxG.camera.zoom + "]
            \nCurrent Sprite Position: [" + curSprite.x + ", " + curSprite.y + "]
            \n[Arrow Keys]: Move Camera | [WASD]: Move Sprite | [ESC]: Exit | [SPACE]: EXTEND MENU";
        }

        for (key in modchartSprites.keys())
		{
			modchartSprites.get(key).spawnParticle(elapsed);
		}
    }

    public function getAllSprites():Array<String>
    {
        var retArray:Array<String> = [""];
        for (spr in modchartSprites.keys())
        {
            retArray.push(spr);
        }
        return retArray;
    }

    public function cameraPositionSet(char:String)
    {
        switch (char)
        {
            case "gf":
                camFollowLol.setPosition(gf.getMidpoint().x, gf.getMidpoint().y);
			    if (!fpm)
			    {
				    camFollowLol.x += gf.cameraPosition[0];
			    }
			    camFollowLol.y += gf.cameraPosition[1];

                camFollowLol.x += daData.cameraPositions.gf[0];
                camFollowLol.y += daData.cameraPositions.gf[1];
            case "dad":
                camFollowLol.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			    if (!fpm)
			    {
				    camFollowLol.x += dad.cameraPosition[0];
			    }
			    else
			    {
				    camFollowLol.x = (dad.getMidpoint().x + 100) + fpmDadOff;
			    }
			    camFollowLol.y += dad.cameraPosition[1];

                camFollowLol.x += daData.cameraPositions.dad[0];
                camFollowLol.y += daData.cameraPositions.dad[1];
            case "bf":
                camFollowLol.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
                switch (name)
		        {
			        case 'limo':
				        camFollowLol.x = boyfriend.getMidpoint().x - 300;
			        case 'mall':
				        camFollowLol.y = boyfriend.getMidpoint().y - 200;
			        case 'school' | 'schoolEvil':
				        camFollowLol.x = boyfriend.getMidpoint().x - 200;
				        camFollowLol.y = boyfriend.getMidpoint().y - 200;
		        }
		        if (!fpm)
		        {
			        camFollowLol.x -= boyfriend.cameraPosition[0];
		        }
		        else
		        {
			        camFollowLol.x = (boyfriend.getMidpoint().x + 100) + fpmBfOff;
		        }
		        camFollowLol.y += boyfriend.cameraPosition[1];

                camFollowLol.x += daData.cameraPositions.bf[0];
                camFollowLol.y += daData.cameraPositions.bf[1];
        }
    }

    public function resetCharPosition(type:Int)
    {
        switch (type)
        {
            case 0:
                dad.x += dad.positionArray[0];
		        dad.y += dad.positionArray[1];
            case 1:
                gf.x += gf.positionArray[0];
		        gf.y += gf.positionArray[1];
            case 2:
                boyfriend.x += boyfriend.positionArray[0];
		        boyfriend.y += boyfriend.positionArray[1];
        }
    }

    public function updateBullshit(elapsed:Float)
    {
        input.update(elapsed);
        snapToButton.update(elapsed);
        spriteDD.update(elapsed);
    }

    override public function onFocus():Void
    {
        return;
        super.onFocus();
    }

    override public function onFocusLost():Void
    {
        return;
        super.onFocusLost();
    }

    override function destroy()
    {
        daScript.call("onDestroy", []);
        if (daShaderScript != null)
        {
            daShaderScript.call("onDestroy", []);
        }
        daScript.stop();
        return;
        super.destroy();
    }

    override function stepHit()
    {
        return;
        super.stepHit();
    }

    override function beatHit()
    {
        return;
        super.beatHit();
    }
}

class ExtendedStageEditorMenu extends FlxTypedGroup<Dynamic>
{
    public var parent:StageEditorState = null;
    public var callback:Void->Void = null;
    public function new(state:StageEditorState, callback:Void->Void)
    {
        super();

        parent = state;
        this.callback = callback;
        cameras = [parent.camOther];

        var bg:FlxSprite = new FlxSprite().makeGraphic(1280, 720, 0xFF000000);
        bg.alpha = 0.5;
        add(bg);

        var charArray:Array<String> = [parent.daSong.player2];
        charArray = getCharacters(charArray);
        var dadDD:FlxUIDropDownMenuCustom = new FlxUIDropDownMenuCustom(40, 40, FlxUIDropDownMenuCustom.makeStrIdLabelArray(charArray, false), function(pressed:String)
        {
            parent.dad.visible = false;
            var daDad:Character = new Character(0, 0, pressed);
            parent.dadGroup.add(daDad);
            daDad.alpha = 0.00001;
            daDad.alreadyLoaded = false;
            parent.dad = daDad;
            if(!parent.dad.alreadyLoaded) 
            {
				parent.dad.alpha = 1;
				parent.dad.alreadyLoaded = true;
			}
            parent.dad.visible = true;
            parent.resetCharPosition(0);
        });
        var label:FlxText = new FlxText(40, 20, dadDD.width, "Opponent", 8);
        add(label);

        charArray = [parent.daSong.player3];
        charArray = getCharacters(charArray);
        var gfDD:FlxUIDropDownMenuCustom = new FlxUIDropDownMenuCustom(40, 90, FlxUIDropDownMenuCustom.makeStrIdLabelArray(charArray, false), function(pressed:String)
        {
            parent.gf.visible = false;
            var daGf:Character = new Character(0, 0, pressed);
            parent.gfGroup.add(daGf);
            daGf.alpha = 0.00001;
            daGf.alreadyLoaded = false;
            parent.gf = daGf;
            if(!parent.gf.alreadyLoaded) 
            {
				parent.gf.alpha = 1;
				parent.gf.alreadyLoaded = true;
			}
            parent.gf.visible = true;
            parent.resetCharPosition(1);
        });
        var label2:FlxText = new FlxText(40, 70, dadDD.width, "Girlfriend", 8);
        add(label2);

        charArray = [parent.daSong.player1];
        charArray = getCharacters(charArray);
        var bfDD:FlxUIDropDownMenuCustom = new FlxUIDropDownMenuCustom(40, 130, FlxUIDropDownMenuCustom.makeStrIdLabelArray(charArray, false), function(pressed:String)
        {
            parent.boyfriend.visible = false;
            var daBf:Boyfriend = new Boyfriend(0, 0, pressed);
            parent.boyfriendGroup.add(daBf);
            daBf.alpha = 0.00001;
            daBf.alreadyLoaded = false;
            parent.boyfriend = daBf;
            if(!parent.boyfriend.alreadyLoaded) 
            {
				parent.boyfriend.alpha = 1;
				parent.boyfriend.alreadyLoaded = true;
			}
            parent.boyfriend.visible = true;
            parent.resetCharPosition(2);
        });
        var label3:FlxText = new FlxText(40, 110, dadDD.width, "Boyfriend", 8);
        add(label3);

        add(bfDD);
        add(gfDD);
        add(dadDD);
    }

    public function getCharacters(huh:Array<String>)
    {
        var retArray = huh;
        var directories:Array<String> = [Paths.mods('characters/'), Paths.mods(Paths.currentModDirectory + '/characters/'), Paths.getPreloadPath('characters/'), Paths.mods('characters/encore/'), Paths.mods(Paths.currentModDirectory + '/characters/encore/'), Paths.getPreloadPath('characters/encore/')];
		for (i in 0...directories.length) 
        {
			var directory:String = directories[i];
			if(FileSystem.exists(directory)) 
            {
				for (file in FileSystem.readDirectory(directory)) 
                {
					var path = haxe.io.Path.join([directory, file]);
					if (!sys.FileSystem.isDirectory(path) && file.endsWith('.json')) 
                    {
						var charToCheck:String = file.substr(0, file.length - 5);
                        if (directory.endsWith("encore/"))
                        {
                            charToCheck = "encore/" + charToCheck;
                        }
						if(!retArray.contains(charToCheck)) 
                        {
							retArray.push(charToCheck);
						}
					}
				}
			}
		}
        return retArray;
    }

    var canPress:Bool = true;
    var blocked:Bool = false;
    override public function update(elapsed:Float)
    {
        if (canPress && !blocked)
        {
            if (FlxG.keys.justPressed.ESCAPE)
            {
                canPress = false;
                callback();
                parent.remove(this);
                kill();
            }
        }
        super.update(elapsed);
    }
}