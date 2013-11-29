package assets {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	
	import services.GameClient;
	
	import social.SocialNetwork;
	
	
	public class Menu_Bar extends MovieClip {
		private var timer:Timer;
		private var timeForTimer:Number = 10 * 1000; // polls every 30 seconds	
		
		public function Menu_Bar() {
					
		}
					
		public function startPolling():void{
			timer = new Timer(timeForTimer, 1000);			
			timer.addEventListener(TimerEvent.TIMER, pollInvites);
			timer.start();			
		}
		
		public function pollInvites(e:TimerEvent):void{
			var gClient:GameClient = GameClient.getInstance();
			var keyForInvites = SocialNetwork.getCurrentId();			
			if(keyForInvites==null){
				//do nothing
			}
			else{
				keyForInvites = keyForInvites + ":inviteInbox";
				gClient.loadGame(keyForInvites, onLoadInvites);
			}
		}		
		private function onLoadInvites(inbox:Object):void{
			if(inbox != false){
				var inboxSize = inbox.invitations.length;
					
				var samplebtn_doc:DisplayObjectContainer;
				var labelsamplebtn:TextField;			
			
				samplebtn_doc = inviteBtn.inviteButton.upState as DisplayObjectContainer;
				labelsamplebtn = samplebtn_doc.getChildAt(3) as TextField;
				labelsamplebtn.text = inboxSize;			
			
				samplebtn_doc = inviteBtn.inviteButton.downState as DisplayObjectContainer;
				labelsamplebtn = samplebtn_doc.getChildAt(3) as TextField;
				labelsamplebtn.text = inboxSize;			
			
				samplebtn_doc = inviteBtn.inviteButton.overState as DisplayObjectContainer;
				labelsamplebtn = samplebtn_doc.getChildAt(3) as TextField;
				labelsamplebtn.text = inboxSize;	
			}
		}
	}
	
}
