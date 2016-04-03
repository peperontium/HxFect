package hxfect.editor.panel;

import hxfect.KeyFrame;
import hxfect.editor.HxFectNodeEditable;
import haxe.ds.IntMap;
import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;

/**
 * ...
 * @author peperontium
 */
class KeyFramePanel extends Sprite{

	private static inline var KFTYPE_SCALING = 0;
	private static inline var KFTYPE_ROTATION = 1;
	private static inline var KFTYPE_TRANSLATION = 2;
	
	
	private var _keyFrame : KeyFrame;
	
	private var _scalingBar : KeyFrameBar;
	private var _rotationBar : KeyFrameBar;
	private var _translationBar : KeyFrameBar;
	
	private var _timeField :NumberInputField;
	private var _timeAddButton : TextButton;
	private var _timeDeclButton : TextButton;
	
	
	private function _RemoveKF(kfType:Int):Int{
		if (_keyFrame == null)
			return -1;
		
		var time:Int = Std.parseInt(_timeField.text);
		
		switch(kfType){
			case KFTYPE_SCALING:
				if(_keyFrame._scaling.exists(time)){
					_keyFrame._scaling.remove(time);
				}
				
			case KFTYPE_ROTATION:
				if(_keyFrame._rotation.exists(time)){
					_keyFrame._rotation.remove(time);
				}
				
			case KFTYPE_TRANSLATION:
				if(_keyFrame._translation.exists(time)){
					_keyFrame._translation.remove(time);
				}
				
		}
		
		_UpdateKFsDisp();
		
		return time;
	}
	
	private function _AddKF(kfType:Int,values:Array<Float>):Int{
		if (_keyFrame == null)
			return -1;
		
		var time:Int = Std.parseInt(_timeField.text);
		
		switch(kfType){
			case KFTYPE_SCALING:
				_keyFrame._scaling.set(time,new Point(values[0],values[1]));
				
			case KFTYPE_ROTATION:
				_keyFrame._rotation.set(time,values[0]);
				
			case KFTYPE_TRANSLATION:
				_keyFrame._translation.set(time,new Point(values[0],values[1]));
				
		}
		
		return time;
	}
	
	private function _UpdateKFsDisp():Void{
		if (_keyFrame == null)
			return;
		
		//時間変わったら各きーふれ更新。あればね
		var time = Std.parseInt(_timeField.text);
		
		
		//	最低一つは基準のキーフレームを残す
		var sc:Point = if(_keyFrame._scaling.exists(time)){_keyFrame._scaling.get(time);}else{new Point(0,0);};
		_scalingBar.updateKFDisplay([sc.x, sc.y]);
		
		var rot:Float = if(_keyFrame._rotation.exists(time)){_keyFrame._rotation.get(time);}else{0;};
		_rotationBar.updateKFDisplay([rot]);
		
		var trans:Point = if(_keyFrame._translation.exists(time)){_keyFrame._translation.get(time);}else{new Point(0,0);};
		_translationBar.updateKFDisplay([trans.x,trans.y]);
	}
	
	private function _AddTime():Void{
		var time = Std.parseInt(_timeField.text);
		
		_timeField.text = Std.string(Math.min(time+1, HxFect.REMAINING_FRAME));
		_UpdateKFsDisp();
	}
	
	private function _DeclTime():Void{
		var time = Std.parseInt(_timeField.text);
		
		_timeField.text = Std.string(Math.max(time-1, 0));
		_UpdateKFsDisp();
	}
	
	public function new() {
		super();
		
		_keyFrame = null;
		
		
		_timeField = new NumberInputField(30);
		_timeField.addEventListener(openfl.events.FocusEvent.FOCUS_OUT,
			function(e):Void {
				_timeField.text = Std.string(MathUtil.clamp(Std.parseInt(_timeField.text),0,HxFect.REMAINING_FRAME));
				_UpdateKFsDisp();
				}
		);
		_timeAddButton = new TextButton(" + ");
		_timeAddButton.setPushedProcedure(_AddTime);
		_timeDeclButton = new TextButton(" - ");
		_timeDeclButton.setPushedProcedure(_DeclTime);
		
		_timeDeclButton.x = 30;
		_timeField.x = _timeDeclButton.x + _timeDeclButton.width + 5;
		_timeAddButton.x = _timeField.x + _timeField.width + 5;
		
		this.addChild(_timeDeclButton);
		this.addChild(_timeField);
		this.addChild(_timeAddButton);
		
		
		_scalingBar = new KeyFrameBar(" S ",2);
		_rotationBar = new KeyFrameBar(" R ",1);
		_translationBar = new KeyFrameBar(" T ",2);
		
		_scalingBar.y = _timeField.height + 10;
		_rotationBar.y = _scalingBar.y + _scalingBar.height + 5;
		_translationBar.y = _rotationBar.y + _rotationBar.height + 5;
		
		_scalingBar.setOnModifiedProcedures(this._AddKF.bind(KFTYPE_SCALING,_),this._RemoveKF.bind(KFTYPE_SCALING));
		_scalingBar.setOnFrameChangedProcedure(setCurrentFrame);
		_rotationBar.setOnModifiedProcedures(this._AddKF.bind(KFTYPE_ROTATION,_),this._RemoveKF.bind(KFTYPE_ROTATION));
		_rotationBar.setOnFrameChangedProcedure(setCurrentFrame);
		_translationBar.setOnModifiedProcedures(this._AddKF.bind(KFTYPE_TRANSLATION,_),this._RemoveKF.bind(KFTYPE_TRANSLATION));
		_translationBar.setOnFrameChangedProcedure(setCurrentFrame);
		
		this.addChild(_scalingBar);
		this.addChild(_rotationBar);
		this.addChild(_translationBar);
	}
	
