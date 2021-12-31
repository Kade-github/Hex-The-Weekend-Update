import flixel.util.FlxColor;
import HexMenuState.Animation;
import sys.FileSystem;
import haxe.Json;
import HexMenuState.HexData;
import flixel.group.FlxGroup.FlxTypedGroup;
import HexMenuState.HexMenuItem;
import flixel.addons.ui.FlxUINumericStepper;
import HexMenuState.ItemData;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.ui.FlxButton;
import flixel.text.FlxText;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUIInputText;
import flixel.FlxG;
import flixel.addons.ui.FlxUITabMenu;
import HexMenuState.HexMenuData;

using StringTools;

class HexMenuCreator extends MusicBeatState
{
	public var hexData:HexMenuData;

	var UI_box:FlxUITabMenu;
	var UI_options:FlxUITabMenu;

	var UI_dropDown:FlxUIDropDownMenu;
	var sparrowDrop:FlxUIDropDownMenu;

	var tab_group_asset:FlxUI;

	var selectedItem:HexMenuItem;

	var assetPath:FlxUIInputText;
	var assetLib:FlxUIInputText;
	var name:FlxUIInputText;
	var animName:FlxUIInputText;
	var animSymbol:FlxUIInputText;

	var statusText:FlxText;
	var selectedText:FlxText;
	var selectedHighlight:FlxText;

	var selectableItems:FlxUIDropDownMenu;

	var newSpriteIndex:Int = 0;
	var newAnimIndex:Int = 0;
	var xEntry:FlxUINumericStepper;
	var yEntry:FlxUINumericStepper;
	var ofxEntry:FlxUINumericStepper;
	var ofyEntry:FlxUINumericStepper;
	var layer:FlxUINumericStepper;
	var scale:FlxUINumericStepper;
	var fps:FlxUINumericStepper;
	var loop:FlxUINumericStepper;

	var _path:String = "newHexMenu.json";

	var items:FlxTypedGroup<HexMenuItem> = new FlxTypedGroup<HexMenuItem>();

	var currentAnim:String;

	var currentSymb:String;

	public function returnAnimationNames():Array<String>
	{
		var array:Array<String> = [];

		if (selectedItem != null)
		{
			for (i in selectedItem.itemMeta.animations)
			{
				array.push(i.name);
			}
			if (array.length == 0)
				array.push("");
		}
		else
			array.push("");

		return array;
	}

	public function populateSelectables()
	{
		var array:Array<String> = [];
		for (i in items)
		{
			array.push(i.itemMeta.name);
		}
		if (array.length == 0)
			array.push("");

		if (selectableItems == null)
		{
			selectableItems = new FlxUIDropDownMenu(325, 24, FlxUIDropDownMenu.makeStrIdLabelArray(array, false), function(ite:String)
			{
				var found = false;
				for (i in items)
				{
					if (i.itemMeta.name == ite)
					{
						found = true;
						Debug.logTrace("selected " + ite);
						selectedItem = i;
						populateSprite();
						break;
					}
				}
				if (!found)
					Debug.logTrace("couldn't find " + ite);
			});
			tab_group_asset.add(selectableItems);
		}
		else
		{
			selectableItems.setData(FlxUIDropDownMenu.makeStrIdLabelArray(array, false));
			if (selectedItem != null)
				selectableItems.selectedLabel = selectedItem.itemMeta.name;
		}
	}

	public function populateAnimation()
	{
		if (selectedItem.itemMeta.animations.length == 0)
			return;
		for (i in selectedItem.itemMeta.animations)
		{
			if (UI_dropDown.selectedLabel == i.name)
			{
				fps.value = i.fps;
				animName.text = i.name;
				animSymbol.text = i.symbol;
				loop.value = i.loop ? 1 : 0;
				currentAnim = animName.text;
				currentSymb = animSymbol.text;
				ofxEntry.value = i.offsetX;
				ofyEntry.value = i.offsetY;
				playAnim();
				Debug.logTrace("found anim");
				break;
			}
		}
	}

