package orichalcum.datastructure.comparison 
{

	public class NumberComparator implements IComparator
	{
		
		public function compare(a:*, b:*):int
		{
			const numberA:Number = Number(a);
			const numberB:Number = Number(b);
			
			if (numberA < numberB) return -1;
			if (numberA > numberB) return 1;
			return 0;
		}
		
	}

}