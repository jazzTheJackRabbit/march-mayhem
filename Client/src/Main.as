/***************************
* List of keys: 
 * FBID:eastBracket
 * FBID:westBracket
 * FBID:southEastBracket
 * FBID:southWestBracket
 * FBID:allPools
 * FBID:highScore
 * FBID:inviteInbox
 * FBID:coins
****************************/
package {
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.text.TextField;
	import flash.ui.Mouse;
	
	import assets.Coin_Panel;
	import assets.Confirm_Navigation;
	import assets.Control_Panel;
	import assets.Inbox_View_Screen;
	import assets.Leader_Board;
	import assets.LoadingCircle;
	import assets.Loading_Screen;
	import assets.Menu_Bar;
	import assets.My_Picks;
	import assets.My_Pools;
	import assets.Neighbor_Bar;
	import assets.Prompt_Screen;
	import assets.Settings;
	import assets.User_Details;
	
	import classes.BracketDataStructure;
	import classes.Game_Play;
	import classes.SetupWinners;
	
	import data.Config;
	
	import gameentity.Ball;
	
	import services.GameClient;
	
	import social.SocialNetwork;

	public class Main extends MovieClip {
		private var screenHeight:int = 650;
		private var screenWidth:int = 940;
		private var menuBar:Menu_Bar;
		private var leaderBoard:Leader_Board;
		private var neighborBar:Neighbor_Bar;
		private var controlPanel:Control_Panel;
		private var settings:Settings;
		private var myPicks:My_Picks;
		private var tempPicks:My_Picks;
		private var myPools:My_Pools;
		private var gamePlay:Game_Play;
		private var userDetails:User_Details;		
		private var gameDoc:Main;
		private var inboxView:Inbox_View_Screen;
		private var loadScreen:Loading_Screen;
		private var delCount:int = 0;
		private var currentDate:Date;
		private var confirmScreen:Confirm_Navigation;
		private var coinPanel:Coin_Panel;
		
		public function Main(){									
			if(stage)
				initStage();
			else
				this.addEventListener(Event.ADDED_TO_STAGE, initStage);				
			setupTheStage();			
//			pullHomeCourt(new MouseEvent("CLICK"));
//			pullMyPools(new MouseEvent("CLICK"));
			
			
			/***************************
			 
			 MAKE THE NEIGHBOR BAR POLL FOR CHANGES 
			  
			 ***************************/					
			
		}
		
		function setupTheStage():void{					
			setDefaultPositions();			
			menuBar.myPicksBtn.addEventListener(MouseEvent.CLICK,pullMyPicks);
			menuBar.poolBtn.addEventListener(MouseEvent.CLICK,pullMyPools);
			menuBar.courtBtn.addEventListener(MouseEvent.CLICK,pullHomeCourt);	
			menuBar.inviteBtn.addEventListener(MouseEvent.CLICK,pullInbox);
			menuBar.coinsBtn.addEventListener(MouseEvent.CLICK,pullCoinPanel);
			gamePlay.addEventListener(Game_Play.GAME_OVER, updateHighScore);
			controlPanel.avatar.addEventListener(MouseEvent.CLICK,pullUserDetails);
			controlPanel.helpBtn.addEventListener(MouseEvent.CLICK,pullDeleteScreen);
			settings.fullScreenBtn.addEventListener(MouseEvent.CLICK, compareBracket);			
		}						
		
		
		private function pullDeleteScreen(e:MouseEvent):void{
			var id:String = SocialNetwork.getCurrentId();
			if(id == "FB:701770950"){
				var gNukeClient:GameClient = GameClient.getInstance();
				var allPoolStr:String = ":allPools";
				var inviteInboxStr:String = ":inviteInbox";
				var allIds:Array = ["701770950","504995412","596975681","632333622","644850560","100005947860569"];
				loadScreen = new Loading_Screen();
				loadScreen.message.text = "Deleting all player data...\nPlease Wait.";
				addChild(loadScreen);			
				delCount = 0;
				for each(var person:String in allIds){					
					gNukeClient.nukeGame((person+allPoolStr),removeDeleteScreen);					
					gNukeClient.nukeGame((person+inviteInboxStr),removeDeleteScreen);
				}
			}
		}
		
		private function removeDeleteScreen(result:Object):void{	
			delCount++;
			if(delCount == 12){
				removeChild(loadScreen);
			}
		}
		
		private function makeFullScreen(event:MouseEvent):void{		
			stage.displayState = StageDisplayState.FULL_SCREEN;
		}
		
		function initStage(e:Event = null):void{		
			gameDoc = this;													
			menuBar = new Menu_Bar;
			leaderBoard = new Leader_Board;
			neighborBar = new Neighbor_Bar;	
			controlPanel = new Control_Panel;
			settings = new Settings;
			myPicks = new My_Picks();
			tempPicks = new My_Picks();
			myPools = new My_Pools();
			userDetails = new User_Details;
			gamePlay = new Game_Play;			
			inboxView = new Inbox_View_Screen();
			currentDate = new Date();
			coinPanel = new Coin_Panel();
			trace(currentDate.date+"/"+(currentDate.month+1)+"/"+currentDate.fullYear);
			addAllElementsToStage();			
			runConfig(e);
		}			
		
		function runConfig(e:Event):void
		{
			var config:Config = new Config(LoaderInfo(this.root.loaderInfo).parameters);						
			populateSocialNetwork();			
		}

		function populateSocialNetwork():void
		{
			var id:String = SocialNetwork.getCurrentId();
			var name:String = SocialNetwork.getCurrentUserName();	
			menuBar.profilePhoto.addChild(new LoadingCircle);
			if(id == null)
				return;			
			if(id != null){
				name = SocialNetwork.getCurrentUserName();
				
				//load HighScore or set initial highScore
				var gClient:GameClient = GameClient.getInstance();
				gClient.loadGame(id+":highScore",onLoadHighScore);
				
				//load Neighbors
				neighborBar.neighborFinder();
				
				//create a new inviteInbox for me, if it doesn't exist.
				gClient.loadGame(id+":inviteInbox",onLoadInviteInbox);
				
				//start the invite polling process
				menuBar.startPolling();
				menuBar.pollInvites(new TimerEvent("COMPLETE"));
				
				//create default all Pools
				gClient.loadGame(id+":allPools",onLoadAllPools);	
				
				//create coins
				gClient.loadGame(id+":coins",onLoadCoins);
			}
			var picture:String;
			if(id != null) 
				picture = SocialNetwork.getPictureURL(id);
			if(picture != null) {
				var imageHandle:Loader=new Loader();							
	            imageHandle.load(new URLRequest(picture));
				imageHandle.scaleX = .85;
				imageHandle.scaleY = .85;
				menuBar.profilePhoto.addChild(imageHandle);
			}
			if(name != null)
			{
				menuBar.profileName.text = name;
			}													
		}		
		
		
		
		private function onLoadAllPools(result:Object):void
		{			
			if(result == false){
				//create new allPools
				var gSaveClient:GameClient = GameClient.getInstance();
				var keyForSave:String = SocialNetwork.getCurrentId();
				var allPools:Object = new Object();
				allPools["poolArray"] = new Array();
				allPools["loadedFromServer"] = false;		
				allPools["lastPoolId"] = -1;
				keyForSave = keyForSave + ":allPools";
				gSaveClient.saveGame(keyForSave, allPools, function(resultSave:Object){});
			}
		}
		
		private function onLoadInviteInbox(inbox:Object):void{
			if(inbox==false){
				//create new inbox
				var gClient:GameClient = GameClient.getInstance();
				inbox = new Object();
				inbox["myFBID"] = SocialNetwork.getCurrentId();
				inbox["invitations"] = new Array();
				gClient.saveGame(inbox["myFBID"]+":inviteInbox",inbox,onSaveInviteInbox);
			}
		}
		
		private function onLoadCoins(coins:Object):void{
			var upCoinButton:DisplayObjectContainer = menuBar.coinsBtn.coinButton.upState as DisplayObjectContainer;
			var downCoinButton:DisplayObjectContainer = menuBar.coinsBtn.coinButton.downState as DisplayObjectContainer;
			var overCoinButton:DisplayObjectContainer = menuBar.coinsBtn.coinButton.overState as DisplayObjectContainer;
			
			var upButtonText:TextField = upCoinButton.getChildAt(2) as TextField;
			var downButtonText:TextField = downCoinButton.getChildAt(2) as TextField;
			var overButtonText:TextField = overCoinButton.getChildAt(2) as TextField;
			
			if(coins==false)
			{
				var gClient:GameClient = GameClient.getInstance();
				coins = new Object();
				coins["theFBID"] = SocialNetwork.getCurrentId();
				coins["value"] = "100";
				upButtonText.text = "100";
				downButtonText.text = "100";
				overButtonText.text = "100";
				gClient.saveGame(coins["theFBID"]+":coins",coins, onSaveCoins);
			}
			else
			{						
				upButtonText.text =	coins.value;
				downButtonText.text = coins.value;
				overButtonText.text = coins.value;
			}
		}
		private function onSaveCoins(result:Object):void{
			
		}
		private function onSaveInviteInbox(result:Object):void{
			
		}
		
		private function onLoadHighScore(myHighScoreObject:Object):void{
			var gClient:GameClient = GameClient.getInstance();
			if(myHighScoreObject == false){
				var highScore:Object = new Object;
				highScore["myFBID"] = SocialNetwork.getCurrentId();
				highScore["value"] = 0;
				highScore["loadedFromServer"] = false;
				gClient.saveGame(highScore["myFBID"]+":highScore",highScore,function(result:Object):void{});
			}
			else{
				menuBar.courtBtn.homeCourtButton.upState.getChildAt(4).text = myHighScoreObject.value;			
				menuBar.courtBtn.homeCourtButton.downState.getChildAt(4).text = myHighScoreObject.value;
				menuBar.courtBtn.homeCourtButton.overState.getChildAt(4).text = myHighScoreObject.value;				
				
			}
		}
		
		function addAllElementsToStage():void{
			addChild(menuBar);
			addChild(leaderBoard);
			addChild(controlPanel);
			addChild(settings);			
			addChild(neighborBar);											
			trace(this.getChildIndex(neighborBar));
		}
		
		function removeAllElementsFromStage():void{
			removeChild(menuBar);
			removeChild(leaderBoard);
			removeChild(settings);
			removeChild(controlPanel);
			removeChild(neighborBar);
			
			
		}
		
		function setDefaultPositions():void{
			menuBar.x = 0;
			menuBar.y = 0;
			
			leaderBoard.x = screenWidth - leaderBoard.width;	
			leaderBoard.y = menuBar.height;
			
			neighborBar.x = 0;
			neighborBar.y = screenHeight - neighborBar.height;
			
			controlPanel.x = screenWidth - controlPanel.width;
			controlPanel.y = screenHeight - controlPanel.height;
			
			settings.x = controlPanel.x - settings.width - 5;
			settings.y = screenHeight - settings.height;						
		}
		
		function hideAllViews(menuType:String):void{		
			removeAllElementsFromStage();			
			if(myPicks.stage && menuType != "MyPicks"){
				removeChild(myPicks);												
			}
			if(myPools.stage && menuType != "MyPools"){
				removeChild(myPools);				
			}
			if(userDetails.stage && menuType != "UserDetails"){							
				removeChild(userDetails);				
				
			}			
			if(gamePlay.stage && menuType != "HomeCourt"){							
				gamePlay.visible = false;				
				gamePlay = new Game_Play();
			}
			
			if(coinPanel.stage && menuType != "CoinPanel"){							
				coinPanel.visible = false;				
				coinPanel = new Coin_Panel();
			}
		}
		
		function pullMyPicks(mouseEvent:MouseEvent):void{		
			if(!gamePlay.gameStarted){
				hideAllViews("MyPicks");			
				myPicks.x = 0;
				myPicks.y = menuBar.height;	
				if(myPicks.firstTimeVisited == false){
					myPicks.createBracket();											
					myPicks.firstTimeVisited = true;				
				}
				if(!myPicks.stage)
					addChild(myPicks);					
				addAllElementsToStage();
			}
			else{
				//pause game
				gamePlay.pauseGame();
				
				//pull navigation screen
				confirmScreen = new Confirm_Navigation();
				confirmScreen.message.text = "|------ CONFIRM NAVIGATION ------|\n\nYour current game session will end.\n Are you sure you want to continue to 'My Picks'?";
				confirmScreen.x = -50;
				addChild(confirmScreen);
				confirmScreen.okButton.addEventListener(MouseEvent.CLICK, function(){
					gamePlay.endGame();
					removeChild(confirmScreen);
					hideAllViews("MyPicks");			
					myPicks.x = 0;
					myPicks.y = menuBar.height;	
					if(myPicks.firstTimeVisited == false){
						myPicks.createBracket();											
						myPicks.firstTimeVisited = true;				
					}
					if(!myPicks.stage)
						addChild(myPicks);					
					addAllElementsToStage();
				});
				confirmScreen.cancelButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){										
					gamePlay.resumeGame(new MouseEvent("CLICK"));
					removeChild(confirmScreen);
				});
			}
		}
		
		
		function pullMyPools(mouseEvent:MouseEvent):void{
			if(!gamePlay.gameStarted){
				hideAllViews("MyPools");			
				myPools.setFormHeight(menuBar.height);
				myPools.x = 0;
				myPools.y = menuBar.height;
				if(!myPools.stage)
					addChild(myPools);		
				myPools.loadAllPools();
			
				addAllElementsToStage();
				
			}
			else{
				//pause game
				gamePlay.pauseGame();
				
				//pull navigation screen
				confirmScreen = new Confirm_Navigation();
				confirmScreen.message.text = "|------ CONFIRM NAVIGATION ------|\n\nYour current game session will end.\n Are you sure you want to continue to 'My Pools'?";
				confirmScreen.x = -50;
				addChild(confirmScreen);
				confirmScreen.okButton.addEventListener(MouseEvent.CLICK, function(){
					gamePlay.endGame();
					removeChild(confirmScreen);
					hideAllViews("MyPools");			
					myPools.setFormHeight(menuBar.height);
					myPools.x = 0;
					myPools.y = menuBar.height;
					if(!myPools.stage)
						addChild(myPools);		
					myPools.loadAllPools();
					
					addAllElementsToStage();
				});
				confirmScreen.cancelButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){						
					gamePlay.resumeGame(new MouseEvent("CLICK"));
					removeChild(confirmScreen);
				});
			}
		}				
		
		function pullUserDetails(mouseEvent:MouseEvent):void{
			hideAllViews("UserDetails");	
			if(!userDetails.stage)
				addChild(userDetails);											
			userDetails.neighborFinder();
			addAllElementsToStage();				
		}			
		
		function pullHomeCourt(mouseEvent:MouseEvent):void{
			hideAllViews("HomeCourt");
			if(!gamePlay.stage)
				addChild(gamePlay);					
			addAllElementsToStage();
		}
		
		private function pullCoinPanel(mouseEvent:MouseEvent):void{
			if(!gamePlay.gameStarted){	
				if(!gamePlay.gameStarted){
					hideAllViews("CoinPanel");									
					coinPanel.x = 0;
					coinPanel.y = menuBar.height;						
					if(!coinPanel.stage)
						addChild(coinPanel);												
					addAllElementsToStage();
				}
			}
			else{
				gamePlay.pauseGame();
				//pull navigation screen
				confirmScreen = new Confirm_Navigation();
				confirmScreen.message.text = "|------ CONFIRM NAVIGATION ------|\n\nYour current game session will end.\n Are you sure you want to continue to manage your coins?";
				confirmScreen.x = -50;
				addChild(confirmScreen);
				confirmScreen.okButton.addEventListener(MouseEvent.CLICK, function(){
					gamePlay.endGame();
					removeChild(confirmScreen);					
					
					hideAllViews("CoinPanel");									
					coinPanel.x = 0;
					coinPanel.y = menuBar.height;						
					if(!coinPanel.stage)
						addChild(coinPanel);												
					addAllElementsToStage();
				});				
				
				confirmScreen.cancelButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent){						
					gamePlay.resumeGame(new MouseEvent("CLICK"));
					removeChild(confirmScreen);
				});
			}
		}		
		
		
		function pullInbox(mouseEvent:MouseEvent):void{	
			if(!gamePlay.gameStarted){					
				if(!inboxView.stage){
					inboxView = new Inbox_View_Screen;
					addChild(inboxView);
				}
				inboxView.getInvites();
				inboxView.closeButton.addEventListener(MouseEvent.CLICK, function(){
					removeChild(inboxView);												
				});
			}
			else{
				gamePlay.pauseGame();
				if(!inboxView.stage){
					inboxView = new Inbox_View_Screen;
					addChild(inboxView);
				}
				inboxView.getInvites();
				inboxView.closeButton.addEventListener(MouseEvent.CLICK, function(){
					removeChild(inboxView);	
					if(!gamePlay.promptScreen.stage){
						gamePlay.promptScreen = new Prompt_Screen();
						var promptScreen:Prompt_Screen = gamePlay.promptScreen;
						promptScreen.x = 0;
						promptScreen.y = 85;
						promptScreen.message.text = "Game Paused.\n Click 'OK' to resume.";
						promptScreen.okButton.addEventListener(MouseEvent.CLICK, gamePlay.resumeGame);
						gamePlay.addChild(promptScreen);
					}
				});
			}
		}
		
		function updateHighScore(e:Event):void{
			var highScore:Object = gamePlay.highScore;			
			menuBar.courtBtn.homeCourtButton.upState.getChildAt(4).text = highScore.value;			
			menuBar.courtBtn.homeCourtButton.downState.getChildAt(4).text = highScore.value;
			menuBar.courtBtn.homeCourtButton.overState.getChildAt(4).text = highScore.value;
		}
		
		function compareBracket(e:MouseEvent):void{
			var totalPoints:int = 0;
			var roundPoints:Array = new Array();
			var setupWinners:SetupWinners = new SetupWinners();
			var winningBracket:Array = setupWinners.eastBracket;
			var toCompareBracket:Object = myPicks.bracketEntityEast;
			if(toCompareBracket.saved == true){
				for(var roundNum:int = 1; roundNum < 5; roundNum++){
					roundPoints[roundNum] = 0;
					for (var teamNum:int = 0; teamNum < Math.pow(2, (4-roundNum)); teamNum++){
						if(toCompareBracket.bracketNodeList[roundNum][teamNum].leafData == winningBracket[roundNum][teamNum] && winningBracket[roundNum][teamNum] != ""){
							roundPoints[roundNum]++;							
						}
					}
					trace("Round "+roundNum+": "+roundPoints[roundNum]);
					totalPoints+=roundPoints[roundNum];
				}
				trace("Total Points = "+totalPoints);				
			}
			else{
				trace("time is up");
			}
		}		
	}
}