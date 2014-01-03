package orichalcum.signals
{
	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;
	import orichalcum.signals.ISignal;
	import orichalcum.signals.Signal;
	
	public class SignalTest 
	{
		
		[Test]
		public function create():void
		{
			const signal:ISignal = new Signal;
		}
		
		/**
		 * Covers:
		 * totalListeners
		 * hasListeners
		 */
		[Test]
		public function empty():void
		{
			const signal:ISignal = new Signal;
			
			assertThat(signal.hasListeners, isFalse());
			assertThat(signal.totalListeners, equalTo(0));
		}
		
		/**
		 * Covers:
		 * addListener
		 * totalListeners
		 * hasListeners
		 * hasListener
		 */
		[Test]
		public function addListener():void
		{
			const signal:ISignal = new Signal;
			const listener:Function = function():void {};
			
			signal.addListener(listener);
			
			assertThat(signal.totalListeners, equalTo(1));
			assertThat(signal.hasListeners, isTrue());
			assertThat(signal.hasListener(listener), isTrue());
		}
		
		/**
		 * Covers:
		 * removeListener
		 * totalListeners
		 * hasListeners
		 * hasListener
		 */
		[Test]
		public function removeListener():void
		{
			const signal:ISignal = new Signal;
			const listener:Function = function():void {};
			
			signal.addListener(listener);
			signal.removeListener(listener);
			
			assertThat(signal.totalListeners, equalTo(0));
			assertThat(signal.hasListeners, isFalse());
			assertThat(signal.hasListener(listener), isFalse());
		}
		
		[Test]
		public function callOnce():void
		{
			const signal:ISignal = new Signal;
			const state:Object = { };
			const listener:Function = function():void { state.listenerCalled = !state.listenerCalled; };
			
			signal.addListener(listener).callOnce();
			signal.dispatch();
			signal.dispatch();
			
			assertThat(state.listenerCalled, isTrue());
		}
		[Test]
		public function callTwice():void
		{
			const signal:ISignal = new Signal;
			const state:Object = { };
			const listener:Function = function():void { state.listenerCalled = !state.listenerCalled; };
			
			signal.addListener(listener);
			signal.dispatch();
			signal.dispatch();
			
			assertThat(state.listenerCalled, isFalse());
		}
		
		[Test]
		public function dispatch_zeroArguments_zeroArgumentListener():void
		{
			const signal:ISignal = new Signal;
			const state:Object = { };
			const listener:Function = function():void { state.listenerCalled = true; };
			
			signal.addListener(listener);
			signal.dispatch();
			
			assertThat(state.listenerCalled, isTrue());
		}
		
		[Test(expects="Error")]
		public function dispatch_zeroArguments_oneArgumentListener():void
		{
			const signal:ISignal = new Signal;
			const listener:Function = function(arg1:*):void {};
			
			signal.addListener(listener);
			signal.dispatch();
		}
		
		[Test]
		public function dispatch_untypedOneArgument_oneArgumentListener():void
		{
			const signal:ISignal = new Signal(null);
			const state:Object = { };
			const listener:Function = function(arg1:*):void { state.arg1 = arg1; };
			
			signal.addListener(listener);
			signal.dispatch(5);
			
			assertThat(state.arg1, equalTo(5));
		}
		
		[Test]
		public function dispatch_typedArguments_multipleArgumentListener():void
		{
			const signal:ISignal = new Signal(
				Object,
				Function,
				Class,
				Array,
				int,
				Number,
				uint
			);
			const state:Object = { };
			const listener:Function = function(
				arg1:Object,
				arg2:Function,
				arg3:Class,
				arg4:Array,
				arg5:int,
				arg6:Number,
				arg7:uint
			):void {
				state.arg1 = arg1;
				state.arg2 = arg2;
				state.arg3 = arg3;
				state.arg4 = arg4;
				state.arg5 = arg5;
				state.arg6 = arg6;
				state.arg7 = arg7;
			};
			
			const arg1:Object = { };
			const arg2:Function = function():void { };
			const arg3:Class = Array;
			const arg4:Array = [];
			const arg5:int = int.MIN_VALUE;
			const arg6:Number = 1.0;
			const arg7:uint = uint.MAX_VALUE;
			
			signal.addListener(listener);
			signal.dispatch(arg1, arg2, arg3, arg4, arg5, arg6, arg7);
			
			assertThat(state.arg1, equalTo(arg1));
			assertThat(state.arg2, equalTo(arg2));
			assertThat(state.arg3, equalTo(arg3));
			assertThat(state.arg4, equalTo(arg4));
			assertThat(state.arg5, equalTo(arg5));
			assertThat(state.arg6, equalTo(arg6));
			assertThat(state.arg7, equalTo(arg7));
		}
		
		[Test(expects="Error")]
		public function argumentCountMismatch_tooLittleArgumentsDispatched():void
		{
			const signal:ISignal = new Signal(int);
			const listener:Function = function(arg1:Function):void { };
			
			signal.addListener(listener);
			signal.dispatch();
		}
		
		[Test(expects="Error")]
		public function argumentCountMismatch_tooManyArgumentsDispatched():void
		{
			const signal:ISignal = new Signal(int, int);
			const listener:Function = function(arg1:Function):void { };
			
			signal.addListener(listener);
			signal.dispatch(1, 2);
		}
		
		[Test(expects="Error")]
		public function argumentTypeMismatch():void
		{
			const signal:ISignal = new Signal(Function);
			const listener:Function = function(arg1:Function):void { };
			
			signal.addListener(listener);
			signal.dispatch(5);
		}
		
		[Test(expects="Error")]
		public function argumentCountMismatch_listenerAcceptsTooManyArguments():void
		{
			const signal:ISignal = new Signal();
			const listener:Function = function(arg1:Function):void { };
			
			signal.addListener(listener);
			signal.dispatch();
		}
		
		[Test(expects="Error")]
		public function argumentCountMismatch_listenerAcceptsTooLittleArguments():void
		{
			const signal:ISignal = new Signal();
			const listener:Function = function(arg1:Function):void { };
			
			signal.addListener(listener);
			signal.dispatch();
		}
		
		[Test]
		public function concurrentListenerRemoval_removedListenerIsBeforeRemover():void
		{
			const signal:ISignal = new Signal();
			const state:Object = { called0:0, called1:0, called2:0 };
			const listener0:Function = function():void { state.called0++; };
			const listener1:Function = function():void { state.called1++; signal.removeListener(listener0); };
			const listener2:Function = function():void { state.called2++; };
			
			signal.addListener(listener0);
			signal.addListener(listener1);
			signal.addListener(listener2);
			signal.dispatch();
			signal.dispatch();
			
			assertThat(state.called0, equalTo(1));
			assertThat(state.called1, equalTo(2));
			assertThat(state.called2, equalTo(2));
		}
		
		[Test]
		public function concurrentListenerRemoval_removedListenerIsRemover():void
		{
			const signal:ISignal = new Signal();
			const state:Object = { called0:0, called1:0, called2:0 };
			const listener0:Function = function():void { state.called0++; };
			const listener1:Function = function():void { state.called1++; signal.removeListener(listener1); };
			const listener2:Function = function():void { state.called2++; };
			
			signal.addListener(listener0);
			signal.addListener(listener1);
			signal.addListener(listener2);
			signal.dispatch();
			signal.dispatch();
			
			assertThat(state.called0, equalTo(2));
			assertThat(state.called1, equalTo(1));
			assertThat(state.called2, equalTo(2));
		}
		
		[Test]
		public function concurrentListenerRemoval_removedListenerIsAfter():void
		{
			const signal:ISignal = new Signal();
			const state:Object = { called0:0, called1:0, called2:0 };
			const listener0:Function = function():void { state.called0++; };
			const listener1:Function = function():void { state.called1++; signal.removeListener(listener2); };
			const listener2:Function = function():void { state.called2++; };
			
			signal.addListener(listener0);
			signal.addListener(listener1);
			signal.addListener(listener2);
			signal.dispatch();
			signal.dispatch();
			
			assertThat(state.called0, equalTo(2));
			assertThat(state.called1, equalTo(2));
			assertThat(state.called2, equalTo(0));
		}
	}

}