package;

import openfl.display.Sprite;
import openfl.display.FPS;

import hxfect.editor.EditorWindow;

import hxfect.*;
import openfl.events.Event;

/**
 * ...
 * @author peperontium
 */
class Main extends Sprite {

	public function new() {
		super();
		/*
		var mgr = new HxFectManager();
		var ef = HxFect.CreateFromFile("img/aa.hxef");
		
		
		mgr.registerEffect(ef, 1);
		ef.x = 200;
		ef.y = 200;
		
		this.addEventListener(Event.ENTER_FRAME, function(e):Void { this.graphics.clear(); mgr.updateAll(); mgr.renderAll(this.graphics); } );
		*/
		
		
		this.addChild(new EditorWindow());
		this.addChild(new FPS(500,10,0xffffff));
	}

}
