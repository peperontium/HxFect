package hxfect.editor.panel;

import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.text.*;
/**
 * ...
 * @author peperontium
 */
class TextButton extends Sprite{
	
	private var _text : TextField;
	private var _pushedProcedure : Void->Void;
	
	public function new(text:String, size:Int = GlobalSetting.TextSize) {
		super();
		
		_pushedProcedure = null;
		
		_text = GlobalSetting.createTextField(size);
		_text.text = text;
		_text.autoSize = TextFieldAutoSize.LEFT;
		
		this.addChild(_text);
		this.addEventListener(MouseEvent.MOUSE_DOWN, _OnPushed);
		this.addEventListener(MouseEvent.MOUSE_UP, _OnPulled);
		this.addEventListener(MouseEvent.MOUSE_OUT, _OnLeaved);
	}
	
	public inline function setPushedProcedure(procedure : (Void->Void)):Void{
		_pushedProcedure = procedure;
	}
	
	private function _OnPushed(e:MouseEvent):Void {
		_text.backgroundColor = GlobalSetting.PushedButtonColor;
		_text.background = true;
	}
	
	private function _OnLeaved(e:MouseEvent):Void {
		_text.backgroundColor = GlobalSetting.ButtonColor;
		_text.background = true;
		
	}
	
	private function _OnPulled(e:MouseEvent):Void {
		if(_pushedProcedure != null){
			_pushedProcedure();
		}
		_OnLeaved(e);
	}
	
}