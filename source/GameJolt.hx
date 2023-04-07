/*

I will be editing the API for this, meaning you have to download a git:
haxelib git tentools https://github.com/TentaRJ/tentools.git

You need to download and rebuild SysTools, I think you only need it for Windows but just get it *just in case*:
haxelib git systools https://github.com/haya3218/systools
haxelib run lime rebuild systools [windows, mac, linux]

SETUP (GameJolt):
To add your game's keys, you will need to make a file in the source folder named GJKeys.hx (filepath: ../source/GJKeys.hx)

In this file, you will need to add the GJKeys class with two public static variables, id:Int and key:String

Example:

package;
class GJKeys
{
    public static var id:Int = 	0; // Put your game's ID here
    public static var key:String = ""; // Put your game's private API key here
}

You can find your game's API key and ID code within the game page's settngs under the game API tab.

Hope this helps! -tenta

SETUP(Toasts):
To use toasts, you will need to do a few things.

Inside the Main class (Main.hx), you need to make a new variable called toastManager.
`public static var gjToastManager.GJToastManager`

Inside the setupGame function in the Main class, you will need to create the toastManager.
`gjToastManager = new GJToastManager();`
`addChild(gjToastManager);`

Toasts can be called by using `Main.gjToastManager.createToast();`

TYSM Firubii for your help! :heart:

USAGE:
To start up the API, the two commands you want to use will be:
GameJoltAPI.connect();
GameJoltAPI.authDaUser(FlxG.save.data.gjUser, FlxG.save.data.gjToken);
*You can't use the API until this step is done!*

FlxG.save.data.gjUser & gjToken are the save values for the username and token, used for logging in once someone already logs in.
Save values (gjUser & gjToken) are deleted when the player signs out with GameJoltAPI.deAuthDaUser(); and are replaced with "".

To open up the login menu, switch the state to GameJoltLogin.
Exiting the login menu will throw you back to Main Menu State. You can change this in the GameJoltLogin class.

The session will automatically start on login and will be pinged every 30 seconds.
If it isn't pinged within 120 seconds, the session automatically ends from GameJolt's side.
Thanks GameJolt, makes my life much easier! Not sarcasm!

You can give a trophy by using:
GameJoltAPI.getTrophy(trophyID);
Each trophy has an ID attached to it. Use that to give a trophy. It could be used for something like a week clear...

Hope this helps! -tenta
*/
package;

// GameJolt things
import flixel.addons.ui.FlxUIState;
import haxe.iterators.StringIterator;
import GJApi;

// Login things
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.addons.ui.FlxUIInputText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import lime.system.System;
import flixel.FlxSprite;
import flixel.ui.FlxBar;

// Toast things
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.display.BitmapData;
import openfl.text.TextField;
import openfl.display.Bitmap;
import openfl.text.TextFormat;
import openfl.Lib;
import flixel.FlxG;
import openfl.display.Sprite;

using StringTools;

#if GAMEJOLT
class GameJoltAPI // Connects to tentools.api.FlxGameJolt
{
    /**
     * Inline variable to see if the user has logged in.
     * True for logged in, false for not logged in.
     */
    static var userLogin:Bool = false;

    /**
     * Inline variable to see if the user wants to submit scores.
     */
    public static var leaderboardToggle:Bool;
    /**
     * Grabs user data and returns as a string, true for Username, false for Token
     * @param username Bool value
     * @return String 
     */
    public static function getUserInfo(username:Bool = true):String
    {
        if(username)return GJApi.username;
        else return GJApi.usertoken;
    }

    /**
     * Returns the user login status
     * @return Bool
     */
    public static function getStatus():Bool
    {
        return userLogin;
    }

    /**
     * Sets the game API key from GJKeys.api
     * Doesn't return anything
     */
    public static function connect() 
    {
        trace("Grabbing API keys...");
        GJApi.init(Std.int(GJKeys.id), Std.string(GJKeys.key), function(data:Bool){
            #if debug
            Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Game " + (data ? "authenticated!" : "not authenticated..."), (!data ? "If you are a developer, check GJKeys.hx\nMake sure the id and key are formatted correctly!" : "Yay!"), false);
            #end
        });
    }

