package hxfect.editor.panel;

import haxe.ds.IntMap;
import haxe.ds.StringMap;
import hxfect.KeyFrame;
import openfl.display.DisplayObjectContainer;
import openfl.display.Tilesheet;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.Vector;
import openfl.ui.Keyboard;

import hxfect.HxFectManager;
import hxfect.HxFectNode;
import hxfect.editor.HxFectNodeEditable;
import hxfect.editor.HxFectEditable;

/**
 * ...
 * @author peperontium
 */
class NodePanel extends Sprite {
	
	private static inline var NODEBUTTONS_X = 470;
	
	private static var NodeNameIDCounter = 1;
	
	///	再生中？
	public var isPlaying(get, set):Bool;
	private inline function get_isPlaying():Bool{
		return _isAnimPlaying;
	}
	private inline function set_isPlaying(isplaying:Bool):Bool {
		_isAnimPlaying = isplaying;
		return _isAnimPlaying;
	}
	
	
	private var _addNodeButton : TextButton;
	private var _removeNodeButton : TextButton;
	private var _nodeTilePanel : NodeTileDataPanel;
	
	private var _loopChangeButton : TextButton;
	private var _loopStateText : TextField;
	
	private var _nodeZInputField : NumberInputField;
	private var _nodeZText : TextField;
	
	private var _animRenderArea : AnimRenderArea;
	
	private var _hxfectManager : HxFectManager;
	private var _effect : HxFectEditable;
	
	private var _nodeTable : IntMap<NodeButton>;
	private var _currentNode : NodeButton;
	private var _dummyRootButton : Sprite;
	
	private var _isAnimPlaying : Bool;
	
	private var _tilesheetGetter: String->Tilesheet;
	private var _onSelectTileChangedProcedure : HxFectNodeEditable->Void;
	
	
	private function _InitButtons():Void {		
		_addNodeButton = new TextButton("add");
		_addNodeButton.x = NODEBUTTONS_X;
		_addNodeButton.y = 450;
		_addNodeButton.setPushedProcedure(_AddNewNode);
		
		_removeNodeButton = new TextButton("remove");
		_removeNodeButton.x = _addNodeButton.x + _addNodeButton.width + 5;
		_removeNodeButton.y = 450;
		_removeNodeButton.setPushedProcedure(_RemoveCurrentNode);
		
		this.addChild(_addNodeButton);
		this.addChild(_removeNodeButton);
		
		_nodeTilePanel = new NodeTileDataPanel();
		_nodeTilePanel.x = NODEBUTTONS_X;
		_nodeTilePanel.y = _addNodeButton.y + _addNodeButton.height + 5;
		_nodeTilePanel.setOnAppliedProcedure(_ApplyTile);
		
		this.addChild(_nodeTilePanel);
		
		
		_loopChangeButton = new TextButton("●");
		_loopChangeButton.setPushedProcedure(
			function():Void{
				if(_loopStateText.text == "Loop"){
					_loopStateText.text = "UnLoop";
					_effect.setRoop(false);
				}else{
					_loopStateText.text = "Loop";
					_effect.setRoop(true);
				}
			}
		);
		_loopStateText = GlobalSetting.createTextField();
		_loopStateText.autoSize = TextFieldAutoSize.LEFT;
		_loopStateText.text = "Loop";
		_effect.setRoop(true);
		
		_loopChangeButton.y = _loopStateText.y = _nodeTilePanel.y + _nodeTilePanel.height + 10;
		_loopChangeButton.x = NODEBUTTONS_X;
		_loopStateText.x = NODEBUTTONS_X + _loopChangeButton.width + 4;
		
		this.addChild(_loopChangeButton);
		this.addChild(_loopStateText);
		
		_nodeZText = GlobalSetting.createTextField();
		_nodeZText.autoSize = TextFieldAutoSize.LEFT;
		_nodeZText.text = "Z=";
		_nodeZInputField = new NumberInputField(30);
		
		_nodeZText.y = _nodeZInputField.y = _loopChangeButton.y;
		_nodeZText.x = _loopStateText.x + _loopStateText.width + 25;
		_nodeZInputField.x = _nodeZText.x + _nodeZText.width;
		_nodeZInputField.addEventListener(
			FocusEvent.FOCUS_OUT,
			function(e):Void {
				if(_currentNode != null)
					_currentNode.effectNode.set_zDepth(Std.parseInt(_nodeZInputField.text));
			}
		);
		
		this.addChild(_nodeZInputField);
		this.addChild(_nodeZText);
		
		
		_animRenderArea = new AnimRenderArea();
		_animRenderArea.setOnTimeChangedProcedure(function(time:Int):Void { _effect.setTime(time); } );
		this.addChild(_animRenderArea);
	}
	
