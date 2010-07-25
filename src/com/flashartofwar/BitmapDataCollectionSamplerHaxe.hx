/**
 *  Haxe memory scrolling version of BitmapDataCollectionSampler
 * 
 * @author Glenn Ko
 */

package com.flashartofwar;

import flash.display.BitmapData;
import flash.display.Sprite;
import flash.Error;
import flash.geom.Rectangle;
import flash.Memory;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.Vector;


class BitmapDataCollectionSamplerHaxe extends Sprite
{
	
	var _totalLength:Int;
	var _breath:Int;
	function getTotalLength():Int {
		return _totalLength;
	}
	function getTotalLengthInBytes():Int {
		return _totalLength << 2;
	}
	function getBreath():Int {
		return _breath;
	}
	var _internalBmpData:BitmapData;
	var _internalBuffer:ByteArray;
	
	static inline var ALREADY_ROTATED:Bool = false;
	
	/** Set this to a custom memory address if needed */
	public var mem_offset:Int;
	
	public function new() 
	{
		super();
		_totalLength = 0;
		_breath = 0;
		mem_offset = 0;
	}
	
	public function getBitmapData():BitmapData {
		return _internalBmpData;
	}
	
	/**
	 * PostConstruct method to initialise data collection and bitmapdata into memory
	 * @param	collection
	 * @param	sampleArea
	 */
	public function init(collection:Vector<BitmapData>, sampleArea:Rectangle) {
		var bmd:BitmapData;
		if (collection.length < 1) throw new Error("Empty bitmapdata collection!");
		
		var calcTotalLength:Int = 0;
		for (i in 0...collection.length) {
			bmd = collection[i];
			calcTotalLength += bmd.width;
      
			if (bmd.height != sampleArea.height) {
				throw new Error("Sorry, no rescaling routine at the moment");
				// need to rescale to fit bounds
			}
			
		}
		_totalLength = calcTotalLength;
		var w:Int;
		var h:Int;
		#if ALREADY_ROTATED 
			w = Std.int(sampleArea.width);
			h = Std.int(sampleArea.height);
		#else
			w = Std.int(sampleArea.height);
			h = Std.int(sampleArea.width);
		#end
		_internalBmpData = new BitmapData(w , h, false, 0);
		_breath = w;
		
		_internalBuffer = new ByteArray();
		_internalBuffer.length = (_totalLength * _breath) << 2;  
		
		_internalBuffer.endian = Endian.LITTLE_ENDIAN;
		_internalBuffer.position = 0;
	
		Memory.select(_internalBuffer);
		
		var lastX:Int = 0;
		
		for (i in 0...collection.length) {
			bmd = collection[i];
			copyPixelsOf(bmd, lastX);
			lastX += bmd.width; 
			
		}
	}
	
	inline function copyPixelsOf(srcBitmapData:BitmapData, positionPx:Int):Void {
		#if ALREADY_ROTATED 
		// Best case scenerio, read from 1 dimensional vector (but convering to vector isn't exactly best case)
		var vec:Vector<UInt> = srcBitmapData.getVector(srcBitmapData.rect);
			var counter:Int = getPositionAddressOf(positionPx);
			var len:Int = vec.length;
			for (v in 0...len) {
				Memory.setI32(counter, Std.int(vec[v]));
				counter += 4;
				
			}		
		#else
			// Worse case scenerio , read in 2 dimensions 
			var h:Int = srcBitmapData.height;
			var w:Int = srcBitmapData.width;
			for (v in 0...h) {
				for (u in 0...w) {
					setPixelMemAt(v , positionPx+u, srcBitmapData.getPixel(u, v) );
				}
			}
		#end
	}
	
	inline function setPixelMemAt(xVal:Int, yVal:Int, color:UInt):Void {
		Memory.setI32( (( yVal * _breath + xVal )) << 2, color);
	}
	
	inline function getPositionAddressOf(positionPixels:Int):Int {  // to add custom direction
		return mem_offset + ( Std.int(positionPixels * _internalBmpData.width ) << 2);
	}
	
	
	public function sample(positionPixels:Int):Void {
		_internalBmpData.lock();
		ApplicationDomain.currentDomain.domainMemory.position =getPositionAddressOf(positionPixels);
		_internalBmpData.setPixels(_internalBmpData.rect, ApplicationDomain.currentDomain.domainMemory);
		_internalBmpData.unlock();
	}
	
	
	
}