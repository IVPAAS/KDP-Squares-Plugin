package com.atarsh.squares {
	import com.kaltura.kdpfl.component.ComponentData;
	import com.kaltura.kdpfl.model.LayoutProxy;
	import com.kaltura.kdpfl.model.type.NotificationType;
	import com.kaltura.kdpfl.view.media.KMediaPlayer;
	
	import flash.display.DisplayObject;
	import flash.media.Video;
	import flash.utils.getQualifiedClassName;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * This class is the mediator for this plugin. it mediates between this plugin and the 
	 * the KDP application according to the PureMVC framework.
	 * @author Eitan
	 */
	public class SquaresMediator extends Mediator {
		
		/**
		 * Mediator name. <br>
		 * The mediator will be registered with this name with the application facade
		 */		
		public static const NAME:String = "SquaresMediator";
		
		
		/**
		 * Constructor.
		 * @param viewComponent		the view component for this mediator
		 * 
		 */
		public function SquaresMediator(viewComponent:Object = null) {
			this.viewComponent = viewComponent;
			view.mediator = this;
			super(NAME,viewComponent);
		}

		
		/**
		 * This function lists the notifications to which the plugin will respond.  
		 * @return 	notifications list
		 * 
		 */
		override public function listNotificationInterests():Array {
			var notify:Array = [Squares.PLAY];
			return notify;
		}

		
		/**
		 * This function handles received notifications  
		 * @param note		notification
		 * 
		 */
		override public function handleNotification(note:INotification):void {
			var data:Object = note.getBody();
			switch (note.getName()) {
				case Squares.PLAY:
					if (view.gameOn) {
						view.killGame();
					}
					else {
						view.go(getVideoObject());
					}
				break;
			}
		}

		public function getVideoObject():KMediaPlayer {
			var lp:LayoutProxy = facade.retrieveProxy(LayoutProxy.NAME) as LayoutProxy;
			var vid:Object = lp.FindCompByName("video");
			return vid.ui;
		}
		
		/**
		 * visualDemoCode calls this method when it changes plugin size.
		 * If you need to do something when resizing - add it here.
		 * @param w		new width
		 * @param h		new height
		 * 
		 */		
		public function setScreenSize(w:Number, h:Number):void {
			view.width = w;
			view.height = h;
			
		}
		
		
		/**
		 * a reference to this mediator's view component.
		 */		
		public function get view():Squares {
			return viewComponent as Squares;
		}
	}
}