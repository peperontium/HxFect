package hxfect.editor.panel;

import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.text.*;
import openfl.ui.Keyboard;

/**
 * ...
 * @author peperontium
 */
class TextInputField extends TextField{

	
	public function new(width:Float) {
		super();
		
		this.defaultTextFormat = GlobalSetting.DefaultTextFormat;
		this.backgroundColor = GlobalSetting.ButtonColor;
		this.background = true;
		this.selectable = false;

		//	adjust input field size 
		this.text = "a";
		this.autoSize = TextFieldAutoSize.LEFT;
		var height = this.height;
		this.autoSize = TextFieldAutoSize.NONE;
		this.width = width;
		this.height= height;
		this.text = "";
		
		this.addEventListener(MouseEvent.CLICK, _OnFocusIn);
		this.addEventListener(FocusEvent.FOCUS_OUT, _OnFocusOut);
		this.addEventListener(KeyboardEvent.KEY_DOWN,_KeyInput);
	}
	
	private function _KeyInput(e:KeyboardEvent):Void{
		if(e.keyCode == Keyboard.BACKSPACE){
			this.text = this.text.substr(0, this.text.length - 1);
		}else{
			this.text += String.fromCharCode(e.charCode);
		}
	}
	
	private function _OnFocusIn(e):Void{
		this.backgroundColor = GlobalSetting.PushedButtonColor;
		this.background = true;
	}
	
	private function _OnFocusOut(e):Void {
		this.backgroundColor = GlobalSetting.ButtonColor;
		this.background = true;
	}
	
}