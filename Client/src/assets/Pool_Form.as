package assets {
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	import data.Config;	
	import gameentity.Ball;	
	import services.GameClient;		
	import social.SocialNetwork;		
	import assets.*;	
	import classes.*;
	import flash.system.System;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	
	
	
	public class Pool_Form extends MovieClip {
		public var poolName:Object;
		public var poolWarning:TextField;
		public var date:Date;
		public var submitDate:TextField;
		
	public function Pool_Form() {
		Add_PoolType();	
		date = new Date();
		date.toDateString();
		submitDate = new TextField();
		var dateSize:TextFormat = new TextFormat();
		dateSize.size = 17;
		dateSize.bold;
		submitDate.x = 130;
		submitDate.y = 255;
		submitDate.height = 25;
		submitDate.defaultTextFormat = dateSize;
		//var today:String = (date.day.toString());
		//var tomonth:String = (date.month.toString());
		var year:String = date.fullYear.toString();		
		var day = date.getDay()+2;
		var month = date.getMonth()+1;
		submitDate.text =  month + "/" + day +"/" + year;
		addChild(submitDate);
	}
		
	function Add_PoolType():void{				
		
		poolName.addEventListener(KeyboardEvent.KEY_UP, poolNameAndDescriptionCheck);
		Description.addEventListener(KeyboardEvent.KEY_UP, DescriptionCheck);
		poolAmount.addEventListener(KeyboardEvent.KEY_UP, poolAmountCheck);
		
		poolType.addItem ( {label:"Full bracket"} );
		poolType.addItem ( {label:"Top 16"} );
		poolType.addItem ( {label:"Top 8"} );
		poolType.addItem ( {label:"Top 4"} );
	}
	
	function poolNameAndDescriptionCheck(e:KeyboardEvent):void{
		
		if(e.keyCode < 65 || e.keyCode > 122)
		{
			
			poolWarning = new TextField;
			poolWarning.width = 250;
			poolWarning.height = 20;
			poolWarning.x = 130;
			poolWarning.y = 45;
			poolWarning.text = "Kindly enter characters from a-z or A-Z";			
			addChild(poolWarning);				
		}
		
	}
	
	function DescriptionCheck(e:KeyboardEvent):void{
		if(e.keyCode < 65 || e.keyCode > 122)
		{
			poolWarning = new TextField;
			poolWarning.width = 250;
			poolWarning.height = 20;
			poolWarning.x = 130;
			poolWarning.y = 95;
			poolWarning.text = "Kindly enter characters from a-z or A-Z";
			addChild(poolWarning);
		}
	}
	
	function poolAmountCheck(e:KeyboardEvent):void{
		if(e.keyCode < 48 || e.keyCode > 57)
		{
			poolWarning = new TextField;
			poolWarning.width = 250;
			poolWarning.height = 20;
			poolWarning.x = 130;
			poolWarning.y = 230;
			poolWarning.text = "Kindly enter characters from 0-9";
			addChild(poolWarning);
		}
	}
	
	
  
  }
	
}
