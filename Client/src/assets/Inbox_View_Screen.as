package assets{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.sendToURL;
	import flash.text.TextField;
	
	import services.GameClient;
	
	import social.SocialNetwork;

	public class Inbox_View_Screen extends MovieClip{
		
		private var selectedInvite:Object;
		private var selectedInviteForInbox:Object;
		
		public function Inbox_View_Screen(){
			datagrid.columns = ["From","Pool Name","Pool Amount"];			
		}
		
		public function getInvites(){
			var gClient:GameClient = GameClient.getInstance();
			var keyForLoad:String = SocialNetwork.getCurrentId();
			if(keyForLoad == null){				
				var seeInvite:Inbox_Click_Here = new Inbox_Click_Here();
				seeInvite["information"] = new Object;
																		
				seeInvite.information["poolOwnerName"] = "NOT CONNECTED";
				seeInvite.information["poolName"] = "TO THE";
				seeInvite.information["poolAmount"] = "INTERNET";
				seeInvite.information["poolId"] = "1";
				
				var dataItem:Object = new Object;		
				dataItem["From"] = seeInvite.information.poolOwnerName;
				dataItem["Pool Name"] = seeInvite.information.poolName;
				dataItem["Pool Amount"] = seeInvite.information.poolAmount;
				dataItem["Pool Id"] = seeInvite.information.poolId;
							
				datagrid.addItem(dataItem);				
				datagrid.addEventListener(Event.CHANGE, pullJoinPrompt);
				trace(dataItem["Pool Id"]);
			}
			else{
				keyForLoad = keyForLoad+":inviteInbox";
				gClient.loadGame(keyForLoad,onInviteInboxLoad);				
			}
		}			
		
		function onInviteInboxLoad(result:Object):void{			
			var inbox:Object = result;
			if(inbox.invitations.length == 0){		
				//no invites
			}
			else{
				var count:int = 1;
				var seeInvite:Inbox_Click_Here;
				for each(var invite:Object in inbox.invitations){													
					
					var dataItem:Object = new Object;		
					
					dataItem["Pool Type"] = invite.details.poolType;
					dataItem["Pool Id"] = invite.details.poolId;
					dataItem["Pool Submit Date"] = invite.details.poolSubmitDate;
					dataItem["Pool Amount"] = invite.details.poolAmount;
					dataItem["Pool Owner Id"] = invite.details.poolOwnerId;		
					dataItem["Pool Name"] = invite.details.poolName;
					dataItem["Pool Description"] = invite.details.poolDescription;
					dataItem["From"] = invite.details.poolOwnerName;
					dataItem["Friends In Pool"] = invite.details.friendsInPool;
					
					datagrid.addItem(dataItem);				
					datagrid.addEventListener(Event.CHANGE, pullJoinPrompt);
				}
			}			
		}
		
		function pullJoinPrompt(event:Event):void{
			selectedInvite = event.target.selectedItem;
			if(selectedInvite!=null){
				var joinPrompt:Join_Prompt = new Join_Prompt();	
				joinPrompt.message.text = "Do you want to accept "+selectedInvite.From+"'s pool ["+selectedInvite["Pool Name"]+"] invitation?";				
			}		
			addChild(joinPrompt);
			joinPrompt.acceptButton.addEventListener(MouseEvent.CLICK, acceptInvite);
			joinPrompt.rejectButton.addEventListener(MouseEvent.CLICK, closePrompt);
		}
		
		private function acceptInvite(e:MouseEvent):void{						
			//get friend's pool's friend list
				//load
			//push to  friend's pool's friend list
				//save
			
			//load my allPools
			var gClient:GameClient = GameClient.getInstance();
			var keyForLoad:String = SocialNetwork.getCurrentId();
			if(keyForLoad == null){
				//not connected to the internet				
			}
			else{
				keyForLoad = keyForLoad + ":allPools";
				gClient.loadGame(keyForLoad, pushJoinedPool)
			}								
			removeChild(e.target.parent);
			datagrid.removeItem(selectedInvite);
		}
		
		private function pushJoinedPool(result:Object):void
		{
			var allMyPools:Object = result;			
			//push the pool to my allPools array
			var inviteAllPoolFormat:Object = new Object;					
			
			//convert datagrid format to allPools format
			inviteAllPoolFormat["poolType"] = selectedInvite["Pool Type"] ;
			inviteAllPoolFormat["poolId"] = selectedInvite["Pool Id"] ;
			inviteAllPoolFormat["poolSubmitDate"] = selectedInvite["Pool Submit Date"] ;
			inviteAllPoolFormat["poolName"] =  selectedInvite["Pool Name"];;
			inviteAllPoolFormat["poolOwnerId"] = selectedInvite["Pool Owner Id"];
			inviteAllPoolFormat["poolAmount"] = selectedInvite["Pool Amount"]
			inviteAllPoolFormat["poolDescription"] = selectedInvite["Pool Description"];
			inviteAllPoolFormat["poolOwnerName"] = selectedInvite["From"];			
			inviteAllPoolFormat["friendsInPool"] = selectedInvite["Friends In Pool"];
			selectedInviteForInbox = inviteAllPoolFormat;
			allMyPools.poolArray.push(inviteAllPoolFormat);
			
			//save my allPools
			var gSaveClient:GameClient = GameClient.getInstance();
			var keyForSave:String = SocialNetwork.getCurrentId();
			if(keyForSave == null){
				//not connected			
			}
			else{
				keyForSave = keyForSave + ":allPools";
				gSaveClient.saveGame(keyForSave, allMyPools, removeInvite);				
			}
		}
		
		function removeInvite(result:Object):void{
			//load all invites
			var inviteLoadClient:GameClient = GameClient.getInstance();
			var keyForLoad:String = SocialNetwork.getCurrentId();
			if(keyForLoad == null){
				//not connected
			}
			else{
				keyForLoad = keyForLoad + ":inviteInbox";
				inviteLoadClient.loadGame(keyForLoad, onLoadInvites);
			}			
		}
		
		function onLoadInvites(inbox:Object):void{		
			//find that invite in my inbox //copy all but that invite into another inbox
			var newInbox:Object = new Object;
			newInbox["invitations"] = new Array();			
			for each(var invite:Object in inbox.invitations){
				if(invite.details.poolOwnerId == selectedInviteForInbox.poolOwnerId && invite.details.poolId == selectedInviteForInbox.poolId){
					//disregard
				}
				else{					
					//push to inbox
					newInbox.invitations.push(invite);
				}
			}						
			//save that inbox
			var inboxSaveClient:GameClient = GameClient.getInstance();
			var keyForInbox = SocialNetwork.getCurrentId();
			newInbox["myFBID"] = keyForInbox;
			if(keyForInbox == null){
				//not connected
			}
			else{
				keyForInbox = keyForInbox + ":inviteInbox";
				inboxSaveClient.saveGame(keyForInbox, newInbox, function(result:Object){/*donothin*/});
			}
		}
		
		function closePrompt(e:MouseEvent):void{		
			removeChild(e.target.parent);
			datagrid.removeItem(selectedInvite);
			//remove from server as well
		}
	}
}