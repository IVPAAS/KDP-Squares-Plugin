package
{
	import com.kaltura.kdpfl.plugin.IPlugin;
	import com.kaltura.kdpfl.plugin.IPluginFactory;
	import com.atarsh.squares.Squares;
	import com.atarsh.squares.SquaresMediator;

	import fl.core.UIComponent;

	import flash.display.DisplayObject;
	import flash.system.Security;

	import org.puremvc.as3.interfaces.IFacade;

	public class squaresGamePlugin extends UIComponent implements IPluginFactory, IPlugin
	{

		private var _squaresMediator:SquaresMediator;

		public function squaresGamePlugin() {
			Security.allowDomain("*");
		}

		/**
		 * This function creates an instance of visualDemoCode, which is the actual plugin.
		 * This way KDP can create multiple instances of the same class.
		 * @param pluginName	name of a plugin. used to differentiate between different
		 * 						instances of the same plugin.
		 * @return 	instance of the actual plugin class.
		 *
		 */
		public function create(pluginName:String=null):IPlugin {
			return this;
		}

		/**
		 *
		 * this function creates initialize the new plugin. it pushes all the inialization params into the the mediator
		 * @param facade
		 * @return
		 *
		 */
		public function initializePlugin(facade:IFacade):void {
			var sqs:Squares = new Squares();
			//create the mediator
			_squaresMediator = new SquaresMediator(sqs);
			// Register the mediator with the PureMVC facade
			facade.registerMediator(_squaresMediator);
			// add the plugin's view to the displayList
			addChild(sqs);
		}


		/**
		 * KDP calls this interface method in order to set the plugin's skin.
		 * This plugin has no skin, so the implementation is empty.
		 * @param styleName		name of style to be set
		 * @param setSkinSize
		 */
		public function setSkin(styleName:String, setSkinSize:Boolean=false):void {}

	}
}