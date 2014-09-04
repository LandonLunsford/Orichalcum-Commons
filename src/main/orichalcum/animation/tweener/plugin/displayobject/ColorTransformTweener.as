package orichalcum.animation.tweener.plugin.displayobject 
{
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.animation.tweener.NumberTweener;
	import orichalcum.utility.Functions;
	import orichalcum.utility.Mathematics;

	public class ColorTransformTweener implements ITweener
	{
		
		static public const properties:Array = ['tint', 'redMultiplier', 'greenMultiplier', 'blueMultiplier', 'alphaMultiplier', 'redOffset', 'greenOffset', 'blueOffset', 'alphaOffset'];
		private var _tweenFunction:Function = Functions.NULL;
		private var _start:int;
		private var _end:int;
		
		private function tintOfColorTransform(t:ColorTransform):int
		{
			const a:int = Mathematics.limit(1 - t.redMultiplier, 0, 1);
			const r:int = Mathematics.limit(t.redOffset * a, -0xff, 0xff);
			const g:int = Mathematics.limit(t.greenOffset * a, -0xff, 0xff);
			const b:int = Mathematics.limit(t.blueOffset * a, -0xff, 0xff);
			return a * 0xff << 24 | r << 16 | g << 8 | b;
		}
		
		public function initialize(target:Object, property:String, from:Object, to:Object, fromValueIfAny:*, toValueIfAny:*):void 
		{
			if (!(target is DisplayObject)) return;
			
			const t:ColorTransform = target.transform.colorTransform;
			const propertyInTransform:Boolean = property in t;
			
			_start = fromValueIfAny is Number
				? fromValueIfAny
				: propertyInTransform
					? t[property]
					: tintOfColorTransform(t);
			
			_end = toValueIfAny is Number
				? toValueIfAny
				: propertyInTransform
					? t[property]
					: tintOfColorTransform(t);
			
			_tweenFunction = propertyInTransform ? _tweenTransform : _tweenTint;
			
			//trace('toValueIfAny', toValueIfAny)
			//trace('start', _start.toString(16));
			//trace('end', _end.toString(16));
		}
		
		public function tween(target:Object, property:String, progress:Number):* 
		{
			return _tweenFunction(target, property, progress);
		}
		
		protected function _tweenTint(target:Object, property:String, progress:Number):*
		{
			const t:ColorTransform = target.transform.colorTransform;
			const a:uint = _start >> 24 & 0xff;
			const r:uint = _start >> 16 & 0xff;
			const g:uint = _start >> 8 & 0xff;
			const b:uint = _start & 0xff;
			t.alphaOffset = a + ((_end >> 24 & 0xff) - a) * progress;
			t.redOffset = r + ((_end >> 16 & 0xff) - r) * progress;
			t.greenOffset = g + ((_end >> 8 & 0xff) - g) * progress;
			t.blueOffset = b + ((_end & 0xff) - b) * progress;
			// works in some cases and not in others
			//t.alphaOffset = (_start >> 24 & 0xff) + ((_delta >> 24 & 0xff)) * progress;
			//t.redOffset = (_start >> 16 & 0xff) + ((_delta >> 16 & 0xff)) * progress;
			//t.greenOffset = (_start >> 8 & 0xff) + ((_delta >> 8 & 0xff)) * progress;
			//t.blueOffset = (_start & 0xff) + ((_delta & 0xff)) * progress;
			t.redMultiplier = t.greenMultiplier = t.blueMultiplier = 1 - t.alphaOffset / 0xff;
			target.transform.colorTransform = t;
		}
		
		protected function _tweenTransform(target:Object, property:String, progress:Number):*
		{
			const t:ColorTransform = target.transform.colorTransform;
			t[property] = _start + (_end - _start) * progress;
			target.transform.colorTransform = t;
		}
		
	}

}
