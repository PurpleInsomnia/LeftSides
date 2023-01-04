package filters;

import flixel.system.FlxAssets.FlxShader;

class CustomShader
{
    public var shader:CustomShaderThing = null;
    
    public function new(source:String)
    {
        shader = new CustomShaderThing(source);
    }

    public function getShaderVal(val:String)
    {
        return Reflect.getProperty(shader, val);
    }

    public function setShaderVal(val:String, arg:Dynamic)
    {
        Reflect.setProperty(shader, val, arg);
    }
}

class CustomShaderThing extends FlxShader
{
    public function new(source:String)
    {
        var ret:String = Paths.getTextFromFile("shaders/" + source + ".frag");
        glFragmentSource += ret;
        super();
    }
}