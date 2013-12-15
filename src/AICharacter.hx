package;

import flixel.util.FlxAngle;
import flixel.util.FlxPath;
import flixel.effects.particles.FlxParticle;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.util.FlxPoint;
import flixel.util.FlxRandom;
import Bullet.BulletState;
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
class AICharacter extends Character
{
    public var lvl:TiledLevel;

    public static var PI_1_8:Float;
    public static var PI_3_8:Float;
    public static var PI_5_8:Float;
    public static var PI_7_8:Float;
    public static var PI_init:Bool = false;

    public function new(b:Bullet,lvl:TiledLevel){
        super(b);
        lastBulletState = BulletState.Fired;
        this.lvl = lvl;
        lastPos = new FlxPoint();

        if (! PI_init){
            PI_init = true;
            PI_1_8 = 1./8.*Math.PI;
            PI_3_8 = 3./8.*Math.PI;
            PI_5_8 = 5./8.*Math.PI;
            PI_7_8 = 7./8.*Math.PI;
        }
    }

    public static var VIEWFIELD:Float = 200;

    public function getTargetRadius(distToBullet:Float):Float{
        if (distToBullet < VIEWFIELD) return 0;
        else return FlxRandom.float() * distToBullet / 3;
    }

    public var target:FlxPoint = null;

    public var lastBulletState:BulletState;

    public var path:Array<FlxPoint>;
    public var pathIdx:Int = 0;

    var consecPos:Int = 0;
    var lastPos:FlxPoint;

    public function setPath(p:Array<FlxPoint>){
        path = p;
        pathIdx = 0;
    }

    public function followPath(){

        var p:FlxPoint = path[pathIdx];
//            FlxG.log.notice("GOTO",p);
//            FlxG.log.notice("POS",myp);
//            FlxG.log.notice("DIST",FlxMath.getDistance(myp,p));
        if (pathIdx >= path.length){
            path = null;
            return;
        }
        if (FlxMath.getDistance(myp,p) < 2){
            pathIdx++;
            return;
        }
        var angle = FlxAngle.angleBetweenPoint(this,p);
//            FlxG.log.notice("ANGLE",angle);
        if      (angle < -PI_7_8) {goLeft();}
        else if (angle < -PI_5_8) {goUp();goLeft();}
        else if (angle < -PI_3_8) {goUp();}
        else if (angle < -PI_1_8) {goUp();goRight();}
        else if (angle <  PI_1_8) {goRight();}
        else if (angle <  PI_3_8) {goDown();goRight();}
        else if (angle <  PI_5_8) {goDown();}
        else if (angle <  PI_7_8) {goDown();goLeft();}
        else                      {goLeft();}
    }

    public var myp(get,null):FlxPoint;

    inline public function get_myp():FlxPoint{
        return new FlxPoint(this.x + this.origin.x,this.y + this.origin.y);
    }

    override public function control():Void {
        if (this.x == lastPos.x && this.y == lastPos.y) consecPos++;
        else {
            FlxG.log.notice("REFRESH CONSEC", consecPos, lastPos);
            lastPos.set(this.x,this.y);
            consecPos = 0;
        }

        if (consecPos == 100 || Math.random() < 0.001){
            FlxG.log.notice("RANDOM", consecPos);

            var ppp:FlxPoint = new FlxPoint();
            ppp.x = myp.x + FlxRandom.intRanged(-200,200);
            ppp.y = myp.y + FlxRandom.intRanged(-200,200);

            setPath([ppp]);
        }

        if(bullet.state == BulletState.Pickup){
            if (lastBulletState != bullet.state || path == null){
                FlxG.log.notice("SEARCHING");
                var pb: FlxPoint = new FlxPoint(bullet.x + bullet.origin.x, bullet.y + bullet.origin.y);

                var r = getTargetRadius(FlxMath.getDistance(myp,pb));
                var a = FlxRandom.float() * 2 * Math.PI;

                var x = r * Math.cos(a);
                var y = r * Math.sin(a);

                target = new FlxPoint();
                target.x = x + pb.x;
                target.y = y + pb.y;

//                FlxG.log.notice("rad",r);
//                FlxG.log.notice("target",target);
//                FlxG.log.notice("bullet",pb);

                setPath(cast(lvl.foregroundTiles.members[0],FlxTilemap).findPath(myp,target));
                for (i in path){
                    FlxG.log.notice("path",i);
                }
            }
        }
        else if (bullet.state == BulletState.Fired){
            FlxG.log.notice("EVADING");
            var ppp:FlxPoint = new FlxPoint();
            ppp.x = myp.x;
            ppp.y = myp.y;
            switch(bullet.lastDirection){
                case Up:
                    if (bullet.y > y && bullet.overlapsAt(bullet.x,y + origin.y - bullet.origin.y,this)){
                        if (FlxRandom.chanceRoll(50)){
                            ppp.x -= Character.size;
                        }
                        else {
                            ppp.x += Character.size;
                        }
                        setPath([ppp]);
                    }
                case Down:
                    if (bullet.y < y && bullet.overlapsAt(bullet.x,y + origin.y - bullet.origin.y,this)){
                        if (FlxRandom.chanceRoll(50)){
                            ppp.x -= Character.size;
                        }
                        else {
                            ppp.x += Character.size;
                        }
                        setPath([ppp]);
                    }
                case Left:
                    if (bullet.x > x && bullet.overlapsAt(x + origin.x - bullet.origin.x,bullet.y,this)){
                        if (FlxRandom.chanceRoll(50)){
                            ppp.y += Character.size;
                        }
                        else {
                            ppp.y -= Character.size;
                        }
                        setPath([ppp]);
                    }
                case Right:
                    if (bullet.x > x && bullet.overlapsAt(x + origin.x - bullet.origin.x,bullet.y,this)){
                        if (FlxRandom.chanceRoll(50)){
                            ppp.y += Character.size;
                        }
                        else {
                            ppp.y -= Character.size;
                        }
                        setPath([ppp]);
                    }
            }
        }

        if (path != null){
            followPath();
        }

        lastBulletState = bullet.state;

//        lvl.collideWithLevel(this,function(l,c){
//            FlxG.log.notice("COLLIDEDEDE");
//        });
    }
}