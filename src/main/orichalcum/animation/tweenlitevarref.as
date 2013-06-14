import com.orihalcum.process.Tween;



delay : Number Amount of delay in seconds (or frames for frames-based tweens) before the tween should begin.
useFrames : 
ease : 
easeParams :
onInit : Function A function that should be called just before the tween inits (renders for the first time). Since onInit runs before the start/end values are recorded internally, it is a good place to run code that affects the target's initial position or other tween-related properties. onStart, by contrast, runs AFTER the tween inits and the start/end values are recorded internally. onStart is called every time the tween begins which can happen more than once if the tween is restarted multiple times.
onStart : Function A function that should be called when the tween begins (when its currentTime is at 0 and changes to some other value which can happen more than once if the tween is restarted multiple times).
onUpdate : Function A function that should be called every time the tween's time/position is updated (on every frame while the timeline is active)
onComplete : Function A function that should be called when the tween has finished
onReverseComplete : Function A function that should be called when the tween has reached its starting point again after having been reversed.
onRepeat : Function A function that should be called every time the tween repeats

immediateRender : Boolean Normally when you create a tween, it begins rendering on the very next frame (when the Flash Player dispatches an ENTER_FRAME event) unless you specify a delay.
This allows you to insert tweens into timelines and perform other actions that may affect its timing.
However, if you prefer to force the tween to render immediately when it is created,
set immediateRender to true.
Or to prevent a tween with a duration of zero from rendering immediately, set this to false.

paused : Boolean If true, the tween will be paused initially.
reversed : Boolean If true, the tween will be reversed initially.
This does not swap the starting / ending values in the tween - it literally changes its orientation / direction.

Imagine the playhead moving backwards instead of forwards.
This does NOT force it to the very end and start playing backwards.
It simply affects the orientation of the tween, so if reversed is set to true initially, it will appear not to play because it is already at the beginning.
To cause it to play backwards from the end, set reversed to true and then set the currentProgress property to 1 immediately after creating the tween (or set the currentTime to the duration).

overwrite : int Controls how (and if) other tweens of the same target are overwritten by this tween. There are several modes to choose from, and TweenMax automatically calls OverwriteManager.init() if you haven't already manually dones so, which means that by default AUTO mode is used (please see http://www.greensock.com/overwritemanager/ for details and a full explanation of the various modes):
repeat : int Number of times that the tween should repeat. To repeat indefinitely, use -1.
repeatDelay : Number Amount of time in seconds (or frames for frames-based tween) between repeats.
yoyo : Boolean Works in conjunction with the repeat property, determining the behavior of each cycle. When yoyo is true, the tween will go back and forth, appearing to reverse every other cycle (this has no affect on the "reversed" property though). So if repeat is 2 and yoyo is false, it will look like: start - 1 - 2 - 3 - 1 - 2 - 3 - 1 - 2 - 3 - end. But if repeat is 2 and yoyo is true, it will look like: start - 1 - 2 - 3 - 3 - 2 - 1 - 1 - 2 - 3 - end.
startAt : Object Allows you to define the starting values for each property.
Typically, TweenMax uses the current value (whatever it happens to be at the time the tween begins) as the start value, but startAt allows you to override that behavior.
Simply pass an object in with whatever properties you'd like to set just before the tween begins. For example, if mc.x is currently 100, and you'd like to tween it from 0 to 500,
do TweenMax.to(mc, 2, { x:500, startAt: { x:0 }} );

// note tweenlite does not fire onInit until frame event, therefore I shouldnt set position directly at .play() execution time

// FROM
// is 0 to 100
// 100 - 0
// is 50 to 100
// 100 - 50
// is 100 to 100
// 100 - 100
Tween.from(target, 5, { x: 100 } )
new Tween(target, 4, {x:100, from:true})
// !!! whenever invoked memorize current position and set tweeeners end to current and tweeners start to vars
// operation needs to occur at init time -- this will directly conflict with startAt
// in my API I will only have from[:Boolean,:Object] so from:true, from:false, from:{x:0}

// TO
// is 0 to 100
// 100 - 0
// is 50 to 100
// 50 - 100
// is 100 to 100
// 100 - 100
Tween.to(target, 5, { x: 100 } )

// I want to create another tween that delegates delay to timeline.delay().to().from() animation.delay(x).from(0).play(); -- pass animation as object for transition callback
if (this.showAnimation)
{
	this.showAnimation.target = this;
	this.showAnimation.play();
}
