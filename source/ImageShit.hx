import flixel.FlxG;
import flixel.graphics.FlxGraphic;

class ImageShit
{
	public static var fuckinbitmaps:Array<FlxGraphic> = [];

	public static function loadGraphic(path):FlxGraphic
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(path, false, "");

		Debug.logInfo(graphic.width);

		fuckinbitmaps.push(graphic);

		return graphic;
	}
}