    /**
     * Inline function to auth the user. Shouldn't be used outside of GameJoltAPI things.
     * @param in1 username
     * @param in2 token
     * @param loginArg Used in only GameJoltLogin
     */
    public static function authDaUser(in1, in2, ?loginArg:Bool = false)
    {
        if(!userLogin)
        {
            GJApi.authUser(in1, in2, function(v:Bool)
            {
                trace("user: "+(in1 == "" ? "n/a" : in1));
                trace("token:"+in2);
                if(v)
                    {
                        Main.gjToastManager.createToast(GameJoltInfo.imagePath, in1 + " signed in!", "Time: " + Date.now(), "alert");
                        trace("User authenticated!");
                        FlxG.save.data.gjUser = in1;
                        FlxG.save.data.gjToken = in2;
                        FlxG.save.flush();
                        userLogin = true;
                        startSession();
                        if(loginArg)
                        {
                            GameJoltLogin.login=true;
                            MusicBeatState.switchState(new GameJoltLogin());
                        }
                    }
                else 
                    {
                        trace("User login failure!");
                        if(loginArg)
                        {
                            GameJoltLogin.login=true;
                            MusicBeatState.switchState(new GameJoltLogin());
                        }
                        Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Not signed in!\nSign in with the options menu!", "", "alert");
                        // MusicBeatState.switchState(new GameJoltLogin());
                    }
            });
        }
    }
    
    /**
     * Inline function to deauth the user, shouldn't be used out of GameJoltLogin state!
     * @return  Logs the user out and closes the game
     */
    public static function deAuthDaUser()
    {
        closeSession();
        userLogin = false;
        trace(FlxG.save.data.gjUser + FlxG.save.data.gjToken);
        ClientPrefs.gameJoltLogin[0] = "";
        ClientPrefs.gameJoltLogin[1] = "";
        ClientPrefs.saveSettings();
        trace("Logged out!");
    }

    /**
     * Give a trophy!
     * @param trophyID Trophy ID. Check your game's API settings for trophy IDs.
     */
    public static function getTrophy(trophyID:Int, image:String) /* Awards a trophy to the user! */
    {
        if(userLogin)
        {
            GJApi.addTrophy(trophyID, function(data:Map<String,String>){
                trace(data);
                var bool:Bool = false;
                if (data.exists("message"))
                {
                    bool = true;
                }
                GJApi.fetchTrophy(trophyID, function(data2:Map<String, String>)
                {
                    if (!bool)
                        Main.gjToastManager.createToast(Paths.getLibraryPath("images/achievements/" + image + ".png"), "Trophy Earned: " + data2.get("title"), data2.get("description"), "award");
                    else
                        trace("Award " + data2.get("title") + " is already unlocked!!");
                });
            });
        }
    }

    /**
     * Checks a trophy to see if it was collected
     * @param id TrophyID
     * @return Bool (True for achieved, false for unachieved)
     */
    public static function checkTrophy(id:Int):Bool
    {
        var value:Bool = false;
        GJApi.fetchTrophy(id, function(data:Map<String, String>)
            {
                trace(data);
                if (data.get("achieved").toString() != "false")
                    value = true;
                trace(id+""+value);
            });
        return value;
    }

    public static function pullTrophy(?id:Int):Map<String,String>
    {
        var returnable:Map<String,String> = new Map<String, String>();
        GJApi.fetchTrophy(id, function(data:Map<String,String>){
            trace(data);
            returnable = data;
        });
        return returnable;
    }

    /**
     * Add a score to a table!
     * @param score Score of the song. **Can only be an int value!**
     * @param tableID ID of the table you want to add the score to!
     * @param extraData (Optional) You could put accuracy or any other details here!
     */
    public static function addScore(score:Int, tableID:Int, ?extraData:String)
    {
        if (GameJoltAPI.leaderboardToggle)
        {
            trace("Trying to add a score");
            var formData:String = extraData.split(" ").join("%20");
            GJApi.addScore(score+"%20Points", score, tableID, false, null, formData, function(data:Map<String, String>){
                trace("Score submitted with a result of: " + data.get("success"));
                Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score submitted!", "Score: " + score + "\nExtra Data: "+extraData, "alert");
            });
        }
        else
        {
            Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Score not submitted!", "Score: " + score + "Extra Data: " +extraData+"\nScore was not submitted due to score submitting being disabled!", "alert");
        }
    }