	public function setCurrentFrame(frame:Int):Void{
		
		_timeField.text = Std.string(frame);
		_UpdateKFsDisp();
	}
	
	public function setKF(node:HxFectNodeEditable):Void {
		_keyFrame = node.keyFrame;
		_scalingBar.resetMarkers(_keyFrame._scaling.keys());
		_rotationBar.resetMarkers(_keyFrame._rotation.keys());
		_translationBar.resetMarkers(_keyFrame._translation.keys());
		_UpdateKFsDisp();
	}
	
	
}

private class KeyFrameBar extends Sprite{
	
	private static inline var NUMBER_FIELD_WIDTH = 65;
	private static inline var KEYFRAME_MARKER_WIDTH = 8;
	
	private static var SharedMarkerBitmapData : BitmapData = null;
	
	
	private var _markerPutBeginX : Float;
	
	private var _barName: TextField;
	private var _markers : IntMap<Bitmap>;
	
	private var _numberInputFields : Array<NumberInputField>;
	private var _addButton 		: TextButton;
	private var _removeButton 	: TextButton;
	
	
	private var _onKFAddedProcedure : Array<Float>->Int;
	private var _onKFRemovedProcedure : Void->Int;
	
	private var _onMarkerClickedProcedure : Int->Void;
	
	
	private function _OnMouseClicked(e:MouseEvent):Void{
		if(e.localX > _markerPutBeginX){
			
			var frame:Int = Math.floor((e.localX-_markerPutBeginX)/KEYFRAME_MARKER_WIDTH);
			if(_onMarkerClickedProcedure != null){
				_onMarkerClickedProcedure(frame);
			}
		}
	}
	
	public function new(name:String,numKFvalues:Int) {
		
		super();
		
		this.addEventListener(MouseEvent.MOUSE_UP,_OnMouseClicked);
		
		_barName = GlobalSetting.createTextField();
		_barName.autoSize = TextFieldAutoSize.LEFT;
		_barName.text = name;
		
		_markers = new IntMap<Bitmap>();
		
		
		_numberInputFields = new Array<NumberInputField>();
		var fieldWidth = (NUMBER_FIELD_WIDTH - numKFvalues * 2 + 2) / numKFvalues;
		var nextX:Float = 30;
		for (idx in 0...numKFvalues) {
			_numberInputFields.push(new NumberInputField(fieldWidth));
			_numberInputFields[idx].x = nextX;
			nextX += fieldWidth + 2;
		}
		
		_removeButton = new TextButton(" - ");
		_removeButton.x = NUMBER_FIELD_WIDTH + 34;
		_addButton = new TextButton(" + ");
		_addButton.x = _removeButton.x + _removeButton.width+4;
		
		this.addChild(_barName);
		for(field in _numberInputFields){
			this.addChild(field);
		}
		this.addChild(_addButton);
		this.addChild(_removeButton);
		
		
		
		_markerPutBeginX = _addButton.x + _addButton.width + 6;
		
		if(SharedMarkerBitmapData == null){
			SharedMarkerBitmapData = new BitmapData(KEYFRAME_MARKER_WIDTH, Std.int(_barName.height),false,0xff99cc);
//			SharedMarkerBitmapData = Assets.getBitmapData("resource/marker.png");
		}
	}
	
	public function updateKFDisplay(kfValues:Array<Float>):Void{
		
		for(idx in 0..._numberInputFields.length)
			_numberInputFields[idx].text = Std.string(kfValues[idx]);
	}
	
	private inline function _AddMarker(frame:Int):Void{
		
		var bmp = new Bitmap(SharedMarkerBitmapData);
		bmp.x = (frame*KEYFRAME_MARKER_WIDTH) + _markerPutBeginX;
		bmp.scaleX = KEYFRAME_MARKER_WIDTH / SharedMarkerBitmapData.width;
		bmp.scaleY = _addButton.height / SharedMarkerBitmapData.height;
		_markers.set(frame, bmp);
		this.addChild(bmp);
	}
	
	private inline function _RemoveMarker(frame:Int):Void{
		var bmp = _markers.get(frame);
		_markers.remove(frame);
		this.removeChild(bmp);
	}
	
	private function _OnAddPushedProcedure():Void {
		
		var values = new Array<Float>();
		
		for(numField in _numberInputFields.iterator()){
			values.push(Std.parseFloat(numField.text));
		}
		
		var addedFrame : Int = _onKFAddedProcedure(values);
		if (addedFrame == -1 || _markers.exists(addedFrame))
			return;
		
		//	新規登録の場合のみマーカー追加
		_AddMarker(addedFrame);
	}
	
	private function _OnRemovePushedProcedure():Void{
		
		var removedFrame:Int = _onKFRemovedProcedure();
		if (removedFrame == -1)
			return;
			
		if (_markers.exists(removedFrame)) {
			_RemoveMarker(removedFrame);
		}
	}
	
	public function setOnModifiedProcedures(addedProc:Array<Float>->Int,removedProc:Void->Int):Void{
		_onKFAddedProcedure = addedProc;
		_onKFRemovedProcedure = removedProc;
		
		_addButton.setPushedProcedure(_OnAddPushedProcedure);
		_removeButton.setPushedProcedure(_OnRemovePushedProcedure);
	}
	
	public inline function setOnFrameChangedProcedure(proc:Int->Void):Void{
		_onMarkerClickedProcedure = proc;
	}

	public function resetMarkers(kfFrames:Iterator<Int>):Void{
		for(frame in _markers.keys()){
			_RemoveMarker(frame);
		}
		
		for(frame in kfFrames){
			_AddMarker(frame);
		}
	}
}