	private function _OnEnterFrame(e:Event):Void{
		
		_isAnimPlaying = _animRenderArea.isPlaying;
		
		if (_isAnimPlaying == false){
			return;
		}
		
		_animRenderArea.setTimeDisp(_effect.getTime());
		
		_hxfectManager.updateAll();
		_animRenderArea.renderAll(_hxfectManager);
		
//		this.graphics.clear();
//		_hxfectManager.updateAll();
//		_hxfectManager.renderAll(this.graphics);
	}
	
	private function _SelectNode(nodeID:Int):Void{
		var nextNode = _nodeTable.get(nodeID);
		
		if (_currentNode != null && _currentNode.nodeID != nextNode.nodeID) {
			_currentNode.deselect();
		}
		_currentNode = nextNode;
		
		_nodeTilePanel.tileID = _currentNode.effectNode.tileID;
		_nodeTilePanel.tileName = _currentNode.effectNode.tileName;
		
		_nodeZInputField.text = Std.string(_currentNode.effectNode.zDepth);
		
		if(_onSelectTileChangedProcedure != null){
			_onSelectTileChangedProcedure(_currentNode.effectNode);
		}
	}
	
	private function _RegisterNewNode(node:HxFectNodeEditable):NodeButton {
		var node = new NodeButton(node, NodeNameIDCounter);
		_nodeTable.set(NodeNameIDCounter, node);
		node.setOnPushedProcedure(_SelectNode);
		NodeNameIDCounter++;
		
		return node;
	}
	
	private function _AddNewNode():Void {
		if (_currentNode == null)
			return;
		
		var node = HxFectNodeEditable.CreateEmptyNode(_effect, _currentNode.effectNode);
		var nodeButton = _RegisterNewNode(node);
		_currentNode.addChildNodeButton(nodeButton);
		
	}
	
	private function _RemoveCurrentNode():Void {
		if (_currentNode == null || _currentNode.nodeID <= 1)
			return;
		
		_nodeTable.remove(_currentNode.nodeID);	
		_currentNode.removeThisNodeButton();
		_currentNode = null;
		
		_nodeTilePanel.reset();
	}
	
	private function _ApplyTile():Void{
		if (_currentNode == null)
			return;
		
		var tile = _tilesheetGetter(_nodeTilePanel.tileName);
		if(tile == null){
			_nodeTilePanel.tileName = "none";
			_currentNode.effectNode.setTileSheet(null,"none",0);
		}else{
			_currentNode.effectNode.setTileSheet(tile,_nodeTilePanel.tileName,_nodeTilePanel.tileID);
		}
		
		_animRenderArea.renderAll(_hxfectManager);
	}
	
	
	public function new() {
		
		super();
		
		_hxfectManager = new HxFectManager();
		_isAnimPlaying = true;
		_nodeTable = new IntMap<NodeButton>();
		
		_effect = HxFectEditable.CreateForEditor(_hxfectManager);
		var rootNode = HxFectNodeEditable.CreateEmptyNode(_effect, null);
		
		_effect.setRootNode(rootNode);
		_hxfectManager.registerEffect(_effect);
		
		var root = _RegisterNewNode(rootNode);
		
		_dummyRootButton = new Sprite();
		_dummyRootButton.addChild(root);
		_dummyRootButton.x = NODEBUTTONS_X;
		this.addChild(_dummyRootButton);
		
		_InitButtons();
		
		_effect.x = _effect.y = AnimRenderArea.RENDERAREA_SIZE / 2;
		
		this.addEventListener(Event.ENTER_FRAME, _OnEnterFrame);
	}
	
