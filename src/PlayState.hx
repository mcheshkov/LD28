package;

import flixel.group.FlxGroup;
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
class PlayState extends FlxState {
    public var chars:FlxGroup;
    public var p:Character;
    public var b:Bullet;
    public var lvl:TiledLevel;

/**
	 * Function that is called up when to state is created to set it up. 
	 */

    override public function create():Void {
// Set a background color
        FlxG.cameras.bgColor = 0xff131c1b;
// Show the mouse (in case it hasn't been disabled)
#if !FLX_NO_MOUSE
		FlxG.mouse.hide();
#end

        super.create();
        FlxG.sound.play("assets/music/LD_3.mp3", 1, true);
        lvl = new TiledLevel("assets/data/map.tmx");
        add(lvl.backgroundTiles);
        add(lvl.foregroundTiles);


        b = new Bullet();
        b.x = 100;
        b.y = 100;

        p = new KeyboardCharacter(1,b);
        p.x = 500;
        p.y = 500;

        var p2 = new AICharacter(2,b,lvl);
        p2.x = 300;
        p2.y = 800;

        var p3 = new AICharacter(3,b,lvl);
        p3.x = 2000;
        p3.y = 1000;

        var p4 = new AICharacter(4,b,lvl);
        p4.x = 1000;
        p4.y = 200;

        var p5 = new AICharacter(5,b,lvl);
        p5.x = 1500;
        p5.y = 1500;

        chars = new FlxGroup();
        chars.add(p);
        chars.add(p2);
        chars.add(p3);
        chars.add(p4);
        chars.add(p5);

        p2.setChars(chars);
        p3.setChars(chars);
        p4.setChars(chars);
        p5.setChars(chars);

        add(chars);
        add(b);

        FlxG.worldBounds.set(-100, -100, 150000, 150000);
        FlxG.camera.follow(p);
    }

/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */

    override public function destroy():Void {
        super.destroy();
    }

/**
	 * Function that is called once every frame.
	 */

    override public function update():Void {
        super.update();

        if (b.state == BulletState.Pickup) {
            FlxG.overlap(chars, b, function(p:Character, b:Bullet) {
                if (!p.isDead) {
                    b.visible = false;
                    p.pickUpBullet();
                }
            });
        }

        if (b.state == BulletState.Fired) {
            FlxG.overlap(chars, b, function(p:Character, b:Bullet) {
                if (p == b.firedBy) return;
                p.death();
                b.drop();
            });
        }


        lvl.collideWithLevel(b, function(tile, bullet:Bullet) {
            bullet.drop();
        });

        lvl.collideWithLevel(chars);

        if (FlxG.keyboard.pressed("R")) FlxG.resetState();
    }
}