    /**
     * Return the highest score from a table!
     * 
     * Usable by pulling the data from the map by [function].get();
     * 
     * Values returned in the map: score, sort, user_id, user, extra_data, stored, guest, success
     * 
     * @param tableID The table you want to pull from
     * @return Map<String,String>
     */
    public static function pullHighScore(tableID:Int):Map<String,String>
    {
        var returnable:Map<String,String>;
        GJApi.fetchScore(tableID, 1, function(data:Map<String,String>)
        {
            trace(data);
            returnable = data;
        });
        return returnable;
    }

    public static function setData(tag:String, value:String, user:Bool = true):Map<String, String>
    {
        var returnable:Map<String, String>;
        if (tag == "points")
        {
            GJApi.setData(tag, Std.string(ClientPrefs.points + Std.parseInt(value)), user, function(data:Map<String,String>)
            {
                trace("set value: " + tag + " to: "+ Std.string(ClientPrefs.points + Std.parseInt(value)));
                if (tag == "points")
                {
                    Main.gjToastManager.createToast(Paths.getLibraryPath("shop/images/icon.png"), "Added " + value + " points to your shop credits!", "pointsAdd");
                }
                returnable = data;
            });
        }
        else
        {
            GJApi.setData(tag, value, user, function(data:Map<String,String>)
            {
                trace("set value: " + tag + " to: "+ value);
                returnable = data;
            });
        }
        return returnable;
    }

    public static function alert(type:String, val:Dynamic)
    {
        switch(type)
        {
            case "points":
                Main.gjToastManager.createToast(GameJoltInfo.imagePath, "Added " + val + " points to your shop credits!", "", "addPoints");
        }
    }

    public static function fetchData(tag:String, ?user:Bool = true):Map<String, String>
    {
        var returnable:Map<String, String>;
        GJApi.fetchData(tag, user, function(data:Map<String,String>)
        {
            returnable = data;
            // I think I actually need this shit here :skull:
            return returnable;
        });
        return returnable;
    }

    /**
     * Inline function to start the session. Shouldn't be used out of GameJoltAPI
     * Starts the session
     */
    public static function startSession()
    {
        GJApi.openSession(function()
            {
                trace("Session started!");
                new FlxTimer().start(20, function(tmr:FlxTimer){pingSession();}, 0);
            });
    }

    /**
     * Tells GameJolt that you are still active!
     * Called every 20 seconds by a loop in startSession().
     */
    public static function pingSession()
    {
        GJApi.pingSession(true, function(){trace("Ping!");});
    }

    /**
     * Closes the session, used for signing out
     */
    public static function closeSession()
    {
        GJApi.closeSession(function(){trace('Closed out the session');});
    }
}

class GameJoltInfo extends FlxSubState
{
    /**
    * Inline variable to change the font for the GameJolt API elements.
    * @param font You can change the font by doing **Paths.font([Name of your font file])** or by listing your file path.
    * If *null*, will default to the normal font.
    */
    public static var font:String = Paths.font("eras.ttf"); /* Example: Paths.font("vcr.ttf"); */
    /**
    * Inline variable to change the font for the notifications made by Firubii.
    * 
    * Don't make it a NULL variable. Worst mistake of my life.
    */
    public static var fontPath:String = Paths.font("eras.ttf"); // Put you're font path here
    /**
    * Image to show for notifications. Leave NULL for no image, it's all good :)
    * 
    * Example: Paths.getLibraryPath("images/stepmania-icon.png")
    */
    public static var imagePath:String = Paths.getLibraryPath("images/notifyIcon.png"); 

    /* Other things that shouldn't be messed with are below this line! */

    /**
    * game haxe!
    */
    public static var version:String = "0.0.3";

    public static var textArray:Array<String> = [
        "No, I will not get off visual studio",
        "Polo Blaze is the best. Fight me.",
        "I don't really like FNF that much anymore tbh",
        "No lol",
        "NOOOOO WE LEFT BEN AT THE STOREEEE!!!!",
        "NOOOO WE LEFT TESS AT SUBWAY!!!!!!",
        "I'm colour blind.",
        ":coldface:",
        "TIME TO SEX"
    ];
}

