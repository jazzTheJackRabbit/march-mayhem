package gameentity {
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class Ball extends MovieClip{
		var gravity:Number=0.5;
		var divide:Number = 6;
		var prevx:Number;
		var prevy:Number;
		public var addx:Number=0;
		public var addy:Number=0;
		public var done:Boolean;
		public function Ball() {
			// constructor code
		}


		public function init():void {
			done=false;
			//trace(this.parent.parent.parent);
			addx = addx/divide;
			addy = addy/divide;
			prevx = x;
			prevy = y;
			this.addEventListener(Event.ENTER_FRAME, moveit);
		}
		private function moveit(e:Event):void {
			
			addy = addy+gravity/divide;
			rotation = Math.atan2(addy, addx)*180/3.141593;
			for (var i:Number=0; i<divide; i++) {
				prevx = prevx+addx;
				prevy = prevy+addy;
				x = prevx;
				y = prevy;
			}
			if(y>0){
				x=-33;
				y=-69;
				this.removeEventListener(Event.ENTER_FRAME, moveit);
				done=true;
			}
		}
	}
	
}
