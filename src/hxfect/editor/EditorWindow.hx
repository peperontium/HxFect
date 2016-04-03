package hxfect.editor;

import openfl.display.Sprite;
#if (cpp||neko)
import sys.io.File;
#end
import hxfect.editor.panel.*;

/**
 * ...
 * @author peperontium
 */
class EditorWindow extends Sprite{

	private var _filePanel		: FilePanel;
	private var _TexturePanel 	: TexturePanel;
	private var _nodePanel 		: NodePanel;
	private var _keyframePanel 	: KeyFramePanel;
	
	public function new() {
		super();
		
		_filePanel = new FilePanel();
		_filePanel.setLoadProcedure(load);
		_filePanel.setSaveProcedure(save);
		
		_TexturePanel = new TexturePanel();
		_TexturePanel.x = 5;
		_TexturePanel.y = _filePanel.height + 30;
		
		_nodePanel = new NodePanel();
		_nodePanel.y = _filePanel.height + 30;
		_nodePanel.x = _TexturePanel.x + _TexturePanel.width + 20;
		_nodePanel.setTilesheetGetter(_TexturePanel.getTilesheetByName);
		
		_TexturePanel.setOnTileUpdatedProcedure(_nodePanel.updateTile);
		
		_keyframePanel = new KeyFramePanel();
		_keyframePanel.x = 15;
		_keyframePanel.y = _TexturePanel.height +_TexturePanel.y + 40;
		
		_nodePanel.setOnSelectNodeChangedprocedure(_keyframePanel.setKF);
		
		
		this.addChild(_filePanel);
		this.addChild(_TexturePanel);
		this.addChild(_nodePanel);
		this.addChild(_keyframePanel);
	}
	
	function save():Void{
		var buf = _TexturePanel.writeOut();
		buf += _nodePanel.writeOut();
		#if (cpp||neko)
		var fo = File.write(_filePanel.path);
		fo.writeString(buf);
		fo.close();
		#else
		trace(buf);
		#end
	}
	
	function load():Void{
		var fi = new TextFileReader(_filePanel.path);
		
		_TexturePanel.importFile(fi);
		_nodePanel.importFile(fi,_TexturePanel.getTilesheetTable());
	}
}