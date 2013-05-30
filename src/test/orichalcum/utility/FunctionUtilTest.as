package orichalcum.utility
{
	import org.hamcrest.assertThat;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.isTrue;
	import org.hamcrest.object.nullValue;
	import org.hamcrest.object.strictlyEqualTo;


	public class FunctionUtilTest 
	{
		
		[Test]
		public function safeCall_context():void
		{
			const _this:* = this;
			FunctionUtil.safeCall(function():void {
				assertThat(_this, strictlyEqualTo(this));
			}, this);
		}
		
		[Test]
		public function safeCall_exactArgs():void
		{
			FunctionUtil.safeCall(function(a:Boolean = false, b:int = -1):void {
				assertThat(a, isTrue());
				assertThat(b, equalTo(1));
			}, this, true, 1);
		}
		
		[Test]
		public function safeCall_tooLittleArgs():void
		{
			FunctionUtil.safeCall(function(a:Boolean = false, b:int = -1):void {
				assertThat(a, isTrue());
				assertThat(b, equalTo(-1));
			}, this, true);
		}
		
		[Test]
		public function safeCall_tooManyArgs():void
		{
			FunctionUtil.safeCall(function(a:Boolean = false, b:int = -1):void {
				assertThat(a, isTrue());
				assertThat(b, equalTo(1));
				assertThat(arguments.length == arguments.callee.length);
			}, this, true, 1, 2);
		}
		
	}

}