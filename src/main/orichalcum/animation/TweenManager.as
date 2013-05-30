package orichalcum.animation 
{
	import com.orichalcum.constants.Ease;
	import com.orichalcum.utility.ObjectUtil;
	import flash.display.DisplayObject;
	import flash.geom.ColorTransform;

	public class TweenManager 
	{
		
		public function to(target:Object, duration:Number = 0, vars:Object = null):Tween
		{
			var tween:Tween;
			if (isColorTween(target, vars))
			{
				tween = new ColorTween(vars.colorTransform, target as DisplayObject, duration, vars);
			}
			else
			{
				tween = new Tween(target, duration, vars);
			}
			tween.start();
			return tween;
		}
		
		public function from(target:Object, duration:Number = 0, vars:Object = null):Tween
		{
			if (isColorTween(target, vars))
			{
				const colorTransform:ColorTransform = target.transform.colorTransform;
				target.transform.colorTransform = vars.colorTransform;
				vars.colorTransform = colorTransform;
			}
			return to(target, duration, ObjectUtil.swap(vars, target));
		}
		
		private function isColorTween(target:Object, vars:Object = null):Boolean
		{
			return vars && vars.colorTransform && target as DisplayObject;
		}
		
	}

}