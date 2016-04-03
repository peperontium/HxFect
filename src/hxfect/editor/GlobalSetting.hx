package hxfect.editor;

import openfl.text.*;

/**
 * ...
 * @author peperontium
 */
class GlobalSetting{

	public static inline var TextSize = 18;
	
	public static var DefaultTextFormat(get, null):TextFormat;
	private static inline function get_DefaultTextFormat():TextFormat {	
		return(new TextFormat(null, TextSize));
	}
	public static inline var ButtonColor = 0xFFEEEEEE;
	public static inline var PushedButtonColor = 0xFFBBBBBB;
	
	public static function createTextField(textSize : Int = TextSize):TextField{
		var tf = new TextField();
		tf.defaultTextFormat = new TextFormat(null,textSize);
		tf.backgroundColor = GlobalSetting.ButtonColor;
		tf.background = true;
		tf.selectable = false;
		
		//	adjust input field size 
		tf.text = "a";
		tf.autoSize = TextFieldAutoSize.LEFT;
		var height = tf.height;
		tf.autoSize = TextFieldAutoSize.NONE;
		tf.height= height;
		tf.text = "";
		
		return tf;
	}
}