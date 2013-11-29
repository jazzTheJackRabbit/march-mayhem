package classes
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import classes.*;
	import assets.*;
	

	public class Pool_Entity extends MovieClip{		
		public var pool_Name:String;
		public var pool_Amount:uint;
		public var pool_Description:String;
		public var pool_Type:String;
		public var submit_Date:String;		
		
		public function Pool_Entity(){
		}
		
		public function setPoolProperties(poolName:String,poolType:String,poolDescription:String,poolAmount:String,submitDate:String):void{
			pool_Name = poolName; 
			pool_Description = poolDescription;
			pool_Type = poolType;
			pool_Amount = (uint)(poolAmount);			
			submit_Date = submitDate;			
		}
	}
} 