	public function updateTile(targetTileName:String,tile:Tilesheet):Void{
		//_currentNode.effectNode.replaceTile(oldName,newName,newTile);
		for (node in _nodeTable) {
			node.effectNode.updateTile(targetTileName,tile);
		}
		_animRenderArea.renderAll(_hxfectManager);
	}
		
	public function setTilesheetGetter(getter:String->Tilesheet):Void{
		_tilesheetGetter = getter;
	}

	public function setOnSelectNodeChangedprocedure(proc:HxFectNodeEditable->Void):Void{
		_onSelectTileChangedProcedure = proc;
	}

	
	private function _ImportNodeTree(data:TextFileReader,parentNode:NodeButton,tileSheetTable: StringMap<Tilesheet>):NodeButton{
		
		var parentEfNode = if (parentNode != null) { parentNode.effectNode; } else { null; };
		var efNode = HxFectNodeEditable.CreateEmptyNode(_effect,parentEfNode);
		
		efNode.name= data.readLine();
		var vals:Array<String> = data.readLine().split(",");
		efNode.setTileSheet(tileSheetTable.get(vals[0]),vals[0],Std.parseInt(vals[1]));
		efNode.set_zDepth(Std.parseInt(vals[2]));
		
		var scalingKF = new OrderedIntMap<Point>();
		var buf = data.readLine();
		if (buf == "[kfScaling]") {
			buf = data.readLine();
			while (buf != "[/kfScaling]") {
				vals = buf.split(",");
				scalingKF.set(Std.parseInt(vals[0]), new Point(Std.parseFloat(vals[1]), Std.parseFloat(vals[2])));
				buf = data.readLine();
			}
		}
		
		var rotationKF = new OrderedIntMap<Float>();
		buf = data.readLine();
		if (buf == "[kfRotation]"){
			buf = data.readLine();
			while(buf != "[/kfRotation]"){
				vals = buf.split(",");
				rotationKF.set(Std.parseInt(vals[0]), Std.parseFloat(vals[1]));
				buf = data.readLine();
			}
		}
		
		var translationKF = new OrderedIntMap<Point>();
		buf = data.readLine();
		if (buf == "[kfTranslation]") {
			buf = data.readLine();
			while(buf != "[/kfTranslation]"){
				vals = buf.split(",");
				translationKF.set(Std.parseInt(vals[0]), new Point(Std.parseFloat(vals[1]), Std.parseFloat(vals[2])));
				buf = data.readLine();
			}
		}
		
		efNode.keyFrame = new KeyFrame(scalingKF, rotationKF, translationKF);
		var nodeButton = _RegisterNewNode(efNode);
		if (parentNode != null ){
			parentNode.addChildNodeButton(nodeButton);
		}else{
			_dummyRootButton.addChild(nodeButton);
		}
		
		buf = data.readLine();
		while(buf != "[/node]"){
			if(buf == "[node]"){
				_ImportNodeTree(data,nodeButton,tileSheetTable);
			}
			buf = data.readLine();
		}
		
		return nodeButton;
	}
	
	public function importFile(data:TextFileReader,tileSheetTable:StringMap<Tilesheet>):Void{
		if (data.readLine() != "[effect]") {
			throw "Invalid token";
		}
		
		_dummyRootButton.removeChild(_dummyRootButton.getChildAt(0));
		
		_hxfectManager.unregisterEffect(_effect);
		
		_nodeTable = new IntMap<NodeButton>();
		_effect = HxFectEditable.CreateForEditor(_hxfectManager);
		_effect.x = _effect.y = AnimRenderArea.RENDERAREA_SIZE / 2;
		
		_hxfectManager.registerEffect(_effect);
		
		var buf = data.readLine();
		_effect.setRoop(buf == "1");
		
		var rootNode : NodeButton = null;
		while (!data.eof() && buf != "[/effect]") {
			buf = data.readLine();
			if(buf == "[node]"){
				rootNode = _ImportNodeTree(data,null,tileSheetTable);
			}
			
		}
		
		_effect.setRootNode(rootNode.effectNode);
	}
	
