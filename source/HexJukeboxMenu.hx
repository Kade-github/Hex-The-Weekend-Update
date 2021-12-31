import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.addons.display.FlxBackdrop;

class HexJukeboxMenu extends HexMenuState
{
	public var selectedIndex = 0;
	public var playingIndex = 0;

	public static function indexToSong(index:Int):String
	{
		switch (index)
		{
			case 0:
				return "dunk";
			case 1:
				return "ram";
			case 2:
				return "hello-world";
			case 3:
				return "glitcher";
			case 4:
				return "encore";
			case 5:
				return "cooling";
			case 6:
				return "detected";
			case 7:
				return "glitcher-remix";
			case 8:
				return "java";
			case 9:
				return "lcd";
			case 10:
				return "hectic";
			case 11:
				return "reboot";
			case 12:
				return "rom";
			case 13:
				return "menu-remix";
			case 14:
				return "breakfast-remix";
			case 15:
				return "gameover-remix";
		}
		return "null";
	}

	public static function songToIndex(song:String):Int
	{
		switch (song)
		{
			case "dunk":
				return 0;
			case "r.a.m":
				return 1;
			case "hello world!":
				return 2;
			case "glitcher":
				return 3;
			case "encore":
				return 4;
			case "cooling":
				return 5;
			case "detected":
				return 6;
			case "glitcher (remix)":
				return 7;
			case "java":
				return 8;
			case "lcd":
				return 9;
			case "hectic":
				return 10;
			case "reboot":
				return 11;
			case "rom":
				return 12;
			case "menu (remix)":
				return 13;
			case "breakfast":
				return 14;
			case "game over":
				return 15;
		}
		return -1;
	}

	public var playingLerp:Float = 0;
	public var reversePlay:Bool = false;

	public override function create()
	{
		var yeah = new FlxBackdrop(Paths.image('jukebox/background', 'hexMenu'), 0, 0, true, true); // backgrounds are the only hardcoded thing sorry :(
		yeah.setPosition(0, 0);
		yeah.antialiasing = true;
		yeah.scrollFactor.set();
		add(yeah);
		yeah.velocity.set(20, 0);
		superCreate();
		super.create();
		Items.members.remove(getItemByName("bg"));

		getItemByName("otherSelect").visible = false;
		selectedIndex = songToIndex(HexMainMenu.currentSong.toLowerCase());
		playingIndex = selectedIndex;
		select();
		if (selectedIndex <= 4)
			getItemByName("playing").y = getItemByName("select_symbol").y + 8;
		else
			getItemByName("playing").y = getItemByName("otherSelect").y + 8;
	}

	public function select()
	{
		Debug.logTrace(selectedIndex);
		if (selectedIndex > 4)
		{
			getItemByName("otherSelect").visible = true;
			getItemByName("select_symbol").visible = false;
			getItemByName("otherSelect").y = 328 + (28 * (selectedIndex - 5));
		}
		else
		{
			getItemByName("otherSelect").visible = false;
			getItemByName("select_symbol").visible = true;
			getItemByName("select_symbol").y = (142 + (28 * selectedIndex)) - 4;
		}
		getItemByName("leftSong").changeOutGraphic("jukebox/left_song_" + (selectedIndex + 1));
	}

	public override function update(elapsed)
	{
		if (FlxG.keys.justPressed.ESCAPE)
			switchState(new HexMainMenu(HexMenuState.loadHexMenu("main-menu")));
		if (!reversePlay)
		{
			playingLerp += elapsed;
			getItemByName("playing").alpha = FlxMath.lerp(0, 1, playingLerp);
			if (getItemByName("playing").alpha == 1)
			{
				reversePlay = !reversePlay;
				playingLerp = 0;
			}
		}
		else
		{
			playingLerp += elapsed;
			getItemByName("playing").alpha = FlxMath.lerp(1, 0, playingLerp);
			if (getItemByName("playing").alpha == 0)
			{
				reversePlay = !reversePlay;
				playingLerp = 0;
			}
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			FlxG.sound.play(Paths.sound("scrollMenu"));
			selectedIndex++;
			if (selectedIndex > 15)
				selectedIndex = 0;
			select();
		}
		if (FlxG.keys.justPressed.UP)
		{
			FlxG.sound.play(Paths.sound("scrollMenu"));
			selectedIndex--;
			if (selectedIndex < 0)
				selectedIndex = 15;
			select();
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			if (selectedIndex <= 4)
				getItemByName("playing").y = getItemByName("select_symbol").y + 8;
			else
				getItemByName("playing").y = getItemByName("otherSelect").y + 8;
			HexMainMenu.currentSong = indexToSong(selectedIndex);
			FlxG.sound.playMusic(Paths.music(HexMainMenu.currentSong, "hexMenu"));
			// this is in freeplay and here, could be replaced with a switch.
			if (HexMainMenu.currentSong == "ram")
				HexMainMenu.currentSong = "R.A.M";
			else if (HexMainMenu.currentSong == "hello-world")
				HexMainMenu.currentSong = "Hello World!";
			else if (HexMainMenu.currentSong == "glitcher-remix")
				HexMainMenu.currentSong = "Glitcher (Remix)";
			else if (HexMainMenu.currentSong == "lcd")
				HexMainMenu.currentSong = "LCD";
			else if (HexMainMenu.currentSong == "rom")
				HexMainMenu.currentSong = "R.O.M";
		}
		super.update(elapsed);
	}
}
