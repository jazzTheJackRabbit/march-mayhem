package assets {
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.Mouse;
	
	import classes.BracketDataStructure;
	import classes.teamUtil;
	
	import data.Config;
	
	import fl.motion.AdjustColor;
	import fl.motion.MotionEvent;
	
	import gameentity.Ball;
	
	import services.GameClient;
	
	import social.SocialNetwork;

	
	public class My_Picks extends MovieClip {		
		private var bracketNodeList:Array;		//Data is stored in the form of an array the contains the rounds within which the teams are present
		private var bracketEntity:Object;
		public var bracketEntityEast:Object;				
		public var bracketEntityWest:Object;		
		public var bracketEntitySouthEast:Object;		
		public var bracketEntitySouthWest:Object;		
		private var selectedZone:String;
		public var firstTimeVisited:Boolean;
		public var matrixSelected:Array = new Array();
		public var matrixNotSelected:Array = new Array();
		private var promptScreen:Prompt_Screen;
		private var loadScreen:Loading_Screen;
		
		public function My_Picks(){
			
			firstTimeVisited = false;			
			selectedZone = "east"; // Default zone			
			setButtonFilters();
			loadScreen = new Loading_Screen;
			saveBtn.addEventListener(MouseEvent.CLICK, savePicks);
			eastBtn.addEventListener(MouseEvent.CLICK, selectZone);
			westBtn.addEventListener(MouseEvent.CLICK, selectZone);
			southEastBtn.addEventListener(MouseEvent.CLICK, selectZone);
			southWestBtn.addEventListener(MouseEvent.CLICK, selectZone);					
		}								
		/****************************************************************/		
		function setButtonFilters():void{
			var colorFilterSelected:AdjustColor = new AdjustColor();
			var colorFilterNotSelected:AdjustColor = new AdjustColor();			
			var colorMatrixSelected:ColorMatrixFilter;
			var colorMatrixNotSelected:ColorMatrixFilter;		
						
			colorFilterSelected.hue = 180;
			colorFilterSelected.saturation = 0;
			colorFilterSelected.brightness = 0;
			colorFilterSelected.contrast = 0;
			matrixSelected = colorFilterSelected.CalculateFinalFlatArray();
			//colorMatrixSelected = new ColorMatrixFilter(matrixSelected);			
			
			colorFilterNotSelected.hue = 0;
			colorFilterNotSelected.saturation = 0;
			colorFilterNotSelected.brightness = 0;
			colorFilterNotSelected.contrast = 0;
			matrixNotSelected = colorFilterNotSelected.CalculateFinalFlatArray();
			//colorMatrixNotSelected = new ColorMatrixFilter(matrixNotSelected);
			
			//trace(matrixNotSelected);
			//trace(matrixSelected);
		}
		/****************************************************************/		
		function resetButtonColors():void{
			var instanceNameForBracketElements:String;											
			for(var roundNum:int=0; roundNum<4; roundNum++){ 
				for(var matchNum:int=0; matchNum<(Math.pow(2,4-roundNum-1)); matchNum++){
					for(var teamNum:int=0; teamNum<2; teamNum++){
						instanceNameForBracketElements = "round"+(roundNum+1)+"Match"+(matchNum+1)+"Team"+(teamNum+1)+"Button";
						this.bracket[instanceNameForBracketElements].upState.getChildAt(0).matrixToApply = matrixNotSelected;
						applyButtonColor(this.bracket[instanceNameForBracketElements]);
					}
				}
			}
		}
		/****************************************************************/
		//Changes the color of the input button by applying the filters
		function applyButtonColor(buttonToTransform:Object):void{
			buttonToTransform.upState.getChildAt(0)["colorMatrixToApply"] = new ColorMatrixFilter(buttonToTransform.upState.getChildAt(0).matrixToApply);			
			buttonToTransform.upState.getChildAt(0).filters = [buttonToTransform.upState.getChildAt(0).colorMatrixToApply];		
		}
		/****************************************************************/
		function setBracketEntitiesToDefault():void{
			bracketEntityEast["bracketNodeList"] = new Array;
			bracketEntityEast["completed"] = false;
			bracketEntityEast["saved"] = false;
			bracketEntityEast["zone"] = "east";
			
			
			bracketEntityWest["bracketNodeList"] = new Array;
			bracketEntityWest["completed"] = false;
			bracketEntityWest["saved"] = false;
			bracketEntityWest["zone"] = "west";
			westBtnBkg.visible = false;
			
			bracketEntitySouthEast["bracketNodeList"] = new Array;
			bracketEntitySouthEast["completed"] = false;
			bracketEntitySouthEast["saved"] = false;
			bracketEntitySouthEast["zone"] = "southEast";
			southEastBtnBkg.visible = false;
			
			bracketEntitySouthWest["bracketNodeList"] = new Array;
			bracketEntitySouthWest["completed"] = false;
			bracketEntitySouthWest["saved"] = false;
			bracketEntitySouthWest["zone"] = "southWest";
			southWestBtnBkg.visible = false;
		}
		/****************************************************************/		
		public function createBracket():void{
			bracketNodeList = new Array();								
			bracketEntityEast = new Object();									
			bracketEntityWest = new Object();
			bracketEntitySouthEast = new Object();
			bracketEntitySouthWest = new Object();
			setBracketEntitiesToDefault();
			loadGame(selectedZone);			
		}
		/****************************************************************/
		private function loadGame(zone:String):void{		
			var gClient:GameClient = GameClient.getInstance();			
			var keyForLoad:String;			
			
			switch(zone){
				case "east":
					bracketEntity = bracketEntityEast;
					keyForLoad = SocialNetwork.getCurrentId() + ":eastBracket";
					break;
				case "west":
					bracketEntity = bracketEntityWest;
					keyForLoad = SocialNetwork.getCurrentId() + ":westBracket";
					break;
				case "southWest":
					bracketEntity = bracketEntitySouthWest;
					keyForLoad = SocialNetwork.getCurrentId() + ":southWestBracket";
					break;
				case "southEast":
					bracketEntity = bracketEntitySouthEast;
					keyForLoad = SocialNetwork.getCurrentId() + ":southEastBracket";
					break;
			}							
			if(bracketEntity.saved != true){				
				if(SocialNetwork.getCurrentId()!=null){		
					loadingScreen();
					gClient.loadGame(keyForLoad,onLoadGame);					
				}				
				else{
					populateLeafNodes();	
				}
			}
			else{				
				loadButtons(bracketEntity);
			}						
//			removeChild(loadScreen);			
		}
		/****************************************************************/
		private function onLoadGame(resultObject:Object):void{			
			var result:Object;
			if(resultObject == false){
				result = new Object();
				result["bracketNodeList"] = new Array;
				result["completed"] = false;
				result["saved"] = false;
				result["zone"] = selectedZone;
			}
			else{
				result = resultObject;
			}
			switch(selectedZone){
				case "east":
					bracketEntityEast = result;									
					break;
				case "west":
					bracketEntityWest = result;					
					break;
				case "southWest":
					bracketEntitySouthWest = result;					
					break;
				case "southEast":
					bracketEntitySouthEast = result;					
					break;
			}				
			bracketEntity = result;						
			
			if(bracketEntity.saved != true){								
				populateLeafNodes();					
			}				
			else{//bracektEntity.saved == true										
				loadButtons(bracketEntity);				
			}
			if(loadScreen.stage){
				removeChild(loadScreen);
			}
		}
		/****************************************************************/
		function loadButtons(localBracketEntity:Object):void{				
			var instanceNameForBracketElements:String;											
			var count:int =0;
			var teamLimit:int = 2;
			
			for(var roundNum:int=0; roundNum<5; roundNum++){ //levels			
				
				for(var matchNum:int=0; matchNum<(Math.pow(2,4-roundNum-1)); matchNum++){//number of leafnodes in every level
					if(roundNum == 4){
						teamLimit = 1;
					}
					
					for(var teamNum:int=0; teamNum<teamLimit; teamNum++){	//matched up nodes					
						instanceNameForBracketElements = "round"+(roundNum+1)+"Match"+(matchNum+1)+"Team"+(teamNum+1)+"Button";								
						
						//-----mouse Up ----
						var samplebtn_doc:DisplayObjectContainer = this.bracket[instanceNameForBracketElements].upState as DisplayObjectContainer;
						var labelsamplebtn:TextField = samplebtn_doc.getChildAt(1) as TextField;
						if(teamNum == 0){
							labelsamplebtn.text = localBracketEntity.bracketNodeList[roundNum][(2*matchNum)].leafData;
							if( localBracketEntity.bracketNodeList[roundNum][(2*matchNum)].leafVisited == 1){
								this.bracket[instanceNameForBracketElements].upState.getChildAt(0).matrixToApply = matrixSelected;
								applyButtonColor(this.bracket[instanceNameForBracketElements]);
							}
						}
						else{ //teamNum =1
							labelsamplebtn.text = localBracketEntity.bracketNodeList[roundNum][(2*matchNum)+teamNum].leafData;
							if( localBracketEntity.bracketNodeList[roundNum][(2*matchNum)+teamNum].leafVisited == 1){
								this.bracket[instanceNameForBracketElements].upState.getChildAt(0).matrixToApply = matrixSelected;
								applyButtonColor(this.bracket[instanceNameForBracketElements]);
							}
						}
						
						//-----mouse Over ----
						samplebtn_doc = this.bracket[instanceNameForBracketElements].overState as DisplayObjectContainer;
						labelsamplebtn= samplebtn_doc.getChildAt(1) as TextField;
						if(teamNum == 0){
							labelsamplebtn.text = localBracketEntity.bracketNodeList[roundNum][(2*matchNum)].leafData;
						}
						else{ //teamNum =1
							labelsamplebtn.text = localBracketEntity.bracketNodeList[roundNum][(2*matchNum)+teamNum].leafData;
						}
						
						//-----mouse Down ----
						samplebtn_doc = this.bracket[instanceNameForBracketElements].downState as DisplayObjectContainer;
						labelsamplebtn = samplebtn_doc.getChildAt(1) as TextField;
						if(teamNum == 0){
							labelsamplebtn.text = localBracketEntity.bracketNodeList[roundNum][(2*matchNum)].leafData;
						}
						else{ //teamNum =1
							labelsamplebtn.text = localBracketEntity.bracketNodeList[roundNum][(2*matchNum)+teamNum].leafData;
						}												
					}			
				}
				if(roundNum==0){
					this.bracket[instanceNameForBracketElements].removeEventListener(MouseEvent.CLICK, selectNextRoundTeam);							
				}
			}					
		}		
		/****************************************************************/
		function clearBracket(mouseEvent:MouseEvent):void{				
			var instanceNameForBracketElements:String;											
			var count:int =0;
			var teamLimit:int = 2;
			for(var roundNum:int=0; roundNum<5; roundNum++){ //levels						
				for(var matchNum:int=0; matchNum<(Math.pow(2,4-roundNum-1)); matchNum++){//number of leafnodes in every level
					if(roundNum == 4){
						teamLimit = 1;
					}				
					for(var teamNum:int=0; teamNum<teamLimit; teamNum++){	//matched up nodes					
						instanceNameForBracketElements = "round"+(roundNum+1)+"Match"+(matchNum+1)+"Team"+(teamNum+1)+"Button";								
						
						//-----mouse Up ----
						var samplebtn_doc:DisplayObjectContainer = this.bracket[instanceNameForBracketElements].upState as DisplayObjectContainer;
						var labelsamplebtn:TextField = samplebtn_doc.getChildAt(1) as TextField;
						if(teamNum == 0){
							labelsamplebtn.text = "";
						}
						else{ //teamNum =1
							labelsamplebtn.text = "";
						}
						
						//-----mouse Over ----
						samplebtn_doc = this.bracket[instanceNameForBracketElements].overState as DisplayObjectContainer;
						labelsamplebtn= samplebtn_doc.getChildAt(1) as TextField;
						if(teamNum == 0){
							labelsamplebtn.text = "";
						}
						else{ //teamNum =1
							labelsamplebtn.text = "";
						}
						
						//-----mouse Down ----
						samplebtn_doc = this.bracket[instanceNameForBracketElements].downState as DisplayObjectContainer;
						labelsamplebtn = samplebtn_doc.getChildAt(1) as TextField;
						if(teamNum == 0){
							labelsamplebtn.text = "";
						}
						else{ //teamNum =1
							labelsamplebtn.text = "";
						}																
					}			
				}
			}			
		}
		/****************************************************************/
		function selectZone(mouseEvent:MouseEvent):void{
			var zone:String = mouseEvent.target.text;				
			switch(zone){
				case "East":
					if(selectedZone != "east"){		
						removeHighlight();
						eastBtnBkg.visible = true;
						resetButtonColors();
						selectedZone = "east";
					}					
					
					break;
				case "West":
					if(selectedZone != "west"){
						removeHighlight();
						westBtnBkg.visible = true;
						resetButtonColors();
						selectedZone = "west";
					}	

					break;
				case "South-West":
					if(selectedZone != "southWest"){
						removeHighlight();
						southWestBtnBkg.visible = true;
						resetButtonColors();
						selectedZone = "southWest";
					}						
					break;
				case "South-East":	
					if(selectedZone != "southEast"){
						removeHighlight();
						southEastBtnBkg.visible = true;
						resetButtonColors();
						selectedZone = "southEast";
					}						
					break;
			}			
			loadGame(selectedZone);
		}
		
		private function removeHighlight():void
		{
			eastBtnBkg.visible = false;
			westBtnBkg.visible = false;
			southEastBtnBkg.visible = false;
			southWestBtnBkg.visible = false;			
		}
		
		private function loadingScreen():void{
			var myFBID:String = SocialNetwork.getCurrentId();
			if(myFBID != null){
				loadScreen = new Loading_Screen;
				loadScreen.y = -75;
				loadScreen.message.text = "Loading the bracket!\n Please Wait...";
				addChild(loadScreen);
			}
		}
		/****************************************************************/	
		// Fill the data structure in any way you want to reflect changes in the buttons
		function populateLeafNodes():void{
			clearBracket(new MouseEvent("CLICK"));
			var teamObject:teamUtil = new teamUtil();
			//myTeamList will contain the top 64 teams for the playoffs
			var myTeamList:Array = teamObject.getTeams();			
			var count:int;
			
			//Configure appropriate teams
			switch(selectedZone){
				case "east":
					count = 0;
					this.bracketNodeList = bracketEntityEast.bracketNodeList;
					break;
				case "west":
					count = 16;
					this.bracketNodeList = bracketEntityWest.bracketNodeList;
					break;
				case "southWest":
					count = 32
					this.bracketNodeList = bracketEntitySouthWest.bracketNodeList;
					break;
				case "southEast":
					count = 48
					this.bracketNodeList = bracketEntitySouthEast.bracketNodeList;
					break;
			}			
			for(var i:int=0; i<5; i++){	
				var roundNodeList:Array = new Array();
				for(var j:int=0; j<Math.pow(2,4-i); j++){
					if(i == 0){
						roundNodeList[j] = new BracketDataStructure();
						roundNodeList[j].setLeafData(myTeamList[count++].teamName);												
					}
					else{
						roundNodeList[j] = new BracketDataStructure();
						roundNodeList[j].setLeafData("");
						//trace(j+" - "+roundNodeList[j].getLeafData());
					}						
				}
				//trace("bracketNodeList["+i+"]" + "= "+roundNodeList);
				this.bracketNodeList[i] = roundNodeList;
				switch(selectedZone){
					case "east":
						bracketEntityEast.bracketNodeList[i] = bracketNodeList[i];
						//bracketNodeListEast[i] = bracketNodeList[i];
						break;
					case "west":
						bracketEntityWest.bracketNodeList[i] = bracketNodeList[i];
						break;
					case "southWest":
						bracketEntitySouthWest.bracketNodeList[i] = bracketNodeList[i];
						break;
					case "southEast":
						bracketEntitySouthEast.bracketNodeList[i] = bracketNodeList[i];
						break;
				}	
			}									
			populateMyBracket();
		}
		/****************************************************************/		
		//This copies whatever is in first round of bracketNodeList DS to the buttons and adds the event listeners for the buttons.
		function populateMyBracket():void{
			var teamObject:teamUtil = new teamUtil();
			var myTeamList:Array = teamObject.getTeams();
			//bracketScrollPane.source = bracket;	
			//bracketScrollPane.hide;
			var instanceNameForBracketElements:String;											
			var count:int =0;
			var teamLimit:int = 2;
			for(var roundNum:int=0; roundNum<5; roundNum++){ //levels			
			
				for(var matchNum:int=0; matchNum<(Math.pow(2,4-roundNum-1)); matchNum++){//number of leafnodes in every level
					if(roundNum == 4){
						teamLimit = 1;
					}
					
					for(var teamNum:int=0; teamNum<teamLimit; teamNum++){	//matched up nodes					
						instanceNameForBracketElements = "round"+(roundNum+1)+"Match"+(matchNum+1)+"Team"+(teamNum+1)+"Button";								
						
						//-----mouse Up ----
						var samplebtn_doc:DisplayObjectContainer = this.bracket[instanceNameForBracketElements].upState as DisplayObjectContainer;
						var labelsamplebtn:TextField = samplebtn_doc.getChildAt(1) as TextField;
						if(teamNum == 0){
							labelsamplebtn.text = bracketNodeList[roundNum][(2*matchNum)].getLeafData();
						}
						else{ //teamNum =1
							labelsamplebtn.text = bracketNodeList[roundNum][(2*matchNum)+teamNum].getLeafData();
						}

						//-----mouse Over ----
						samplebtn_doc = this.bracket[instanceNameForBracketElements].overState as DisplayObjectContainer;
						labelsamplebtn= samplebtn_doc.getChildAt(1) as TextField;
						if(teamNum == 0){
							labelsamplebtn.text = bracketNodeList[roundNum][(2*matchNum)].getLeafData();
						}
						else{ //teamNum =1
							labelsamplebtn.text = bracketNodeList[roundNum][(2*matchNum)+teamNum].getLeafData();
						}
 
						//-----mouse Down ----
						samplebtn_doc = this.bracket[instanceNameForBracketElements].downState as DisplayObjectContainer;
						labelsamplebtn = samplebtn_doc.getChildAt(1) as TextField;
						if(teamNum == 0){
							labelsamplebtn.text = bracketNodeList[roundNum][(2*matchNum)].getLeafData();
						}
						else{ //teamNum =1
							labelsamplebtn.text = bracketNodeList[roundNum][(2*matchNum)+teamNum].getLeafData();
						}
											
						//Add event Listerners for elements of 0th rounds
						if(roundNum==0){
							this.bracket[instanceNameForBracketElements].addEventListener(MouseEvent.CLICK, selectNextRoundTeam);							
						}
						this.bracket[instanceNameForBracketElements].upState.getChildAt(0)["matrixToApply"] = matrixNotSelected;
					}			
				}
			}
		}
		/****************************************************************/
		function selectNextRoundTeam(mouseEvent:MouseEvent):void{
			var teamSelectedObject:Object = mouseEvent.target;
			var teamSelected:DisplayObjectContainer = teamSelectedObject.upState as DisplayObjectContainer;
			var teamSelectedLabel:TextField = teamSelected.getChildAt(1) as TextField;
			var selectedTeamMatchNumber:int;//1-8
			var selectedTeamNumber:int;//1-2
			var matchNumberForNextRound:int;//8,4,2,1
			var teamNumberForNextRound:int;//1-2
			var currentRound:int;//1-5
			var nextRound:int;//2-5
			var instanceNameForNextBracketElement:String;
			var checkEventListenerName:String;
			//Make bracketNodeList contain the data of the appropriate zone
			switch(selectedZone){
				case "east":
					bracketNodeList = bracketEntityEast["bracketNodeList"];
					//bracketNodeList = bracketNodeListEast;
					break;
				case "west":
					bracketNodeList = bracketEntityWest["bracketNodeList"];
					break;
				case "southWest":
				 	bracketNodeList = bracketEntitySouthWest["bracketNodeList"];
					break;
				case "southEast":
				 	bracketNodeList = bracketEntitySouthEast["bracketNodeList"];
					break;
			}	
			selectedTeamMatchNumber = (int)(teamSelectedObject.name.substring(11,12));
			selectedTeamNumber = (int)(teamSelectedObject.name.substring(16,17));
			currentRound = (int)(teamSelectedObject.name.substring(5,6));			
			nextRound = (int)(currentRound)+1;
			
			if(selectedTeamMatchNumber % 2 == 0){
				matchNumberForNextRound = (int)(selectedTeamMatchNumber/2);
				teamNumberForNextRound = 2;
			}
			else{
				matchNumberForNextRound = (int)((selectedTeamMatchNumber/2)+1);
				teamNumberForNextRound = 1;
			}
			
			instanceNameForNextBracketElement = "round"+nextRound+"Match"+matchNumberForNextRound+"Team"+teamNumberForNextRound+"Button";	
			
			checkEventListenerName = "round"+nextRound+"Match"+matchNumberForNextRound+"Team"+((teamNumberForNextRound%2)+1)+"Button";	
			if(nextRound != 5){
				if(this.bracket[checkEventListenerName].upState.getChildAt(0).matrixToApply != matrixSelected ){
					this.bracket[instanceNameForNextBracketElement].addEventListener(MouseEvent.CLICK, selectNextRoundTeam);	
				}
			}			
			//Part to select team for next round
			var winningTeamForCurrentRound:DisplayObjectContainer = this.bracket[instanceNameForNextBracketElement].upState as DisplayObjectContainer;
			var winningTeamForCurrentRoundLabel:TextField = winningTeamForCurrentRound.getChildAt(1) as TextField;
			winningTeamForCurrentRoundLabel.text = teamSelectedLabel.text;
			if(teamNumberForNextRound == 1){				
				bracketNodeList[nextRound - 1][2*(matchNumberForNextRound-1)].setLeafData(winningTeamForCurrentRoundLabel.text);				
			}
			else{ //teamNumberForNextRound == 2
				bracketNodeList[nextRound - 1][2*(matchNumberForNextRound-1) + (teamNumberForNextRound -1)].setLeafData(winningTeamForCurrentRoundLabel.text);				
			}			
			//set the selected team's leafvisited var to true
			bracketNodeList[currentRound - 1][2*(selectedTeamMatchNumber-1) + (selectedTeamNumber -1)].leafVisited = true;
			//bracketSaveObject[instanceNameForNextBracketElement] = winningTeamForCurrentRoundLabel.text;
			//Transfer the contents of brackNodeList to the appropriate bracketNodeList*Zone*
			switch(selectedZone){
				case "east":
					bracketEntityEast["bracketNodeList"] = bracketNodeList;
					//trace("East complete = "+checkCompletion(bracketEntityEast));
					//bracketNodeListEast = bracketNodeList;
					break;
				case "west":
					bracketEntityWest["bracketNodeList"] = bracketNodeList;
					//trace("West complete = "+checkCompletion(bracketEntityWest));
					break;
				case "southWest":
				 	bracketEntitySouthWest["bracketNodeList"] = bracketNodeList;
					//trace("southWest complete = "+checkCompletion(bracketEntitySouthEast));
					break;
				case "southEast":
				 	bracketEntitySouthEast["bracketNodeList"] = bracketNodeList;
					//trace("southEast complete = "+checkCompletion(bracketEntitySouthWest));
					break;
			}	
			
			//change the text for all animations of the buttons.
			winningTeamForCurrentRound = this.bracket[instanceNameForNextBracketElement].overState as DisplayObjectContainer;
			winningTeamForCurrentRoundLabel = winningTeamForCurrentRound.getChildAt(1) as TextField;
			winningTeamForCurrentRoundLabel.text = teamSelectedLabel.text;
			
			winningTeamForCurrentRound = this.bracket[instanceNameForNextBracketElement].downState as DisplayObjectContainer;
			winningTeamForCurrentRoundLabel = winningTeamForCurrentRound.getChildAt(1) as TextField;
			winningTeamForCurrentRoundLabel.text = teamSelectedLabel.text;
			
			//remove event listener and change button color for teams of the current match
			onSelectChangeButton(teamSelectedObject,selectedTeamMatchNumber, currentRound);									
		}
		/****************************************************************/
		//Calls applyButtonColor and changes color of button
		function onSelectChangeButton(selectedTeam:Object, currentMatch:int, currentRound:int):void{			
			var currentButtonName:String;
			for(var currentTeam:int=1; currentTeam<=2; currentTeam++){
				currentButtonName = "round"+currentRound+"Match"+currentMatch+"Team"+currentTeam+"Button";
				this.bracket[currentButtonName].removeEventListener(MouseEvent.CLICK, selectNextRoundTeam);				
			}				
								
			selectedTeam.upState.getChildAt(0)["matrixToApply"] = matrixSelected;			
			applyButtonColor(selectedTeam);
		}
		/****************************************************************/		
		//Check status of the brackets for each zone: Provides teams chosen, completed and saved status
		function displayZoneNodes(zone:String):void{
			var bracketNodeList:Array;
			switch(selectedZone){
				case "east":
					bracketNodeList = bracketEntityEast.bracketNodeList;
					//bracketNodeList = bracketNodeListEast;
					break;
				case "west":
					bracketNodeList = bracketEntityWest.bracketNodeList;
					break;
				case "southWest":
				 	bracketNodeList = bracketEntitySouthWest.bracketNodeList;
					break;
				case "southEast":
				 	bracketNodeList = bracketEntitySouthEast.bracketNodeList;
					break;
			}				
			for(var roundNum:int=0; roundNum<5; roundNum++){ 					
				trace("Round:"+roundNum);
				for(var matchNum:int=0; matchNum<(Math.pow(2,4-roundNum)); matchNum++){
					trace(bracketNodeList[roundNum][matchNum].getLeafData());					
				}				
				trace("");				
			}
			switch(selectedZone){
				case "east":
					trace("East Completed:"+bracketEntityEast.completed);
					trace("East Saved:"+bracketEntityEast.saved);
					break;
				case "west":
					trace("West Completed:"+bracketEntityWest.completed);
					trace("West Saved:"+bracketEntityWest.saved);					
					break;
				case "southWest":
				 	trace("South West Completed:"+bracketEntitySouthWest.completed);
					trace("South West Saved:"+bracketEntitySouthWest.saved);					
					break;
				case "southEast":
				 	trace("South East Completed:"+bracketEntitySouthEast.completed);
					trace("South East Saved:"+bracketEntitySouthEast.saved);					
					break;
			}					
		}
		/****************************************************************/
		function savePicks(mouseEvent:MouseEvent):void{
			//displayZoneNodes(selectedZone);
			var myfbid:String = SocialNetwork.getCurrentId(); 
			switch(selectedZone){
				case "east":					
					bracketNodeList = bracketEntityEast.bracketNodeList;
					if(checkCompletion(bracketEntityEast)){
						if(!bracketEntityEast.saved){							
							bracketEntityEast.saved = true;						
							if(myfbid != null){
								loadScreen = new Loading_Screen;
								loadScreen.y = -75;
								loadScreen.message.text = "Saving your 'East' bracket!\n Please Wait...";
								addChild(loadScreen);							
								save();
							}							
						}
						else{
							promptScreen = new Prompt_Screen();						
							promptScreen.message.text = "You've already saved your pool!\n Please wait for the results.";
							promptScreen.okButton.addEventListener(MouseEvent.CLICK, function(){removeChild(promptScreen);});
							addChild(promptScreen);	
						}
					}
					else{						
						promptScreen = new Prompt_Screen();						
						promptScreen.message.text ="Can't save yet.\n Please complete the bracket.";
						promptScreen.okButton.addEventListener(MouseEvent.CLICK, function(){removeChild(promptScreen);});
						addChild(promptScreen);						
					}
					break;
				case "west":
					bracketNodeList = bracketEntityWest.bracketNodeList;
					if(checkCompletion(bracketEntityWest)){
						if(!bracketEntityWest.saved){
							bracketEntityWest.saved = true;													
							if(myfbid != null){
								loadScreen = new Loading_Screen;
								loadScreen.y = -75;
								loadScreen.message.text = "Saving your 'West' bracket!\n Please Wait...";
								addChild(loadScreen);							
								save();
							}
						}
						else{
							promptScreen = new Prompt_Screen();						
							promptScreen.message.text ="You've already saved your pool!\n Please wait for the results.";
							promptScreen.okButton.addEventListener(MouseEvent.CLICK, function(){removeChild(promptScreen);});
							addChild(promptScreen);	
						}
					}
					else{
						promptScreen = new Prompt_Screen();						
						promptScreen.message.text ="Can't save yet.\n Please complete the bracket.";
						promptScreen.okButton.addEventListener(MouseEvent.CLICK, function(){removeChild(promptScreen);});
						addChild(promptScreen);						
					}
					break;
				case "southEast":
					bracketNodeList = bracketEntitySouthEast.bracketNodeList;
					if(checkCompletion(bracketEntitySouthEast)){
						if(!bracketEntitySouthEast.saved){
							bracketEntitySouthEast.saved = true;						
							if(myfbid != null){
								loadScreen = new Loading_Screen;
								loadScreen.y = -75;
								loadScreen.message.text = "Saving your 'South East' bracket!\n Please Wait...";
								addChild(loadScreen);							
								save();
							}
						}
						else{
							promptScreen = new Prompt_Screen();						
							promptScreen.message.text = "You've already saved your pool!\n Please wait for the results.";
							promptScreen.okButton.addEventListener(MouseEvent.CLICK, function(){removeChild(promptScreen);});
							addChild(promptScreen);	
						}
					}
					else{
						promptScreen = new Prompt_Screen();						
						promptScreen.message.text ="Can't save yet.\n Please complete the bracket.";
						promptScreen.okButton.addEventListener(MouseEvent.CLICK, function(){removeChild(promptScreen);});
						addChild(promptScreen);						
					}
					break;
				case "southWest":
					bracketNodeList = bracketEntitySouthWest.bracketNodeList;
					if(checkCompletion(bracketEntitySouthWest)){
						if(!bracketEntitySouthWest.saved){
							bracketEntitySouthWest.saved = true;						
							if(myfbid != null){
								loadScreen = new Loading_Screen;
								loadScreen.y = -75;
								loadScreen.message.text = "Saving your 'South West' bracket!\n Please Wait...";
								addChild(loadScreen);							
								save();
							}
						}
						else{
							promptScreen = new Prompt_Screen();						
							promptScreen.message.text = "You've already saved your pool!\n Please wait for the results.";
							promptScreen.okButton.addEventListener(MouseEvent.CLICK, function(){removeChild(promptScreen);});
							addChild(promptScreen);	
						}
					}
					else{
						promptScreen = new Prompt_Screen();						
						promptScreen.message.text ="Can't save yet.\n Please complete the bracket.";
						promptScreen.okButton.addEventListener(MouseEvent.CLICK, function(){removeChild(promptScreen);});
						addChild(promptScreen);				
					}
					break;
			}
		}
		/****************************************************************/
		function checkCompletion(zoneBracket:Object):Boolean{
			var completionFlag:Boolean = true;
			for(var roundNum:int=0; roundNum<5; roundNum++){ //levels										
				for(var matchNum:int=0; matchNum<(Math.pow(2,4-roundNum)); matchNum++){//number of leafnodes in every level
					if(bracketNodeList[roundNum][matchNum].leafData == ""){
						completionFlag = false;
						break;
					}					
				}				
				if(completionFlag ==false){
						break;
					}					
				//end of for matchNum
			}
			if(completionFlag == true){
					zoneBracket.completed = true;					
			}
			return zoneBracket.completed;
		}
		/****************************************************************/
		function save():void{			
			trace('Saving Picks now');					
			var id:String = SocialNetwork.getCurrentId();
			if(id != null) {
				var gclient:GameClient = GameClient.getInstance();
				var gameStateZoneBracket:Object;				
				
				switch(selectedZone){
					case "east":						
						gameStateZoneBracket = bracketEntityEast;
						id = SocialNetwork.getCurrentId() + ":eastBracket";						
						break;
					case "west":
						gameStateZoneBracket = bracketEntityWest;
						id = SocialNetwork.getCurrentId() + ":westBracket";
						break;						
					
					case "southEast":
						gameStateZoneBracket = bracketEntitySouthEast;
						id = SocialNetwork.getCurrentId() + ":southEastBracket";
						break;
					
					case "southWest":
						gameStateZoneBracket = bracketEntitySouthWest;
						id = SocialNetwork.getCurrentId() + ":southWestBracket";
						break;					
				}				
				gclient.saveGame(id, gameStateZoneBracket, onSaved);				
			}			
		}			
		/****************************************************************/
		function onSaved(result:Object):void{
			promptScreen = new Prompt_Screen();						
			promptScreen.message.text ="Your "+selectedZone.toUpperCase()+" bracket was saved Successfully!";
			promptScreen.okButton.addEventListener(MouseEvent.CLICK, function(){removeChild(promptScreen);});
			removeChild(loadScreen);
			addChild(promptScreen);	
		}
	}	
}
