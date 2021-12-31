import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

class UnlockedState extends MusicBeatState
{
	public var unlockSprite:String;

	public override function create()
	{
		var spr = new FlxSprite(0, 0).loadGraphic(Paths.image(unlockSprite, "hex"));
		spr.scrollFactor.set();
		add(spr);
		super.create();
	}

	public override function update(elapsed)
	{
		if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.ENTER)
		{
			FlxG.sound.playMusic(Paths.music("freakyMenu"));
			HexMainMenu.currentSong = "Menu (Remix)";
			switchState(new HexMainMenu(HexMenuState.loadHexMenu("main-menu")));
		}
		super.update(elapsed);
	}
}
