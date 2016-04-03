package hxfect.editor;

import hxfect.HxFect;

import haxe.ds.StringMap;
import openfl.display.Tilesheet;

/**
 * ...
 * @author peperontium
 */
class HxFectEditable extends HxFect {
	
	
	override public function update():Bool {
		//	強制ループ
		if (_timer > HxFect.REMAINING_FRAME) {
			_timer = 0;
		}
		
		
		return super.update();
	}
	
	
	public function setRootNode(rootNode:HxFectNodeEditable):Void{
		_rootNode = rootNode;	
	}
	
	private inline function new() {
		super();
		
	}

	public static function CreateForEditor():HxFectEditable{
		var hxfect = new HxFectEditable();
		
		hxfect._isLoop = true;
		
		
		return hxfect;
	}
	
	public inline function getTime():Int{
		return _timer;
	}
	
	public inline function setRoop(isLoop:Bool):Void{
		_isLoop = isLoop;
	}
	
	public inline function unregisterRenderNode(node:HxFectNode):Void{
		_zSortedRenderNodes.get( -node.zDepth).remove(node);
	}
	
	
	public function writeOut():String{
		var buf = "[effect]\n";
		buf += '${ if(_isLoop){1;}else{0;} }';
		
		buf += cast(_rootNode, HxFectNodeEditable).writeNode();
		
		buf += "[/effect]\n";
		
		return buf;
	}
	
}