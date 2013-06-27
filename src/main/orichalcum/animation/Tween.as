package orichalcum.animation 
{
	import flash.display.Shape;
	import orichalcum.animation.tweener.ITweener;

	public class Tween extends Animation 
	{
		
		protected var _to:Object;
		protected var _from:Object;
		protected var _tweeners:Object;
		
		public function Tween(target:Object = null) 
		{
			this.target(target);
		}
		
		public function to(...args):*
		{
			return args.length ? _setTo(args[0]) : _to;
		}
		
		public function from(...args):*
		{
			return args.length ? _setFrom(args[0]) : _to;
		}
		
		private function _setTo(value:Object):Tween 
		{
			_to = value;
			return this;
		}
		
		private function _setFrom(value:Object):Tween 
		{
			_from = value;
			return this;
		}
		
		override protected function _initialize(isJump:Boolean, callback:Function):void
		{
			_initialized = true;
			
			const from:Object = _from ? _from : _target;
			const to:Object = _to ? _to : _target;
			
			if (to === from) return;
			
			const values:Object = _to ? _to : _from;
			
			for (var property:String in values)
			{
				_tweeners ||= {};
				
				const tweener:ITweener = _tweeners[property] ||= Animation._createTweener(property, _target[property]);
				
				// boolean tween bug where start isnt set dynamically when in to
				if (tweener)
				{
					/** the property in? fork fills in the blank for assumed things left out of the other param list **/
					tweener.init(
						property in from ? from[property] : _target[property]
						,to[property]
					);
				}
			}
			
			callback(isJump);
		}
		
		// AnimationTimeline should override this and target each child
		override protected function _renderTarget(target:Object, progress:Number, isStart:Boolean, isEnd:Boolean):void
		{
			target is Shape && trace('rendering', target, 'progress', progress);
			
			for (var property:String in _tweeners)
			{
				target[property] = _tweeners[property].tween(target, property, progress, isStart, isEnd);
			}
			
		}
		
	}

}
