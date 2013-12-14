package;

import Bullet.BulletState;
import Bullet.BulletState;
import flixel.addons.editors.tiled.TiledMap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
    public var p:Character;
    public var b:Bullet;
    public var lvl:TiledLevel;

	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		// Set a background color
		FlxG.cameras.bgColor = 0xff131c1b;
		// Show the mouse (in case it hasn't been disabled)
		#if !FLX_NO_MOUSE
		FlxG.mouse.show();
		#end
		
		super.create();

        lvl = new TiledLevel("assets/data/map.tmx");
        add(lvl.backgroundTiles);
        add(lvl.foregroundTiles);




        b = new Bullet();
        p = new Character(b);
        p.x = 100;
        p.y = 100;
        b.x = 300;
        b.y = 300;
        add(p);
        add(b);

        FlxG.camera.follow(p);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
        super.update();

        if (b.state == BulletState.Pickup){
            FlxG.overlap(p,b,function(p:Character,b:Bullet){
                FlxG.log.warn("ASDASDASD");
                b.visible = false;
                p.pickUpBullet();
            });
        }


        lvl.collideWithLevel(b, function(tile, bullet:Bullet){
            bullet.drop();
        });

        lvl.collideWithLevel(p);

        if(FlxG.keyboard.pressed("R")) FlxG.resetState();
	}
}