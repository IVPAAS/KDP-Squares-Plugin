package com.atarsh.squares
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.external.ExternalInterface;
	import flash.text.TextField;

	public class Square extends Sprite
	{
		/**
		 * piece's x position 
		 */		
		public var xpos:int;
		
		private var _ypos:int;
		/**
		 * piece's y position 
		 */		
		public function set ypos(val:int):void {
			_ypos = val;
//			((this.getChildAt(0) as Sprite).getChildAt(0) as TextField).text = xpos + ", " + val;
		}
		
		public function get ypos():int {
			return _ypos;
		}
		
		private var _xcorrect:int;
		private var _ycorrect:int;
		
		
		public function Square(disp:DisplayObject, xx:int, yy:int)
		{
			_xcorrect = xx;
			_ycorrect = yy;
			addChild(disp);
		}
		
		public function isGood():Boolean {
			return xpos == _xcorrect && ypos == _ycorrect;
		}

		public function get xcorrect():int
		{
			return _xcorrect;
		}

		public function get ycorrect():int
		{
			return _ycorrect;
		}

//		public function get text():String {
//			return ((this.getChildAt(0) as Sprite).getChildAt(0) as TextField).text;
//		}

	}
}