	public function populateSprite()
	{
		selectedText.text = "Selected: " + selectedItem.itemMeta.name;
		xEntry.value = selectedItem.itemMeta.x;
		yEntry.value = selectedItem.itemMeta.y;
		layer.value = selectedItem.itemMeta.layer;
		sparrowDrop.selectedLabel = selectedItem.itemMeta.isSparrow ? "true" : "false";
		name.text = selectedItem.itemMeta.name;
		scale.value = selectedItem.itemMeta.scale;
		assetLib.text = selectedItem.itemMeta.graphicLib;
		assetPath.text = selectedItem.itemMeta.graphicPath;
		refreshAnimDrop();

		if (selectedItem.itemMeta.animations.length == 0)
			currentAnim = "";

		populateAnimation();
	}

	public function createTextInput(textInput:FlxUIInputText, name:String)
	{
		textInput.name = name;
		return textInput;
	}

	public function refreshAnimDrop()
	{
		if (UI_dropDown != null)
			tab_group_asset.remove(UI_dropDown);

		UI_dropDown = new FlxUIDropDownMenu(12, 225, FlxUIDropDownMenu.makeStrIdLabelArray(returnAnimationNames(), false), function(animation:String)
		{
			populateAnimation();
		});

		UI_dropDown.selectedLabel = currentAnim;

		tab_group_asset.add(UI_dropDown);
	}

	public function playAnim()
	{
		if (selectedItem == null)
			return;
		var found = false;
		if (selectedItem.frames.numFrames > 0)
		{
			for (i in selectedItem.frames.frames)
			{
				if (StringTools.startsWith(i.name, currentSymb))
				{
					found = true;
					var an = getAnimation(currentAnim);
					selectedItem.offset.set(an.offsetX, an.offsetY);
					selectedItem.animation.play(currentAnim);
					selectedItem.setGraphicSize(Std.int(selectedItem.width * selectedItem.itemMeta.scale));
					break;
				}
			}
		}
		if (!found)
			statusText.text = "Couldn't find sym " + currentSymb;
	}

	public function createAnimation()
	{
		if (selectedItem == null)
			return;
		if (!selectedItem.itemMeta.isSparrow)
			return;
		newAnimIndex++;
		var anim:Animation = {
			name: "newAnimation" + newAnimIndex,
			fps: 24,
			symbol: "symbol",
			loop: false,
			offsetX: 0,
			offsetY: 0
		};
		selectedItem.itemMeta.animations.push(anim);

		currentAnim = anim.name;
		currentSymb = anim.symbol;

		selectedItem.animation.addByPrefix(anim.name, anim.symbol, anim.fps, anim.loop);

		playAnim();

		refreshAnimDrop();
		statusText.text = "Created animation " + anim.name;

		populateAnimation();
	}

	public function getAnimation(name):Animation
	{
		if (selectedItem == null)
			return null;
		for (i in selectedItem.itemMeta.animations)
		{
			if (i.name == name)
				return i;
		}
		return null;
	}

	public function deleteAnimation()
	{
		if (selectedItem == null)
			return;
		if (!selectedItem.itemMeta.isSparrow)
			return;
		var toRemove:Animation = null;
		for (i in selectedItem.itemMeta.animations)
		{
			if (i.name == UI_dropDown.selectedLabel)
			{
				toRemove = i;
				break;
			}
		}
		if (toRemove != null)
		{
			selectedItem.itemMeta.animations.remove(toRemove);
			selectedItem.animation.remove(toRemove.name);
			refreshAnimDrop();
		}
	}

	public function removeGraphic()
	{
		if (selectedItem == null)
			return;
		items.members.remove(selectedItem);
		selectedItem.destroy();
		selectedItem = null;
		populateSelectables();
	}

	public function export()
	{
		var itemDatas:Array<ItemData> = [];
		for (i in items)
		{
			itemDatas.push(i.itemMeta);
		}

		var json:HexData = itemDatas;

		var data = Json.stringify(json, null, " ");

		sys.io.File.saveContent(_path, data);

		statusText.text = "Saved to 'newHexMenu.json'";
	}

