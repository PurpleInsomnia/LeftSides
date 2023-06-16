package fnf;

import flixel.FlxSprite;

class FNFSprite extends FlxSprite
{
    public var inFront:Bool = false;
    public var isLightSource:Bool = false;

    public var savedAlpha:Float = 0;
    public function saveAlpha()
    {
        savedAlpha = alpha;
    }

    public var graphicName:String = "";
}