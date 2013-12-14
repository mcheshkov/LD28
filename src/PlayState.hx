package;

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

        var lvl = new TiledLevel("assets/data/map.tmx");
        add(lvl.foregroundTiles);




        b = new Bullet();
        p = new Character(b);
        b.x = 100;
        b.y = 100;
        add(p);
        add(b);
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
        if (b.state == Pickup){
            FlxG.overlap(p,b,function(p:Character,b:Bullet){
                b.visible = false;
                p.pickUpBullet();
            });
        }

		super.update();
	}
}