	public function createNew()
	{
		while (items.members.length != 0)
		{
			items.members.remove(items.members[0]);
		}

		_path = "newHexMenu.json";

		hexData = new HexMenuData(null);
		refreshAnimDrop();
		populateSelectables();
		if (items.members.length >= 1)
		{
			selectedItem = items.members[0];
			populateSprite();
		}
		relayer();
	}

	public function loadS(path = "newHexMenu.json")
	{
		_path = path;
		while (items.members.length != 0)
		{
			items.members.remove(items.members[0]);
		}

		hexData = new HexMenuData(path);
		for (i in hexData.data)
		{
			var sprite:HexMenuItem = new HexMenuItem(i.x, i.y, i);
			if (i.isSparrow)
			{
				sprite.frames = Paths.getSparrowAtlas(i.graphicPath, i.graphicLib);
				for (anim in i.animations)
				{
					sprite.animation.addByPrefix(anim.name, anim.symbol, anim.fps, anim.loop);
				}
				if (i.animations.length != 0)
					sprite.animation.play(i.animations[0].name);
			}
			else
				sprite.loadGraphic(Paths.image(i.graphicPath, i.graphicLib));
			sprite.scrollFactor.set();
			sprite.setGraphicSize(Std.int(sprite.width * sprite.itemMeta.scale));
			items.add(sprite);
		}
		if (created)
		{
			refreshAnimDrop();
			populateSelectables();
			if (items.members.length >= 1)
			{
				selectedItem = items.members[0];
				populateSprite();
			}
			relayer();
		}
	}

	var created = false;

	public function relayer()
	{
		var tempArray:Array<HexMenuItem> = [];
		while (items.members.length != 0)
		{
			tempArray.push(items.members[0]);
			items.members.remove(items.members[0]);
		}

		for (i in 0...10)
		{
			for (item in tempArray)
			{
				if (item.itemMeta.layer == i)
				{
					item.antialiasing = true;
					items.add(item);
				}
			}
		}

		add(selectedHighlight);
	}

