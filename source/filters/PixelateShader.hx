package filters;

import flixel.system.FlxAssets.FlxShader;

class PixelateShader
{
    public var shader:PixelateFilter = new PixelateFilter();

    public function new()
    {
        shader.uBlocksize.value = [0, 0];
    }

    public function changeBlocks(x:Float, y:Float)
    {
        shader.uBlocksize.value = [x, y];
    }
}

class PixelateFilter extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform vec2 uBlocksize;

		void main()
		{
			vec2 blocks = openfl_TextureSize / uBlocksize;
			gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv * blocks) / blocks);
		}')

	public function new()
	{
		super();
	}
}