class GameJoltLogin extends MusicBeatState
{
    var gamejoltText1:FlxText;
    var gamejoltText2:FlxText;
    var loginTexts:FlxTypedGroup<FlxText>;
    var loginBoxes:FlxTypedGroup<FlxUIInputText>;
    var loginButtons:FlxTypedGroup<FlxButton>;
    var usernameText:FlxText;
    var tokenText:FlxText;
    var usernameBox:FlxUIInputText;
    var tokenBox:FlxUIInputText;
    var signInBox:FlxButton;
    var helpBox:FlxButton;
    var logOutBox:FlxButton;
    var cancelBox:FlxButton;
    // var profileIcon:FlxSprite;
    var username1:FlxText;
    var username2:FlxText;
    // var gamename:FlxText;
    // var trophy:FlxBar;
    // var trophyText:FlxText;
    // var missTrophyText:FlxText;
    // public static var charBop:FlxSprite;
    // var icon:FlxSprite;
    var baseX:Int = -190;
    var versionText:FlxText;
    var funnyText:FlxText;
    var fontSize:Int = 24;
    public static var login:Bool = false;
    // static var trophyCheck:Bool = false;
    override function create()
    {
        #if MODS_ALLOWED
		Paths.destroyLoadedImages();
		#end

        if (FlxG.save.data.lbToggle != null)
        {
            GameJoltAPI.leaderboardToggle = FlxG.save.data.lbToggle;
        }

        FlxG.sound.playMusic(Paths.music('gamejoltMenu'), 0);
        FlxG.sound.music.fadeIn(2, 0, 0.85);

        trace(GJApi.initialized);
        FlxG.mouse.visible = true;

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('gamejolt/bg'));
		bg.setGraphicSize(FlxG.width);
		bg.antialiasing = true;
		bg.updateHitbox();
		bg.screenCenter();
		bg.scrollFactor.set();
		bg.alpha = 0.25;
		add(bg);

        gamejoltText1 = new FlxText(0, 25, 0, "Gamejolt", 16);
        gamejoltText1.screenCenter(X);
        gamejoltText1.x += baseX;
        gamejoltText1.color = FlxColor.fromRGB(84,155,149);
        gamejoltText1.font = GameJoltInfo.fontPath;
        add(gamejoltText1);

        gamejoltText2 = new FlxText(0, 45, 0, Date.now().toString(), 16);
        gamejoltText2.screenCenter(X);
        gamejoltText2.x += baseX;
        gamejoltText2.color = FlxColor.fromRGB(84,155,149);
        gamejoltText2.font = GameJoltInfo.fontPath;
        add(gamejoltText2);

        funnyText = new FlxText(5, FlxG.height - 40, 0, GameJoltInfo.textArray[FlxG.random.int(0, GameJoltInfo.textArray.length - 1)]+ " -PurpleInsomnia", 12);
        funnyText.font = GameJoltInfo.fontPath;
        add(funnyText);

        versionText = new FlxText(5, FlxG.height - 22, 0, "Game ID: " + GJKeys.id + " API: " + GameJoltInfo.version, 12);
        versionText.font = GameJoltInfo.fontPath;
        add(versionText);

        loginTexts = new FlxTypedGroup<FlxText>(2);
        add(loginTexts);

        usernameText = new FlxText(0, 125, 300, "Username:", 20);
        usernameText.font = GameJoltInfo.fontPath;

        tokenText = new FlxText(0, 225, 300, "Game Token: (Not Your Password)", 20);
        tokenText.font = GameJoltInfo.fontPath;

        loginTexts.add(usernameText);
        loginTexts.add(tokenText);
        loginTexts.forEach(function(item:FlxText){
            item.screenCenter(X);
            item.x += baseX;
            item.font = GameJoltInfo.font;
        });

        loginBoxes = new FlxTypedGroup<FlxUIInputText>(2);
        add(loginBoxes);

        usernameBox = new FlxUIInputText(0, 175, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);
        tokenBox = new FlxUIInputText(0, 275, 300, null, 32, FlxColor.BLACK, FlxColor.GRAY);

        loginBoxes.add(usernameBox);
        loginBoxes.add(tokenBox);
        loginBoxes.forEach(function(item:FlxUIInputText){
            item.screenCenter(X);
            item.x += baseX;
            item.font = GameJoltInfo.font;
        });

        if(GameJoltAPI.getStatus())
        {
            remove(loginTexts);
            remove(loginBoxes);
        }

        loginButtons = new FlxTypedGroup<FlxButton>(3);
        add(loginButtons);

        signInBox = new FlxButton(150, 375, "", function()
        {
            trace(usernameBox.text);
            trace(tokenBox.text);
            ClientPrefs.gameJoltLogin[0] = usernameBox.text;
            ClientPrefs.gameJoltLogin[1] = tokenBox.text;
            GameJoltAPI.authDaUser(usernameBox.text, tokenBox.text, false);
        });
        signInBox.loadGraphic(Paths.image("gamejolt/buttons/signIn"), true, 150, 75);

