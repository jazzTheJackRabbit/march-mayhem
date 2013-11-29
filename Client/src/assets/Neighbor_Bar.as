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
	
	
	
	public class Neighbor_Bar extends MovieClip {
		
		var allMyFriendsIds:Array = new Array();		
		var allMyFriendsNames:Array = new Array;		
		var indexOfFriendsWhoPlay:Array;		
		var playingFriendList:Array = new Array();
		var currentFBID:String;			
		var friendPositionX:Number = 623 + 72 + 10;
		var friendPositionY:Number = 12;
		var friendCount:int;
		var dummyCount:int = 0;
		var dummyScale:int = 0;
		var dummyScaleMax:int = 0;
		var buttonReference:Array = new Array();
		var visibleWindow:Array = new Array();
		
		public function Neighbor_Bar() {
			for(var a = 0; a< 9; a++){
				createFriendScoreButton1();
			}
			nextNeighbors.addEventListener(MouseEvent.CLICK, moveForward);
			prevNeighbors.addEventListener(MouseEvent.CLICK, moveBackward);
		}
		
		public function setVisibleWindow(){
			for(var i=0; i<6;i++){
				if(buttonReference[i]!=null){
					visibleWindow[i] = buttonReference[i];
					visibleWindow[i].visible = true;
				}
				else{
					visibleWindow[i] = null;
				}				
			}
		}
		
		public function moveForward(mouseEvent:MouseEvent){			
			if(dummyScale<(dummyScaleMax)){
				for(var i=0; i<buttonReference.length; i++){				
					buttonReference[i].x+=(buttonReference[i].width+20)*6;					
				}
				dummyScale++;
				
				for(i=0; i<6;i++){										
					if(visibleWindow[i]!=null){
						visibleWindow[i].visible = false;
					}
				}							
				
				visibleWindow = new Array();
				
				for(i=6*dummyScale; i<6*(dummyScale+1);i++){	
					if(buttonReference[i]!=null){
						buttonReference[i].visible = true;
						visibleWindow.push(buttonReference[i]);
					}				
				}							
			}
		}
		
		public function moveBackward(mouseEvent:MouseEvent){
			if(dummyScale!=0){
				for(var i=0; i<buttonReference.length; i++){				
					buttonReference[i].x-=(buttonReference[i].width+20)*6;					
				}
				dummyScale--;
				
				for(i=0; i<6;i++){			
					if(visibleWindow[i]!=null){
						visibleWindow[i].visible = false;
					}
				}							
				
				visibleWindow = new Array();
				
				for(i=6*dummyScale; i<6*(dummyScale+1);i++){	
					if(buttonReference[i]!=null){
						buttonReference[i].visible = true;
						visibleWindow.push(buttonReference[i]);
					}				
				}							
			}				
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
			if(neighbors==false){
				//not connected to the internet
			}
			else{	
				var gClient:GameClient = GameClient.getInstance();
				var friendsFBID:String;
				var friendsKey:String;
				allMyFriendsIds = neighbors.uid;
				allMyFriendsNames = neighbors.first_name;
				indexOfFriendsWhoPlay = new Array();
				
				//find all friends who are using the application
				for(var index:int=0; index<neighbors.plays.length;index++){					
					if(neighbors.plays[index] == 1){									
						indexOfFriendsWhoPlay.push(index);
					}									
				}								
				
				//get each friend's details.
				friendCount = 0;
				for(index = 0; index < indexOfFriendsWhoPlay.length; index++){					
					friendsFBID = allMyFriendsIds[indexOfFriendsWhoPlay[index]];
					currentFBID = friendsFBID.slice(3, friendsFBID.length);
					friendsKey = currentFBID +":highScore";						
					gClient.loadGame(friendsKey, loadDetailsForFriend);										
				}
			}
		}							
		
		private function loadDetailsForFriend(friendsScore:Object):void{	
			friendCount++;
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
			currentUserDetails["pictureURL"] = "http://graph.facebook.com/"+currentUserDetails["fbid"].slice(3,currentUserDetails["fbid"].length)+"/picture";			
			
			playingFriendList.push(currentUserDetails);
			if(friendCount == indexOfFriendsWhoPlay.length){				
				createScoreButtonsForAllFriends();
			}
		}	
		
		private function createScoreButtonsForAllFriends():void{
			playingFriendList.sortOn(["highScore"], Array.NUMERIC | Array.DESCENDING);
			for each(var usersDetail:Object in playingFriendList){
				createFriendScoreButton(usersDetail);
			}
			removeChild(miniLoadingScreen);
		}
		
		private function createFriendScoreButton(friendObj:Object):void{									
			if(friendObj.fbid != "EarlyAdopterID"){
				var friendScoreButton:Friends_Score = new Friends_Score();				
				friendScoreButton.x = friendPositionX - friendScoreButton.width - 20;
				friendScoreButton.y = friendPositionY;		
				friendPositionX = friendScoreButton.x;		
				addChild(friendScoreButton);
				//				var imageHandle:Loader=new Loader();							
				//				imageHandle.load(new URLRequest(friendObj.pictureUrl));			
				//						
				var friend:DisplayObjectContainer = friendScoreButton.upState as DisplayObjectContainer;			
				var friendName:TextField = friend.getChildAt(2) as TextField;			
				var profilePhoto:MovieClip = friend.getChildAt(3) as MovieClip;
				var friendScore:TextField = friend.getChildAt(4) as TextField;	
				friendName.text = friendObj.name;				
				friendScore.text = friendObj.highScore;
				//				profilePhoto.addChild(imageHandle);
				
				
				friend = friendScoreButton.overState as DisplayObjectContainer;			
				friendName = friend.getChildAt(2) as TextField;
				friendScore = friend.getChildAt(4) as TextField;
				profilePhoto = friend.getChildAt(3) as MovieClip;			
				friendName.text = friendObj.name;
				friendScore.text = friendObj.highScore;
				//				profilePhoto.addChild(imageHandle);
				
				
				friend = friendScoreButton.downState as DisplayObjectContainer;				
				friendName = friend.getChildAt(2) as TextField;
				friendScore = friend.getChildAt(4) as TextField;
				profilePhoto = friend.getChildAt(3) as MovieClip;			
				friendName.text = friendObj.name;
				friendScore.text = friendObj.highScore;
				//				profilePhoto.addChild(imageHandle);					
			}		
		}	
		
		private function createFriendScoreButton1():void{
			var friendObj:Object = new Object;
			friendObj["name"]= "Amogh"			
			dummyCount++;
			var friendScoreButton:Friends_Score = new Friends_Score();
			
			buttonReference.push(friendScoreButton);
			dummyScaleMax = Math.floor((dummyCount-1)/ 6);
			
			friendScoreButton.x = friendPositionX - friendScoreButton.width - 20;
			friendScoreButton.y = friendPositionY;		
			friendPositionX = friendScoreButton.x;						
			addChild(friendScoreButton);
			this.setChildIndex(friendScoreButton,4);
			friendScoreButton.visible = false;			
			
			var friend:DisplayObjectContainer = friendScoreButton.upState as DisplayObjectContainer;			
			var friendName:TextField = friend.getChildAt(2) as TextField;			
			var profilePhoto:MovieClip = friend.getChildAt(3) as MovieClip;
			var friendScore:TextField = friend.getChildAt(4) as TextField;	
			friendName.text = ""+dummyCount;				
			friendScore.text = "000";
			//				profilePhoto.addChild(imageHandle);
			
			
			friend = friendScoreButton.overState as DisplayObjectContainer;			
			friendName = friend.getChildAt(2) as TextField;
			friendScore = friend.getChildAt(4) as TextField;
			profilePhoto = friend.getChildAt(3) as MovieClip;			
			friendName.text = ""+dummyCount;
			friendScore.text = "000";
			//				profilePhoto.addChild(imageHandle);
			
			
			friend = friendScoreButton.downState as DisplayObjectContainer;				
			friendName = friend.getChildAt(2) as TextField;
			friendScore = friend.getChildAt(4) as TextField;
			profilePhoto = friend.getChildAt(3) as MovieClip;			
			friendName.text = ""+dummyCount;
			friendScore.text = "000";
			//				profilePhoto.addChild(imageHandle);					
			//			}		
			setVisibleWindow();
		}
	}
}