	public inline function writeOut():String{
		return _effect.writeOut();
	}
}

private class NodeButton extends Sprite{
	
	private static inline var WIDTH = 192;
	private static inline var STEP_DEPTH = 24;
	
	public var effectNode(get, null):HxFectNodeEditable;
	private inline function get_effectNode():HxFectNodeEditable{
		return _refEffectNode;
	}
	
	public var nodeID(get, null):Int;
	private inline function get_nodeID():Int{
		return _nodeID;
	}
	
	private var _nodeNameText:TextField;
	private var _onPusedProcedure : Int->Void;
	
	private var _refEffectNode : HxFectNodeEditable;
	private var _nodeID : Int;
	
	
	public function new(refNode:HxFectNodeEditable, id:Int) {
		
		super();
		
		_nodeNameText = GlobalSetting.createTextField();
		_nodeNameText.autoSize = TextFieldAutoSize.NONE;
		_nodeNameText.width = 150;
		
		_refEffectNode = refNode;
		_nodeID = id;
		
		if(_refEffectNode.name == null || _refEffectNode.name == ""){
			_nodeNameText.text = "NewNode" + id;
			_refEffectNode.name = _nodeNameText.text;
		}else{
			_nodeNameText.text = _refEffectNode.name;
		}
		
		this.addChild(_nodeNameText);
		
		this.addEventListener(Event.REMOVED_FROM_STAGE,_OnRemovedFromStage);
		this.addEventListener(MouseEvent.MOUSE_DOWN, _OnPushed);
		this.addEventListener(KeyboardEvent.KEY_DOWN,_KeyInput);
	}
	
	private function _OnRemovedFromStage(e:Event):Void {
		this.removeEventListener(Event.REMOVED_FROM_STAGE,_OnRemovedFromStage);
		this.removeEventListener(MouseEvent.MOUSE_DOWN, _OnPushed);
		this.removeEventListener(KeyboardEvent.KEY_DOWN,_KeyInput);
	}
	
	private function _OnPushed(e:MouseEvent):Void {
		if(e.target != this._nodeNameText){
			return;
		}
		
		_nodeNameText.backgroundColor = GlobalSetting.PushedButtonColor;
		_nodeNameText.background = true;
		_onPusedProcedure(_nodeID);
	}
	
	private function _KeyInput(e:KeyboardEvent):Void{
		if(e.target != this._nodeNameText){
			return;
		}
		
		if(e.keyCode == Keyboard.BACKSPACE){
			_nodeNameText.text = _nodeNameText.text.substr(0, _nodeNameText.text.length - 1);
		}else if(e.keyCode >= Keyboard.NUMBER_0 && e.keyCode <= Keyboard.Z){
			_nodeNameText.text += String.fromCharCode(e.charCode);
		}
		_refEffectNode.name = _nodeNameText.text;
	}
	
	public function updateRenderPos(container:DisplayObjectContainer):Void { 
		
		if (container.numChildren == 1) {
			container.getChildAt(0).y = 0;
			return;
		}
		
		var nextY:Float = 0;
		for(idx in 0...container.numChildren){
			var child = container.getChildAt(idx);
			child.y = nextY;
			nextY = child.y+child.height;
		}
		
		updateRenderPos(container.parent);
	}
	
	public function addChildNodeButton(childNode:NodeButton):Void{
		childNode.x = STEP_DEPTH;
		childNode.y = this.height;
		this.addChild(childNode);
		
		updateRenderPos(this);
	}
	
	public function removeThisNodeButton():Void{
		var parent = this.parent;
		this.parent.removeChild(this);
		_refEffectNode.removeThisNode();
		
		
		updateRenderPos(parent);
	}
	
	public function deselect():Void{
		_nodeNameText.backgroundColor = GlobalSetting.ButtonColor;
		_nodeNameText.background = true;
	}
	
	public function setOnPushedProcedure(proc:Int->Void):Void{
		_onPusedProcedure = proc;
	}
}


private class NodeTileDataPanel extends Sprite{
	
