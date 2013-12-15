package;

import Bullet.BulletState;
import Direction;
import Bullet.BulletState;
import Direction;
import Direction;
import Direction;
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
    public static var SPEED:Int = 300;
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

        loadAssets();

        loadChar2();
        color = COLOR;

        lastDirection = Direction.Right;
        charged = false;

        this.bullet = bullet;
    }

    public var assestLoaded:Bool = false;

    public function loadAssets(){
        if (assestLoaded) return;

        i1 = Assets.getBitmapData("assets/images/character1.png");
        i2 = Assets.getBitmapData("assets/images/character2.png");
    }

    public function loadChar1(){
        loadGraphic(i1,true,true,32,32);

        loadAnimations();
    }

    public function loadChar2(){
        loadGraphic(i2,true,true,32,32);

        loadAnimations();
    }

    public function loadAnimations(){
        animation.add("down_stand",[0,6],10);
        animation.add("side_stand",[1,7],10);
        animation.add("up_stand",[2,8],10);

        animation.add("down_walk",[0,3],10);
        animation.add("side_walk",[1,4],10);
        animation.add("up_walk",[2,5],10);
    }

    public var walking:Bool = false;

    public function goLeft(){
        velocity.x = -SPEED;
        lastDirection = Direction.Left;
        animation.play("side_walk");
        facing = FlxObject.LEFT;
        walking = true;
    }

    public function goRight(){
        velocity.x = SPEED;
        lastDirection = Direction.Right;
        animation.play("side_walk");
        facing = FlxObject.RIGHT;
        walking = true;
    }

    public function goUp(){
        velocity.y = -SPEED;
        lastDirection = Direction.Up;
        animation.play("up_walk");
//        facing = FlxObject.LEFT;
        walking = true;
    }

    public function goDown(){
        velocity.y = SPEED;
        lastDirection = Direction.Down;
        animation.play("down_walk");
//        facing = FlxObject.DOWN;
        walking = true;
    }

    public function fire(){
        fireBullet(lastDirection);
    }

    public function control():Void{

    }

    override public function update():Void {
        super.update();

        walking = false;
        velocity.set(0,0);

        control();

        if (! walking){
            switch(lastDirection){
            case Direction.Up:
                animation.play("up_stand");
            case Direction.Down:
                animation.play("down_stand");
            case Direction.Left | Direction.Right:
                animation.play("side_stand");
            }
        }
    }

    public function pickUpBullet(){
        FlxG.log.warn("pick up");
//        makeGraphic(size,size,CHARGED_COLOR);
        color = CHARGED_COLOR;
        charged = true;

        bullet.state = BulletState.Equip;
    }

    public function fireBullet(d:Direction){
        if (! charged) return;

        FlxG.camera.shake(0.005,0.1);
        
        bullet.x = x + _halfWidth - bullet.width * .5;
        bullet.y = y + _halfHeight - bullet.height * .5;

        switch(d){
        case Direction.Up:
            bullet.y -= _halfHeight + bullet.height * .5;
        case Direction.Down:
            bullet.y += _halfHeight + bullet.height * .5;
        case Direction.Left:
            bullet.x -= _halfWidth + bullet.width * .5;
        case Direction.Right:
            bullet.x += _halfWidth + bullet.width * .5;
        }

//        makeGraphic(size,size,COLOR);
        color = COLOR;
        charged = false;

        bullet.visible = true;
        bullet.state = BulletState.Fired;
        bullet.firedBy = this;
        bullet.fire(d);
    }
}