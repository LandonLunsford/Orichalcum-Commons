package orichalcum.animation 
{
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	import orichalcum.animation.tweener.BooleanTweener;
	import orichalcum.animation.tweener.ITweener;
	import orichalcum.animation.tweener.NumberTweener;
	import orichalcum.core.Core;
	import orichalcum.utility.FunctionUtil;
	
	/**
	 * Abstract animation class
	 * 	subclasses and differences:
	 * 	_AnimationTimeline
	 * 		.stagger(time) // this will add stagger to all its children
	 * 		//- ease ?
	 * 	_AnimationTween
	 * 		.to(values)
	 * 		.from(values)
	 * 		
	 */
	public class Animation extends AnimationBase
	{
		
		/** The duration in milliseconds for all animations if the animation's duration is not explicitly set **/
		static public var durations:Object = { slow:800, normal:400, fast:200 };
		
		/** The duration in milliseconds for all animations if the animation's duration is not explicitly set **/
		static public var defaultDuration:Number = durations.normal;
		
		/** The easing function used for all animations if the animation's ease is not explicitly set **/
		static public var defaultEase:Function = Ease.quadOut;
		
		/** If true, all animations will be paused **/
		static public var pauseAll:Boolean;
		
		/** @private */
		static private const _tweenersByProperty:Object = {};
		
		/** @private */
		static private const _tweenersByClass:Object = {'Boolean': BooleanTweener, 'Number': NumberTweener, 'int': NumberTweener, 'uint': NumberTweener};
		
		/** @private */
		private var _children:Array = [];
		
		/** @private no wrapper class holding this for efficiency only */
		private var _childrenStartPositions:Array = [];
		
		/** @private */
		private var _insertionTime:Number = 0;
		
		/** @private */
		private var _previousEndTime:Number = 0;
		
		
		static public function install(tweener:Class, triggers:*):void
		{
			if (tweener == null)
			{
				throw new ArgumentError('Argument "tweener" passed to method "install" of class "orichalcum.animation.Tween" must not be null.');
			}
			else if (triggers is String)
			{
				_tweenersByProperty[triggers] = tweener;
			}
			else if (triggers is Class)
			{
				_tweenersByClass[getQualifiedClassName(triggers)] = tweener;
			}
			else if (triggers is Array || triggers is Vector.<String>)
			{
				for each(var trigger:String in triggers)
					install(tweener, trigger);
			}
			else
			{
				throw new ArgumentError('Argument "tweener" passed to method "install" of class "orichalcum.animation.Tween" must be one of the following types: String, Class, Array, Vector.<String>, Vector.<Class>.');
			}
		}
		
		/** @private */
		static internal function _createTweener(propertyName:String, propertyValue:*):ITweener
		{
			const tweenerForProperty:Class = _tweenersByProperty[propertyName];
			if (tweenerForProperty) return new tweenerForProperty;
			
			const tweenerForClass:Class = _tweenersByClass[getQualifiedClassName(propertyValue)];
			if (tweenerForClass) return new tweenerForClass;
			
			return null;
		}
		
		public function Animation(animations:Array = null)
		{
			_construct(animations);
		}
		
		/////////////////////////////////////////////////////////////////////////////////
		// Private Parts
		/////////////////////////////////////////////////////////////////////////////////
		
		private function _construct(animations:Array):void 
		{
			for each(var input:* in animations)
			{
				if (input is Number)
				{
					var waitTime:Number = input;
					_insertionTime = isNaN(input) ? _previousEndTime : _insertionTime + waitTime;
				}
				else if (input is AnimationBase)
				{
					add(input as AnimationBase);
				}
			}
		}
		
		public function add(animation:AnimationBase, time:Number = NaN):Animation 
		{
			const insertionTime:Number = isNaN(time) ? _insertionTime : time;
			const endTime:Number = insertionTime + animation._duration;
			
			_childrenStartPositions.push(insertionTime);
			_children.push(animation);
			
			_previousEndTime = endTime;
			if (_duration < endTime)
				_duration = endTime;
			
			trace('adding', animation, 'at time', insertionTime, 'ending', endTime);
			
			return this;
		}
		
		/////////////////////////////////////////////////////////////////////////////////
		// Overrides
		/////////////////////////////////////////////////////////////////////////////////
		
		override protected function _integrate(event:Event = null):void 
		{
			// need better way to proxy this over rewriting
			// need to do backwards if running in reverse too doofy
			
			super._integrate(event);
			
			var index:int, count:int = _children.length, step:int;
			if (_position > _previousPosition)
			{
				index = 0;
				step = 1;
			}
			else
			{
				index = count - 1;
				step = -1;
			}
			
			for (; count-- > 0; index += step)
			{
				
				
				var child:AnimationBase = _children[index];
				
				
				//trace('integrating', child, index);
				/**
				 * I need some kind of interface here, IAnimatable
				 * .duration
				 * .target
				 * .ease
				 * .render()
				 */
				
				child && _isPlaying && child._render(_position - _childrenStartPositions[index] + (_useFrames ? 1 : Core.deltaTime) * _timeScale * _step * (_yoyo ? 2 : 1), false, true, _target != AnimationBase.NULL_TARGET ? _target : child._target, _ease != null ? _ease : child._ease);
				
				
			}
			
		}
		
		//override protected function _renderTarget(target:Object, progress:Number, isStart:Boolean, isEnd:Boolean):void
		//{
			// abstract
			
		//}
		
	}

}
