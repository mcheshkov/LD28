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

    public function new(bullet:Bullet){
        super();

        makeGraphic(size,size,COLOR);
        charged = false;

        this.bullet = bullet;
    }

    override public function update():Void {
        if (FlxG.keyboard.pressed("DOWN")){
            velocity.y = speed;
        }
        else if (FlxG.keyboard.pressed("UP")){
            velocity.y = -speed;
        }
        else {
            velocity.y = 0;
        }

        if (FlxG.keyboard.pressed("LEFT")){
            velocity.x = -speed;
        }
        else if (FlxG.keyboard.pressed("RIGHT")){
            velocity.x = speed;
        }
        else {
            velocity.x = 0;
        }

        if (FlxG.keyboard.pressed("S")){
            fireBullet(Direction.Down);
        }
        if (FlxG.keyboard.pressed("W")){
            fireBullet(Direction.Up);
        }
        if (FlxG.keyboard.pressed("A")){
            fireBullet(Direction.Left);
        }
        if (FlxG.keyboard.pressed("D")){
            fireBullet(Direction.Right);
        }

        if (charged){
            bullet.x = x;
            bullet.y = y;
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

        makeGraphic(size,size,COLOR);
        charged = false;

        bullet.visible = true;
        bullet.state = Fired;
        bullet.fire(d);
    }
}