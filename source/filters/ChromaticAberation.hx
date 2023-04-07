package filters;

import flixel.system.FlxAssets.FlxShader;

class ChromaticAberation
{
    public var shader:CAShader = new CAShader();

    public var max:Float = 0.40;

    public function new()
    {
        shader.intensity.value = [max];
    }
}

class CAShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header

    uniform float intensity = 1.0;

    void main()
    {
	    //sets the base color without changes
	    //vec4 because it has 4 values: (red, green, blue, alpha)
	    vec4 basecolor = texture2D(bitmap, openfl_TextureCoordv);
	
	    //create newcolor to equal basecolor
	    vec4 newcolor = basecolor;
	
	    //divides level of intensity by 100
	    float adj_amt = intensity / 100.0;
		
	    //offsets the red value
	    newcolor.r = texture2D(bitmap, vec2(openfl_TextureCoordv.x + adj_amt, openfl_TextureCoordv.y + adj_amt)).r;
	    // green value stays the same
	    newcolor.g = basecolor.g;
	    //offsets the blue value
	    newcolor.b = texture2D(bitmap, vec2(openfl_TextureCoordv.x - adj_amt, openfl_TextureCoordv.y - adj_amt)).b;

	    //sets the fragment color to the value of newcolor
	    gl_FragColor = newcolor;
    }')

    public function new()
    {
        super();
    }
}