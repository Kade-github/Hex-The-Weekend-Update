import flixel.addons.display.FlxBackdrop;
import flixel.tweens.FlxTween;
import HexMenuState.HexMenuItem;
import flixel.FlxG;

using StringTools;

class HexCreditsMenu extends HexMenuState
{
	public var hoveredMenuItem:HexMenuItem;

	public override function create()
	{
		var yeah = new FlxBackdrop(Paths.image('credits/background', 'hexMenu'), 0, 0, true, true); // backgrounds are the only hardcoded thing sorry :(
		yeah.setPosition(0, 0);
		yeah.antialiasing = true;
		yeah.scrollFactor.set();
		add(yeah);
		yeah.velocity.set(20, 0);
		FlxG.mouse.visible = true;
		superCreate();
		super.create();
		Items.members.remove(getItemByName("bg"));

		getItemByName("cameos").visible = false;
	}

	public override function update(elapsed)
	{
		if (FlxG.keys.justPressed.ESCAPE)
			switchState(new HexMainMenu(HexMenuState.loadHexMenu("main-menu")));
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
		{
			FlxG.sound.play(Paths.sound("scrollMenu"));
			getItemByName("cameos").visible = !getItemByName("cameos").visible;
		}

		// smart gamer moves

		var hovered = false;
		for (i in Items)
		{
			if (i.itemMeta.name.endsWith("Icon") && FlxG.mouse.overlaps(i))
			{
				hoveredMenuItem = i;
				hovered = true;
			}
		}
		if (!hovered)
			hoveredMenuItem = null;

		// FlxG.watch.addQuick("Hovered", hovered);

		if (hoveredMenuItem != null && !getItemByName("cameos").visible)
		{
			for (i in Items)
			{
				if (i.itemMeta.name.endsWith("Icon") && i.itemMeta.name != hoveredMenuItem.itemMeta.name)
				{
					if (i.alpha == 1)
						FlxTween.tween(i, {alpha: 0.5}, 0.1);
				}
				else
					i.alpha = 1;
			}
		}
		else
		{
			for (i in Items)
			{
				if (i.alpha == 0.5)
					FlxTween.tween(i, {alpha: 1}, 0.1);
			}
		}

		if (FlxG.mouse.justPressed && hoveredMenuItem != null && !getItemByName("cameos").visible)
		{
			switch (hoveredMenuItem.itemMeta.name)
			{
				case "yingIcon":
					fancyOpenURL("https://www.youtube.com/c/YingYang48");
				case "kadeIcon":
					fancyOpenURL("https://www.youtube.com/c/kadedev");
				case "djIcon":
					fancyOpenURL("https://www.youtube.com/channel/UCwbK4bAoqfd8D_NwlGzlZQg");
				case "moroIcon":
					fancyOpenURL("https://www.youtube.com/channel/UCFAn3uATFn-3fJMztiH5Qzw");
				case "jzIcon":
					fancyOpenURL("https://www.youtube.com/c/JzBoy");
				case "mamiIcon":
					fancyOpenURL("https://www.youtube.com/c/MamiPipO");
			}
		}
		super.update(elapsed);
	}
}
