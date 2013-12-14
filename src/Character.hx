package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class Character extends FlxSprite
{
    public static var speed:Int = 100;
    public static var COLOR:UInt = 0xff00ff00;
    public static var CHARGED_COLOR:UInt = 0xff00ffff;
    public static var size:Int = 32;

    public var charged:Bool;

    public var bullet:Bullet;
    public var lastDirection:Direction;

    public function new(bullet:Bullet){
        super();

        makeGraphic(size,size,COLOR);
        charged = false;

        this.bullet = bullet;
    }

    override public function update():Void {
        if (FlxG.keyboard.pressed("DOWN")){
            velocity.y = speed;
            lastDirection = Direction.Down;
        }
        else if (FlxG.keyboard.pressed("UP")){
            velocity.y = -speed;
            lastDirection = Direction.Up;
        }
        else {
            velocity.y = 0;
        }

        if (FlxG.keyboard.pressed("LEFT")){
            velocity.x = -speed;
            lastDirection = Direction.Left;
        }
        else if (FlxG.keyboard.pressed("RIGHT")){
            velocity.x = speed;
            lastDirection = Direction.Right;
        }
        else {
            velocity.x = 0;
        }

        if(FlxG.keyboard.pressed("SHIFT")){
            fireBullet(lastDirection);
        }

        super.update();
    }

    public function pickUpBullet(){
        FlxG.log.warn("pick up");
        makeGraphic(size,size,CHARGED_COLOR);
        charged = true;

        bullet.state = Equip;
    }

    public function fireBullet(d:Direction){
        if (! charged) return;

        bullet.x = x + _halfWidth - bullet.width * .5;
        bullet.y = y + _halfHeight - bullet.height * .5;

        makeGraphic(size,size,COLOR);
        charged = false;

        bullet.visible = true;
        bullet.state = Fired;
        bullet.fire(d);
    }
}