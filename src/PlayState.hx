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
    public var heads:FlxGroup;

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

        FlxG.sound.playMusic("assets/music/LD_3.mp3", 1);
        lvl = new TiledLevel("assets/data/map.tmx");
        add(lvl.backgroundTiles);
        add(lvl.foregroundTiles);

        heads = new FlxGroup();

        b = new Bullet();
        b.x = 300;
        b.y = 300;

        p = new KeyboardCharacter(1, b);
        p.x = 500;
        p.y = 500;
        p.id = 1;

        var p2 = new AICharacter(2, b, lvl);
        p2.x = 300;
        p2.y = 800;
        p2.id = 2;

        var p3 = new AICharacter(3, b, lvl);
        p3.x = 400;
        p3.y = 1000;
        p3.id = 3;

        var p4 = new AICharacter(4, b, lvl);
        p4.x = 1000;
        p4.y = 200;
        p4.id = 4;

        var p5 = new AICharacter(5, b, lvl);
        p5.x = 500;
        p5.y = 1250;
        p5.id = 5;



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

        p2.headSpr.x = 5;
        p2.headSpr.y = 5;
        add(p2.headSpr);

        p3.headSpr.x = 25;
        p3.headSpr.y = 5;
        add(p3.headSpr);

        p4.headSpr.x = 45;
        p4.headSpr.y = 5;
        add(p4.headSpr);

        p5.headSpr.x = 65;
        p5.headSpr.y = 5;
        add(p5.headSpr);

        add(chars);
        add(b);

        FlxG.worldBounds.set(-100, -100, 150000, 150000);

        FlxG.camera.follow(p);
        FlxG.camera.setBounds(32, 32, 49 * 32, 49 * 32);
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
                if(p.headSpr.exists){
                    remove(p.headSpr);
                }
                b.drop(true);
            });
        }


        lvl.collideWithLevel(b, function(tile, bullet:Bullet) {
            bullet.drop();
        });

        lvl.collideWithLevel(chars);

        if (FlxG.keyboard.pressed("R")) FlxG.switchState(new MenuState());
    }
}