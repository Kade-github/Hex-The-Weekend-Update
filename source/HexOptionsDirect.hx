import flixel.addons.display.FlxBackdrop;

class HexOptionsDirect extends HexMenuState
{
	public static var instance:HexOptionsDirect;

	override function create()
	{
		instance = this;
		superCreate();
		var yeah = new FlxBackdrop(Paths.image('options/background', 'hexMenu'), 0, 0, true, true); // backgrounds are the only hardcoded thing sorry :(
		yeah.setPosition(0, 0);
		yeah.antialiasing = true;
		yeah.scrollFactor.set();
		add(yeah);
		yeah.velocity.set(20, 0);
		super.create();
		Items.members.remove(getItemByName("bg"));

		persistentUpdate = true;

		openSubState(new OptionsMenu());
	}

	override function closeSubState()
	{
		Debug.logTrace("a");
		if (transOutFinished)
			super.closeSubState();
	}

	override function update(elapsed)
	{
		super.update(elapsed);
	}
}
