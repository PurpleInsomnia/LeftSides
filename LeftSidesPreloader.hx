package ;
 
import flixel.system.FlxBasePreloader;
import flixel.FlxSprite;
import flixel.FlxG;
import openfl.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.Lib;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxBasic;

class LeftSidesPreloader extends FlxBasePreloader
{
    public function new(MinDisplayTime:Float=3, ?AllowedURLs:Array<String>) 
    {
        super(MinDisplayTime, AllowedURLs);
    }
     
    var logo:Bitmap;
     
    override function create():Void 
    {
        this._width = Lib.current.stage.stageWidth;
        this._height = Lib.current.stage.stageHeight;
         
        var ratio:Float = this._width / 2560; //This allows us to scale assets depending on the size of the screen.
         
        logo = new Bitmap('art/preloaderScreen');
        addChild(logo);
         
        super.create();
    }
     
    override function update(Percent:Float):Void 
    {
        if(Percent < 69)
        {
            logo.x -= Percent * 0.6;
            logo.y -= Percent / 2;
        }else{
            logo.x = ((this._width) / 2) - ((logo.width) / 2);
            logo.y = (this._height / 2) - ((logo.height) / 2);
        }
        
        super.update(Percent);
    }
}