	public var tileID(get, set):Int;
	private inline function get_tileID():Int{
		return Std.parseInt(_tileIDInputField.text);
	}
	private inline function set_tileID(id:Int):Int{
		_tileIDInputField.text = Std.string(id);
		return id;
	}
	public var tileName(get, set):String;
	private inline function get_tileName():String{
		return _tileNameInputField.text;
	}
	private inline function set_tileName(str:String):String{
		_tileNameInputField.text = str;
		return str;
	}
	
	
	
	private var _tileNameInputField:TextInputField;
	private var _tileIDInputField:NumberInputField;
	
	private var _applyButton : TextButton;
	
	
	public function new(){
		super();
		
		_tileNameInputField = new TextInputField(150);
		_tileIDInputField = new NumberInputField(30);
		
		_applyButton = new TextButton("apply tile");
		
		_applyButton.x = _tileIDInputField.width + 10; 
		_applyButton.y = _tileIDInputField.y = _tileNameInputField.height + 10;
		
		
		this.addChild(_tileNameInputField);
		this.addChild(_tileIDInputField);
		this.addChild(_applyButton);
	}
	
	public function reset():Void{
		_tileIDInputField.text = "0";
		_tileNameInputField.text = "none";
	}
	
	public inline function setOnAppliedProcedure(procedure:Void->Void):Void{
		_applyButton.setPushedProcedure(procedure);
	}
}

private class AnimRenderArea extends Sprite{
	
	public static inline var RENDERAREA_SIZE = 420;
	
	public var isPlaying(default, null):Bool;
	
	private var _checkBackGround : Tilesheet;
	private var _checkDrawData : Array<Float>;
	
	private var _playButton : TextButton;
	private var _stopButton : TextButton;
	private var _timeField  : NumberInputField;
	
	private var _onTimeChangedProcedure : Int->Void;
	
	public function new(){
		super();
		
		isPlaying = false;
		
		_checkBackGround = new Tilesheet(openfl.Assets.getBitmapData("resource/check.png"));
		_checkBackGround.addTileRect(new openfl.geom.Rectangle(0, 0, 384, 384));
		var areaSize = RENDERAREA_SIZE;
		_checkDrawData = [	0	, 0	 , 0, (areaSize/2)/ 384,
							areaSize/2	, 0	 , 0, (areaSize/2) / 384,
							0	, (areaSize/2), 0, (areaSize/2) / 384,
							areaSize/2 , (areaSize/2), 0 ,(areaSize/2) / 384];
		
		_playButton = new TextButton("▲");
		_playButton.setPushedProcedure(
			function():Void{
				isPlaying = true;
			}
		);
		this.addChild(_playButton);
		_stopButton = new TextButton("■");
		_stopButton.setPushedProcedure(
			function():Void{
				isPlaying = false;
			}
		);
		this.addChild(_stopButton);
		
		_timeField = new NumberInputField(50);
		_timeField.addEventListener(openfl.events.FocusEvent.FOCUS_OUT,
			function(e):Void {
				_timeField.text = Std.string(MathUtil.clamp(Std.parseInt(_timeField.text), 0, HxFect.REMAINING_FRAME));
				_onTimeChangedProcedure(Std.parseInt(_timeField.text));
			}
		);
		this.addChild(_timeField);
		
		_stopButton.x = areaSize / 2;
		_stopButton.y = areaSize + 5;
		_playButton.x = _stopButton.x + _stopButton.width + 4;
		_playButton.y = areaSize + 5;
		_timeField.x = _playButton.x + _playButton.width + 4;
		_timeField.y = areaSize + 5;
		
		
		
		_checkBackGround.drawTiles(this.graphics,_checkDrawData,false,Tilesheet.TILE_SCALE);
	}
	
	public inline function setOnTimeChangedProcedure(proc:Int->Void):Void{
		_onTimeChangedProcedure = proc;
	}
	
	public inline function setTimeDisp(time:Int):Void{
		_timeField.text = Std.string(time);
	}
	
	public function renderAll(manager:HxFectManager):Void{
		
		this.graphics.clear();
		
		_checkBackGround.drawTiles(this.graphics, _checkDrawData, false, Tilesheet.TILE_SCALE);
		
		manager.renderAll(this.graphics);
	}
}