        trace("huh?");

        logOutBox = new FlxButton(0, 500, "", function()
        {
            GameJoltAPI.deAuthDaUser();
        });
        logOutBox.loadGraphic(Paths.image("gamejolt/buttons/logOut"), true, 150, 75);

        cancelBox = new FlxButton(0,625, "", function()
        {
            FlxG.save.flush();
            FlxG.sound.play(Paths.sound('confirmMenu'), 0.7, false, null, true, function()
            {
                FlxG.save.flush();
                ClientPrefs.saveSettings();
                FlxG.sound.music.stop();
                MusicBeatState.switchState(new options.OptionsState());
            });
        });
        cancelBox.loadGraphic(Paths.image("gamejolt/buttons/cancel"), true, 150, 75);

        if(!GameJoltAPI.getStatus())
        {
            loginButtons.add(signInBox);
        }
        else
        {
            loginButtons.add(logOutBox);
        }
        loginButtons.add(cancelBox);

        loginButtons.forEach(function(item:FlxButton){
            item.screenCenter(X);
            item.x += baseX;
        });

        if(GameJoltAPI.getStatus())
        {
            username1 = new FlxText(0, 95, 0, "Signed in as:", 40);
            username1.alignment = CENTER;
            username1.screenCenter(X);
            username1.x += baseX;
            username1.font = GameJoltInfo.fontPath;
            add(username1);

            username2 = new FlxText(0, 145, 0, "" + GameJoltAPI.getUserInfo(true) + "", 40);
            username2.alignment = CENTER;
            username2.screenCenter(X);
            username2.x += baseX;
            username2.font = GameJoltInfo.fontPath;
            add(username2);
        }

        trace("huh?");
    }

    override function update(elapsed:Float)
    {
        gamejoltText2.text = Date.now().toString();

        if (FlxG.save.data.lbToggle == null)
        {
            FlxG.save.data.lbToggle = false;
            FlxG.save.flush();
        }

        super.update(elapsed);
    }

    function openLink(url:String)
    {
        #if linux
        Sys.command('/usr/bin/xdg-open', [url, "&"]);
        #else
        FlxG.openURL(url);
        #end
    }
}

/* The toast things, pulled from Hololive Funkin
* Thank you Firubii for the code for this!
* https://twitter.com/firubiii
* https://github.com/firubii
* ILYSM
*/

class GJToastManager extends Sprite
{
    public static var ENTER_TIME:Float = 0.5;
    public static var DISPLAY_TIME:Float = 3.0;
    public static var LEAVE_TIME:Float = 0.5;
    public static var TOTAL_TIME:Float = ENTER_TIME + DISPLAY_TIME + LEAVE_TIME;

    var playTime:FlxTimer = new FlxTimer();

    public function new()
    {
        super();
        FlxG.signals.postStateSwitch.add(onStateSwitch);
        FlxG.signals.gameResized.add(onWindowResized);
    }

    /**
     * Create a toast!
     * 
     * Usage: **Main.gjToastManager.createToast(iconPath, title, description);**
     * @param iconPath Path for the image **Paths.getLibraryPath("image/example.png")**
     * @param title Title for the toast
     * @param description Description for the toast
     * @param sound Want to have an alert sound? Set this to **true**! Defaults to **false**.
     */
    public function createToast(iconPath:String, title:String, description:String, ?sound:String = ""):Void
    {
       if (sound != "")FlxG.sound.play(Paths.sound(sound), 0.75); 
        
        var toast = new Toast(iconPath, title, description);
        addChild(toast);

        playTime.start(TOTAL_TIME);
        playToasts();
    }