	override public function create()
	{
		FlxG.mouse.visible = true;
		FlxG.sound.soundTrayEnabled = false;

		selectedHighlight = new FlxText(0, 0, 0, "");
		selectedHighlight.setFormat(Paths.font("Gotham_Black_Regular.ttf"), 16, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		selectedHighlight.borderSize = 4;
		selectedHighlight.borderQuality = 2;

		add(items);

		if (hexData == null)
			hexData = new HexMenuData(null);
		var tabs = [{name: "Assets", label: 'Asset menu'},];

		UI_box = new FlxUITabMenu(null, tabs, true);
		UI_box.scrollFactor.set();
		UI_box.resize(475, 325);
		UI_box.x = FlxG.width - UI_box.width - 40;
		UI_box.y = 20;

		add(UI_box);

		tab_group_asset = new FlxUI(null, UI_box);

		tab_group_asset.add(new FlxText(12, 4, 0, "Asset Path", 8));

		assetPath = new FlxUIInputText(12, 24, 100, "");
		tab_group_asset.add(createTextInput(assetPath, "assetPath"));

		tab_group_asset.add(new FlxText(180, 4, 0, "Asset Lib", 8));

		selectedText = new FlxText(325, 4, 0, "Selected: Nothing", 8);

		tab_group_asset.add(selectedText);

		assetLib = new FlxUIInputText(180, 24, 100, "");
		tab_group_asset.add(createTextInput(assetLib, "assetLib"));

		statusText = new FlxText(180, 50, 0, "");
		tab_group_asset.add(statusText);

		tab_group_asset.add(new FlxButton(12, 50, "Summon", () ->
		{
			loadGraphic();
		}));

		tab_group_asset.add(new FlxButton(325, 72, "Remove", () ->
		{
			if (!selectableItems.dropPanel.visible)
				removeGraphic();
		}));

		tab_group_asset.add(new FlxButton(325, 120, "Export", () ->
		{
			if (!selectableItems.dropPanel.visible)
				export();
		}));

		tab_group_asset.add(new FlxButton(325, 138, "Load", () ->
		{
			if (!selectableItems.dropPanel.visible)
				loadS(_path);
		}));

		tab_group_asset.add(new FlxButton(325, 156, "createNew", () ->
		{
			if (!selectableItems.dropPanel.visible)
				createNew();
		}));

		tab_group_asset.add(new FlxText(12, 72, 0, "X Value", 8));

		xEntry = new FlxUINumericStepper(12, 92, 1, 0, -100, 1280);
		xEntry.name = "x";
		tab_group_asset.add(xEntry);

		tab_group_asset.add(new FlxText(180, 72, 0, "Y Value", 8));

		yEntry = new FlxUINumericStepper(180, 92, 1, 0, -100, 720);
		yEntry.name = "y";
		tab_group_asset.add(yEntry);

		tab_group_asset.add(new FlxText(12, 120, 0, "Name", 8));

		name = new FlxUIInputText(12, 138, 140, "");
		tab_group_asset.add(createTextInput(name, "name"));

		tab_group_asset.add(new FlxText(180, 120, 0, "Is a sparrow atlas?", 8));

		tab_group_asset.add(new FlxText(12, 155, 0, "Layer", 8));

		layer = new FlxUINumericStepper(12, 175, 1, 0, 0, 10);
		layer.name = "layer";
		tab_group_asset.add(layer);

		tab_group_asset.add(new FlxText(84, 155, 0, "Scale", 8));

		scale = new FlxUINumericStepper(84, 175, 0.1, 1, 0.1, 2.0, 1);
		scale.name = "scale";
		tab_group_asset.add(scale);

		tab_group_asset.add(new FlxText(12, 200, 0, "Animations", 8));

		tab_group_asset.add(new FlxButton(135, 195, "Create", () ->
		{
			createAnimation();
		}));

		tab_group_asset.add(new FlxButton(240, 195, "Delete", () ->
		{
			deleteAnimation();
		}));

		tab_group_asset.add(new FlxText(135, 225, 0, "Name", 8));

		animName = new FlxUIInputText(135, 250, 60, "");
		tab_group_asset.add(createTextInput(animName, "animName"));

		tab_group_asset.add(new FlxText(205, 225, 0, "Prefix", 8));

		animSymbol = new FlxUIInputText(205, 250, 60, "");
		tab_group_asset.add(createTextInput(animSymbol, "animSymbol"));

		tab_group_asset.add(new FlxText(275, 225, 0, "Fps", 8));

		fps = new FlxUINumericStepper(275, 250, 1, 24, 1, 60);
		fps.name = "fps";
		tab_group_asset.add(fps);

		tab_group_asset.add(new FlxText(345, 225, 0, "Loop?", 8));

		loop = new FlxUINumericStepper(345, 250, 1, 0, 0, 1);
		loop.name = "loop";
		tab_group_asset.add(loop);

		ofxEntry = new FlxUINumericStepper(135, 285, 1, 0, -100, 100);
		ofxEntry.name = "ofx";
		tab_group_asset.add(ofxEntry);

		ofyEntry = new FlxUINumericStepper(205, 285, 1, 0, -100, 100);
		ofyEntry.name = "ofy";
		tab_group_asset.add(ofyEntry);

		refreshAnimDrop();

		sparrowDrop = new FlxUIDropDownMenu(180, 138, FlxUIDropDownMenu.makeStrIdLabelArray(["false", "true"], false), function(bool:String)
		{
			if (selectedItem != null)
			{
				selectedItem.itemMeta.isSparrow = (bool == "false" ? false : true);
				var path = Paths.image(assetPath.text, assetLib.text);
				if (Paths.doesImageAssetExist(path))
				{
					if (selectedItem.itemMeta.isSparrow)
					{
						selectedItem.frames = Paths.getSparrowAtlas(assetPath.text, assetLib.text);
					}
					else
						selectedItem.loadGraphic(path);
				}
				else
				{
					statusText.text = "Cannot find that file!";
				}
			}
		});
		tab_group_asset.add(sparrowDrop);

		populateSelectables();

		tab_group_asset.name = "Assets";
		UI_box.addGroup(tab_group_asset);

		relayer();

		created = true;

		super.create();
	}

	public function loadGraphic()
	{
		var path = Paths.image(assetPath.text, assetLib.text);
		Debug.logTrace("trying to find " + path);
		if (Paths.doesImageAssetExist(path))
		{
			newSpriteIndex++;
			var item:ItemData = {
				x: 0,
				y: 0,
				animations: [],
				name: "newSprite" + newSpriteIndex,
				isSparrow: false,
				layer: 0,
				graphicPath: assetPath.text,
				graphicLib: assetLib.text,
				scale: 1.0
			};
			var item:HexMenuItem = new HexMenuItem(0, 0, item);
			item.loadGraphic(path);
			item.scrollFactor.set();
			items.add(item);
			selectedItem = item;
			statusText.text = "Created " + item.itemMeta.name;
			populateSelectables();
			populateSprite();
		}
		else
			statusText.text = "Cannot find that file!";

		relayer();
	}

	override function update(elapsed)
	{
		if (FlxG.keys.justPressed.ESCAPE)
			switchState(new HexMainMenu(new HexMenuData(Paths.json("main-menu", "hexMenu").replace("hexMenu:", ""))));

		if (selectedItem == null)
		{
			super.update(elapsed);
			return;
		}
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.C)
		{
			loadGraphic();
		}

		if (FlxG.keys.pressed.LEFT)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.x--;
				super.update(elapsed);
				return;
			}
			var anm = getAnimation(UI_dropDown.selectedLabel);
			if (anm == null)
			{
				statusText.text = "Couldn't find anm " + UI_dropDown.selectedLabel;
				super.update(elapsed);
				return;
			}
			anm.offsetX--;
			if (anm.offsetX < -1280)
				anm.offsetX = -1280;

