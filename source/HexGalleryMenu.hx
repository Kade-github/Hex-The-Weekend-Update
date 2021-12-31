import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

using StringTools;

class HexGalleryMenu extends HexMenuState
{
	public var selectedIndex = 0;
	public var selectedPage = 0;
	public var zoomedImage:FlxSprite;

	public override function create()
	{
		var yeah = new FlxBackdrop(Paths.image('gallery/background', 'hexMenu'), 0, 0, true, true); // backgrounds are the only hardcoded thing sorry :(
		yeah.setPosition(0, 0);
		yeah.antialiasing = true;
		yeah.scrollFactor.set();
		add(yeah);
		yeah.velocity.set(20, 0);
		superCreate();
		super.create();
		Items.members.remove(getItemByName("bg"));

		setVisible(0);
	}

	public function select()
	{
		getItemByName("pos" + (selectedIndex + 1)).changeOutGraphic("gallery/left_select_" + (selectedIndex + 1));
		if (selectedPage == 0)
		{
			getItemByName("rightTextPos").changeOutGraphic("gallery/right_drawings_text_" + (selectedIndex + 1));
			getItemByName("cconceptPos").changeOutGraphic("gallery/right_drawings_image_" + (selectedIndex + 1));
		}
		else
		{
			getItemByName("rightTextPos").changeOutGraphic("gallery/right_concepts_text_" + (selectedIndex + 1));
			getItemByName("cconceptPos").changeOutGraphic("gallery/right_concepts_image_" + (selectedIndex + 1));
		}
	}

	public function setVisible(page:Int)
	{
		selectedPage = page;
		getItemByName("pos" + (selectedIndex + 1)).changeOutGraphic("gallery/left_normal_" + (selectedIndex + 1));
		selectedIndex = 0;
		var index = 1;
		for (i in Items)
		{
			if (page == 0)
			{
				if (i.itemMeta.name.startsWith("conc"))
				{
					i.changeOutGraphic("gallery/left_drawings_text_" + index);
					index++;
				}
			}
			else
			{
				if (i.itemMeta.name.startsWith("conc"))
				{
					i.changeOutGraphic("gallery/left_concepts_text_" + index);
					index++;
				}
			}
		}

		if (page == 0)
		{
			getItemByName("upConcepts").changeOutGraphic("gallery/up_concepts_normal");
			getItemByName("upDrawings").changeOutGraphic("gallery/up_drawings_select");
			getItemByName("draw8").visible = true;
			getItemByName("pos8").visible = true;
		}
		else
		{
			getItemByName("upConcepts").changeOutGraphic("gallery/up_concepts_select");
			getItemByName("upDrawings").changeOutGraphic("gallery/up_drawings_normal");
			getItemByName("draw8").visible = false;
			getItemByName("pos8").visible = false;
		}
		select();
	}

	public var tween:FlxTween;

	public override function update(elapsed)
	{
		if (FlxG.keys.justPressed.ESCAPE)
			switchState(new HexMainMenu(HexMenuState.loadHexMenu("main-menu")));
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT)
		{
			if (zoomedImage != null)
			{
				tween = FlxTween.tween(zoomedImage, {alpha: 0}, 0.2, {
					onComplete: function(tw)
					{
						remove(zoomedImage);
					}
				});
			}
			FlxG.sound.play(Paths.sound("scrollMenu"));
			setVisible(selectedPage == 0 ? 1 : 0);
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			if (zoomedImage != null)
			{
				if (!tween.finished)
					tween.cancel();
				remove(zoomedImage);
			}
			if (selectedPage == 0)
				zoomedImage = new FlxSprite(0, 0).loadGraphic(Paths.image("gallery/zoom_drawings_" + (selectedIndex + 1), "hexMenu"));
			else
				zoomedImage = new FlxSprite(0, 0).loadGraphic(Paths.image("gallery/zoom_concepts_" + (selectedIndex + 1), "hexMenu"));
			add(zoomedImage);
			zoomedImage.alpha = 0;

			tween = FlxTween.tween(zoomedImage, {alpha: 1}, 0.2);
		}

		if (FlxG.keys.justPressed.DOWN)
		{
			if (zoomedImage != null)
			{
				tween = FlxTween.tween(zoomedImage, {alpha: 0}, 0.2, {
					onComplete: function(tw)
					{
						remove(zoomedImage);
					}
				});
			}
			FlxG.sound.play(Paths.sound("scrollMenu"));
			getItemByName("pos" + (selectedIndex + 1)).changeOutGraphic("gallery/left_normal_" + (selectedIndex + 1));
			selectedIndex++;
			var max = selectedPage == 0 ? 7 : 6;
			if (selectedIndex > max)
				selectedIndex = 0;
			select();
		}
		if (FlxG.keys.justPressed.UP)
		{
			if (zoomedImage != null)
			{
				tween = FlxTween.tween(zoomedImage, {alpha: 0}, 0.2, {
					onComplete: function(tw)
					{
						remove(zoomedImage);
					}
				});
			}
			FlxG.sound.play(Paths.sound("scrollMenu"));
			getItemByName("pos" + (selectedIndex + 1)).changeOutGraphic("gallery/left_normal_" + (selectedIndex + 1));
			selectedIndex--;
			var max = selectedPage == 0 ? 7 : 6;
			if (selectedIndex < 0)
				selectedIndex = max;
			select();
		}
		super.update(elapsed);
	}
}
