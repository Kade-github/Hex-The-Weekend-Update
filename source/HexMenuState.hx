import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import sys.FileSystem;
import haxe.Json;

using StringTools;

typedef Animation =
{
	public var name:String;
	public var symbol:String;
	public var fps:Int;
	public var loop:Bool;
	public var offsetX:Int;
	public var offsetY:Int;
}

typedef ItemData =
{
	public var graphicPath:String;
	public var graphicLib:String;
	public var isSparrow:Bool;
	public var animations:Array<Animation>;
	public var x:Int;
	public var y:Int;
	public var name:String;
	public var layer:Int;
	public var scale:Float;
}

typedef HexData = Array<ItemData>;

class HexMenuData
{
	public var path:String;
	public var data:HexData;

	public function new(dataPath:String)
	{
		if (dataPath == null) // create new
		{
			data = [];
		}
		else
		{
			path = dataPath;
			Debug.logTrace("loading " + path);
			var jsonShit = sys.io.File.getContent(FileSystem.absolutePath(dataPath));
			var jsonData = Json.parse(jsonShit);
			data = cast jsonData;
		}
	}
}

class HexMenuItem extends FlxSprite
{
	public var itemMeta:ItemData;

	public function new(x, y, _itemMeta)
	{
		itemMeta = _itemMeta;
		super(x, y);
	}

	public function changeOutGraphic(path, lib = "hexMenu")
	{
		if (itemMeta.isSparrow)
		{
			Debug.logError("You cannot change the graphic of a sparrow atlas!");
			return;
		}

		loadGraphic(Paths.image(path, lib));
		setGraphicSize(Std.int(width * itemMeta.scale));
	}

	override function updateAnimation(elapsed):Void
	{
		// if an animation is being set in MenuCreator and it is being thrown between two of them
		// it crashes here, unless you do this shit.
		if (animation.curAnim == null)
			return;
		if (animation.curAnim.frames == null)
			return;
		if (animation.curAnim.numFrames == 0)
			return;
		animation.update(elapsed);
	}

	public function playAnimation(name:String)
	{
		var anm = null;
		for (i in itemMeta.animations)
			if (i.name == name)
				anm = i;
		if (anm == null)
		{
			Debug.logError("failed to play " + name);
			return;
		}
		offset.set(anm.offsetX, anm.offsetY);
		animation.play(name);
		setGraphicSize(Std.int(width * itemMeta.scale));
	}
}

class HexMenuState extends MusicBeatState
{
	public var Items:FlxTypedGroup<HexMenuItem>;

	public var hexData:HexMenuData;

	public var _path:String;

	public static function loadHexMenu(name):HexMenuData
	{
		return new HexMenuData(Paths.json(name, "hexMenu").replace("hexMenu:", ""));
	}

	var tempArray:Array<HexMenuItem> = [];

	public function getItemByName(name):HexMenuItem
	{
		for (i in Items)
		{
			if (i.itemMeta.name == name)
				return i;
		}
		Debug.logTrace("couldn't find " + name);
		return null;
	}

	public function new(_hexData:HexMenuData)
	{
		_path = _hexData.path;
		hexData = _hexData;
		super();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.F1)
		{
			var creator = new HexMenuCreator();
			creator.loadS(_path);
			switchState(creator);
		}
		super.update(elapsed);
	}

	override function load()
	{
		var index = 0;
		for (i in hexData.data)
		{
			var sprite:HexMenuItem = new HexMenuItem(i.x, i.y, i);
			sprite.antialiasing = true;
			if (i.isSparrow)
			{
				sprite.frames = Paths.getSparrowAtlas(i.graphicPath, i.graphicLib);
				for (anim in i.animations)
				{
					sprite.animation.addByPrefix(anim.name, anim.symbol, anim.fps, anim.loop);
				}
			}
			else
			{
				sprite.loadGraphic(Paths.image(i.graphicPath, i.graphicLib));
			}
			tempArray.push(sprite);
			LoadingScreen.progress = Math.floor((index / (hexData.data.length - 1)) * 100);
			index++;
		}
		super.load();
	}

	function superCreate()
	{
		super.create();
	}

	override function create()
	{
		Items = new FlxTypedGroup<HexMenuItem>();

		// layering
		for (layer in 0...10)
		{
			for (i in tempArray)
			{
				if (i.itemMeta.layer == layer)
				{
					Items.add(i);
					if (i.itemMeta.animations.length != 0)
					{
						var an = i.animation.getByName(i.itemMeta.animations[0].name);
						Debug.logTrace("playing "
							+ i.itemMeta.animations[0].name
								+ " "
								+ (an != null ? "which it exists" : "it doesn't exist")
								+ " "
								+ an.looped);
						i.playAnimation(i.itemMeta.animations[0].name);
						i.scrollFactor.set();
					}
				}
			}
		}
		add(Items);
	}
}
