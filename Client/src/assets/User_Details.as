package assets {
	
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	import services.GameClient;
	import services.NeighborClient;
	
	import social.SocialNetwork;
	
	
	
	public class User_Details extends MovieClip {
		
		var allMyFriendsIds:Array = new Array();		
		var allMyFriendsNames:Array = new Array;		
		var indexOfFriendsWhoPlay:Array;		
		var currentFBID:String;			
		var friendAccessIndex:Number;
		public function User_Details() {
			x = 0;
			y = 85;
			textField.text = "";			
		}
		
		public function neighborFinder():void{
			var nClient:NeighborClient = NeighborClient.getInstance();
			var keyForLoad:String = SocialNetwork.getCurrentId();
			if(keyForLoad!=null){
				nClient.getNeighbors(getFriends);
			}
			else{
				getFriends(false);
			}
		}
		
		private function getFriends(neighbors:Object):void{			
			textField.text = "";
			if(neighbors==false){
				textField.text = "Sorry, you're not connected to the Internet!";
			}
			else{	
				var gClient:GameClient = GameClient.getInstance();
				var friendsFBID:String;
				var friendsKey:String;
				allMyFriendsIds = neighbors.uid;
				allMyFriendsNames = neighbors.first_name;
				indexOfFriendsWhoPlay = new Array();
				for(var index:int=0; index<neighbors.plays.length;index++){					
					if(neighbors.plays[index] == 1){
						textField.appendText(index+" , ");					
						indexOfFriendsWhoPlay.push(index);
					}									
				}				
				textField.appendText("\n");					
				for(index = 0; index < indexOfFriendsWhoPlay.length; index++){					
					friendsFBID = allMyFriendsIds[indexOfFriendsWhoPlay[index]];
					currentFBID = friendsFBID.slice(3, friendsFBID.length);
					friendsKey = currentFBID +":highScore";	
					textField.appendText(friendsKey);
					gClient.loadGame(friendsKey, loadDetailsForFriend);					
					textField.appendText("\n");
				}
			}
		}							
		
		private function loadDetailsForFriend(friendsScore:Object):void{			
			var currentUserDetails:Object = new Object;						
			currentUserDetails["fbid"] = friendsScore==false?"EarlyAdopterID":friendsScore["myFBID"];
			currentUserDetails["highScore"] = friendsScore==false?"EarlyAdopterScore":friendsScore.value;
			var currentFriendIdToCompare:String ;
			for each(var position:Number in indexOfFriendsWhoPlay){				
				if(currentUserDetails["fbid"] == allMyFriendsIds[position]){
					currentUserDetails["name"] = allMyFriendsNames[position];
					break;
				}
			}					
			currentUserDetails["name"] = friendsScore==false?"EarlyAdopterName":currentUserDetails["name"];
			currentUserDetails["pictureURL"] = "http://graph.facebook.com/"+currentUserDetails["fbid"]+"/picture";			
			textField.appendText(currentUserDetails["fbid"]+" - "+currentUserDetails["name"]+" - "+currentUserDetails["highScore"]+" - "+currentUserDetails["pictureURL"]+" \n");			
		}
	} 	
}

	
