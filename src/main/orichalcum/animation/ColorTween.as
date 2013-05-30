package orichalcum.animation
{
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	
	/**
	 * @TODO API upgrade -- less object creation
	 * @example Tween.to(target, 12, {redOffset:-255, redMultiplier:255});
	 * @example Tween.to(target, 24, {colorOffset:-0xffbbaa});
	 * 	-- equates to {redOffset:-0xff, greenOffset:-0xbb, blueOffset:-0xaa}
	 * 
	 * @NOTE if object's colorTransform has not been initialized all multiplier values default to 0
	 * 
	 * @author Landon Lunsford
	 */
	
	public class ColorTween extends Tween
	{
		/** @OPTIMIZATION **/
		private var _to_alphaMultiplier:Number;
		private var _to_redMultiplier:Number;
		private var _to_greenMultiplier:Number;
		private var _to_blueMultiplier:Number;
		private var _to_alphaOffset:Number;
		private var _to_redOffset:Number;
		private var _to_greenOffset:Number;
		private var _to_blueOffset:Number;
		private var _from_alphaMultiplier:Number;
		private var _from_redMultiplier:Number;
		private var _from_greenMultiplier:Number;
		private var _from_blueMultiplier:Number;
		private var _from_alphaOffset:Number;
		private var _from_redOffset:Number;
		private var _from_greenOffset:Number;
		private var _from_blueOffset:Number;
		
		public function ColorTween(colorTransform:ColorTransform, target:DisplayObject, duration:Number, vars:Object = null)
		{
			super(target, duration, vars);
			
			_to_alphaMultiplier = colorTransform.alphaMultiplier;
			_to_redMultiplier = colorTransform.redMultiplier;
			_to_greenMultiplier = colorTransform.greenMultiplier;
			_to_blueMultiplier = colorTransform.blueMultiplier;
			_to_alphaOffset = colorTransform.alphaOffset;
			_to_redOffset = colorTransform.redOffset;
			_to_greenOffset = colorTransform.greenOffset;
			_to_blueOffset = colorTransform.blueOffset;
		}

		override public function reverse():void
		{
			super.reverse();
			
			var temporary:Number;
			temporary = _from_alphaMultiplier;
			_from_alphaMultiplier = _to_alphaMultiplier;
			_to_alphaMultiplier = temporary;
			temporary = _from_redMultiplier;
			_from_redMultiplier = _to_redMultiplier;
			_to_redMultiplier = temporary;
			temporary = _from_greenMultiplier;
			_from_greenMultiplier = _to_greenMultiplier;
			_to_greenMultiplier = temporary;
			temporary = _from_blueMultiplier;
			_from_blueMultiplier = _to_blueMultiplier;
			_to_blueMultiplier = temporary;
			temporary = _from_alphaOffset;
			_from_alphaOffset = _to_alphaOffset;
			_to_alphaOffset = temporary;
			temporary = _from_redOffset;
			_from_redOffset = _to_redOffset;
			_to_redOffset = temporary;
			temporary = _from_greenOffset;
			_from_greenOffset = _to_greenOffset;
			_to_greenOffset = temporary;
			temporary = _from_blueOffset;
			_from_blueOffset = _to_blueOffset;
			_to_blueOffset = temporary;
		}

		override protected function initialize():void
		{
			super.initialize();
			
			const colorTransform:ColorTransform = target.transform.colorTransform;
			_from_alphaMultiplier = colorTransform.alphaMultiplier;
			_from_redMultiplier = colorTransform.redMultiplier;
			_from_greenMultiplier = colorTransform.greenMultiplier;
			_from_blueMultiplier = colorTransform.blueMultiplier;
			_from_alphaOffset = colorTransform.alphaOffset;
			_from_redOffset = colorTransform.redOffset;
			_from_greenOffset = colorTransform.greenOffset;
			_from_blueOffset = colorTransform.blueOffset;
		}
		
		override protected function render():void
		{
			super.render();
			
			const colorTransform:ColorTransform = target.transform.colorTransform;
			const progress:Number = getProgress(0, 1);
			colorTransform.alphaOffset = _from_alphaOffset + (_to_alphaOffset - _from_alphaOffset) * progress;
			colorTransform.redOffset = _from_redOffset + (_to_redOffset - _from_redOffset) * progress;
			colorTransform.greenOffset = _from_greenOffset + (_to_greenOffset - _from_greenOffset) * progress;
			colorTransform.blueOffset = _from_blueOffset + (_to_blueOffset - _from_blueOffset) * progress;
			target.transform.colorTransform = colorTransform;
		}

	}

}
