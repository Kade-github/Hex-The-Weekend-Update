import flixel.addons.ui.FlxUI;
import sys.thread.Mutex;
import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxSprite;

class MasterObjectLoader
{
	public static var mutex:Mutex;

	public static var Objects:Array<Dynamic> = [];

	public static function addObject(bruh:Dynamic)
	{
		if (Std.isOfType(bruh, FlxSprite))
		{
			var sprite:FlxSprite = cast(bruh, FlxSprite);
			if (sprite.graphic == null)
				return;
		}
		if (Std.isOfType(bruh, FlxUI))
			return;
		mutex.acquire();
		Objects.push(bruh);
		mutex.release();
	}

	public static function removeObject(object:Dynamic)
	{
		if (Std.isOfType(object, FlxSprite))
		{
			var sprite:FlxSprite = cast(object, FlxSprite);
			if (sprite.graphic == null)
				return;
		}
		if (Std.isOfType(object, FlxUI))
			return;
		mutex.acquire();
		Objects.remove(object);
		mutex.release();
	}

	public static function resetAssets(removeLoadingScreen:Bool = false)
	{
		var keep:Array<Dynamic> = [];
		mutex.acquire();
		for (object in Objects)
		{
			if (Std.isOfType(object, FlxSprite))
			{
				var sprite:FlxSprite = object;
				if (sprite.ID >= 99999 && !removeLoadingScreen) // loading screen assets
				{
					keep.push(sprite);
					continue;
				}
				FlxG.bitmap.remove(sprite.graphic);
				// sprite.destroy();
			}
			if (Std.isOfType(object, FlxGraphic))
			{
				var graph:FlxGraphic = object;
				FlxG.bitmap.remove(graph);
				// graph.destroy();
			}
		}
		Objects = [];
		for (k in keep)
			Objects.push(k);
		mutex.release();
	}
}
