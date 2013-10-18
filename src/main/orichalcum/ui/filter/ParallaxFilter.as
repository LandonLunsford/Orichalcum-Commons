package orichalcum.ui.filter
{
	import flash.display.DisplayObject;
	
	public class ParallaxFilter
	{
		/**
		 * Applies the parallax effect on an ordered collection of layers
		 * @param	layers Array of DisplayObjects
		 * @param	focusX The x coordinate between 0 and the provided width (usually stage.mouseX)
		 * @param	focusY The y coordinate between 0 and the provided height (usually stage.mouseY)
		 * @param	width The width of the vieport desired (usually stage.stageWidth)
		 * @param	height The height of the vieport desired (usually stage.stageheight)
		 * @example	stage.addEventListener(Event.ENTER_FRAME, function(event:Event):void {
		 * 			_parralaxFilter.apply([layerA, layerB], stage.mouseX, stage.mouseY, stage.stageWidth, stage.stageHeight);
		 *		});
		 */
		public function apply(layers:Array, focusX:Number, focusY:Number, width:Number, height:Number):void
		{
			for each(var layer:DisplayObject in layers)
			{
				if (layer)
				{
					layer.x = -(focusX / width) * (layer.width - width);
					layer.y = -(focusY / height) * (layer.height - height);
				}
			}
		}
	}
}
