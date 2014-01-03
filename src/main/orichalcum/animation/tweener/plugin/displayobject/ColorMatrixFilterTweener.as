package orichalcum.animation.tweener.plugin.displayobject
{
	import flash.filters.ColorMatrixFilter;
	import orichalcum.animation.tweener.ITweener;

	public class ColorMatrixFilterTweener implements ITweener
	{
		
		static public const properties:Array = ['colorMatrix'];
		static private const IDENTITY:Array = [
			1, 0, 0, 0, 0,
			0, 1, 0, 0, 0,
			0, 0, 1, 0, 0,
			0, 0, 0, 1, 0
		];
		
		private var _filterIndex:int = -1;
		private var _filter:ColorMatrixFilter;
		private var _from:Array = [];
		private var _to:Array = [];
		
		public function initialize(target:Object, property:String, from:Object, to:Object, fromValueIfAny:*, toValueIfAny:*):void 
		{
			
			_from = fromValueIfAny ? fromValueIfAny : IDENTITY.concat();
			_to = toValueIfAny ? toValueIfAny : IDENTITY.concat();
			const filters:Array = target.filters;
			if (_filterIndex < 0)
			{
				_filterIndex = filters.length;
				_filter = new ColorMatrixFilter;
			}
		}
		
		public function tween(target:Object, property:String, progress:Number):* 
		{
			const matrix:Array = _filter.matrix;
			for (var i:int = 0; i < _from.length; i++)
			{
				matrix[i] = _from[i] + (_to[i] - _from[i]) * progress;
			}
			_filter.matrix = matrix;
			
			const filters:Array = target.filters;
			filters[_filterIndex] = _filter;
			target.filters = filters;
		}
		
	}

}
