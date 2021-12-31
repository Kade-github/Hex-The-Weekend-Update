import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxCamera.FlxCameraFollowStyle;
import HexMenuState.HexMenuItem;
import flixel.FlxG;

using StringTools;

class HexMainMenu extends HexMenuState
{
	public static var currentSong:String = "Menu (Remix)";

	public var _songText:FlxText;

	var selectedIndex = 0;

	var Boxes:Array<HexMenuItem> = [];

	var targetY:Array<Float> = [];

	var yeah:FlxBackdrop;

	public function select()
	{
		if (selectedIndex > 5)
		{
			selectedIndex = 0;
		}
		if (selectedIndex < 0)
		{
			selectedIndex = 5;
		}
		if (!FlxG.save.data.weekendxBeat)
		{
			if (selectedIndex == 2)
				selectedIndex = 4;
			if (selectedIndex == 3)
				selectedIndex = 1;
		}
		for (i in Boxes)
		{
			i.changeOutGraphic("main/box_normal");
			i.offset.set(0, 0);

			var index = Boxes.indexOf(i);

			var awayIndex = index - selectedIndex;

			targetY[index] = awayIndex;
		}
		Boxes[selectedIndex].changeOutGraphic("main/box_select");
		Boxes[selectedIndex].offset.set(30, 17);

		FlxG.sound.play(Paths.sound("scrollMenu"));

		getItemByName("options").playAnimation("options b");

		getItemByName("credits").playAnimation("credits b");
		getItemByName("freeplay").playAnimation("freeplay b");
		getItemByName("story mode").playAnimation("story mode b");
		getItemByName("gallery").playAnimation("gallery b");
		getItemByName("jukebox").playAnimation("jukebox b");
		switch (selectedIndex)
		{
			case 0:
				getItemByName("story mode").playAnimation("story mode selected");
			case 1:
				getItemByName("freeplay").playAnimation("freeplay selected");
			case 2:
				getItemByName("gallery").playAnimation("gallery selected");
			case 3:
				getItemByName("jukebox").playAnimation("jukebox selected");
			case 4:
				getItemByName("options").playAnimation("options selected");
			case 5:
				getItemByName("credits").playAnimation("credits selected");
		}
	}

	override function create()
	{
		KeyBinds.keyCheck();
		FlxG.mouse.visible = false;
		superCreate();
		yeah = new FlxBackdrop(Paths.image('main/background', 'hexMenu'), 0, 0, true, true); // backgrounds are the only hardcoded thing sorry :(
		yeah.setPosition(0, 0);
		yeah.antialiasing = true;
		yeah.scrollFactor.set();
		add(yeah);
		yeah.velocity.set(20, 0);
		super.create();
		Items.members.remove(getItemByName("bg"));
		for (i in Items)
		{
			if (i.itemMeta.name.startsWith("box"))
				Boxes.push(i);
		}
		_songText = new FlxText(0, 0, 0, "");
		_songText.setFormat(Paths.font("Gotham_Black_Regular.ttf"), 24, FlxColor.fromRGB(21, 21, 40), FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE,
			FlxColor.WHITE);
		_songText.borderSize = 2;
		_songText.antialiasing = true;
		add(_songText);
		select();
		for (i in Boxes)
		{
			var scaledY = FlxMath.remapToRange(targetY[Boxes.indexOf(i)], 0, 1, 0, 1.3);
			i.y = (scaledY * 120) + (FlxG.height * 0.48);
		}

		if (FlxG.save.data.weekendxBeat == null)
			FlxG.save.data.weekendxbeat = false;
		if (FlxG.save.data.weekxBeat == null)
			FlxG.save.data.weekxbeat = false;

		Debug.logTrace(FlxG.save.data.weekendxBeat + " <<<");

		if (FlxG.save.data.weekendxBeat)
		{
			getItemByName("locked1").visible = false;
			getItemByName("locked2").visible = false;
		}

		getItemByName("story mode").setPosition(Boxes[0].x, Boxes[0].y);
		getItemByName("freeplay").setPosition(Boxes[1].x, Boxes[1].y);
		getItemByName("gallery").setPosition(Boxes[2].x, Boxes[2].y);
		getItemByName("jukebox").setPosition(Boxes[3].x, Boxes[3].y);
		getItemByName("options").setPosition(Boxes[4].x, Boxes[4].y);
		getItemByName("credits").setPosition(Boxes[5].x, Boxes[5].y);
	}

	var lerp:Float = 0;
	var toggle:Bool = false;

