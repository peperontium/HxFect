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
		
		this.addChild(new EditorWindow());
		this.addChild(new FPS(500, 10, 0xffffff));
		
		
		/*var hxfectManager = new HxFectManager();
		var hxfect = HxFect.CreateFromFile("ef/runaty.hxef",hxfectManager);
		hxfect.play(0);
		
		hxfect.x = 200;
		hxfect.y = 200;
		
		this.addEventListener(Event.ENTER_FRAME,function(e):Void{
			this.graphics.clear();
			hxfectManager.updateAll();
			hxfectManager.renderAll(this.graphics);
			}
		);/**/
		
		}
	

}
