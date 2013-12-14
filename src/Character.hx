package;

import flixel.FlxObject;
import flixel.FlxSprite;
import flash.display.BitmapData;
import openfl.Assets;
import flash.display.Bitmap;
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

    public var i1:BitmapData;
    public var i2:BitmapData;

    public var charged:Bool;

    public var bullet:Bullet;
    public var lastDirection:Direction;

    public function new(bullet:Bullet){
        super();

        i1 = Assets.getBitmapData("assets/images/character1.png");
        i2 = Assets.getBitmapData("assets/images/character2.png");


        loadGraphic(i2,true,true,32,32);
        animation.add("down",[0]);
        animation.add("side",[1]);
        animation.add("up",[2]);
        color = COLOR;

        charged = false;

        this.bullet = bullet;
    }

    override public function update():Void {
        if (FlxG.keyboard.pressed("DOWN")){
            velocity.y = speed;
            lastDirection = Direction.Down;
            animation.play("down");
        }
        else if (FlxG.keyboard.pressed("UP")){
            velocity.y = -speed;
            lastDirection = Direction.Up;
            animation.play("up");
        }
        else {
            velocity.y = 0;
        }

        if (FlxG.keyboard.pressed("LEFT")){
            velocity.x = -speed;
            lastDirection = Direction.Left;
            animation.play("side");
            facing = FlxObject.LEFT;
        }
        else if (FlxG.keyboard.pressed("RIGHT")){
            velocity.x = speed;
            lastDirection = Direction.Right;
            animation.play("side");
            facing = FlxObject.RIGHT;
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
//        makeGraphic(size,size,CHARGED_COLOR);
        color = CHARGED_COLOR;
        charged = true;

        bullet.state = Equip;
    }

    public function fireBullet(d:Direction){
        if (! charged) return;

        FlxG.camera.shake(0.005,0.1);
        
        bullet.x = x + _halfWidth - bullet.width * .5;
        bullet.y = y + _halfHeight - bullet.height * .5;

        switch(d){
        case Up:
            bullet.y -= _halfHeight + bullet.height * .5;
        case Down:
            bullet.y += _halfHeight + bullet.height * .5;
        case Left:
            bullet.x -= _halfWidth + bullet.width * .5;
        case Right:
            bullet.x += _halfWidth + bullet.width * .5;
        }

//        makeGraphic(size,size,COLOR);
        color = COLOR;
        charged = false;

        bullet.visible = true;
        bullet.state = Fired;
        bullet.firedBy = this;
        bullet.fire(d);
    }
}