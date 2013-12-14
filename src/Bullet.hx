package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

enum BulletState{
    Pickup;
    Equip;
    Fired;
}

/**
 * A FlxState which can be used for the actual gameplay.
 */
class Bullet extends FlxSprite
{
    public static var SPEED:Int = 500;
    public static var COLOR:Int = 0xff407740;
    public static var size:Int = 8;

    public var state:BulletState;

    public function new(){
        super();

        makeGraphic(size,size,COLOR);
        state = Pickup;
    }

    override public function update():Void {
        super.update();
    }

    public function fire(d:Direction){
        switch(d){
        case Up:
            velocity.y = -SPEED;
        case Down:
            velocity.y = SPEED;
        case Left:
            velocity.x = -SPEED;
        case Right:
            velocity.x = SPEED;
        }
        state = Fired;
    }
}