package;

import flash.Lib;
import flixel.FlxGame;

class GameClass extends FlxGame {
    public function new() {
        var stageWidth:Int = Lib.current.stage.stageWidth;
        var stageHeight:Int = Lib.current.stage.stageHeight;

        var ratioX:Float = stageWidth / 800;
        var ratioY:Float = stageHeight / 600;
        var ratio:Float = Math.min(ratioX, ratioY) * 2;

        var fps:Int = 60;


        super(Math.ceil(stageWidth / ratio), Math.ceil(stageHeight / ratio), PlayState, ratio, fps, fps);
    }
}