	var beatLerp:Float = 0;

	override function stepHit()
	{
		super.stepHit();
	}

	override function beatHit()
	{
		beatLerp = 1;
		super.beatHit();
	}

	public function selectThing()
	{
		switch (selectedIndex)
		{
			case 0:
				switchState(new HexStoryMenu(HexMenuState.loadHexMenu("story-menu")));
			case 1:
				switchState(new HexFreeplayMenu(HexMenuState.loadHexMenu("freeplay-menu")));
			case 2:
				switchState(new HexGalleryMenu(HexMenuState.loadHexMenu("gallery-menu")));
			case 3:
				switchState(new HexJukeboxMenu(HexMenuState.loadHexMenu("jukebox-menu")));
			case 4:
				switchState(new HexOptionsDirect(HexMenuState.loadHexMenu("options-menu")));
			case 5:
				switchState(new HexCreditsMenu(HexMenuState.loadHexMenu("credits-menu")));
		}
	}

	override function update(elapsed:Float)
	{
		Conductor.songPosition = FlxG.sound.music.time;
		if (currentSong != _songText.text)
		{
			switch (currentSong.toLowerCase())
			{
				case "menu (remix)":
					Conductor.changeBPM(102);
				case "dunk":
					Conductor.changeBPM(95);
				case "r.a.m" | "reboot" | "r.o.m":
					Conductor.changeBPM(120);
				case "hello world!":
					Conductor.changeBPM(150);
				case "glitcher":
					Conductor.changeBPM(175);
				case "encore":
					Conductor.changeBPM(116);
				case "cooling":
					Conductor.changeBPM(155);
				case "detected":
					Conductor.changeBPM(195);
				case "glitcher (remix)":
					Conductor.changeBPM(180);
				case "java" | "game over":
					Conductor.changeBPM(100);
				case "lcd" | "breakfast":
					Conductor.changeBPM(160);
			}
			_songText.text = (currentSong.charAt(0).toUpperCase() + currentSong.substr(1)).replace("remix", "Remix");
			_songText.x = getItemByName("note").x - (_songText.fieldWidth + 16);
			_songText.y = getItemByName("note").y + ((getItemByName("note").height / 2) - 12);
		}

		var bpmModifier = 1 + ((Conductor.bpm / 60) / 10);

		if (beatLerp > 0)
			beatLerp -= (elapsed * 1.6) * (bpmModifier);

		FlxG.watch.addQuick("beatLerp", beatLerp);
		FlxG.watch.addQuick("bpmMod", bpmModifier);
		getItemByName("note").setGraphicSize(Std.int(getItemByName("note").width * FlxMath.lerp(1, 1.12, beatLerp)));

		if (!toggle)
		{
			lerp += elapsed * 0.3;
			if (lerp >= 1)
				toggle = !toggle;
			getItemByName("backdrop").y = FlxMath.lerp(16, -16, lerp);
		}
		else
		{
			lerp -= elapsed * 0.3;
			if (lerp <= 0.0)
				toggle = !toggle;
			getItemByName("backdrop").y = FlxMath.lerp(16, -16, lerp);
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			selectedIndex++;
			select();
		}
		if (FlxG.keys.justPressed.UP)
		{
			selectedIndex--;
			select();
		}

		var index = 0;

		for (i in Boxes)
		{
			var scaledY = FlxMath.remapToRange(targetY[index], 0, 1, 0, 1.3);

			i.y = FlxMath.lerp(i.y, (scaledY * 120) + (FlxG.height * 0.48), 0.30);
			index++;
		}

		getItemByName("locked1").y = getItemByName("gallery").y + 15;
		getItemByName("locked1").x = getItemByName("gallery").x + 415;
		getItemByName("locked2").y = getItemByName("jukebox").y + 15;
		getItemByName("locked2").x = getItemByName("jukebox").x + 415;

		getItemByName("story mode").setPosition(Boxes[0].x, Boxes[0].y);
		getItemByName("freeplay").setPosition(Boxes[1].x, Boxes[1].y);
		getItemByName("gallery").setPosition(Boxes[2].x, Boxes[2].y);
		getItemByName("jukebox").setPosition(Boxes[3].x, Boxes[3].y);
		getItemByName("options").setPosition(Boxes[4].x, Boxes[4].y);
		getItemByName("credits").setPosition(Boxes[5].x, Boxes[5].y);

		if (FlxG.keys.justPressed.ENTER)
		{
			selectThing();
		}
		super.update(elapsed);
	}
}
