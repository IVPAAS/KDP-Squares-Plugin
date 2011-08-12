package com.atarsh.squares {
	import com.kaltura.kdpfl.model.type.NotificationType;
	import com.kaltura.kdpfl.view.media.KMediaPlayer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BitmapFilterType;
	import flash.filters.GradientBevelFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.net.URLRequest;


	/**
	 * This class is the view component for this plugin.
	 * @author Eitan
	 *
	 */
	public class Squares extends Sprite {
		public static const PLAY:String = "play_squares";

		/**
		 * indicating the game is running.
		 */
		public var gameOn:Boolean;
		
		private var _squaresBevel:GradientBevelFilter;

		/**
		 * logical representation of teh game board.
		 * a 2D array holding <code>Square</code> references.
		 */
		private var _board:Array;

		/**
		 * x position of the vacant slot
		 */
		private var _vacantX:int;

		/**
		 * y posistion of the vacant slot
		 */
		private var _vacantY:int;

		/**
		 * the bitmap used for game
		 */
		private var _bitmapData:BitmapData;

		/**
		 * the video object from which to grab the bitmap
		 */
		private var _video:KMediaPlayer;

		/**
		 * means of communication with the KDP
		 */
		private var _mediator:SquaresMediator;

		/**
		 * slot height
		 */
		private var HEIGHT:int = 80;

		/**
		 * slot width
		 */
		private var WIDTH:int = 80;

		/**
		 * number of initial shuffle moves
		 */
		private const MOVES:int = 75;



		public function go(vid:KMediaPlayer):void {
			gameOn = true;
			// disable KDP gui, stop entry from playing, exit fullscreen 
//			_mediator.sendNotification(NotificationType.CLOSE_FULL_SCREEN);
			_mediator.sendNotification(NotificationType.ENABLE_GUI, {guiEnabled: false, enableType: "full"});
			_mediator.sendNotification(NotificationType.DO_PAUSE);

			_video = vid;
			if (getBitmapData()) {
				// go
				initBoard();
				_video.visible = false;
				shuffle();
			}
			else {
				gameOn = false;
				_mediator.sendNotification(NotificationType.ENABLE_GUI, {guiEnabled: true, enableType: "full"});
			}
		}



		/**
		 * create the bitmapdata from the video's current frame,
		 * remove video and relevant listeners and start game
		 * @param event MouseEvent
		 * @return true if got bitmapdata, false otherwise
		 */
		private function getBitmapData(event:MouseEvent = null):Boolean {
			_bitmapData = new BitmapData(_video.width, _video.height, false, 0x000000);
			try {
				_bitmapData.draw(_video);
			} catch (e:Error) {
				trace("Unable to create image: ", e.message); 
				return false;
			}
			HEIGHT = _video.height / 4;
			WIDTH = _video.width / 4;
			return true;
		}



		/**
		 * shuffle Squares
		 */
		private function shuffle():void {
			for (var i:int = 0; i < MOVES; i++) {
				shuffleStep();
			}
		}


		/**
		 * a single shuffle step: select a Square adjacent
		 * to the empty slot and move it.
		 */
		private function shuffleStep():void {
			var isHoriz:Boolean;
			var step:int = -1;
			if (Math.random() > 0.5) {
				isHoriz = true;
			}

			if (isHoriz) {
				if (_vacantX == 0) {
					// move the next tile left
					moveSquareToVacant(_board[1][_vacantY]);
				} else if (_vacantX == 3) {
					// move the next tile right
					moveSquareToVacant(_board[2][_vacantY]);
				} else {
					// select dir
					if (Math.random() > 0.5) {
						step = 1;
					}
					moveSquareToVacant(_board[_vacantX + step][_vacantY]);
				}
			} else {
				if (_vacantY == 0) {
					// move the next tile left
					moveSquareToVacant(_board[_vacantX][1]);
				} else if (_vacantY == 3) {
					// move the next tile right
					moveSquareToVacant(_board[_vacantX][2]);
				} else {
					// select dir
					if (Math.random() > 0.5) {
						step = 1;
					}
					moveSquareToVacant(_board[_vacantX][_vacantY + step]);
				}
			}
		}


		/**
		 * create the Squares
		 */
		private function initBoard():void {
			_vacantX = 3;
			_vacantY = 3;
			_board = new Array();
			var ar:Array;
			var piece:Square;
			var disp:Bitmap;
			for (var i:int = 0; i < 4; i++) {
				ar = new Array();
				_board.push(ar);
				for (var j:int = 0; j < 4; j++) {
					if (i != 3 || j < 3) {
						disp = createSquareGpx(i, j);
						piece = new Square(disp, i, j);
						piece.x = i * WIDTH;
						piece.y = j * HEIGHT;
						piece.xpos = i;
						piece.ypos = j;
						piece.addEventListener(MouseEvent.CLICK, squareClickHandler);
						addChild(piece);
						ar.push(piece);
					}
				}
			}
		}

		/**
		 * create a single square's graphics
		 * @param s	text for the square
		 * */
		private function createSquareGpx(col:int, row:int):Bitmap {
			var bmd:BitmapData = new BitmapData(WIDTH, HEIGHT);
			var pt:Point = new Point(0, 0);
			bmd.copyPixels(_bitmapData, new Rectangle(col * WIDTH, row * HEIGHT, WIDTH, HEIGHT), pt);

			bmd.applyFilter(bmd, new Rectangle(0, 0, WIDTH, HEIGHT), pt, getFilter());

			var mc:Bitmap = new Bitmap(bmd);

			return mc;
		}
		
		
		
		private function getFilter():GradientBevelFilter {
			if (!_squaresBevel) {
				var distance:Number = 5;
				var angleInDegrees:Number = 225; // opposite 45 degrees
				var colors:Array = [0xFFFFFF, 0xCCCCCC, 0x000000];
				var alphas:Array = [0.5, 0, 0.5];
				var ratios:Array = [0, 128, 255];
				var blurX:Number = 8;
				var blurY:Number = 8;
				var strength:Number = 2;
				var quality:Number = BitmapFilterQuality.HIGH
				var type:String = BitmapFilterType.INNER;
				var knockout:Boolean = false;
				
				_squaresBevel = new GradientBevelFilter(distance, angleInDegrees, colors, alphas, ratios, blurX, blurY, strength, quality, type, knockout);
			}
			return _squaresBevel;
		}

		/**
		 * move the given square to the vacant slot
		 * @param sq Square to move
		 */
		private function moveSquareToVacant(sq:Square):void {
			// set board
			_board[sq.xpos][sq.ypos] = null;
			_board[_vacantX][_vacantY] = sq;
			// update tile and _vacs
			var tx:int = _vacantX;
			var ty:int = _vacantY;
			_vacantX = sq.xpos;
			_vacantY = sq.ypos;
			sq.xpos = tx;
			sq.ypos = ty;
			// move graphic
			sq.x = tx * WIDTH;
			sq.y = ty * HEIGHT;
		}


		/**
		 * try to move the clicked square
		 * @param e	MouseEvent
		 */
		private function squareClickHandler(e:MouseEvent):void {
			var sq:Square = e.currentTarget as Square;
			if (canMove(sq)) {
				moveSquareToVacant(sq);
				// check game end
				if (isGameOver()) {
					endGame();
				}
			}
		}

		private function endGame():void {
			for (var i:int = 0; i < 4; i++) {
				for (var j:int = 0; j < 4; j++) {
					if (_board[i][j]) {
						removeChild(_board[i][j]);
						_board[i][j].removeEventListener(MouseEvent.CLICK, squareClickHandler);
					}
				}
			}
			_video.visible = true;
			_mediator.sendNotification(NotificationType.ENABLE_GUI, {guiEnabled: true, enableType: "full"});
		}
		
		public function killGame():void {
			endGame();
			gameOn = false;
		}

		/**
		 * check if the given square is ajdacent to the vacant slot
		 * @param sq	square to test
		 * @return true if the square may move, false otherwise
		 */
		private function canMove(sq:Square):Boolean {
			return (xor(okx(sq), oky(sq)));
		}

		/**
		 * logical xor
		 * @param arg1
		 * @param arg2
		 * @return arg1 XOR arg2
		 */
		private function xor(arg1:Boolean, arg2:Boolean):Boolean {
			return (arg1 && !arg2 || arg2 && !arg1);
		}

		/**
		 * checks if the given square may move horizontaly
		 * @param sq
		 */
		private function okx(sq:Square):Boolean {
			var res:Boolean = sq.xpos == _vacantX + 1 || sq.xpos == _vacantX - 1;
			res &&= sq.ypos == _vacantY;
			return res;
		}

		/**
		 * checks if the given square can move vertiacally
		 * @param sq
		 */
		private function oky(sq:Square):Boolean {
			var res:Boolean = sq.ypos == _vacantY + 1 || sq.ypos == _vacantY - 1;
			res &&= sq.xpos == _vacantX;
			return res;
		}

		/**
		 * checks if all squares are in their correct positions
		 * @return true if game finished successfully, false otherwise
		 */
		private function isGameOver():Boolean {
			var res:Boolean = true;
			for (var i:int = 0; i < 4; i++) {
				for (var j:int = 0; j < 4; j++) {
					if (_board[i][j] && !(_board[i][j] as Square).isGood()) {
						res = false;
					}
				}
			}
			return res;
		}

		public function get mediator():SquaresMediator {
			return _mediator;
		}

		public function set mediator(value:SquaresMediator):void {
			_mediator = value;
		}
	}
}