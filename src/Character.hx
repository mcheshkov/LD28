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

        loadAssets();

        loadChar1();

        height = 32;
        width = 32;
        _offset.x = 16;
        _offset.y = 1;

        lastDirection = Direction.Right;
        charged = false;

        this.bullet = bullet;
    }

    public var assestLoaded:Bool = false;

    public function loadAssets(){
        if (assestLoaded) return;

        i1 = Assets.getBitmapData("assets/images/trex1.png");
        i2 = Assets.getBitmapData("assets/images/character2.png");
    }

    public function loadChar1(){
        loadGraphic(i1,true,true,65,33);

        loadAnimations();
    }

    public function loadChar2(){
        loadGraphic(i2,true,true,32,32);

        loadAnimations();
    }

    public function loadAnimations(){
        animation.add("death_side",[0,1,2,3,4,5,6],10);


        animation.add("down_stand",[27,28],4);
        animation.add("side_stand",[9,10],4);
        animation.add("up_stand",[36, 37],4);


        animation.add("down_walk",[29, 30],4);
        animation.add("side_walk",[11, 12, 13, 14, 15, 16, 17],10);
        animation.add("up_walk",[38, 39],4);

        animation.add("down_stand_load",[31,32],4);
        animation.add("side_stand_load",[18,19],4);

        animation.add("down_walk_load",[33, 34],4);
        animation.add("side_walk_load",[20, 21, 22, 23, 24, 25, 26],10);
    }

    public var walking:Bool = false;

    public function goLeft(){
        velocity.x = -speed;
        lastDirection = Direction.Left;
        animation.play("side_walk");
        facing = FlxObject.LEFT;
        walking = true;
    }

    public function goRight(){
        velocity.x = speed;
        lastDirection = Direction.Right;
        animation.play("side_walk");
        facing = FlxObject.RIGHT;
        walking = true;
    }

    public function goUp(){
        velocity.y = -speed;
        lastDirection = Direction.Up;
        animation.play("up_walk");
//        facing = FlxObject.LEFT;
        walking = true;
    }

    public function goDown(){
        velocity.y = speed;
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
        if (FlxG.keyboard.pressed("DOWN")){
            velocity.y = speed;
            lastDirection = Direction.Down;
            charged ? animation.play("down_walk") : animation.play("down_walk_load");
            walking = true;
        }
        else if (FlxG.keyboard.pressed("UP")){
            velocity.y = -speed;
            lastDirection = Direction.Up;
            animation.play("up_walk");
            walking = true;
        }
        else {
            velocity.y = 0;
        }

        control();
        if (FlxG.keyboard.pressed("LEFT")){
            velocity.x = -speed;
            lastDirection = Direction.Left;
            charged ? animation.play("side_walk") : animation.play("side_walk_load");
            facing = FlxObject.LEFT;
            walking = true;
        }
        else if (FlxG.keyboard.pressed("RIGHT")){
            velocity.x = speed;
            lastDirection = Direction.Right;
            charged ? animation.play("side_walk") : animation.play("side_walk_load");
            facing = FlxObject.RIGHT;
            walking = true;
        }
        else {
            velocity.x = 0;
        }

        if (! walking){
            switch(lastDirection){
            case Direction.Up:
                animation.play("up_stand");
            case Direction.Down:
                animation.play("down_stand");
            case Direction.Left | Direction.Right:
                animation.play("side_stand");
                charged ? animation.play("down_stand") : animation.play("down_stand_load");
            case Direction.Left:
                charged ? animation.play("side_stand") : animation.play("side_stand_load");
            case Direction.Right:
                charged ? animation.play("side_stand") : animation.play("side_stand_load");
            }
        }

        if(FlxG.keyboard.pressed("SHIFT")){
            fireBullet(lastDirection);
        }

        super.update();
    }

    public function pickUpBullet(){
        FlxG.log.warn("pick up");
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