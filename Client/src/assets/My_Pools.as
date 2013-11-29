package assets {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import classes.Pool_Entity;
	
	import services.GameClient;
	import services.NeighborClient;
	
	import social.SocialNetwork;
	
	public class My_Pools extends MovieClip {
		
		private var poolForm:Pool_Form;
		private var formHeight:Number;		
		private var allPools:Object;		
		private var poolDetail:Pool_Detail;
		private var myText:TextField;
		private var link_X:Number;
		private var link_Y:Number;
		private var friendLink_X:Number;
		private var friendLink_Y:Number;
		private var poolLinkIndex:Number = 0;
		private var inviteFriendList:Array;
		private var inviteScreen:Invite_Screen;
		private var friendListTextField:TextField = new TextField();
		private var invitingPoolInformation:Object;
		private var invitingFriend:Object;
		private var promptScreen:Prompt_Screen;
		public var i:int = 1;
		private var loadScreen:Loading_Screen;
		private var coins:Coins;
		private var warning:TextField;
				
		public function My_Pools() {
			allPools = new Object();
			allPools["poolArray"] = new Array();
			allPools["loadedFromServer"] = false;		
			allPools["lastPoolId"] = -1;
			
			link_X = -5;
			link_Y = -68;
			friendLink_X = 50;
			friendLink_Y = 10;
			
			//create a dummy object for the scroll pane to work properly
			createDummyObject();
			startPool.addEventListener(MouseEvent.CLICK,pullPoolForm);					
		}
		function createDummyObject():void{
			var dummyObject:Object = new Object;
			dummyObject["poolName"] = "";
			createLink(dummyObject);
		}
		
		public function loadAllPools():void{
			var gClient:GameClient = GameClient.getInstance();
			var keyForLoad:String = SocialNetwork.getCurrentId();
			if(allPools.loadedFromServer == false){
				if(keyForLoad!=null){
					keyForLoad = keyForLoad + ":allPools";
					loadingScreen();
					gClient.loadGame(keyForLoad,onAllPoolsLoad);
				}
				else{
					//not connected to FB - no need of creating links for pools	
				}
			}
			else{
				//load locally
			}
		}
		
		private function loadingScreen():void{
			var myFBID:String = SocialNetwork.getCurrentId();
			if(myFBID != null){
				loadScreen = new Loading_Screen;
				loadScreen.y = -75;
				loadScreen.message.text = "Loading all your Pools!\n Please Wait...";
				addChild(loadScreen);
			}
		}
		
		function onAllPoolsLoad(result:Object):void{	
			if(result != false){			
				allPools = result;
				allPools["loadedFromServer"] = true;					
				renderPoolLinks();		
			}					
		}
		
		function renderPoolLinks():void{		
			var poolArray:Array;
			poolArray = allPools["poolArray"];
			for each(var pool:Object in poolArray){
				createLink(pool);
			}
			removeChild(loadScreen);
		}
		
		public function setFormHeight(menuBarHeight:Number):void{	
			formHeight = menuBarHeight;
		}
		
		public function pullPoolForm(mouseEvent:MouseEvent):void{
						
			if(poolForm==null)
			{
				
				poolForm = new Pool_Form();
			}
			poolForm.x = 228;
			poolForm.y = 70;						
			if(!poolForm.stage)
				addChild(poolForm);		
			else
				poolForm.visible = true;						
			poolForm.submitBtn.addEventListener(MouseEvent.CLICK,checkInputs);
			poolForm.cancelBtn.addEventListener(MouseEvent.CLICK,cancelForm);
			//poolForm.addEventListener(KeyboardEvent.KEY_DOWN,checkKeyToSubmit);							
		}
		
		private function cancelForm(e:MouseEvent):void{			
			removeChild(poolForm);
			if(warning.stage){
					removeChild(warning);
			}
			poolForm = null;
		}
		
		/*function checkKeyToSubmit(e:KeyboardEvent):void{			
			if(e.keyCode == 13){
				checkInputs(new MouseEvent("CLICK"));
			}
		} 
		*/
		function checkInputs(e:MouseEvent):void{
			if(poolForm.poolName.text == " " || poolForm.Description.text == " " || poolForm.poolAmount.text == "")
			{
				if(warning == null){
					warning = new TextField();					
				}				
				warning.x = 620;
				warning.y = 150;
				warning.width = 100;
				warning.height = 50;
				warning.wordWrap = true;
				warning.border = true;
				warning.text = "Fill in all the fields before submitting";
				if(!warning.stage){
					addChild(warning);
				}
			}
			
			else
			{
				if(warning.stage){
					removeChild(warning);
				}
				submitForm();
			}
		}
		
		function submitForm():void{
			allPools.lastPoolId++;
			sendPoolEntries();
			savePoolArray();
			removeChild(poolForm);
			poolForm = null;
		}				
		
		function sendPoolEntries():void{
			var poolEntity:Object = new Object();		
			setPoolProperties(poolEntity);
			allPools.poolArray.push(poolEntity);
			createLink(poolEntity);
		}
		
		function setPoolProperties(entity:Object):void{
			entity["poolId"] = allPools.lastPoolId;
			entity["poolOwnerName"] = (SocialNetwork.getCurrentUserName()!=null)?SocialNetwork.getCurrentUserName():null;
			entity["poolOwnerId"] = (SocialNetwork.getCurrentId()!=null)?SocialNetwork.getCurrentId():null;
			entity["poolName"] = (poolForm.poolName.text=="")?"Pool "+allPools.poolArray.length:poolForm.poolName.text;
			entity["poolType"] = poolForm.poolType.value;					
			entity["poolDescription"] = poolForm.Description.text;
			entity["poolAmount"] = poolForm.poolAmount.text;
			entity["poolSubmitDate"] = poolForm.submitDate.text;
			entity["friendsInPool"] = null;
		}
		
		function savePoolArray():void{			
			var gClient:GameClient = GameClient.getInstance();
			var keyForSave:String = SocialNetwork.getCurrentId();
			if(keyForSave != null){
				keyForSave = SocialNetwork.getCurrentId()+":allPools";
				gClient.saveGame(keyForSave,allPools,onPoolArraySave);
			}
		}
		
		
		function onPoolArraySave(result:Object):void{
			trace("Save Successful");
		}
		
		
		
		function onPoolSave(poolEntity:Object):void{
			trace('Saved Picks: '+poolEntity);			
		}
		
		function createLink(entity:Object):void{
			var link:Pool_Link = new Pool_Link();
			var samplebtn_doc:DisplayObjectContainer;
			var labelsamplebtn:TextField;
			var inviteButton:Invite_Button = new Invite_Button();
						
			link.information = entity;	
			inviteButton.information = entity;
			
			samplebtn_doc = link.upState as DisplayObjectContainer;
			labelsamplebtn = samplebtn_doc.getChildAt(1) as TextField;
			labelsamplebtn.text = (poolLinkIndex)+". "+entity.poolName;			
			
			samplebtn_doc = link.downState as DisplayObjectContainer;
			labelsamplebtn = samplebtn_doc.getChildAt(1) as TextField;
			labelsamplebtn.text = (poolLinkIndex)+". "+entity.poolName;			
			
			samplebtn_doc = link.overState as DisplayObjectContainer;
			labelsamplebtn = samplebtn_doc.getChildAt(1) as TextField;
			labelsamplebtn.text = (poolLinkIndex++)+". "+entity.poolName;			
			
			inviteButton.addEventListener(MouseEvent.CLICK, inviteMyFriends);
			
			link.x = link_X;
			link.y = link_Y+25;
			if(link.y != -25){
				link.y+= 5;
			}
			inviteButton.x = link.x  + 430;
			inviteButton.y = link.y + 9;			
			link_Y = link.y;
			link.addEventListener(MouseEvent.CLICK, pullPoolDetails);
			poolTableScroll.source = poolDisplay;			
			poolDisplay.addChild(link);		
			poolDisplay.addChild(inviteButton);
		}
		
		private function inviteMyFriends(e:MouseEvent):void{
			var nClient:NeighborClient = NeighborClient.getInstance();
			var userKey:String = SocialNetwork.getCurrentId();
			invitingPoolInformation = e.target.information;			
			if(userKey == null){
				pullFriendInviteList(false);
			}
			else{
				loadingScreen();
				nClient.getNeighbors(getFriendsWhoPlay);
				pullFriendInviteList(true);
			}										
		}
		
		private function getFriendsWhoPlay(neighbors:Object):void{
			var friend:Object;
			var playingFriendsList:Array = new Array;
			var playingFriendsListIndex:Array = new Array;
			for(var index:int; index<neighbors.plays.length; index++){
				if(neighbors.plays[index] == 1){
					playingFriendsListIndex.push(index);
				}
			}
			
			for (index = 0; index<playingFriendsListIndex.length; index++){
				friend = new Object();
				friend["fbid"] = neighbors.uid[playingFriendsListIndex[index]];
				friend["name"] = neighbors.first_name[playingFriendsListIndex[index]];
				friend["indexInAllFriends"] = playingFriendsListIndex[index];
				playingFriendsList.push(friend);
			}
			
			inviteFriendList = playingFriendsList;
			var friendCount:Number = 1;
			var friendLink:Friend_Link;
			for each(var friendObj in inviteFriendList){
				friendLink = new Friend_Link();
				friendLink.information = friendObj;
				friendLink.setupButtons(friendCount+". "+friendLink.information.name);
				createFriendLink(friendLink);
				friendCount++;
			}	
			friendLink_X = 50;
			friendLink_Y = 10;	
			removeChild(loadScreen);
		}
		
		private function createFriendLink(friendLink:Friend_Link):void
		{
			friendLink.x = friendLink_X ;
			friendLink.y = friendLink_Y + 25;
			if(friendLink.y != 75){
				friendLink.y+= 5;
			}					
			friendLink_Y = friendLink.y;
			friendLink.addEventListener(MouseEvent.CLICK, inviteFriend);
			inviteScreen.renderTextBox.addChild(friendLink);
//			inviteScreen.friendListTextField.visible = false;
		}
		
		function inviteFriend(event:MouseEvent):void{			
			invitingFriend = event.target.information; //has friend's details who the user wants to invite
			var friendsKeyForInbox:String = invitingFriend.fbid+":inviteInbox";
								
			//make database call and get the inbox
			var gClient:GameClient = GameClient.getInstance();			
			gClient.loadGame(friendsKeyForInbox, onLoadInviteInbox);
		
		}
		
		private function onLoadInviteInbox(result:Object):void{
			var inbox:Object = result;
			if(inbox==false){
				//don't do anything, current users have to play the game;
			}
			else{
				var gSaveClient:GameClient = GameClient.getInstance();
				var friendsKeyForInbox:String = invitingFriend.fbid+":inviteInbox";
				var friendsInvite:Object = new Object();
				var poolInviteFlag:Boolean = false;
				friendsInvite["details"] = invitingPoolInformation;
						
				//check if already invited
				for each(var invite:Object in inbox.invitations){
					if(invite.details.poolId == invitingPoolInformation.poolId && invite.details.poolOwner == invitingPoolInformation.poolOwner){
						poolInviteFlag = true;
						break;
					}
				}
				
				if(poolInviteFlag==false){
					inbox.invitations.push(friendsInvite);
					gSaveClient.saveGame(friendsKeyForInbox, inbox, onSaveInviteInbox);
				}
				else{
					promptScreen = new Prompt_Screen();
					promptScreen.message.text = invitingFriend.name+" has already been invited!";
					promptScreen.okButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){removeChild(promptScreen);});
					addChild(promptScreen);
				}			
			//TODO ----> push friend id and name to the pool in poolArray.
			}
		}
		
		private function onSaveInviteInbox(result:Object):void{			
			promptScreen = new Prompt_Screen();
			promptScreen.message.text = invitingFriend.name+" has successfully been invited!\nPress 'OK' to continue...";
			promptScreen.okButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){removeChild(promptScreen);});
			addChild(promptScreen);
		}
		
		private function pullFriendInviteList(friendListFlag:Boolean):void{
			inviteScreen = new Invite_Screen();		
			inviteScreen.friendListScroll.source = inviteScreen.renderTextBox;
			inviteScreen.closeButton.addEventListener(MouseEvent.CLICK, function(){removeChild(inviteScreen)});					
			if(friendListFlag == false){								
				inviteScreen.friendListTextField.text = "Sorry! You need to be connected to the internet to get your friend list.";								
				var samplebtn_doc:DisplayObjectContainer;
				var labelsamplebtn:TextField;
				var inviteButton:Invite_Button = new Invite_Button();															
//				inviteScreen.renderTextBox.addChild(friendListTextField);	
				
			}				
			addChild(inviteScreen);
		}
				
		function pullPoolDetails(e:MouseEvent):void{
			var current_pool:Object = e.target.information;
			poolDetail = new Pool_Detail(); 
			poolDetail.x = 0;
			poolDetail.y = 0;
			poolDetail.showPoolProperties(current_pool.poolName,current_pool.poolDescription,current_pool.poolAmount,current_pool.poolType,current_pool.poolSubmitDate);			
			addChild(poolDetail);
			poolDetail.backBtn.addEventListener(MouseEvent.CLICK, hidePoolDetail);
			startPool.addEventListener(MouseEvent.CLICK,hidePoolDetail);
		}
			
		function hidePoolDetail(e:MouseEvent):void{
			if(poolDetail.stage)
			{
				removeChild(poolDetail);
			}
		}
			
	}
	
}
	
