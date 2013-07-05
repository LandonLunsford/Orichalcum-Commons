package orichalcum.animation.tweener.plugin.displayobject 
{
	import flash.display.DisplayObject;
	import flash.filters.BlurFilter;
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.utility.FunctionUtil;
	
	public class BlurFilterTweener implements ITweener
	{
		static public const properties:Array = ['blur', 'blurX', 'blurY'];
		
		private var _tweenFunction:Function = FunctionUtil.NULL;
		private var _filterIndex:int = -1;
		private var _filter:Object;
		private var _start:Number;
		private var _delta:Number;
		
		/* INTERFACE orichalcum.animation.tweener.ITweener */
		
		public function initialize(target:Object, property:String, from:Object, to:Object, fromValueIfAny:*, toValueIfAny:*):void 
		{
			if (!(target is DisplayObject)) return;
			
			const filters:Array = target.filters;
			for (var i:int = 0; i < filters.length; i++)
			{
				var filter:BlurFilter = filters[i];
				if (filter)
				{
					_filterIndex = i;
					_filter = filter;
				}
			}
			
			if (_filterIndex < 0)
			{
				_filterIndex = filters.length;
				_filter = new BlurFilter(0, 0, 1);
			}
			
			const propertyInFilter:Boolean = property in _filter;
			
			_start = fromValueIfAny is Number
				? fromValueIfAny
				: propertyInFilter
					? _filter[property]
					: _filter.blurX;
					
			_delta = (toValueIfAny is Number
				? toValueIfAny
				: propertyInFilter
					? _filter[property]
					: _filter.blurX) - _start;
					
			_tweenFunction = propertyInFilter ? tweenBlurProperty : tweenBlur;
		}
		
		public function tween(target:Object, property:String, progress:Number):* 
		{
			return _tweenFunction(target, property, progress);
		}
		
		public function tweenBlur(target:Object, property:String, progress:Number):*
		{
			_filter.blurX = _filter.blurY = _start + _delta * progress;
			applyFilter(target);
		}
		
		public function tweenBlurProperty(target:Object, property:String, progress:Number):*
		{
			_filter[property] = _start + _delta * progress;
			applyFilter(target);
		}
		
		protected function applyFilter(target:Object):void
		{
			const filters:Array = target.filters;
			filters[_filterIndex] = _filter;
			target.filters = filters;
		}
		
	}

}
