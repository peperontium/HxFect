package hxfect.editor.panel;

import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

/**
 * ...
 * @author peperontium
 */
class NumberInputField extends TextInputField{
	
	
	
	public function new(width:Float) {
		super(width);
		this.text = "0";
	}
	
	override function _KeyInput(e:KeyboardEvent):Void {
		
		if(e.keyCode == Keyboard.BACKSPACE){
			///	backspace
			this.text = this.text.substr(0, this.text.length-1);
			if (this.text.length == 0){
				this.text = "0";
			}
		}else if(e.keyCode >= Keyboard.NUMBER_0 && e.keyCode <= Keyboard.NUMBER_9){
			///	0~9
			this.text = Std.string(Std.parseFloat(this.text + String.fromCharCode(e.charCode)));
		}else if(e.keyCode == Keyboard.MINUS && this.text == "0"){
			this.text = "-";
		}else if(e.keyCode == Keyboard.PERIOD && this.text.indexOf(".") == -1){
			this.text += ".";
		}
	}
}