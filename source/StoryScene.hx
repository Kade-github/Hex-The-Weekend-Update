import flixel.FlxG;
import flixel.FlxSprite;

class StoryScene extends MusicBeatState
{
	public var handler:MP4Handler;

	public var path:String = "";

	public function new(bruh)
	{
		path = bruh;
		super();
	}

	public override function load()
	{
		handler = new MP4Handler();
	}

	public override function update(elapsed)
	{
		if (FlxG.keys.justPressed.ESCAPE)
		{
			handler.kill();
			switchState(new BruhADiagWindow(PlayState.SONG.songId));
		}
		super.update(elapsed);
	}

	public override function create()
	{
		handler.playMP4(Paths.video(path));
		handler.finishCallback = function()
		{
			switchState(new BruhADiagWindow(PlayState.SONG.songId));
		};
		super.create();
	}
}
