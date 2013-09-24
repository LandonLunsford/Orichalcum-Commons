package orichalcum.io 
{

	public class KeyboardManager 
	{
		
		static private var _instance:KeyboardManager;
		
		static public function getInstance():KeyboardManager
		{
			return _instance ||= new KeyboardManager;
		}
		
		public function KeyboardManager() 
		{
			
		}
		
	}

}