    public function playToasts():Void
    {
        for (i in 0...numChildren)
        {
            var child = getChildAt(i);
            FlxTween.cancelTweensOf(child);
            FlxTween.tween(child, {y: (numChildren - 1 - i) * child.height}, ENTER_TIME, {ease: FlxEase.quadOut,
                onComplete: function(tween:FlxTween)
                {
                    FlxTween.cancelTweensOf(child);
                    FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {ease: FlxEase.quadOut, startDelay: DISPLAY_TIME,
                        onComplete: function(tween:FlxTween)
                        {
                            cast(child, Toast).removeChildren();
                            removeChild(child);
                        }
                    });
                }
            });
        }
    }

    public function collapseToasts():Void
    {
        for (i in 0...numChildren)
        {
            var child = getChildAt(i);
            FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {ease: FlxEase.quadOut,
                onComplete: function(tween:FlxTween)
                {
                    cast(child, Toast).removeChildren();
                    removeChild(child);
                }
            });
        }
    }

    public function onStateSwitch():Void
    {
        if (!playTime.active)
            return;

        /*
        var elapsedSec = playTime.elapsedTime / 1000;
        if (elapsedSec < ENTER_TIME)
        {
            for (i in 0...numChildren)
            {
                var child = getChildAt(i);
                FlxTween.cancelTweensOf(child);
                FlxTween.tween(child, {y: (numChildren - 1 - i) * child.height}, ENTER_TIME - elapsedSec, {ease: FlxEase.quadOut,
                    onComplete: function(tween:FlxTween)
                    {
                        FlxTween.cancelTweensOf(child);
                        FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {ease: FlxEase.quadOut, startDelay: DISPLAY_TIME,
                            onComplete: function(tween:FlxTween)
                            {
                                cast(child, Toast).removeChildren();
                                removeChild(child);
                            }
                        });
                    }
                });
            }
        }
        else if (elapsedSec < DISPLAY_TIME)
        {
            for (i in 0...numChildren)
            {
                var child = getChildAt(i);
                FlxTween.cancelTweensOf(child);
                FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {ease: FlxEase.quadOut, startDelay: DISPLAY_TIME - (elapsedSec - ENTER_TIME),
                    onComplete: function(tween:FlxTween)
                    {
                        cast(child, Toast).removeChildren();
                        removeChild(child);
                    }
                });
            }
        }
        else if (elapsedSec < LEAVE_TIME)
        {
            for (i in 0...numChildren)
            {
                var child = getChildAt(i);
                FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME -  (elapsedSec - ENTER_TIME - DISPLAY_TIME), {ease: FlxEase.quadOut,
                    onComplete: function(tween:FlxTween)
                    {
                        cast(child, Toast).removeChildren();
                        removeChild(child);
                    }
                });
            }
        }
        */
        for (i in 0...numChildren)
        {
            var child = getChildAt(i);
            FlxTween.cancelTweensOf(child);
            FlxTween.tween(child, {y: (i + 1) * -child.height}, LEAVE_TIME, {ease: FlxEase.quadOut,
                onComplete: function(tween:FlxTween)
                {
                    cast(child, Toast).removeChildren();
                    removeChild(child);
                }
            });
        }
    }

    public function onWindowResized(x:Int, y:Int):Void
    {
        for (i in 0...numChildren)
        {
            var child = getChildAt(i);
            child.x = Lib.current.stage.stageWidth - child.width;
        }
    }
}

class Toast extends Sprite
{
    var back:Bitmap;
    var icon:Bitmap;
    var title:TextField;
    var desc:TextField;

    public function new(iconPath:String, titleText:String, description:String)
    {
        super();
        back = new Bitmap(new BitmapData(500, 120, true, 0xFF000000));
        back.alpha = 0.5;
        back.x = 0;
        back.y = 0;

        if(iconPath != null)
        {
            icon = new Bitmap(BitmapData.fromFile(iconPath));
            icon.x = 10;
            icon.y = 10;
        }

        title = new TextField();
        title.text = titleText;
        title.setTextFormat(new TextFormat(openfl.utils.Assets.getFont(GameJoltInfo.fontPath).fontName, 24, 0xFFFF00, true));
        title.wordWrap = true;
        title.width = 360;
        if(iconPath!=null){title.x = 120;}
        else{title.x = 5;}
        title.y = 5;

        desc = new TextField();
        desc.text = description;
        desc.setTextFormat(new TextFormat(openfl.utils.Assets.getFont(GameJoltInfo.fontPath).fontName, 18, 0xFFFFFF));
        desc.wordWrap = true;
        desc.width = 360;
        desc.height = 95;
        if(iconPath!=null){desc.x = 120;}
        else{desc.x = 5;}
        desc.y = 30;
        if (titleText.length >= 25 || titleText.contains("\n"))
        {   
            desc.y += 25;
            desc.height -= 25;
        }

        addChild(back);
        if(iconPath!=null){addChild(icon);}
        addChild(title);
        addChild(desc);

        width = back.width;
        height = back.height;
        x = Lib.current.stage.stageWidth - width;
        y = -height;
    }
}
#end