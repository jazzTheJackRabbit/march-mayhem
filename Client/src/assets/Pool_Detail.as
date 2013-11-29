package assets {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import classes.*;
	import assets.*;
	
	public class Pool_Detail extends MovieClip {
		public var poolName:String;
		private var poolAmount:uint;
		private var poolDescription:String;
		private var poolType:String;
		private var submitDate:String;	
		
	public function Pool_Detail() {
			
	}
		
	public function showPoolProperties(poolName:String, poolDescription:String, poolAmount:String, poolType:String, submitDate:String):void{
		fullPoolDetail.appendText("Pool Name :-\t" +poolName+ "\n" + "\n" + "Pool Description :-\t"+ poolDescription + "\n" + "\n" + "Pool Type :-\t" + poolType + "\n" + "\n" + "Pool Amount :-\t" + poolAmount + "\n" + "\n" + "Submit Date :\t" + submitDate);
		
	}
	
  }
	
}
