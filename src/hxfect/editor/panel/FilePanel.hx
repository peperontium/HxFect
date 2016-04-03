package hxfect.editor.panel;

import openfl.display.Bitmap;
import openfl.display.Sprite;
import openfl.text.TextField;

/**
 * ...
 * @author peperontium
 */

/**
 * ファイル入出力用のパネル
 */
class FilePanel extends Sprite{

	private static inline var PATH_EXTENSION = ".hxef";
	
	public var path(get, null):String;
	private inline function get_path():String{
		return _pathInputField.text + _pathExtension.text;
	}
	
	private var _saveButton : TextButton;
	private var _loadButton : TextButton;
	
	private var _pathInputField : TextInputField;
	private var _pathExtension : TextField;
	
	
	public function new() {
		super();
		
		_saveButton = new TextButton("save");
		_loadButton = new TextButton("load");
		_pathInputField = new TextInputField(200);
		_pathExtension  = GlobalSetting.createTextField();
		_pathExtension.autoSize = openfl.text.TextFieldAutoSize.LEFT;
		_pathExtension.text = PATH_EXTENSION;
		
		_saveButton.x = 15;
		_loadButton.x = _saveButton.x + _saveButton.width + 10;
		_pathInputField.x = _loadButton.x + _loadButton.width + 10;
		_pathExtension.x = _pathInputField.x + _pathInputField.width;
		
		_saveButton.y = _loadButton.y = _pathInputField.y = _pathExtension.y = 6;
		
		
		
		this.addChild(_saveButton);
		this.addChild(_loadButton);
		this.addChild(_pathInputField);
		this.addChild(_pathExtension);
	}
	
	public inline function setSaveProcedure(proc:Void->Void):Void{
		_saveButton.setPushedProcedure(proc);
	}
	
	public inline function setLoadProcedure(proc:Void->Void):Void{
		_loadButton.setPushedProcedure(proc);
	}
	
}

