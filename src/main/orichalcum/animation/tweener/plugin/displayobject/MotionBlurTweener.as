package orichalcum.animation.tweener.plugin.displayobject 
{
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.utility.FunctionUtil;
	
	
	/**
	 * This is great but it should really be a function working in parallel to tweening
	 * since tweening can be started and stopped.
	 * The major problem is the blur that remains at the end of the tween
	 */
	public class MotionBlurTweener implements ITweener
	{
		static public const properties:Array = ['motionBlur'];
		
		private var _filterIndex:int = -1;
		private var _filter:Object;
		private var _previousX:Number;
		private var _previousY:Number;
		private var _scale:Number = 1;
		private var _maximum:Number = Number.MAX_VALUE;
		
		/* INTERFACE orichalcum.animation.tweener.ITweener */
		
		public function initialize(target:Object, property:String, from:Object, to:Object, fromValueIfAny:*, toValueIfAny:*):void 
		{
			const filters:Array = target.filters;
			if (_filterIndex < 0)
			{
				_filterIndex = filters.length;
				_filter = new BlurFilter(0, 0, 1);
			}
			
			_previousX = target.x;
			_previousY = target.y;
			
			const settings:* = fromValueIfAny != null ? fromValueIfAny : toValueIfAny;
			if (typeof(settings) === 'object')
			{
				if ('scale' in settings) _scale = settings.scale;
				if ('max' in settings) _maximum = settings.max;
			}
		}
		
		public function tween(target:Object, property:String, progress:Number):* 
		{
			_filter.blurX = Math.min(Math.abs((target.x - _previousX) * _scale), _maximum);
			_filter.blurY = Math.min(Math.abs((target.y - _previousY) * _scale), _maximum);
			
			// hotfix
			if (progress < 0.001 || progress > 0.999)
				_filter.blurX = _filter.blurY = 0;
			
			applyFilter(target);
			_previousX = target.x;
			_previousY = target.y;
		}
		
		protected function applyFilter(target:Object):void
		{
			const filters:Array = target.filters;
			filters[_filterIndex] = _filter;
			target.filters = filters;
		}
		
	}

}