			ofxEntry.value = anm.offsetX;
			playAnim();
		}

		if (FlxG.keys.pressed.RIGHT)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.x++;
				super.update(elapsed);
				return;
			}
			var anm = getAnimation(UI_dropDown.selectedLabel);
			if (anm == null)
			{
				statusText.text = "Couldn't find anm " + UI_dropDown.selectedLabel;
				super.update(elapsed);
				return;
			}
			anm.offsetX++;
			if (anm.offsetX > 1280)
				anm.offsetX = 1280;

			ofxEntry.value = anm.offsetX;
			playAnim();
		}

		if (FlxG.keys.pressed.UP)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.y--;
				super.update(elapsed);
				return;
			}
			var anm = getAnimation(UI_dropDown.selectedLabel);
			if (anm == null)
			{
				statusText.text = "Couldn't find anm " + UI_dropDown.selectedLabel;
				super.update(elapsed);
				return;
			}
			anm.offsetY--;
			if (anm.offsetY < -720)
				anm.offsetY = -720;

			ofyEntry.value = anm.offsetY;
			playAnim();
		}

		if (FlxG.keys.pressed.DOWN)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.y++;
				super.update(elapsed);
				return;
			}
			var anm = getAnimation(UI_dropDown.selectedLabel);
			if (anm == null)
			{
				statusText.text = "Couldn't find anm " + UI_dropDown.selectedLabel;
				super.update(elapsed);
				return;
			}
			anm.offsetY++;
			if (anm.offsetY > 720)
				anm.offsetY = 720;

			ofyEntry.value = anm.offsetY;
			playAnim();
		}

		if (FlxG.mouse.overlaps(selectedItem) && FlxG.mouse.pressed)
		{
			if (FlxG.mouse.overlaps(UI_box) && FlxG.keys.pressed.CONTROL)
				UI_box.alpha = 0.2;
			else if (FlxG.mouse.overlaps(UI_box) && !FlxG.keys.pressed.CONTROL)
			{
				super.update(elapsed);
				return;
			}
			else
				UI_box.alpha = 1;

			selectedItem.x = FlxG.mouse.screenX - (selectedItem.width / 2);
			selectedItem.y = FlxG.mouse.screenY - (selectedItem.height / 2);

			// coulda used math.max or math.min but im stupid and I forgot how they work
			if (selectedItem.x > 1280)
				selectedItem.x = 1280;
			if (selectedItem.y > 720)
				selectedItem.y = 720;
			if (selectedItem.x < -100)
				selectedItem.x = -100;
			if (selectedItem.y < -100)
				selectedItem.y = -100;
			selectedItem.itemMeta.x = Math.floor(selectedItem.x);
			selectedItem.itemMeta.y = Math.floor(selectedItem.y);

			xEntry.value = selectedItem.x;
			yEntry.value = selectedItem.y;
		}
		else
		{
			UI_box.alpha = 1;
		}

		selectedHighlight.x = selectedItem.x - 5;
		selectedHighlight.y = selectedItem.y - 5;
		selectedHighlight.text = selectedItem.itemMeta.name;

		super.update(elapsed);
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (selectedItem == null)
			return;
		if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			switch (wname)
			{
				case "x":
					selectedItem.x = nums.value;
					selectedItem.itemMeta.x = Math.floor(selectedItem.x);
				case "y":
					selectedItem.y = nums.value;
					selectedItem.itemMeta.y = Math.floor(selectedItem.y);
				case "ofx":
					var anm = getAnimation(UI_dropDown.selectedLabel);
					if (anm == null)
					{
						statusText.text = "Couldn't find anm " + UI_dropDown.selectedLabel;
						return;
					}
					anm.offsetX = Math.floor(nums.value);
					playAnim();
				case "ofy":
					var anm = getAnimation(UI_dropDown.selectedLabel);
					if (anm == null)
					{
						statusText.text = "Couldn't find anm " + UI_dropDown.selectedLabel;
						return;
					}
					anm.offsetY = Math.floor(nums.value);
					playAnim();
				case "layer":
					selectedItem.itemMeta.layer = Math.floor(nums.value);
					relayer();
				case "scale":
					selectedItem.itemMeta.scale = nums.value;
					selectedItem.setGraphicSize(Std.int(selectedItem.width * nums.value));
				case "loop":
					var anm = getAnimation(UI_dropDown.selectedLabel);
					if (anm == null)
					{
						statusText.text = "Couldn't find anm " + UI_dropDown.selectedLabel;
						return;
					}
					statusText.text = "";
					anm.loop = loop.value == 0 ? false : true;
					var animation = selectedItem.animation.getByName(anm.name);
					if (animation == null)
					{
						statusText.text = "Couldn't find anm  " + anm.name;
						return;
					}
					selectedItem.animation.remove(currentAnim);
					selectedItem.animation.addByPrefix(anm.name, anm.symbol, anm.fps, anm.loop);
					playAnim();
			}
		}
		else if (id == FlxUIInputText.CHANGE_EVENT && (sender is FlxUIInputText))
		{
			var text:FlxUIInputText = cast sender;
			switch (text.name)
			{
				case "name":
					selectedItem.itemMeta.name = text.text;
					selectedText.text = "Selected: " + selectedItem.itemMeta.name;
					populateSelectables();
				case "animName" | "animSymbol":
					var anm = getAnimation(UI_dropDown.selectedLabel);
					if (anm == null)
					{
						statusText.text = "Couldn't find anm " + UI_dropDown.selectedLabel;
						return;
					}
					selectedItem.animation.remove(currentAnim);
					statusText.text = "";
					anm.name = animName.text;
					anm.symbol = animSymbol.text;
					currentAnim = animName.text;
					currentSymb = animSymbol.text;
					selectedItem.animation.addByPrefix(anm.name, anm.symbol, anm.fps, anm.loop);
					refreshAnimDrop();
					playAnim();
			}
		}
	}
}
