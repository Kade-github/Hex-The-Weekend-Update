package;

import flash.display.BlendMode;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxBasic;
import flixel.group.FlxGroup;
import flixel.system.FlxSound;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class Stage extends MusicBeatState
{
	public var curStage:String = '';
	public var camZoom:Float; // The zoom of the camera to have at the start of the game
	public var hideLastBG:Bool = false; // True = hide last BGs and show ones from slowBacks on certain step, False = Toggle visibility of BGs from SlowBacks on certain step
	// Use visible property to manage if BG would be visible or not at the start of the game
	public var tweenDuration:Float = 2; // How long will it tween hiding/showing BGs, variable above must be set to True for tween to activate
	public var toAdd:Array<Dynamic> = []; // Add BGs on stage startup, load BG in by using "toAdd.push(bgVar);"
	// Layering algorithm for noobs: Everything loads by the method of "On Top", example: You load wall first(Every other added BG layers on it), then you load road(comes on top of wall and doesn't clip through it), then loading street lights(comes on top of wall and road)
	public var swagBacks:Map<String,
		Dynamic> = []; // Store BGs here to use them later (for example with slowBacks, using your custom stage event or to adjust position in stage debug menu(press 8 while in PlayState with debug build of the game))

	public var appearInFront:Array<FlxSprite> = [];

	public var swagGroup:Map<String, FlxTypedGroup<Dynamic>> = []; // Store Groups
	public var animatedBacks:Array<FlxSprite> = []; // Store animated backgrounds and make them play animation(Animation must be named Idle!! Else use swagGroup/swagBacks and script it in stepHit/beatHit function of this file!!)
	public var layInFront:Array<Array<FlxSprite>> = [[], [], []]; // BG layering, format: first [0] - in front of GF, second [1] - in front of opponent, third [2] - in front of boyfriend(and technically also opponent since Haxe layering moment)
	public var slowBacks:Map<Int,
		Array<FlxSprite>> = []; // Change/add/remove backgrounds mid song! Format: "slowBacks[StepToBeActivated] = [Sprites,To,Be,Changed,Or,Added];"

	// BGs still must be added by using toAdd Array for them to show in game after slowBacks take effect!!
	// BGs still must be added by using toAdd Array for them to show in game after slowBacks take effect!!
	// All of the above must be set or used in your stage case code block!!
	public var positions:Map<String, Map<String, Array<Int>>> = [
		// Assign your characters positions on stage here!
		'hexw' => ['gf-w' => [248, -33], 'bf-w' => [753, 258], 'hex-w' => [69, -58]],
		'hexwd' => ['gf-wd' => [248, -33], 'bf-wd' => [753, 238], 'hex-g-bruh' => [125, -75]],
		'hexwdg' => ['gf-wd' => [248, -33], 'bf-wd' => [753, 238], 'hex-g-bruh' => [125, -75]],
		'hexwstage' => ['lcdGF1' => [248, -33], 'lcdBF1' => [753, 258], 'lcdHEX1' => [69, -58]],
	];

	public function new(daStage:String)
	{
		super();
		this.curStage = daStage;
		camZoom = 1.05; // Don't change zoom here, unless you want to change zoom of every stage that doesn't have custom one
		if (PlayStateChangeables.Optimize)
			return;

		switch (daStage)
		{
			case 'hex':
				{
					camZoom = 0.9;
					curStage = 'hex';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback', 'hex'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					toAdd.push(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront', 'hex'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					toAdd.push(stageFront);
				}
			case 'hexss':
				{
					camZoom = 0.9;
					curStage = 'hexss';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('sunset/stageback', 'hex'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					toAdd.push(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('sunset/stagefront', 'hex'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					toAdd.push(stageFront);
				}
			case 'hexn':
				{
					camZoom = 0.9;
					curStage = 'hexn';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('night/stageback', 'hex'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					toAdd.push(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('night/stagefront', 'hex'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					toAdd.push(stageFront);
				}
			case 'hexg':
				{
					camZoom = 0.9;
					curStage = 'hexg';
					swagBacks['unGlitchedBG'] = new FlxSprite(-600, -200).loadGraphic(Paths.image('glitcher/stageback', 'hex'));
					swagBacks['unGlitchedBG'].antialiasing = true;
					swagBacks['unGlitchedBG'].scrollFactor.set(0.9, 0.9);
					swagBacks['unGlitchedBG'].active = false;
					toAdd.push(swagBacks['unGlitchedBG']);

					swagBacks['unGlitchedStageFront'] = new FlxSprite(-650, 600).loadGraphic(Paths.image('glitcher/stagefront', 'hex'));
					swagBacks['unGlitchedStageFront'].setGraphicSize(Std.int(swagBacks['unGlitchedStageFront'].width * 1.1));
					swagBacks['unGlitchedStageFront'].updateHitbox();
					swagBacks['unGlitchedStageFront'].antialiasing = true;
					swagBacks['unGlitchedStageFront'].scrollFactor.set(0.9, 0.9);
					swagBacks['unGlitchedStageFront'].active = false;
					toAdd.push(swagBacks['unGlitchedStageFront']);

					PlayState.glitcherDad = new Character(100, 100, 'hex-wire');
					PlayState.glitcherBF = new Boyfriend(770, 450, 'bf-wire');
					swagBacks['glitcherStage'] = new FlxSprite(-600, -200).loadGraphic(Paths.image('WIRE/WIREStageBack', 'hex'));
					swagBacks['glitcherStage'].antialiasing = true;
					swagBacks['glitcherStage'].scrollFactor.set(0.9, 0.9);
					swagBacks['glitcherStage'].active = false;

					PlayState.glitcherDad.alpha = 0;
					PlayState.glitcherBF.alpha = 0;
					swagBacks['glitcherStage'].alpha = 0;

					toAdd.push(swagBacks['glitcherStage']);
				}
			case 'hexw':
				{
					camZoom = 0.9;
					curStage = 'hexw';
					if (PlayState.SONG.songId.toLowerCase() == "cooling")
						swagBacks['hexBack'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/hexBack', 'hex'));
					else
						swagBacks['hexBack'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/hexBack_noVis', 'hex'));
					swagBacks['hexBack'].antialiasing = true;
					swagBacks['hexBack'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexBack'].setGraphicSize(Std.int(swagBacks['hexBack'].width * 1.5));

					swagBacks['hexFront'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/hexFront', 'hex'));
					swagBacks['hexFront'].antialiasing = true;
					swagBacks['hexFront'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexFront'].setGraphicSize(Std.int(swagBacks['hexFront'].width * 1.5));

					swagBacks['topOverlay'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/topOverlay', 'hex'));
					swagBacks['topOverlay'].antialiasing = true;
					swagBacks['topOverlay'].scrollFactor.set(0.9, 0.9);
					swagBacks['topOverlay'].setGraphicSize(Std.int(swagBacks['topOverlay'].width * 1.5));

					var sprite:FlxSprite = new FlxSprite(42, -14);
					sprite.frames = Paths.getSparrowAtlas('weekend/crowd', "hex");
					if (PlayState.SONG.songId == "java")
						sprite.frames = Paths.getSparrowAtlas('weekend/javaCrowd', "hex");
					sprite.animation.addByPrefix('bop', 'Symbol 1', 24, false);
					sprite.antialiasing = true;
					sprite.scrollFactor.set(0.9, 0.9);
					sprite.setGraphicSize(Std.int(sprite.width * 1.5));

					swagBacks['crowd'] = sprite;

					toAdd.push(swagBacks['hexBack']);
					toAdd.push(swagBacks['hexFront']);

					// spotlights

					for (i in 0...4)
					{
						var spotLight = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/spot' + (i + 1), 'hex'));
						spotLight.antialiasing = true;
						spotLight.scrollFactor.set(0.9, 0.9);
						spotLight.setGraphicSize(Std.int(spotLight.width * 1.5));
						spotLight.alpha = 0;

						spotLight.blend = BlendMode.ADD;

						swagBacks['spot' + i] = spotLight;
						layInFront[0].push(swagBacks['spot' + i]);
					}
					if (PlayState.SONG.songId.toLowerCase() == "cooling")
					{
						PlayState.coolingDad = new Character(69, -58, 'hex-wc');
						PlayState.coolingBF = new Boyfriend(753, 258, 'bf-wc');
						PlayState.coolingGF = new Boyfriend(248, -33, 'gf-wc');

						PlayState.coolingDad.alpha = 0;
						PlayState.coolingBF.alpha = 0;
						PlayState.coolingGF.alpha = 0;

						swagBacks['hexDarkBack'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/breakBack', 'hex'));
						swagBacks['hexDarkBack'].antialiasing = true;
						swagBacks['hexDarkBack'].scrollFactor.set(0.9, 0.9);
						swagBacks['hexDarkBack'].setGraphicSize(Std.int(swagBacks['hexDarkBack'].width * 1.5));

						swagBacks['hexDarkFront'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/breakFront', 'hex'));
						swagBacks['hexDarkFront'].antialiasing = true;
						swagBacks['hexDarkFront'].scrollFactor.set(0.9, 0.9);
						swagBacks['hexDarkFront'].setGraphicSize(Std.int(swagBacks['hexDarkFront'].width * 1.5));

						swagBacks['topDarkOverlay'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/breakOverlay', 'hex'));
						swagBacks['topDarkOverlay'].antialiasing = true;
						swagBacks['topDarkOverlay'].scrollFactor.set(0.9, 0.9);
						swagBacks['topDarkOverlay'].setGraphicSize(Std.int(swagBacks['topDarkOverlay'].width * 1.5));

						var dsprite:FlxSprite = new FlxSprite(42, -14);
						dsprite.frames = Paths.getSparrowAtlas('weekend/crowd_dark', "hex");
						dsprite.animation.addByPrefix('bop', 'Symbol 1', 24, false);
						dsprite.antialiasing = true;
						dsprite.scrollFactor.set(0.9, 0.9);
						dsprite.setGraphicSize(Std.int(dsprite.width * 1.5));

						swagBacks['darkCrowd'] = dsprite;

						swagBacks['hexDarkBack'].alpha = 0;
						swagBacks['hexDarkFront'].alpha = 0;
						swagBacks['topDarkOverlay'].alpha = 0;
						swagBacks['darkCrowd'].alpha = 0;

						toAdd.push(swagBacks['hexDarkBack']);
						toAdd.push(swagBacks['hexDarkFront']);

						for (i in 0...2)
						{
							var spotLight = new FlxSprite(0, 0).loadGraphic(Paths.image('weekend/breakSpotlight', 'hex'));
							spotLight.antialiasing = true;
							spotLight.scrollFactor.set(0.9, 0.9);
							spotLight.setGraphicSize(Std.int(spotLight.width * 1.5));
							spotLight.alpha = 0;

							spotLight.blend = BlendMode.ADD;

							swagBacks['breakSpot' + i] = spotLight;
							layInFront[0].push(swagBacks['breakSpot' + i]);
						}
					}
				}
			case 'hexwd':
				{
					camZoom = 0.9;
					curStage = 'hexwd';
					swagBacks['hexBack'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/detected/hexBack', 'hex'));
					swagBacks['hexBack'].antialiasing = true;
					swagBacks['hexBack'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexBack'].setGraphicSize(Std.int(swagBacks['hexBack'].width * 1.5));

					swagBacks['hexFront'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/detected/hexFront', 'hex'));
					swagBacks['hexFront'].antialiasing = true;
					swagBacks['hexFront'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexFront'].setGraphicSize(Std.int(swagBacks['hexFront'].width * 1.5));

					swagBacks['topOverlay'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/detected/topOverlay', 'hex'));
					swagBacks['topOverlay'].antialiasing = true;
					swagBacks['topOverlay'].scrollFactor.set(0.9, 0.9);
					swagBacks['topOverlay'].setGraphicSize(Std.int(swagBacks['topOverlay'].width * 1.5));

					var sprite:FlxSprite = new FlxSprite(42, -14);
					sprite.frames = Paths.getSparrowAtlas('weekend/detected/crowd', "hex");
					sprite.animation.addByPrefix('bop', 'Symbol 1', 24, false);
					sprite.antialiasing = true;
					sprite.scrollFactor.set(0.9, 0.9);
					sprite.setGraphicSize(Std.int(sprite.width * 1.5));

					swagBacks['crowd'] = sprite;

					toAdd.push(swagBacks['hexBack']);
					toAdd.push(swagBacks['hexFront']);
				}
			case "hexwdg":
				{
					PlayState.glitcherRDad = new Character(125, -75, 'rmxHex');
					PlayState.glitcherRBF = new Boyfriend(753, 238, 'rmxBF');

					camZoom = 0.9;
					curStage = 'hexwdg';
					swagBacks['hexBack'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/detected/hexBack', 'hex'));
					swagBacks['hexBack'].antialiasing = true;
					swagBacks['hexBack'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexBack'].setGraphicSize(Std.int(swagBacks['hexBack'].width * 1.5));

					swagBacks['hexFront'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/detected/hexFront', 'hex'));
					swagBacks['hexFront'].antialiasing = true;
					swagBacks['hexFront'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexFront'].setGraphicSize(Std.int(swagBacks['hexFront'].width * 1.5));

					swagBacks['topOverlay'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('weekend/detected/topOverlay', 'hex'));
					swagBacks['topOverlay'].antialiasing = true;
					swagBacks['topOverlay'].scrollFactor.set(0.9, 0.9);
					swagBacks['topOverlay'].setGraphicSize(Std.int(swagBacks['topOverlay'].width * 1.5));

					var sprite:FlxSprite = new FlxSprite(42, -14);
					sprite.frames = Paths.getSparrowAtlas('glitcher/remix/remixCrowd', "hex");
					sprite.animation.addByPrefix('bop', 'Symbol 1', 24, false);
					sprite.antialiasing = true;
					sprite.scrollFactor.set(0.9, 0.9);
					sprite.setGraphicSize(Std.int(sprite.width * 1.5));

					swagBacks['crowd'] = sprite;

					toAdd.push(swagBacks['hexBack']);
					toAdd.push(swagBacks['hexFront']);

					swagBacks['hexrBack'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('glitcher/remix/au_wire_back', 'hex'));
					swagBacks['hexrBack'].antialiasing = true;
					swagBacks['hexrBack'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexrBack'].setGraphicSize(Std.int(swagBacks['hexrBack'].width * 1.5));

					swagBacks['hexrFront'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('glitcher/remix/au_wire_front', 'hex'));
					swagBacks['hexrFront'].antialiasing = true;
					swagBacks['hexrFront'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexrFront'].setGraphicSize(Std.int(swagBacks['hexrFront'].width * 1.5));
					swagBacks['hexrFront'].alpha = 0;
					swagBacks['hexrBack'].alpha = 0;
					toAdd.push(swagBacks['hexrBack']);
					toAdd.push(swagBacks['hexrFront']);
				}
			case 'hexwstage':
				{
					camZoom = 0.9;
					curStage = 'hexwstage';

					// man this is stupid (don't cancel me again please)

					PlayState.lcdDad2 = new Character(69, -58, 'lcdHEX2');
					PlayState.lcdBF2 = new Boyfriend(753, 258, 'lcdBF2');
					PlayState.lcdGF2 = new Boyfriend(248, -33, 'lcdGF2');
					PlayState.lcdDad3 = new Character(69, -58, 'lcdHEX3');
					PlayState.lcdBF3 = new Boyfriend(753, 258, 'lcdBF3');
					PlayState.lcdGF3 = new Boyfriend(248, -33, 'lcdGF3');

					PlayState.lcdDad2.alpha = 0;
					PlayState.lcdBF2.alpha = 0;
					PlayState.lcdGF2.alpha = 0;

					PlayState.lcdDad3.alpha = 0;
					PlayState.lcdBF3.alpha = 0;
					PlayState.lcdGF3.alpha = 0;

					swagBacks['hexBack1'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('lcd/au_lcd_back_1', 'hex'));
					swagBacks['hexBack1'].antialiasing = true;
					swagBacks['hexBack1'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexBack1'].setGraphicSize(Std.int(swagBacks['hexBack1'].width * 1.5));

					swagBacks['hexBack2'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('lcd/au_lcd_back_2', 'hex'));
					swagBacks['hexBack2'].antialiasing = true;
					swagBacks['hexBack2'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexBack2'].setGraphicSize(Std.int(swagBacks['hexBack2'].width * 1.5));

					swagBacks['hexBack3'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('lcd/au_lcd_back_3', 'hex'));
					swagBacks['hexBack3'].antialiasing = true;
					swagBacks['hexBack3'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexBack3'].setGraphicSize(Std.int(swagBacks['hexBack3'].width * 1.5));

					swagBacks['hexFront1'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('lcd/au_lcd_front_1', 'hex'));
					swagBacks['hexFront1'].antialiasing = true;
					swagBacks['hexFront1'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexFront1'].setGraphicSize(Std.int(swagBacks['hexFront1'].width * 1.5));

					swagBacks['hexFront2'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('lcd/au_lcd_front_2', 'hex'));
					swagBacks['hexFront2'].antialiasing = true;
					swagBacks['hexFront2'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexFront2'].setGraphicSize(Std.int(swagBacks['hexFront2'].width * 1.5));

					swagBacks['hexFront3'] = new FlxSprite(-24, 24).loadGraphic(Paths.image('lcd/au_lcd_front_3', 'hex'));
					swagBacks['hexFront3'].antialiasing = true;
					swagBacks['hexFront3'].scrollFactor.set(0.9, 0.9);
					swagBacks['hexFront3'].setGraphicSize(Std.int(swagBacks['hexFront3'].width * 1.5));

					var light1:FlxSprite = new FlxSprite(42, 44);
					light1.frames = Paths.getSparrowAtlas('lcd/au_lcd_lights_1', "hex");
					light1.animation.addByPrefix('bop', 'Symbol 1', 24, false);
					light1.antialiasing = true;
					light1.scrollFactor.set(0.9, 0.9);
					light1.setGraphicSize(Std.int(light1.width * 1.5));

					swagBacks['lights1'] = light1;

					var light2:FlxSprite = new FlxSprite(42, 44);
					light2.frames = Paths.getSparrowAtlas('lcd/au_lcd_lights_2', "hex");
					light2.animation.addByPrefix('bop', 'Symbol 1', 24, false);
					light2.antialiasing = true;
					light2.scrollFactor.set(0.9, 0.9);
					light2.setGraphicSize(Std.int(light2.width * 1.5));

					swagBacks['lights2'] = light2;

					var light3:FlxSprite = new FlxSprite(42, 44);
					light3.frames = Paths.getSparrowAtlas('lcd/au_lcd_lights_3', "hex");
					light3.animation.addByPrefix('bop', 'Symbol 1', 24, false);
					light3.antialiasing = true;
					light3.scrollFactor.set(0.9, 0.9);
					light3.setGraphicSize(Std.int(light2.width * 1.5));

					swagBacks['lights3'] = light3;

					var sprite:FlxSprite = new FlxSprite(42, -14);
					sprite.frames = Paths.getSparrowAtlas('lcd/au_lcd_audience_1', "hex");
					sprite.animation.addByPrefix('bop', 'Symbol 1', 24, false);
					sprite.antialiasing = true;
					sprite.scrollFactor.set(0.9, 0.9);
					sprite.setGraphicSize(Std.int(sprite.width * 1.5));

					swagBacks['crowd1'] = sprite;

					var sprite2:FlxSprite = new FlxSprite(42, -14);
					sprite2.frames = Paths.getSparrowAtlas('lcd/au_lcd_audience_2', "hex");
					sprite2.animation.addByPrefix('bop', 'Symbol 1', 24, false);
					sprite2.antialiasing = true;
					sprite2.scrollFactor.set(0.9, 0.9);
					sprite2.setGraphicSize(Std.int(sprite.width * 1.5));

					swagBacks['crowd2'] = sprite2;

					var sprite3:FlxSprite = new FlxSprite(42, -14);
					sprite3.frames = Paths.getSparrowAtlas('lcd/au_lcd_audience_3', "hex");
					sprite3.animation.addByPrefix('bop', 'Symbol 1', 24, false);
					sprite3.antialiasing = true;
					sprite3.scrollFactor.set(0.9, 0.9);
					sprite3.setGraphicSize(Std.int(sprite.width * 1.5));

					swagBacks['crowd3'] = sprite3;

					toAdd.push(swagBacks['hexBack1']);
					toAdd.push(swagBacks['hexBack2']);
					toAdd.push(swagBacks['hexBack3']);
					toAdd.push(swagBacks['lights1']);
					toAdd.push(swagBacks['lights2']);
					toAdd.push(swagBacks['lights3']);
				}
			default:
				{
					camZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.loadImage('stageback', 'shared'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.loadImage('stagefront', 'shared'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = FlxG.save.data.antialiasing;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					swagBacks['stageFront'] = stageFront;
					toAdd.push(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.loadImage('stagecurtains', 'shared'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					stageCurtains.antialiasing = FlxG.save.data.antialiasing;
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					swagBacks['stageCurtains'] = stageCurtains;
					toAdd.push(stageCurtains);
				}
		}
	}

	override public function update(elapsed:Float)
	{
		// super.update(elapsed);

		if (!PlayStateChangeables.Optimize)
		{
			switch (curStage)
			{
				case 'philly':
					if (trainMoving)
					{
						trainFrameTiming += elapsed;

						if (trainFrameTiming >= 1 / 24)
						{
							updateTrainPos();
							trainFrameTiming = 0;
						}
					}
					// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
			}
		}
	}

	override function stepHit()
	{
		super.stepHit();

		if (!PlayStateChangeables.Optimize)
		{
			var array = slowBacks[curStep];
			if (array != null && array.length > 0)
			{
				if (hideLastBG)
				{
					for (bg in swagBacks)
					{
						if (!array.contains(bg))
						{
							var tween = FlxTween.tween(bg, {alpha: 0}, tweenDuration, {
								onComplete: function(tween:FlxTween):Void
								{
									bg.visible = false;
								}
							});
						}
					}
					for (bg in array)
					{
						bg.visible = true;
						FlxTween.tween(bg, {alpha: 1}, tweenDuration);
					}
				}
				else
				{
					for (bg in array)
						bg.visible = !bg.visible;
				}
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (FlxG.save.data.distractions && animatedBacks.length > 0)
		{
			for (bg in animatedBacks)
				bg.animation.play('idle', true);
		}

		if (!PlayStateChangeables.Optimize)
		{
			switch (curStage)
			{
				case 'halloween':
					if (FlxG.random.bool(Conductor.bpm > 320 ? 100 : 10) && curBeat > lightningStrikeBeat + lightningOffset)
					{
						if (FlxG.save.data.distractions)
						{
							lightningStrikeShit();
							trace('spooky');
						}
					}
				case 'school':
					if (FlxG.save.data.distractions)
					{
						swagBacks['bgGirls'].dance();
					}
				case 'limo':
					if (FlxG.save.data.distractions)
					{
						swagGroup['grpLimoDancers'].forEach(function(dancer:BackgroundDancer)
						{
							dancer.dance();
						});

						if (FlxG.random.bool(10) && fastCarCanDrive)
							fastCarDrive();
					}
				case "philly":
					if (FlxG.save.data.distractions)
					{
						if (!trainMoving)
							trainCooldown += 1;

						if (curBeat % 4 == 0)
						{
							var phillyCityLights = swagGroup['phillyCityLights'];
							phillyCityLights.forEach(function(light:FlxSprite)
							{
								light.visible = false;
							});

							curLight = FlxG.random.int(0, phillyCityLights.length - 1);

							phillyCityLights.members[curLight].visible = true;
							// phillyCityLights.members[curLight].alpha = 1;
						}
					}

					if (curBeat % 8 == 4 && FlxG.random.bool(Conductor.bpm > 320 ? 150 : 30) && !trainMoving && trainCooldown > 8)
					{
						if (FlxG.save.data.distractions)
						{
							trainCooldown = FlxG.random.int(-4, 0);
							trainStart();
							trace('train');
						}
					}
			}
		}
	}

	// Variables and Functions for Stages
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var curLight:Int = 0;

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2, 'shared'));
		swagBacks['halloweenBG'].animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		if (PlayState.boyfriend != null)
		{
			PlayState.boyfriend.playAnim('scared', true);
			PlayState.gf.playAnim('scared', true);
		}
		else
		{
			GameplayCustomizeState.boyfriend.playAnim('scared', true);
			GameplayCustomizeState.gf.playAnim('scared', true);
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;
	var trainSound:FlxSound;

	function trainStart():Void
	{
		if (FlxG.save.data.distractions)
		{
			trainMoving = true;
			trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;

				if (PlayState.gf != null)
					PlayState.gf.playAnim('hairBlow');
				else
					GameplayCustomizeState.gf.playAnim('hairBlow');
			}

			if (startedMoving)
			{
				var phillyTrain = swagBacks['phillyTrain'];
				phillyTrain.x -= 400;

				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}
	}

	function trainReset():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (PlayState.gf != null)
				PlayState.gf.playAnim('hairFall');
			else
				GameplayCustomizeState.gf.playAnim('hairFall');

			swagBacks['phillyTrain'].x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (FlxG.save.data.distractions)
		{
			var fastCar = swagBacks['fastCar'];
			fastCar.x = -12600;
			fastCar.y = FlxG.random.int(140, 250);
			fastCar.velocity.x = 0;
			fastCar.visible = false;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if (FlxG.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1, 'shared'), 0.7);

			swagBacks['fastCar'].visible = true;
			swagBacks['fastCar'].velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}
}
