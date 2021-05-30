package;

import Section.SwagSection;
import Song.SwagSong;
import NamebeMappings.NameMap;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import Controls.KeyboardScheme;
import Discord.DiscordClient;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var MAPPINGS:NameMap;
	public static var isStoryMode:Bool = false;
	public static var isWeekend:Bool = false;
	public static var storyWeek:Int = 0;
	public static var weekend:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekendPlaylist:Array<String> = [];
	public static var weekEndFreeplay:Bool = false;
	public static var randomLevel:Bool = false;

	public static var gamingsOwnCoords:Array<Float>;
	public static var hasFocusedOnGaming:Bool = false;
	public static var hasFocusedOnDudes:Bool = false;

	public static var sheShed:String;

	var halloweenLevel:Bool = false;
	var areTheirDogs:Bool = false;

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;
	private var gspot:Character;
	private var gaming:Character;
	private var bab:Character;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

    var grpLimoNadders:FlxTypedGroup<BackgroundNadders>;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;
	var pogBabby:FlxSprite;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;
	var gamingBop:FlxSprite;
	var grpGuardDogs:FlxTypedGroup<GuardDogs>;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	public static var stagePath:String = 'assets/images/stages/'; 
	
	var vans:FlxSprite;
	var sun:FlxSprite;

	var paly2:String;
	var paly3:String;

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	var songsWithDialogue:Array<String> = [
		'senpai', 'roses', 'thorns', 
		'north', 'radical-vs-masked-babbys', 'monkey-sprite', 
		'namebe', 'fnaf-at-phillys', 'destructed', 
		'the-backyardagains', 'funny'
	];

	public static var campaignScore:Int = 0;
	public static var weekendScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	static public var whatInputSystem:String;

	var charColors:Array<FlxColor> = [
		0xFFf71436,
		0xFF24ff45,
		0xFF88a4cf,
		0xFFffbd2e,
		0xFF19fca2,
		0xFF9e3923,
		0xFF3cff00,
		0xFFff00e1,
		0xFFffa8f0,
		0xFF24ff45,
		0xFF7565f0,
		0xFFffff00,
		0xFFbf0033,
		0xFF000000,
		0xFF000000,
		0xFF41855e,
		0xFFffe4a8,
		0xFFffe0cf,
		0xFFb55de8,
		0xFF001eff,
		0xFFff0000,
		0xFFfba6ff,
		0xFFf2f277,
		0xFFd9f4ff,
		0xFFffa8f9,
		0xFFeb4d09,
		0xFFdfff4f,
		0xFF472fbd,
		0xFFff4548,
		0xFF7c57bd,
		0xFF644e66,
		0xFFffffff,
		0xFFf5e187
	];

	override public function create()
	{
		if (FlxG.save.data.DFJK)
			controls.setKeyboardScheme(KeyboardScheme.DeeEffJayKay, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);

		trace('https://www.youtube.com/watch?v=iik25wqIuFo');
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		whatInputSystem = FlxG.save.data.inputSystem;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.changeBPM(SONG.bpm);

		sheShed = SONG.song.toLowerCase();

		if (songsWithDialogue.contains(sheShed))
		{
			switch (sheShed)
			{
				case 'tutorial':
					dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
				case 'bopeebo':
					dialogue = [
						'HEY!',
						"You think you can just sing\nwith my daughter like that?",
						"If you want to date her...",
						"You're going to have to go \nthrough ME first!"
					];
				case 'fresh':
					dialogue = ["Not too shabby boy.", ""];
				case 'dadbattle':
					dialogue = [
						"gah you think you're hot stuff?",
						"If you can beat me here...",
						"Only then I will even CONSIDER letting you\ndate my daughter!"
					];
				case 'senpai':
					dialogue = CoolUtil.coolTextFile('assets/data/senpai/senpaiDialogue.txt');
				case 'roses':
					dialogue = CoolUtil.coolTextFile('assets/data/roses/rosesDialogue.txt');
				case 'thorns':
					dialogue = CoolUtil.coolTextFile('assets/data/thorns/thornsDialogue.txt');
				case 'radical-vs-masked-babbys':
					setDialogue('masked-babbys');
				case 'fnaf-at-phillys':
					setDialogue('fnaf-philly');
				case 'the-backyardagains':
					setDialogue('flynets1');
				case 'funny':
					setDialogue('flynets2');
				default:
					setDialogue(sheShed);
			}
		}

		var allThemStages:Array<String> = ['spooky', 'spookyscary', 'flynets', 'water', 'junk', '3.4', 'nadalyn', 'philly', 'pit', 'freebeat', 'limo', 'mall', 'mallEvil', 'home', 'school', 'schoolEvil', 'nunjunk', 'bustom', 'iAmJUNKING', 'stage', 'scribble'];

		if (!randomLevel)
		{
			switch(sheShed)
			{
				case 'radical-vs-masked-babbys' | 'north':
					curStage = "spooky";
				case 'monkey-sprite':
					curStage = "spookyscary";
				case 'the-backyardagains' | 'funny':
					curStage = "flynets";
				case 'interrogation':
					curStage = 'water';
				case 'junkrus':
					curStage = 'junk';
				case '3.4':
					curStage = '3.4';
				case 'nadalyn-sings-spookeez' | 'nadbattle' | 'nadders':
					curStage = 'nadalyn';
				case 'namebe' | 'fnaf-at-phillys' | 'destructed' | 'start-conjunction' | 'energy-lights' | 'telegroove':
					curStage = 'philly';
				case 'tha-biscoot':
					curStage = 'pit';
				case 'freebeat_1':
					curStage = 'freebeat';
				case 'bonbon-loool' | 'bonnie-song' | 'without-you':
					curStage = 'limo';
				case 'cocoa' | 'eggnog':
					curStage = 'mall';
				case 'winter-horrorland':
					curStage = 'mallEvil';
				case 'gamings-congrats' | 'tutorial':
					curStage = 'home';
				case 'color-my-bonbon':
					curStage = 'bonbon-prep';
				case 'senpai' | 'roses':
					curStage = 'school';
				case 'thorns':
					curStage = 'schoolEvil';
				case 'ceast':
					curStage = 'nunjunk';
				case 'bustom-source' | 'fl-keys' | 'i-didnt-ask':
					curStage = 'bustom';
				case 'scary-junk':
					curStage = 'iAmJUNKING';
				case 'scribble-street':
					curStage = 'scribble';
				default:
					curStage = 'stage';
			}
		}
		else
			curStage = allThemStages[FlxG.random.int(0, allThemStages.length)];

		switch(curStage)
		{
			case 'spooky':
				curStage = "spooky";
				halloweenLevel = true;

				var hallowTex = FlxAtlasFrames.fromSparrow(stagePath + 'babbys/normal.png', stagePath + 'babbys/normal.xml');

				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);
				
				pogBabby = new FlxSprite(-820, 275);
				pogBabby.frames = FlxAtlasFrames.fromSparrow(stagePath + 'babbys/babby_pog.png', stagePath + 'babbys/babby_pog.xml');
				pogBabby.animation.addByPrefix('pog', 'pog', 24, false);
				pogBabby.antialiasing = true;

				trace('WEEK 2 BG');

				isHalloween = true;
			case 'spookyscary':
				halloweenLevel = true;

				var hallowTex = FlxAtlasFrames.fromSparrow(stagePath + 'babbys/scary.png', stagePath + 'babbys/scary.xml');

				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'junkiung');
				halloweenBG.animation.addByPrefix('lightning', 'junkingVEETOO', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);

				pogBabby = new FlxSprite(-140, 415);
				pogBabby.frames = FlxAtlasFrames.fromSparrow(stagePath + 'babbys/babby_pog.png', stagePath + 'babbys/babby_pog.xml');
				pogBabby.animation.addByPrefix('pog', 'pog', 12, false);

				trace('WEEK 2 BG BUT SCARY');

				isHalloween = true;
			case 'flynets':
				halloweenLevel = true;
				areTheirDogs = false;
	
				var hallowTex = FlxAtlasFrames.fromSparrow(stagePath + 'babbys/non_babby_junk/flynets.png', stagePath + 'babbys/normal.xml');
	
				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);

				if (SONG.song != 'the-backyardagains')
				{
					var dogPositions:Array<Dynamic> = [
						[160, 445],
						[670, 440],
						[1060, 510]
					];
					grpGuardDogs = new FlxTypedGroup<GuardDogs>();
					add(grpGuardDogs);

					for (i in 0...3)
					{
						var daPos:Array<Float> = dogPositions[i];
						var dog:GuardDogs = new GuardDogs(daPos[0], daPos[1] - 300);
						grpGuardDogs.add(dog);
					}
					areTheirDogs = true;
				}
	
				isHalloween = true;
			case 'scribble':
				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(stagePath + 'scribble/sky.png');
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(stagePath + 'scribble/friendlyNieghborhood.png');
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(stagePath + 'scribble/room.png');
				add(streetBehind);

				// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(stagePath + 'scribble/floor.png');
				add(street);
			case 'water':
				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);

				var hallowTex = FlxAtlasFrames.fromSparrow(stagePath + 'babbys/non_babby_junk/water.png', stagePath + 'babbys/normal.xml');
	
				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);

				wiggleShit.effectType = WiggleEffectType.DREAMY;
				wiggleShit.waveAmplitude = 0.01;
				wiggleShit.waveFrequency = 7;
				wiggleShit.waveSpeed = 1;

				halloweenBG.shader = wiggleShit.shader;

				var waveSprite = new FlxEffectSprite(halloweenBG, [waveEffectBG]);

				//waveSprite.scale.set(6, 6);
				waveSprite.setPosition(-200, 100);

				// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
				// waveSprite.updateHitbox();
				// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
				// waveSpriteFG.updateHitbox();

				//add(waveSprite);
			case 'junk':

				var hallowTex = FlxAtlasFrames.fromSparrow(stagePath + 'babbys/non_babby_junk/redball_thing_i_think.png', stagePath + 'babbys/normal.xml');
	
				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);
			case '3.4':
				var hallowTex = FlxAtlasFrames.fromSparrow(stagePath + 'babbys/non_babby_junk/3.4bg.png', stagePath + 'babbys/normal.xml');
	
				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				add(halloweenBG);
			case 'nadalyn':				
				var naddersBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(stagePath + 'nadalyn/nadders.png');
				naddersBG.scrollFactor.set(0.1, 0.1);
				add(naddersBG);
							
				var bgNadders:FlxSprite = new FlxSprite(-200, 480);
				bgNadders.frames = FlxAtlasFrames.fromSparrow(stagePath + 'nadalyn/nadalyn_dancers.png', stagePath + 'nadalyn/nadalyn_dancers.xml');
				bgNadders.scrollFactor.set(0.4, 0.4);
				add(bgNadders);

				grpLimoNadders = new FlxTypedGroup<BackgroundNadders>();
				add(grpLimoNadders);

				for (i in 0...5)
				{
					var dancerNad:BackgroundNadders = new BackgroundNadders((370 * i) + 130, bgNadders.y - 400);
					dancerNad.scrollFactor.set(0.4, 0.4);
					grpLimoNadders.add(dancerNad);
				}
			case 'philly':
				if (sheShed == 'namebe' || sheShed == 'destructed' || sheShed == 'fnaf-at-phillys')
				{
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(stagePath + 'namebe/' + sheShed + '/sky.png');
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					if (SONG.song == 'Namebe')
						sun = new FlxSprite(720, -280).loadGraphic(stagePath + 'namebe/SUN.png');
					else if (sheShed == 'fnaf-at-phillys')
						sun = new FlxSprite(720, -230).loadGraphic(stagePath + 'namebe/SUN2.png');
					
					if (SONG.song != 'Destructed')
					{	
						sun.setGraphicSize(Std.int(sun.width * 0.2));
						sun.scrollFactor.set(0.1, 0.1);
						add(sun);
					}

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(stagePath + 'namebe/' + sheShed + '/city.png');
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					add(city);

					if (sheShed == 'fnaf-at-phillys' && FlxG.random.bool(15))
						city.loadGraphic(stagePath + 'namebe/' + sheShed + '/BigOlBunny.png');

					phillyTrain = new FlxSprite(2000, 360).loadGraphic(stagePath + 'namebe/' + sheShed + '/train.png');
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded('assets/sounds/train_passes' + TitleState.soundExt);
					FlxG.sound.list.add(trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, 50).loadGraphic(stagePath + 'namebe/' + sheShed + '/street.png');
					add(street);
					if (sheShed == 'destructed')
					{	
						vans = new FlxSprite(-1386, 196);
						vans.frames = FlxAtlasFrames.fromSparrow(stagePath + 'namebe/van.png', stagePath + 'namebe/van.xml');
						vans.animation.addByPrefix('close', 'van vroom', 24, false);
						vans.animation.play('close');
						vans.setGraphicSize(Std.int(vans.width * 1.4));
						vans.antialiasing = true;
						vans.updateHitbox();
						add(vans);
						vans.visible = false;
					}
				}
				else
				{
					var city:FlxSprite = new FlxSprite(-120, -50).loadGraphic(stagePath + 'beans/' + sheShed + '/bg.png');
					city.scrollFactor.set(0.1, 0.1);
					add(city);

					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					add(phillyCityLights);
					
					for (i in 0...3)
					{
						var light:FlxSprite = new FlxSprite(city.x);
						if (sheShed == 'energy-lights')
							light.loadGraphic(stagePath + 'beans/energy-lights/rocks' + i + '.png');
						else
							light.loadGraphic(stagePath + 'beans/' + sheShed + '/rocks.png');
						light.scrollFactor.set(0.3, 0.3);
						light.visible = true;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						phillyCityLights.add(light);
					}
					
					phillyTrain = new FlxSprite(2000, 360).loadGraphic(stagePath + 'beans/' + sheShed + '/weird.png');
					add(phillyTrain);

					trainSound = new FlxSound().loadEmbedded('assets/sounds/weird' + TitleState.soundExt);
					FlxG.sound.list.add(trainSound);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(stagePath + 'beans/' + sheShed + '/ground.png');
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);
				}
			case 'pit':

				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(stagePath + 'pit/bg.png');
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(stagePath + 'pit/details1.png');
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				add(city);

				var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(stagePath + 'pit/details2.png');
				add(streetBehind);

				// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(stagePath + 'pit/ground.png');
				add(street);
			case 'freebeat':
				defaultCamZoom = 0.9;
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(stagePath + 'freebeat/bg.png');
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(stagePath + 'freebeat/thing.png');
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				add(stageCurtains);
			case 'limo':
				defaultCamZoom = 0.90;

				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(stagePath + 'bonbon/limoSunset.png');
				skyBG.scrollFactor.set(0.1, 0.1);
				add(skyBG);

				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = FlxAtlasFrames.fromSparrow(stagePath + 'bonbon/bgLimo.png', stagePath + 'bonbon/bgLimo.xml');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				add(bgLimo);

				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				add(grpLimoDancers);

				for (i in 0...5)
				{
					var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
					dancer.scrollFactor.set(0.4, 0.4);
					if (sheShed != 'without-you')
						grpLimoDancers.add(dancer);
				}

				//var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(stagePath + 'bonbon/limoOverlay.png');
				//overlayShit.alpha = 0.5;
				//add(overlayShit);

				// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

				// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

				// overlayShit.shader = shaderBullshit;

				var limoTex = FlxAtlasFrames.fromSparrow(stagePath + 'bonbon/limoDrive.png', stagePath + 'bonbon/limoDrive.xml');

				var cloud:FlxSprite = new FlxSprite(-325, 515).loadGraphic(stagePath + 'bonbon/cloud.png');
				cloud.scrollFactor.set(0.9, 0.9);
				if (sheShed == 'without-you')
					cloud.setPosition(70, 485);
				add(cloud);

				gamingBop = new FlxSprite(-260, 190);
				gamingBop.frames = FlxAtlasFrames.fromSparrow(stagePath + 'bonbon/gamingRightBounce.png', stagePath + 'bonbon/gamingRightBounce.xml');
				gamingBop.animation.addByPrefix('bop', 'gamingRight', 24, false);
				gamingBop.antialiasing = true;
				gamingBop.scrollFactor.set(0.9, 0.9);
				gamingBop.setGraphicSize(Std.int(gamingBop.width * 1));
				gamingBop.updateHitbox();
				if (sheShed != 'without-you')
					add(gamingBop);

				limo = new FlxSprite(-120, 550);
				limo.frames = limoTex;
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;

				fastCar = new FlxSprite(-300, 160).loadGraphic(stagePath + 'bonbon/fastCarLol.png');
				// add(limo);

				//var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(stagePath + 'bonbon/limoOverlay.png');
				//overlayShit.alpha = 0.5;
				//add(overlayShit);
			case 'mall':

				defaultCamZoom = 0.80;

				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(stagePath + 'christmas/bgWalls.png');
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				upperBoppers = new FlxSprite(-240, -90);
				upperBoppers.frames = FlxAtlasFrames.fromSparrow(stagePath + 'christmas/upperBop.png', stagePath + 'christmas/upperBop.xml');
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = true;
				upperBoppers.scrollFactor.set(0.33, 0.33);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				add(upperBoppers);

				var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(stagePath + 'christmas/bgEscalator.png');
				bgEscalator.antialiasing = true;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				add(bgEscalator);

				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(stagePath + 'christmas/christmasTree.png');
				tree.antialiasing = true;
				tree.scrollFactor.set(0.40, 0.40);
				add(tree);

				bottomBoppers = new FlxSprite(-300, 140);
				bottomBoppers.frames = FlxAtlasFrames.fromSparrow(stagePath + 'christmas/bottomBop.png', stagePath + 'christmas/bottomBop.xml');
				bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = true;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				add(bottomBoppers);

				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(stagePath + 'christmas/fgSnow.png');
				fgSnow.active = false;
				fgSnow.antialiasing = true;
				add(fgSnow);

				santa = new FlxSprite(-820, 275);
				santa.frames = FlxAtlasFrames.fromSparrow(stagePath + 'christmas/santa.png', stagePath + 'christmas/santa.xml');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = true;
				add(santa);
			case 'mallEvil':
				var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(stagePath + 'christmas/evilBG.png');
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				add(bg);

				var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(stagePath + 'christmas/evilTree.png');
				evilTree.antialiasing = true;
				evilTree.scrollFactor.set(0.2, 0.2);
				add(evilTree);

				var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(stagePath + 'christmas/evilSnow.png');
				evilSnow.antialiasing = true;
				add(evilSnow);
			case 'home':
				var bg:FlxSprite = new FlxSprite(-900, -275).loadGraphic(stagePath + 'office/livingroom.png');
				// bg.setGraphicSize(Std.int(bg.width * 2.5));
				// bg.updateHitbox();
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);
			case 'bonbon-prep':
				var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic('assets/images/color_my_bonbon/loadingScreen.png');
				bg.antialiasing = true;
				bg.scrollFactor.set(0.9, 0.9);
				bg.active = false;
				add(bg);

				FlxG.switchState(new BonBonState());
			case 'school':

				// defaultCamZoom = 0.9;

				var bgSky = new FlxSprite().loadGraphic(stagePath + 'weeb/weebSky.png');
				bgSky.scrollFactor.set(0.1, 0.1);
				add(bgSky);

				var repositionShit = -200;

				var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(stagePath + 'weeb/weebSchool.png');
				bgSchool.scrollFactor.set(0.6, 0.90);
				add(bgSchool);

				var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(stagePath + 'weeb/weebStreet.png');
				bgStreet.scrollFactor.set(0.95, 0.95);
				add(bgStreet);

				var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(stagePath + 'weeb/weebTreesBack.png');
				fgTrees.scrollFactor.set(0.9, 0.9);
				add(fgTrees);

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				var treetex = FlxAtlasFrames.fromSpriteSheetPacker(stagePath + 'weeb/weebTrees.png', stagePath + 'weeb/weebTrees.txt');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				add(bgTrees);

				var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
				treeLeaves.frames = FlxAtlasFrames.fromSparrow(stagePath + 'weeb/petals.png', stagePath + 'weeb/petals.xml');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				add(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);

				if (sheShed == 'roses')
				{
					bgGirls.getScared();
				}

				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				add(bgGirls);
			case 'schoolEvil':

				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
				var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

				var posX = 400;
				var posY = 200;

				var bg:FlxSprite = new FlxSprite(posX, posY);
				bg.frames = FlxAtlasFrames.fromSparrow(stagePath + 'weeb/animatedEvilSchool.png', stagePath + 'weeb/animatedEvilSchool.xml');
				bg.animation.addByPrefix('idle', 'background 2', 24);
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 0.9);
				bg.scale.set(6, 6);
				add(bg);

				/* 
					var bg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(stagePath + 'weeb/evilSchoolBG.png');
					bg.scale.set(6, 6);
					// bg.setGraphicSize(Std.int(bg.width * 6));
					// bg.updateHitbox();
					add(bg);

					var fg:FlxSprite = new FlxSprite(posX, posY).loadGraphic(stagePath + 'weeb/evilSchoolFG.png');
					fg.scale.set(6, 6);
					// fg.setGraphicSize(Std.int(fg.width * 6));
					// fg.updateHitbox();
					add(fg);

					wiggleShit.effectType = WiggleEffectType.DREAMY;
					wiggleShit.waveAmplitude = 0.01;
					wiggleShit.waveFrequency = 60;
					wiggleShit.waveSpeed = 0.8;
				*/

				// bg.shader = wiggleShit.shader;
				// fg.shader = wiggleShit.shader;

				/* 
					var waveSprite = new FlxEffectSprite(bg, [waveEffectBG]);
					var waveSpriteFG = new FlxEffectSprite(fg, [waveEffectFG]);

					// Using scale since setGraphicSize() doesnt work???
					waveSprite.scale.set(6, 6);
					waveSpriteFG.scale.set(6, 6);
					waveSprite.setPosition(posX, posY);
					waveSpriteFG.setPosition(posX, posY);

					waveSprite.scrollFactor.set(0.7, 0.8);
					waveSpriteFG.scrollFactor.set(0.9, 0.8);

					// waveSprite.setGraphicSize(Std.int(waveSprite.width * 6));
					// waveSprite.updateHitbox();
					// waveSpriteFG.setGraphicSize(Std.int(fg.width * 6));
					// waveSpriteFG.updateHitbox();

					add(waveSprite);
					add(waveSpriteFG);
				/*/
			case 'nunjunk':
				defaultCamZoom = 0.9;

				var floor:FlxSprite = new FlxSprite(-325, -685).loadGraphic(stagePath + 'nunjunk/church1/floor.png');
				add(floor);

				var bg:FlxSprite = new FlxSprite(-325, -685).loadGraphic(stagePath + 'nunjunk/church1/bg.png');
				add(bg);

				var pillars:FlxSprite = new FlxSprite(-325, -685).loadGraphic(stagePath + 'nunjunk/church1/pillars.png');
				pillars.scrollFactor.set(0.99, 0.99);
				add(pillars);
			case 'bustom':

				var bg:FlxSprite = new FlxSprite(-375, -153).loadGraphic(stagePath + 'bustom/bg.png');
				add(bg);

				/*if (MAPPINGS == null)
					MAPPINGS = NamebeMappings.loadMapsFromJson('i-didnt-ask');*/
			case 'iAmJUNKING':
				defaultCamZoom = 0.54;

				var thaBiscoot:FlxSprite = new FlxSprite(-1293, -688).loadGraphic(stagePath + 'scarie/placeholderBG.png');
				add(thaBiscoot);
			default:
				defaultCamZoom = 1;

				var iAmActuallyDunkingMyJunk:FlxSprite = new FlxSprite(-270, 50).loadGraphic(stagePath + 'office/STAGELAYER3.png');
				iAmActuallyDunkingMyJunk.setGraphicSize(1828);
				iAmActuallyDunkingMyJunk.updateHitbox();
				iAmActuallyDunkingMyJunk.antialiasing = true;
				iAmActuallyDunkingMyJunk.scrollFactor.set(0.8, 0.8);
				add(iAmActuallyDunkingMyJunk);

				var stageFront:FlxSprite = new FlxSprite(-270, 50).loadGraphic(stagePath + 'office/STAGELAYER2.png');
				stageFront.setGraphicSize(1828);
				stageFront.updateHitbox();
				stageFront.antialiasing = true;
				stageFront.scrollFactor.set(0.9, 0.9);
				add(stageFront);

				var bg:FlxSprite = new FlxSprite(-270, 50).loadGraphic(stagePath + 'office/STAGELAYER1.png');
				bg.setGraphicSize(1828);
				bg.updateHitbox();
				bg.antialiasing = true;
				add(bg);

				var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(stagePath + 'office/stagecurtains.png');
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				stageCurtains.antialiasing = true;
				stageCurtains.scrollFactor.set(1.3, 1.3);
				stageCurtains.active = false;

				add(stageCurtains);
		}

		var gfVersion:String = 'gaming-speakers';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'invisible';
			case 'school' | 'schoolEvil':
				gfVersion = 'jack';
			case 'bustom':
				if (SONG.song == 'I-Didnt-Ask')
					gfVersion = 'namebe-speakers';
				else
					gfVersion = 'gaming-gunpoint';
		}

		if (randomLevel)
		{
			gfVersion = Character.charArray[FlxG.random.int(0, Character.charArray.length)];
			SONG.player1 = Character.charArray[FlxG.random.int(0, Character.charArray.length)];
			SONG.player2 = Character.charArray[FlxG.random.int(0, Character.charArray.length)];
			SONG.player3 = Character.charArray[FlxG.random.int(0, Character.charArray.length)];
			SONG.player4 = Character.charArray[FlxG.random.int(0, Character.charArray.length)];
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		gamingsOwnCoords = [gf.getMidpoint().x - 140, gf.getMidpoint().y - 150];

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		if (curStage == 'spookyscary')
            add(pogBabby);

        gspot = new Character(300, 100, SONG.player3);
		dad = new Character(100, 100, SONG.player2);
		gaming = new Character(1300, 9400, SONG.player4);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gaming-speakers':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "babbys":
				dad.y += 200;
				dad.x += 100;
			case 'skank-n-pronoun':
				dad.y += 200;
			case "skank":
				dad.y += 200;
				if (isWeekend)
					tweenCamIn();
			case "austin":
				dad.y += 200;
			case "monkey-sprite":
				dad.y += 60;
			case 'christmas-monkey':
				dad.y += 130;
			case 'interviewer':
				camPos.x += 400;
			case 'namebe':
				camPos.x += 600;
				dad.x -= 65;
				dad.y += 250;
			case 'parents-christmas':
				dad.x -= 500;
			case 'salted':
			    camPos.x += 600;
                dad.y += 300;
			case 'stick':
			    camPos.x += 600;
                dad.y += 300;
			case 'wow':
			    camPos.x += 600;
                dad.y += 300;
			case 'goomba':
				camPos.x += 600;
                dad.y += 300;
			case 'wow2':
			    camPos.x += 600;
                dad.y += 300;
            case 'nadalyn':
                camPos.x += 600;       
                dad.y += 300;
            case 'machine':
                dad.y += 300;
            case 'gaming':
                dad.y += 300;
            case 'bonbon':
                dad.y += 100;
			case 'senpai' | 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'four':
                dad.y += 100;
                dad.x -= 537;
            case 'x':
                dad.y += 230;
                dad.x -= 537;
			case 'pronun':
				dad.y += 320;
				dad.x -= 75;
			case 'charlie':
				dad.y += 275;
			case 'flandre-cool-awesome':
				dad.x -= 650;
				dad.y -= 80;
		}
		
		if (curStage == 'limo')
            dad.y -= 300;

        switch (SONG.player3)
		{
			case 'gaming-speakers':
				gspot.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "babbys":
				gspot.y += 200;
			case "monkey-sprite":
				gspot.y += 100;
			case 'christmas-monkey':
				gspot.y += 130;
			case 'interviewer':
				camPos.x += 400;
			case 'namebe':
				gspot.y += 300;
			case 'parents-christmas':
				gspot.x -= 500;
			case 'salted':
                gspot.y += 300;
			case 'wow':
                gspot.y += 300;
			case 'wow2':
                gspot.y += 300;
        	case 'nadalyn':
                gspot.y += 300;
            case 'machine':
                gspot.y += 300;
            case 'x':
                gspot.y += 230;
                gspot.x -= 237;
		}
		
		switch (SONG.player4)
		{
			case "babbys":
				gaming.y = 230;
				gaming.x = 1230;
			case "monkey-sprite":
				gaming.y = 230;
				gaming.x = 1230;
			case 'christmas-monkey':
				gaming.y = 230;
				gaming.x = 1230;
			case 'interviewer':
				gaming.y = 230;
				gaming.x = 1230;
			case 'namebe':
				gaming.y = 230;
				gaming.x = 1230;
			case 'parents-christmas':
				gaming.y = 230;
				gaming.x = 1230;
			case 'salted':
			    gaming.y = 230;
				gaming.x = 1230;
			case 'wow':
			    gaming.y = 230;
				gaming.x = 1230;
			case 'wow2':
			    gaming.y = 230;
				gaming.x = 1230;
            case 'nadalyn':
                gaming.y = 230;
				gaming.x = 1230;
            case 'machine':
                gaming.y = 230;
				gaming.x = 1230;
		}

    	if (!isStoryMode && !isWeekend && !randomLevel)
		{
			if (FreeplayState.curChar == 'RadicalOne' || FreeplayState.curChar == 'RedBall')
				boyfriend = new Boyfriend(770, 450, SONG.player1);
			else
				boyfriend = new Boyfriend(770, 345, SONG.player1);
		}
		else
			boyfriend = new Boyfriend(770, 345, SONG.player1);

		switch (SONG.player1)
		{
			case 'red-ball':
				boyfriend.y += 105;
		}

		//boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'nunjunk':
				gf.x -= 147;
				gf.y -= 50;
				boyfriend.y -= 50;
			case 'bustom':
				gf.x -= 155;
				boyfriend.x += 125;
		}

		add(gf);
		add(gspot);
		add(dad);
		add(gaming);
		add(boyfriend);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		var darf:DialogueBubble = new DialogueBubble(false, dialogue);
		// darf.x += 70;
		darf.y = FlxG.height * 0.5;
		darf.scrollFactor.set();
		darf.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic('assets/images/UI/healthBar.png');
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		if (sheShed != 'job-interview')
			add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(charColors[Character.charArray.indexOf(SONG.player2)], charColors[Character.charArray.indexOf(SONG.player1)]);
		// healthBar
		if (sheShed != 'job-interview')
			add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 190, healthBarBG.y + 30, 0, "", 20);
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT);
		scoreTxt.scrollFactor.set();
		if (sheShed != 'job-interview')
			add(scoreTxt);

		var penis:FlxText = new FlxText(15, healthBarBG.y + 30, 0, FlxG.save.data.inputSystem + ' Input', 20);
		penis.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT);
		penis.scrollFactor.set();
		if (sheShed != 'job-interview')
			add(penis);
		
		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		if (sheShed != 'job-interview')
			add(iconP1);
		
		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		if (sheShed != 'job-interview')
			add(iconP2);

		if (!isStoryMode && !isWeekend && !weekEndFreeplay && !randomLevel)
        {
			if (SONG.player1 == 'radical')
			{
				switch (FreeplayState.curChar)
				{
					case 'RadicalOne':
						iconP1.animation.play('old-racial');
					case 'RedBall':
						iconP1.animation.play('red-ball');
					case 'RacialPride':
						iconP1.animation.play('racial-pride');	
				}
			}

			if (SONG.player2 == 'radical')
			{
				switch (FreeplayState.curChar)
				{
					case 'RadicalOne':
						iconP2.animation.play('old-racial');
					case 'RedBall':
						iconP2.animation.play('red-ball');
					case 'RacialPride':
						iconP2.animation.play('racial-pride');	
				}
			}
		}

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		darf.cameras = [camHUD];
		penis.cameras = [camHUD];

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play('assets/sounds/Lights_Turn_On' + TitleState.soundExt);
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'north':
				    camFollow.x += 200;
                    schoolIntro(doof);
                case 'radical-vs-masked-babbys' | 'monkey-sprite' | 'namebe' | 'fnaf-at-phillys' | 'bonnie-song' | 'bonbon-loool' | 'without-you':
                    schoolIntro(doof);
                case 'destructed':
                    camFollow.x -= 350;
                    camFollow.y += 100;
                    schoolIntro(doof);
				case 'job-interview':
					camFollow.x = 640;
					camFollow.y = 360;
					schoolIntro(doof);
				default:
					startCountdown();
			}
		}
		else if (isWeekend)
		{
			switch (curSong.toLowerCase())
			{
				case 'senpai' | 'thorns':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play('assets/sounds/ANGRY' + TitleState.soundExt);
					schoolIntro(doof);
				case 'the-backyardagains' | 'funny':
					flynetIntro(darf);
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				case 'job-interview':
					add(healthBarBG);
					add(scoreTxt);
					add(healthBar);
					add(iconP1);
					add(iconP2);
					startCountdown();
				default:
					startCountdown();
			}
		}

                #if lime
		trace("LIME WILL BE REAL IN 30 SECONDS");
		#end

		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var blackOffice:FlxSprite = new FlxSprite(0, 0).loadGraphic('assets/images/theeseE.png');
		blackOffice.scrollFactor.set();
		if (sheShed ==  'job-interview')
			add(blackOffice);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = FlxAtlasFrames.fromSparrow(stagePath + 'weeb/senpaiCrazy.png', stagePath + 'weeb/senpaiCrazy.xml');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (sheShed == 'roses' || sheShed == 'thorns' || sheShed == 'radical-vs-masked-babbys')
		{
			remove(black);

			if (sheShed == 'thorns')
			{
				add(red);
			}
		}

		if (sheShed == 'destructed')
			gspot.visible = false;

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (sheShed == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.screenCenter();
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play('assets/sounds/Senpai_Dies' + TitleState.soundExt, 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else if (sheShed == 'destructed')
					{
						vans.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							vans.alpha += 0.15;
							if (vans.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
                                vans.visible = true;
								vans.animation.play('close');
								FlxG.sound.play('assets/sounds/CarFirst' + TitleState.soundExt, 1, false, null, true, function()
								{
                                    gspot.visible = true;
                                    FlxG.sound.play('assets/sounds/CarSecond' + TitleState.soundExt, 1, false, null, true, function()
          							{
          								add(dialogueBox);
          							});
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
                                    //hi
								});
							}
						});
					}
					else if (sheShed == 'job-interview')
					{

					/*	var sky:FlxSprite = new FlxSprite(0, -134);
						sky.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/sky.png', 'assets/images/cutscenes/week1/sky.xml');
						sky.animation.addByPrefix('idle', 'cutscene8', 20, false);
						sky.animation.play('idle');

						var rlogo:FlxSprite = new FlxSprite(-554, -518);
						rlogo.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/radical_logo.png', 'assets/images/cutscenes/week1/radical_logo.xml');
						rlogo.animation.addByPrefix('idle', 'cutscene', 20, false);
						rlogo.animation.play('idle');

						var elavator:FlxSprite = new FlxSprite(-672, -166);
						elavator.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/elavator.png', 'assets/images/cutscenes/week1/elavator.xml');
						elavator.animation.addByPrefix('idle', 'cutscene6', 20, false);
						elavator.animation.play('idle');

						var paper:FlxSprite = new FlxSprite(-973, -114);
						paper.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/paper.png', 'assets/images/cutscenes/week1/paper.xml');
						paper.animation.addByPrefix('idle', 'cutscene2', 20, false);
						paper.animation.play('idle');

						var gamingAndRacial:FlxSprite = new FlxSprite(-480, -289);
						gamingAndRacial.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/gamingAndRacial.png', 'assets/images/cutscenes/week1/gamingAndRacial.xml');
						gamingAndRacial.animation.addByPrefix('idle', 'cutscene7', 20, false);
						gamingAndRacial.animation.play('idle');

						var gamingCut:FlxSprite = new FlxSprite(0, 0);
						gamingCut.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/gaming.png', 'assets/images/cutscenes/week1/gaming.xml');
						gamingCut.animation.addByPrefix('idle', 'cutscene4', 20, false);
						gamingCut.animation.play('idle');

						var racialCut:FlxSprite = new FlxSprite(0, 0);
						racialCut.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/radical.png', 'assets/images/cutscenes/week1/radical.xml');
						racialCut.animation.addByPrefix('idle', 'cutscene5', 20, false);
						racialCut.animation.play('idle');

						var rad1:FlxSprite = new FlxSprite(-507, -386);
						rad1.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/radLooking1.png', 'assets/images/cutscenes/week1/radLooking1.xml');
						rad1.animation.addByPrefix('idle', 'cutscene3', 20, false);
						rad1.animation.play('idle');

						var rad2:FlxSprite = new FlxSprite(-1003, -694);
						rad2.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/radLooking2.png', 'assets/images/cutscenes/week1/radLooking2.xml');
						rad2.animation.addByPrefix('idle', 'cutscene3.2', 20, false);
						rad2.animation.play('idle');

						var rad3:FlxSprite = new FlxSprite(-1008, -697);
						rad3.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/radLooking3.png', 'assets/images/cutscenes/week1/radLooking3.xml');
						rad3.animation.addByPrefix('idle', 'cutscene3.3', 20, false);
						rad3.animation.play('idle');

						var rad4:FlxSprite = new FlxSprite(-416, -312);
						rad4.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/radLooking4.png', 'assets/images/cutscenes/week1/radLooking4.xml');
						rad4.animation.addByPrefix('idle', 'cutscene3.4', 20, false);
						rad4.animation.play('idle');

						var rad5:FlxSprite = new FlxSprite(-552, -371);
						rad5.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/radLooking5.png', 'assets/images/cutscenes/week1/radLooking5.xml');
						rad5.animation.addByPrefix('idle', 'cutscene3.4.2', 20, false);
						rad5.animation.play('idle');

						var rad6:FlxSprite = new FlxSprite(-563, -375);
						rad6.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/radLooking6.png', 'assets/images/cutscenes/week1/radLooking6.xml');
						rad6.animation.addByPrefix('idle', 'cutscene3.fade', 20, false);
						rad6.animation.play('idle');

						var rad7:FlxSprite = new FlxSprite(-563, -375);
						rad7.frames = FlxAtlasFrames.fromSparrow('assets/images/cutscenes/week1/radLooking7.png', 'assets/images/cutscenes/week1/radLooking7.xml');
						rad7.animation.addByPrefix('idle', 'cutscene3.fade.2', 20, false);
						rad7.animation.play('idle');

						add(sky);
						add(gamingAndRacial);
						add(elavator);
						add(gamingCut);
						add(racialCut);
						add(rlogo);
						add(rad1);
						add(rad2);
						add(rad3);
						add(rad4);
						add(rad5);
						add(rad6);
						add(rad7);
						add(paper);*/
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{	
						/*	sky.animation.play('idle');
							gamingAndRacial.animation.play('idle');
							elavator.animation.play('idle');
							gamingCut.animation.play('idle');
							racialCut.animation.play('idle');
							rlogo.animation.play('idle');
							rad1.animation.play('idle');
							rad2.animation.play('idle');
							rad3.animation.play('idle');
							rad4.animation.play('idle');
							rad5.animation.play('idle');
							rad6.animation.play('idle');
							rad7.animation.play('idle');
							paper.animation.play('idle');*/
							remove(blackOffice);
							FlxG.sound.play('assets/music/cut' + TitleState.soundExt, 1, false, null, true, function()
							{
								add(healthBarBG);
								add(scoreTxt);
								add(healthBar);
								add(iconP1);
								add(iconP2);
								startCountdown();
							});
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function flynetIntro(?dialogueBubble:DialogueBubble):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		switch (curSong.toLowerCase())
		{
			case 'the-backyardagains':
				dad.visible = false;
				camFollow.x = dad.getMidpoint().x + 100;
				camFollow.y += 100;
			case 'funny':
				camFollow.x = dad.getMidpoint().x + 100;
				camFollow.y += 60;
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBubble != null)
				{
					inCutscene = true;

					if (sheShed == 'the-backyardagains')
					{
						dad.playAnim('introSpin');
						dad.visible = true;
						new FlxTimer().start(1.35, function(swagTimer:FlxTimer)
						{
							add(dialogueBubble);
						});
					}
					else if (SONG.song == 'funny')
					{
						new FlxTimer().start(1.35, function(swagTimer:FlxTimer)
						{
							add(dialogueBubble);
						});
					}
					else
					{
						add(dialogueBubble);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;
		hasFocusedOnDudes = false;
		hasFocusedOnGaming = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		if (curStage == 'flynets')
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.04);
			FlxG.camera.zoom = defaultCamZoom;
			FlxG.camera.focusOn(camFollow.getPosition());
		}

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			gspot.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['UI/ready.png', "UI/set.png", "UI/go.png"]);
			introAssets.set('school', [
				'UI/pixelUI/ready-pixel.png',
				'UI/pixelUI/set-pixel.png',
				'UI/pixelUI/date-pixel.png'
			]);
			introAssets.set('schoolEvil', [
				'UI/pixelUI/ready-pixel.png',
				'UI/pixelUI/set-pixel.png',
				'UI/pixelUI/date-pixel.png'
			]);
			introAssets.set('freebeat', [
				'UI/red/ready.png',
				'UI/red/set.png',
				'UI/red/go.png'
			]);
			introAssets.set('junk', [
				'UI/red/ready.png',
				'UI/red/set.png',
				'UI/red/go.png'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					switch (value)
					{
						case 'school' | 'schoolEvil':
							altSuffix = '-pixel';
						case 'freebeat' | 'junk':
							altSuffix = '-red';
					}
					
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play('assets/sounds/intro3' + altSuffix + TitleState.soundExt, 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[0]);
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro2' + altSuffix + TitleState.soundExt, 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic('assets/images/' + introAlts[1]);
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro1' + altSuffix + TitleState.soundExt, 0.6);
				case 3:
					var go:FlxSprite;

					if (curStage.startsWith('school'))
					{
						go = new FlxSprite().loadGraphic('assets/images/' + introAlts[2]);
						go.scrollFactor.set();
						go.setGraphicSize(Std.int(go.width * daPixelZoom));
					}
					else if (curStage.startsWith('freebeat') || curStage == 'junk')
					{
						go = new FlxSprite().loadGraphic('assets/images/' + introAlts[2]);
						go.scrollFactor.set();
					}
					else if (curStage.startsWith('flynets'))
					{
						go = new FlxSprite().loadGraphic('assets/images/UI/go.png');
						go.scrollFactor.set();
					}
					else
					{
						go = new FlxSprite(0, 0);
						go.frames = FlxAtlasFrames.fromSparrow('assets/images/UI/goAnim.png', 'assets/images/UI/goAnim.xml');
						go.animation.addByPrefix('go', 'GO!!', 24, false);
						go.scrollFactor.set();
					}


					go.updateHitbox();

					go.screenCenter();
					add(go);
					switch (curStage)
					{
						case 'school' | 'freebeat' | 'junk':
							FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									go.destroy();
								}
							});
						case 'flynets':
							FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									go.destroy();
								}
							});
						default:
							go.animation.play('go');
							boyfriend.playAnim('hey', true);
					}
					FlxG.sound.play('assets/sounds/introGo' + altSuffix + TitleState.soundExt, 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic("assets/music/" + SONG.song + "_Inst" + TitleState.soundExt, 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded("assets/music/" + curSong + "_Voices" + TitleState.soundExt);
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);

			switch (curStage)
			{
				case 'school':
					babyArrow.loadGraphic('assets/images/UI/pixelUI/arrows-pixels.png', true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
					}

				case 'schoolEvil':
					// ALL THIS IS COPY PASTED CUZ IM LAZY

					babyArrow.loadGraphic('assets/images/UI/pixelUI/arrows-pixels.png', true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
					}

				default:
					babyArrow.frames = FlxAtlasFrames.fromSparrow('assets/images/UI/NOTE_assets.png', 'assets/images/UI/NOTE_assets.xml');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		if (sheShed == 'interrogation')
			wiggleShit.update(elapsed);

		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

        var lanceyJustYawned:String = 'nah';

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

		super.update(elapsed);

		scoreTxt.text = "Score:" + songScore;

		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			FlxG.switchState(new ChartingState());
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				switch (dad.curCharacter)
				{
					case 'bonbon':
						camFollow.y = dad.getMidpoint().y + 200;
					case 'senpai' | 'senpai-angry':
						camFollow.y = dad.getMidpoint().y - 430;
						camFollow.x = dad.getMidpoint().x - 100;
					case 'namebe':
						camFollow.x = dad.getMidpoint().x + 300;
					case 'babbys':
						camFollow.y = dad.getMidpoint().y - 35;
					case 'monkey-sprite':
						camFollow.setPosition(dad.getMidpoint().x, dad.getMidpoint().y - 200);
					case 'pronun':
						camFollow.y = dad.getMidpoint().y - 105;
					case 'flandre-cool-awesome':
						camFollow.y = dad.getMidpoint().y - 175;
				}

				if (dad.curCharacter == 'bonbon')
					vocals.volume = 1;

				if (sheShed == 'tutorial')
				{
					tweenCamIn();
				}

				if (sheShed == 'interrogation')
				{
					tweenCamIn();
				}
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

				switch (curStage)
				{
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300;
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'school' | 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200;
						camFollow.y = boyfriend.getMidpoint().y - 200;
					case 'iAmJUNKING':
						camFollow.y = boyfriend.getMidpoint().y - 230;
				}

				if (sheShed == 'tutorial' || sheShed == 'interrogation')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", totalBeats);

		if (curSong == 'Fresh')
		{
			switch (totalBeats)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (totalBeats)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
				if (whatInputSystem == 'RadicalOne')
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.y > FlxG.height)
						{
							daNote.active = false;
							daNote.visible = false;
						}
						else
						{
							daNote.visible = true;
							daNote.active = true;
						}

						if (!daNote.mustPress && daNote.wasGoodHit)
						{
							if (SONG.song != 'Tutorial' || SONG.song != 'Interrogation')
								camZooming = true;

							var altAnim:String = "";
							var gspotAnim:String = "";
							var dontplayAnim:String = "";

							if (SONG.notes[Math.floor(curStep / 16)] != null)
							{
								if (SONG.notes[Math.floor(curStep / 16)].altAnim)
									altAnim = '-alt';
								if (SONG.notes[Math.floor(curStep / 16)].gspotAnim)
									gspotAnim = '-gspot';
								if (SONG.notes[Math.floor(curStep / 16)].dontplayAnim)
									dontplayAnim = '-dontplay';
							}

							//trace("DA ALT THO?: " + SONG.notes[Math.floor(curStep / 16)].altAnim);

							animateCharacters(daNote, altAnim, gspotAnim, dontplayAnim);

							dad.holdTimer = 0;
							gspot.holdTimer = 0;

							if (SONG.needsVoices)
								vocals.volume = 1;

							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}

						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2)));

						// WIP interpolation shit? Need to fix the pause issue
						// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

						if (daNote.y < -daNote.height)
						{
							if (daNote.tooLate || !daNote.wasGoodHit)
							{
								health -= 0.0475;
								vocals.volume = 0;
							}

							daNote.active = false;
							daNote.visible = false;

							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					});
				}
				else if (whatInputSystem == 'Kade Engine')
				{
					notes.forEachAlive(function(daNote:Note)
					{	
						if (daNote.y > FlxG.height)
						{
							daNote.active = false;
							daNote.visible = false;
						}
						else
						{
							daNote.visible = true;
							daNote.active = true;
						}
		
						if (!daNote.mustPress && daNote.wasGoodHit)
						{
							if (SONG.song != 'Tutorial')
								camZooming = true;
		
							var altAnim:String = "";
							var gspotAnim:String = "";
							var dontplayAnim:String = "";

							if (SONG.notes[Math.floor(curStep / 16)] != null)
							{
								if (SONG.notes[Math.floor(curStep / 16)].altAnim)
									altAnim = '-alt';
								if (SONG.notes[Math.floor(curStep / 16)].gspotAnim)
									gspotAnim = '-gspot';
								if (SONG.notes[Math.floor(curStep / 16)].dontplayAnim)
									dontplayAnim = '-dontplay';
							}
		
							animateCharacters(daNote, altAnim, gspotAnim, dontplayAnim);
		
							dad.holdTimer = 0;
							gspot.holdTimer = 0;
		
							if (SONG.needsVoices)
								vocals.volume = 1;
		
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
		
						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
						//trace(daNote.y);
						// WIP interpolation shit? Need to fix the pause issue
						// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
		
						if (daNote.y < -daNote.height && !FlxG.save.data.downscroll || daNote.y >= strumLine.y + 106 && FlxG.save.data.downscroll)
						{
							if (daNote.isSustainNote && daNote.wasGoodHit)
							{
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							}
							else
							{
								health -= 0.075;
								vocals.volume = 0;
								noteMissKade(daNote.noteData);
							}
		
							daNote.active = false;
							daNote.visible = false;
		
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					});
				}
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function animateCharacters(daNote:Note, altAnim:String, gspotAnim:String, dontplayAnim:String)
	{
		switch (Math.abs(daNote.noteData))
		{
			case 2:
				dad.playAnim('singUP' + altAnim + gspotAnim, true);
				gspot.playAnim('singUP' + altAnim + gspotAnim + dontplayAnim, true);
			case 3:
				dad.playAnim('singRIGHT' + altAnim + gspotAnim, true);
				gspot.playAnim('singRIGHT' + altAnim + gspotAnim + dontplayAnim, true);
			case 1:
				dad.playAnim('singDOWN' + altAnim + gspotAnim, true);
				gspot.playAnim('singDOWN' + altAnim + gspotAnim + dontplayAnim, true);
			case 0:
				dad.playAnim('singLEFT' + altAnim + gspotAnim, true);
				gspot.playAnim('singLEFT' + altAnim + gspotAnim + dontplayAnim, true);
		}
	}

	function endSong():Void
	{
		controls.setKeyboardScheme(KeyboardScheme.Solo, true);

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);

				FlxG.switchState(new StoryMenuState());

				trace(StoryMenuState.weekData);

				// if ()
				//StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					NGio.unlockMedal(60961);
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				//FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('https://us.rule34.xxx//images/114/108917d22423b516f73a1ce0618d19cd90f01a9b.jpg');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (sheShed == 'eggnog' || sheShed == 'radical-vs-masked-babbys')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play('assets/sounds/Lights_Shut_off' + TitleState.soundExt);
				}

				if (sheShed == 'north')
				{
					transIn = null;
					transOut = null;
					prevCamFollow = camFollow;
				}

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				FlxG.switchState(new PlayState());

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
			}
		}
		else if (isWeekend)
		{
			weekendScore += songScore;

			weekendPlaylist.remove(weekendPlaylist[0]);

			if (weekendPlaylist.length <= 0)
			{
				FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);

				FlxG.switchState(new WeekendMenuState());

				if (SONG.validScore)
				{
					NGio.unlockMedal(60961);
					Highscore.saveWeekendScore(weekend, weekendScore);
				}
			}
			else
			{
				trace('https://lotus.paheal.net/_images/80322ae33480fa20c8ca4acf9ccc2ea2/4105279%20-%20Flandre_Scarlet%20Suika_Ibuki%20Touhou.jpg');
				trace(PlayState.weekendPlaylist[0].toLowerCase());

				if (sheShed == 'senpai')
				{
					transIn = null;
					transOut = null;
					prevCamFollow = camFollow;
				}

				PlayState.SONG = Song.loadFromJson(PlayState.weekendPlaylist[0].toLowerCase(), PlayState.weekendPlaylist[0]);
				FlxG.sound.music.stop();

				FlxG.switchState(new PlayState());

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
			}
		}
		else if (weekEndFreeplay)
		{
			FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);
			trace('https://lotus.paheal.net/_images/fe1373a376e1aeba78151320305fa2c4/3814219%20-%20LUNA_PRISMRIVER%20Suika_Ibuki%20Touhou.jpg');
			FlxG.switchState(new WeekendMenuState());
		}
		else if (randomLevel)
		{
			FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);
			trace('https://peach.paheal.net/_images/aa882218582e0ad6bdb1a6e99e52f1f6/1013705%20-%20Mamo_Williams%20Suika_Ibuki%20Touhou.png');
			FlxG.switchState(new MainMenuState());
		}
		else
		{
			trace('https://wimg.rule34.xxx//images/781/fc1d51f73ab6f44995a0a658a29140b238b2ec31.png?780429');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
				var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
				// boyfriend.playAnim('hey');
				vocals.volume = 1;

				var placement:String = Std.string(combo);

				var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
				coolText.screenCenter();
				coolText.x = FlxG.width * 0.55;
				//

				var rating:FlxSprite = new FlxSprite();
				var score:Int = 350;

				var daRating:String = "sick";

				if (noteDiff > Conductor.safeZoneOffset * 1 || noteDiff < Conductor.safeZoneOffset * -1)
				{
					daRating = 'shit';
					score = 50;
				}
				else if (noteDiff > Conductor.safeZoneOffset * 0.85 || noteDiff < Conductor.safeZoneOffset * -0.85)
				{
					daRating = 'bad';
					score = 100;
				}
				else if (noteDiff > Conductor.safeZoneOffset * 0.3 || noteDiff < Conductor.safeZoneOffset * -0.3)
				{
					daRating = 'good';
					score = 200;
				}

				songScore += score;

				/* if (combo > 60)
						daRating = 'sick';
					else if (combo > 12)
						daRating = 'good'
					else if (combo > 4)
						daRating = 'bad';
				*/

				var pixelShitPart1:String = "";
				var pixelShitPart2:String = '';

				if (curStage.startsWith('school'))
				{
					pixelShitPart1 = 'pixelUI/';
					pixelShitPart2 = '-pixel';
				}

				rating.loadGraphic('assets/images/UI/' + pixelShitPart1 + daRating + pixelShitPart2 + ".png");
				rating.screenCenter();
				rating.x = coolText.x - 40;
				rating.y -= 60;
				rating.acceleration.y = 550;
				rating.velocity.y -= FlxG.random.int(140, 175);
				rating.velocity.x -= FlxG.random.int(0, 10);

				var comboSpr:FlxSprite = new FlxSprite().loadGraphic('assets/images/UI/' + pixelShitPart1 + 'combo' + pixelShitPart2 + '.png');
				comboSpr.screenCenter();
				comboSpr.x = coolText.x;
				comboSpr.acceleration.y = 600;
				comboSpr.velocity.y -= 150;

				comboSpr.velocity.x += FlxG.random.int(1, 10);
				add(rating);

				if (!curStage.startsWith('school'))
				{
					rating.setGraphicSize(Std.int(rating.width * 0.7));
					rating.antialiasing = true;
					comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
					comboSpr.antialiasing = true;
				}
				else
				{
					rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
					comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
				}

				comboSpr.updateHitbox();
				rating.updateHitbox();

				var seperatedScore:Array<Int> = [];

				seperatedScore.push(Math.floor(combo / 100));
				seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
				seperatedScore.push(combo % 10);

				var daLoop:Int = 0;
				for (i in seperatedScore)
				{
					var numScore:FlxSprite = new FlxSprite().loadGraphic('assets/images/UI/' + pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2 + '.png');
					numScore.screenCenter();
					numScore.x = coolText.x + (43 * daLoop) - 90;
					numScore.y += 80;

					if (!curStage.startsWith('school'))
					{
						numScore.antialiasing = true;
						numScore.setGraphicSize(Std.int(numScore.width * 0.5));
					}
					else
					{
						numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
					}
					numScore.updateHitbox();

					numScore.acceleration.y = FlxG.random.int(200, 300);
					numScore.velocity.y -= FlxG.random.int(140, 160);
					numScore.velocity.x = FlxG.random.float(-5, 5);

					if (combo >= 10 || combo == 0)
						add(numScore);

					FlxTween.tween(numScore, {alpha: 0}, 0.2, {
						onComplete: function(tween:FlxTween)
						{
							numScore.destroy();
						},
						startDelay: Conductor.crochet * 0.002
					});

					daLoop++;
				}
				/* 
					trace(combo);
					trace(seperatedScore);
				*/

				coolText.text = Std.string(seperatedScore);
				// add(coolText);

				FlxTween.tween(rating, {alpha: 0}, 0.2, {
					startDelay: Conductor.crochet * 0.001
				});

				FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						coolText.destroy();
						comboSpr.destroy();

						rating.destroy();
					},
					startDelay: Conductor.crochet * 0.001
				});
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;	

	private function keyShit():Void
	{
		switch (whatInputSystem)
		{
			case 'RadicalOne':
				// HOLDING
				var up = controls.UP;
				var right = controls.RIGHT;
				var down = controls.DOWN;
				var left = controls.LEFT;

				var upP = controls.UP_P;
				var rightP = controls.RIGHT_P;
				var downP = controls.DOWN_P;
				var leftP = controls.LEFT_P;

				var upR = controls.UP_R;
				var rightR = controls.RIGHT_R;
				var downR = controls.DOWN_R;
				var leftR = controls.LEFT_R;

				var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

				// FlxG.watch.addQuick('asdfa', upP);
				if ((upP || rightP || downP || leftP) && generatedMusic)
				{
					boyfriend.holdTimer = 0;

					var possibleNotes:Array<Note> = [];

					var ignoreList:Array<Int> = [];

					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
						{
							// the sorting probably doesn't need to be in here? who cares lol
							possibleNotes.push(daNote);
							possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

							ignoreList.push(daNote.noteData);
						}
					});

					if (possibleNotes.length > 0)
					{
						var daNote = possibleNotes[0];

						if (perfectMode)
							noteCheck(true, daNote);

						// Jump notes
						if (possibleNotes.length >= 2)
						{
							if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
							{
								for (coolNote in possibleNotes)
								{
									if (controlArray[coolNote.noteData])
										goodNoteHit(coolNote);
									else
									{
										var inIgnoreList:Bool = false;
										for (shit in 0...ignoreList.length)
										{
											if (controlArray[ignoreList[shit]])
												inIgnoreList = true;
										}
										if (!inIgnoreList)
											badNoteCheck();
									}
								}
							}
							else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
							{
								noteCheck(controlArray[daNote.noteData], daNote);
							}
							else
							{
								for (coolNote in possibleNotes)
								{
									noteCheck(controlArray[coolNote.noteData], coolNote);
								}
							}
						}
						else // regular notes?
						{
							noteCheck(controlArray[daNote.noteData], daNote);
						}
						/* 
							if (controlArray[daNote.noteData])
								goodNoteHit(daNote);
						*/
						// trace(daNote.noteData);
						/* 
							switch (daNote.noteData)
							{
								case 2: // NOTES YOU JUST PRESSED
									if (upP || rightP || downP || leftP)
										noteCheck(upP, daNote);
								case 3:
									if (upP || rightP || downP || leftP)
										noteCheck(rightP, daNote);
								case 1:
									if (upP || rightP || downP || leftP)
										noteCheck(downP, daNote);
								case 0:
									if (upP || rightP || downP || leftP)
										noteCheck(leftP, daNote);
							}
						*/
						if (daNote.wasGoodHit)
						{
							daNote.kill();
							notes.remove(daNote, true);
							daNote.destroy();
						}
					}
					else
					{
						badNoteCheck();
					}
				}

				if ((up || right || down || left) && generatedMusic)
				{
					notes.forEachAlive(function(daNote:Note)
					{
						if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
						{
							switch (daNote.noteData)
							{
								// NOTES YOU ARE HOLDING
								case 2:
									if (up)
										goodNoteHit(daNote);
								case 3:
									if (right)
										goodNoteHit(daNote);
								case 1:
									if (down)
										goodNoteHit(daNote);
								case 0:
									if (left)
										goodNoteHit(daNote);
							}
						}
					});
				}

				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
				{
					if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					{
						boyfriend.playAnim('idle');
					}
				}

				playerStrums.forEach(function(spr:FlxSprite)
				{
					switch (spr.ID)
					{
						case 2:
							if (upP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (upR)
								spr.animation.play('static');
						case 3:
							if (rightP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (rightR)
								spr.animation.play('static');
						case 1:
							if (downP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (downR)
								spr.animation.play('static');
						case 0:
							if (leftP && spr.animation.curAnim.name != 'confirm')
								spr.animation.play('pressed');
							if (leftR)
								spr.animation.play('static');
					}

					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
					else
						spr.centerOffsets();
				});
			case 'Kade Engine':
				var up = controls.UP;
				var right = controls.RIGHT;
				var down = controls.DOWN;
				var left = controls.LEFT;

				var upP = controls.UP_P;
				var rightP = controls.RIGHT_P;
				var downP = controls.DOWN_P;
				var leftP = controls.LEFT_P;

				var upR = controls.UP_R;
				var rightR = controls.RIGHT_R;
				var downR = controls.DOWN_R;
				var leftR = controls.LEFT_R;

				var controlArray:Array<Bool> = [leftP, downP, upP, rightP];

				// FlxG.watch.addQuick('asdfa', upP);
				if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
					{
						boyfriend.holdTimer = 0;
			
						var possibleNotes:Array<Note> = [];
			
						var ignoreList:Array<Int> = [];
			
						notes.forEachAlive(function(daNote:Note)
						{
							if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
							{
								// the sorting probably doesn't need to be in here? who cares lol
								possibleNotes.push(daNote);
								possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			
								ignoreList.push(daNote.noteData);
							}
						});
			
						
						if (possibleNotes.length > 0)
						{
							var daNote = possibleNotes[0];
			
							// Jump notes
							if (possibleNotes.length >= 2)
							{
								if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
								{
									for (coolNote in possibleNotes)
									{
										if (controlArray[coolNote.noteData])
											goodNoteHit(coolNote);
										else
										{
											var inIgnoreList:Bool = false;
											for (shit in 0...ignoreList.length)
											{
												if (controlArray[ignoreList[shit]])
													inIgnoreList = true;
											}
										}
									}
								}
								else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
								{
									noteCheckKade(controlArray, daNote);
								}
								else
								{
									for (coolNote in possibleNotes)
									{
										noteCheckKade(controlArray, coolNote);
									}
								}
							}
							else // regular notes?
								noteCheckKade(controlArray, daNote);

							if (daNote.wasGoodHit)
							{
								daNote.kill();
								notes.remove(daNote, true);
								daNote.destroy();
							}
						}
							
						}

						if ((up || right || down || left) && generatedMusic)
							{
								notes.forEachAlive(function(daNote:Note)
								{
									if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
									{
										switch (daNote.noteData)
										{
											// NOTES YOU ARE HOLDING
											case 2:
												if (up || upHold)
													goodNoteHitKade(daNote);
											case 3:
												if (right || rightHold)
													goodNoteHitKade(daNote);
											case 1:
												if (down || downHold)
													goodNoteHitKade(daNote);
											case 0:
												if (left || leftHold)
													goodNoteHitKade(daNote);
										}
									}
								});
							}
					
							if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
							{
								if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
								{
									boyfriend.playAnim('idle');
								}
							}
					
							playerStrums.forEach(function(spr:FlxSprite)
							{
								switch (spr.ID)
								{
									case 2:
										if (upP && spr.animation.curAnim.name != 'confirm')
										{
											spr.animation.play('pressed');
										}
										if (upR)
										{
											spr.animation.play('static');
										}
									case 3:
										if (rightP && spr.animation.curAnim.name != 'confirm')
											spr.animation.play('pressed');
										if (rightR)
										{
											spr.animation.play('static');
										}
									case 1:
										if (downP && spr.animation.curAnim.name != 'confirm')
											spr.animation.play('pressed');
										if (downR)
										{
											spr.animation.play('static');
										}
									case 0:
										if (leftP && spr.animation.curAnim.name != 'confirm')
											spr.animation.play('pressed');
										if (leftR)
										{
											spr.animation.play('static');
										}
								}
								
								if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
								{
									spr.centerOffsets();
									spr.offset.x -= 13;
									spr.offset.y -= 13;
								}
								else
									spr.centerOffsets();
							});
					}
		}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5)
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 10;

			FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play('assets/sounds/missnote1' + TitleState.soundExt, 1, false);
			// FlxG.log.add('played imss note');

			switch (direction)
			{
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
			}
		}
	}

	function noteMissKade(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5)
			{
				gf.playAnim('sad');
			}
			combo = 0;

			songScore -= 10;

			FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play('assets/sounds/missnote1' + TitleState.soundExt, 1, false);
			// FlxG.log.add('played imss note');

			switch (direction)
			{
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
			}
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		if (leftP)
			noteMiss(0);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
		if (downP)
			noteMiss(1);
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		if (keyP)
			goodNoteHit(note);
		else
		{
			badNoteCheck();
		}
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;

	function noteCheckKade(controlArray:Array<Bool>, note:Note):Void
	{
		if (controlArray[note.noteData])
		{
			for (b in controlArray) {
				if (b)
					mashing++;
			}

			// ANTI MASH CODE FOR THE BOYS

			if (mashing <= getKeyPresses(note) && mashViolations < 2)
			{
				mashViolations++;
				goodNoteHitKade(note, (mashing <= getKeyPresses(note)));
			}
			else
			{
				playerStrums.members[note.noteData].animation.play('static');
				trace('mash ' + mashing);
			}

			if (mashing != 0)
				mashing = 0;
		}
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			switch (note.noteData)
			{
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 0:
					boyfriend.playAnim('singLEFT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	function goodNoteHitKade(note:Note, resetMashViolation = true):Void
		{

			if (resetMashViolation)
				mashViolations--;

			if (!note.wasGoodHit)
			{
				if (!note.isSustainNote)
				{
					popUpScore(note.strumTime);
					combo += 1;
				}

				if (note.noteData >= 0)
					health += 0.023;
				else
					health += 0.004;


				switch (note.noteData)
				{
					case 2:
						boyfriend.playAnim('singUP', true);
					case 3:
						boyfriend.playAnim('singRIGHT', true);
					case 1:
						boyfriend.playAnim('singDOWN', true);
					case 0:
						boyfriend.playAnim('singLEFT', true);
				}
	
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.animation.play('confirm', true);
					}
				});
	
				note.wasGoodHit = true;
				vocals.volume = 1;
	
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play('assets/sounds/carPass' + FlxG.random.int(0, 1) + TitleState.soundExt, 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
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

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play('assets/sounds/thunder_' + FlxG.random.int(1, 2) + TitleState.soundExt);
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		if (SONG.needsVoices)
		{
			if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20)
			{
				resyncVocals();
			}
		}

		if (dad.curCharacter == 'babbys' && totalSteps % 4 == 2)
		{
			// dad.dance();
		}
		
		if (dad.curCharacter == 'nadalyn' && totalSteps % 4 == 2)
		{
			// dad.dance();
		}

		super.stepHit();
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		if (sheShed == 'thorns')
			wiggleShit.update(Conductor.crochet);
		super.beatHit();

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			else
				Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			{
				dad.dance();
				gspot.dance();
				gaming.dance();
			}
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'bonbon-loool' && curBeat >= 168 && curBeat <= 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		paly2 = SONG.player2;
		paly3 = SONG.player3;

		if (paly2 == '')
			paly2 = 'null';
		if (paly3 == '')
			paly3 = 'null';

		if (SONG.player3 == 'invisible')
		{
			if (healthBar.percent < 20)
				DiscordClient.changePresence("LOSING TO " + paly2.toUpperCase() + "; LAUGH AT THIS PERSON (oh yea btw " + sheShed + " is playing in the background)", null, 'sussy', 'racialdiversity');
			else if (healthBar.percent > 80)
				DiscordClient.changePresence("Winning in a racial arguement against " + paly2 + " to the tune of " + sheShed + "!", null, 'sussy', 'racialdiversity');
			else
				DiscordClient.changePresence("Discussing racial things with " + paly2 + " to the tune of " + sheShed, null, 'sussy', 'racialdiversity');
		}		
		else if (SONG.player3 == SONG.player2)
		{
			if (healthBar.percent < 20)
				DiscordClient.changePresence("LOSING TO TWICE THE " + paly2.toUpperCase() + "; LAUGH AT THIS PERSON (oh yea btw " + sheShed + " is playing in the background)", null, 'sussy', 'racialdiversity');
			else if (healthBar.percent > 80)
				DiscordClient.changePresence("Winning in a racial arguement against twice the " + paly2 + " to the tune of " + sheShed + "!", null, 'sussy', 'racialdiversity');
			else
				DiscordClient.changePresence("Discussing racial things with twice the " + paly2 + " to the tune of " + sheShed, null, 'sussy', 'racialdiversity');
		}
		else
		{
			if (healthBar.percent < 20)
				DiscordClient.changePresence("LOSING TO " + paly2.toUpperCase() + " AND " + paly3.toUpperCase() + "; LAUGH AT THIS PERSON (oh yea btw " + sheShed + " is playing in the background)", null, 'sussy', 'racialdiversity');
			else if (healthBar.percent > 80)
				DiscordClient.changePresence("Winning in a racial arguement against " + paly2 + " and " + paly3 + " to the tune of " + sheShed + "!", null, 'sussy', 'racialdiversity');
			else
				DiscordClient.changePresence("Discussing racial things with " + paly2 + " and " + paly3 + " to the tune of " + sheShed, null, 'sussy', 'racialdiversity');
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && totalBeats % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (totalBeats % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing"))
		{
			boyfriend.playAnim('idle');
		}

		if (totalBeats % 8 == 7 && curSong == 'Job-Interview')
		{
			boyfriend.playAnim('hey', true);

			if (SONG.song == 'Tutorial' && dad.curCharacter == 'gaming')
			{
				dad.playAnim('cheer', true);
			}
		}

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'spookyscary':
                pogBabby.animation.play('pog',true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
				gamingBop.animation.play('bop');
            case 'nadalyn':
                grpLimoNadders.forEach(function(dancerNad:BackgroundNadders)
				{
					dancerNad.danceNad();
				});
			case 'flynets':
				if (areTheirDogs)
				{
					grpGuardDogs.forEach(function(dog:GuardDogs)
					{
						dog.dance(sheShed);
					});
				}
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (totalBeats % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}

				if (sheShed == 'namebe' || sheShed == 'fnaf-at-phillys')
                    sun.y += 0.35;
			case 'bustom':
				if (sheShed == 'bustom-source')
				{
					switch (curBeat)
					{
						case 15 | 111 | 131 | 207:
							new FlxTimer().start(0.001, function(tmr:FlxTimer)
							{
								dad.playAnim('weird');
							});
					}
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	function setDialogue(diaPath:String)
	{
		dialogue = CoolUtil.coolTextFile('assets/data/dialogue/' + diaPath + '.txt');
	}

	static public function zoomIntoGaming()
	{
		if (!hasFocusedOnGaming)
		{	
			hasFocusedOnDudes = false;
			hasFocusedOnGaming = true;
			var daCamPos:FlxObject = new FlxObject(0, 0, 1, 1);
			daCamPos.setPosition(Std.int(gamingsOwnCoords[0]), Std.int(gamingsOwnCoords[1]));
			FlxG.camera.follow(daCamPos, NO_DEAD_ZONE, 0.04);
			FlxG.camera.zoom = 1.85;
			FlxG.camera.focusOn(daCamPos.getPosition());
		}
		else
		{
			trace('Already focused on gaming?');
		}
	}

	static public function focusOnTheDudes()
	{
		if (!hasFocusedOnDudes)
		{
			hasFocusedOnGaming = false;
			hasFocusedOnDudes = true;
			var daCamPos:FlxObject = new FlxObject(0, 0, 1, 1);
			daCamPos.setPosition(640, 570);
			FlxG.camera.follow(daCamPos, NO_DEAD_ZONE, 0.04);
			FlxG.camera.zoom = 1.45;
			FlxG.camera.focusOn(daCamPos.getPosition());
		}
	}

	static public function initModes()
	{
		randomLevel = false;
		isStoryMode = false;
		isWeekend = false;
		weekEndFreeplay = false;
	}

	var curLight:Int = 0;
}