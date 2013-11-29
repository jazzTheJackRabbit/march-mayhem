package classes{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import assets.Character;
	import assets.Prompt_Screen;
	
	import data.Config;
	
	import gameentity.Ball;
	
	import services.GameClient;
	
	import social.SocialNetwork;
	
	public class Game_Play extends MovieClip implements IEventDispatcher {
		
		var angleA:Number;
		var power:Number;
		var degrees:Number;
		var m_ball:Ball;
		var timer:Timer;
		var playingTime:int = 15;
		var score:int = 0;		
		public var highScore:Object = new Object;
		public var gameStarted:Boolean = false;
		public var gamePaused:Boolean = false;
		public var startPause:Boolean = true; // true for text = start - false for text = pause
		
		public static const GAME_OVER:String = "gameOver";
		
		private var droppingFromCircle1:Boolean=false;		
		private var droppingFromCircle2:Boolean=false;		
		public var promptScreen:Prompt_Screen;
		
		public function Game_Play(){
			stop();
			angleA=0;
			power=0;
			degrees=0;						
			highScore["value"] = 0;
			highScore["loadedFromServer"] = false;			
			boy.visible = false;
			promptScreen = new Prompt_Screen();
			if(stage)				
				addedToStage();			
			else				
				this.addEventListener(Event.ADDED_TO_STAGE, addedToStage);
	    }

		private function addedToStage(e:Event = null):void{			
			removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			setScoreBoardToDefault();						
			loadHighScore();			
			this.scoreBoard.startButton.addEventListener(MouseEvent.CLICK, startGame);			
			//startGame(new MouseEvent("CLICK"));
			//moveBoy();			
		}
		
		public function startGame(e:MouseEvent):void{	
			if(startPause){
				setScoreBoardToDefault();
				startTimer();
				setTimerCountdown(playingTime);				
				boy.visible = true;
				powerdrag.visible = true;
				score = 0;			
				changeStartButtonName("Pause");
				startPause = false;
				moveBoy();
			}
			else{
				//PAUSE GAME
				if(!gamePaused){
					pauseGame();
					//pull promt screen
					promptScreen = new Prompt_Screen();
					promptScreen.x = 0;
					promptScreen.y = 85;
					promptScreen.message.text = "Game Paused.\n Click 'OK' to resume.";
					promptScreen.okButton.addEventListener(MouseEvent.CLICK, resumeGame);
					addChild(promptScreen); 	
				}				
			}
		}
		
		public function pauseGame():void
		{
			changeStartButtonName("Resume");
			gamePaused = true;
			boy.b1.stop();
			stopTimer();							
			boy.visible = false;
			powerdrag.visible = false;	
			
		}
		
		public function resumeGame(e:MouseEvent):void{
			changeStartButtonName("Pause");
			gamePaused = false;
			boy.visible = true;
			powerdrag.visible = true;
			boy.b1.play();
			startTimer();
			moveBoy();
			if(promptScreen.stage){
				removeChild(promptScreen);
			}
		}
		
		private function stopTimer():void
		{			
			timer.stop();
			//pull pause screen;
		}
		
		private function loadHighScore():void{
			var gClient:GameClient = GameClient.getInstance();
			var keyForLoad:String = Config.user;			
			if(highScore.loadedFromServer == false){
				if(keyForLoad!=null){					
						keyForLoad = keyForLoad + ":highScore";
						gClient.loadGame(keyForLoad,onLoadHighScore);		
				}
				else{
					//for testing purposes where id = null
					renderHighScore(highScore);					
				}
			}
			else{				
				renderHighScore(highScore);
			}			
		}
		
		private function onLoadHighScore(resultTotalScore:Object):void
		{
			if(resultTotalScore == false)
			{
				highScore.value=0;
				highScore.loadedFromServer = true;
				renderHighScore(highScore);
			}
			else
			{
				highScore.value= resultTotalScore.value;
				highScore.loadedFromServer = true;
				renderHighScore(highScore);
			}
			dispatchEvent(new Event(Game_Play.GAME_OVER));
		}
	   
		private function changeStartButtonName(param0:String):void
		{
			scoreBoard.startButton.upState.getChildAt(1).text = param0;
			scoreBoard.startButton.downState.getChildAt(1).text = param0;
			scoreBoard.startButton.overState.getChildAt(1).text = param0;			
		}
		
		private function startTimer():void{			
			if(!gameStarted){
				gameStarted = true;
				timer = new Timer(1000, playingTime);			
				timer.addEventListener(TimerEvent.TIMER, timerCountdown);
			}
			timer.start();							
		}		
		
		private function timerCountdown(e:TimerEvent):void{		
			setTimerCountdown(playingTime - timer.currentCount);
		}
		
		private function setTimerCountdown(currentTime:int):void
		{
			
			var minutes:int = Math.floor(currentTime / 60);//1
			var seconds:int = currentTime % 60;//30
			
			var minutesUnits:int = (minutes % 10);
			var minutesTens:int = (minutes / 10);
			
			var secondsUnits:int = (seconds % 10);
			var secondsTens:int = (seconds / 10);
			
			scoreBoard.timerMinutesUnits.gotoAndStop(minutesUnits+1);
			scoreBoard.timerMinutesTens.gotoAndStop(minutesTens+1);
			
			scoreBoard.timerSecondsUnits.gotoAndStop(secondsUnits+1);			
			scoreBoard.timerSecondsTens.gotoAndStop(secondsTens+1);
			
			if(currentTime == 0){
				
				endGame();			
			}
		}
		
		public function endGame():void
		{			
			timer.stop();
			gameStarted = false;
			startPause = true;
			boy.visible = false;
			powerdrag.visible = false;
			changeStartButtonName("Start");
			//check if score is > than highScore
			if(score > highScore.value){
				highScore.value = score;
				renderHighScore(highScore);
				saveHighScore();			
			}			
			dispatchEvent(new Event(Game_Play.GAME_OVER));
		}
		
		function setScoreBoardToDefault():void{			
			scoreBoard.scoreUnits.gotoAndStop(1);
			scoreBoard.scoreTens.gotoAndStop(1);
			scoreBoard.scoreHundreds.gotoAndStop(1);
			
			if(highScore.value == 0){
				scoreBoard.highScoreUnits.gotoAndStop(1);
				scoreBoard.highScoreTens.gotoAndStop(1);
				scoreBoard.highScoreHundreds.gotoAndStop(1);
			}
			
			scoreBoard.timerSecondsUnits.gotoAndStop(1);
			scoreBoard.timerSecondsTens.gotoAndStop(1);
			scoreBoard.timerMinutesUnits.gotoAndStop(1);
			scoreBoard.timerMinutesTens.gotoAndStop(1);
		}
		
		function addScore():void
		{
			score++;											
			var scoreUnits:int = 0;
			var scoreTens:int = 0;
			var scoreHundreds:int = 0;								
			
			if(score<100){
				scoreUnits = score % 10;
				scoreTens = score / 10;
			}					
			else{
				scoreUnits = score % 10;
				scoreTens = scoreTens / 10;
				scoreTens = scoreTens % 10;
				scoreHundreds = score / 100;
			}			
			
			scoreBoard.scoreUnits.gotoAndStop(scoreUnits + 1);
			scoreBoard.scoreTens.gotoAndStop(scoreTens + 1);
			scoreBoard.scoreHundreds.gotoAndStop(scoreHundreds + 1);															
		}
		
		function renderHighScore(highScoreObj:Object):void{
			var high_score:int = highScoreObj.value;
			var highScoreUnits:int = 0;
			var highScoreTens:int = 0;
			var highScoreHundreds:int = 0;
			
			if(high_score<100){
				highScoreUnits = high_score % 10;
				highScoreTens = high_score / 10;
				highScoreHundreds = 0 ;
			}
				
			else{
				highScoreUnits = high_score % 10;
				highScoreTens = highScoreTens / 10;
				highScoreTens = highScoreTens % 10;
				highScoreHundreds = high_score / 100;	
			}
			
			scoreBoard.highScoreUnits.gotoAndStop(highScoreUnits + 1);
			scoreBoard.highScoreTens.gotoAndStop(highScoreTens + 1);
			scoreBoard.highScoreHundreds.gotoAndStop(highScoreHundreds + 1);
		}
		
		function saveHighScore():void
		{								
			var gclient:GameClient = GameClient.getInstance();		
			var id:String = SocialNetwork.getCurrentId();
			var keyForSave:String;
			highScore["myFBID"] = id;
			if(id != null) {
				keyForSave = id + ":highScore";
				gclient.saveGame(keyForSave, highScore , onHighScoreSave );
			}					
		}
		
		function onHighScoreSave(result:Object):void
		{
		
		}
		
		function moveBoy():void {
			boy.b1.gotoAndStop(1);
			boy.x=265+Math.random()*275;
			setPosition();
			/*dis.distance_txt.text=String(nest.x-boy.x);
			boy.b1.play();
			if (mouseX>boy.x) {
				if (mouseX-boy.x>10) {
					boy.x+=5;

				} else {
					boy.b1.gotoAndStop(1);
				}
			} else if (mouseX<boy.x) {
				if (mouseX-boy.x<10) {
					boy.x-=5;
				} else {
					boy.b1.gotoAndStop(1);
				}
			}*/
			
		}
		function setPosition():void {
			//trace(powerdrag);
			powerdrag.x=boy.x+20;
			//var stage2:DisplayObject = stage; //WHAT IS THIS GUY DOING?
			//trace(stage2);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, rotat);
		}
		function rotat(e:MouseEvent):void {			
			var a:Number = powerdrag.y-stage.mouseY;
			var b:Number = powerdrag.x-stage.mouseX;
			angleA = Math.atan2(-a, -b);
			degrees = angleA * 180 / 3.141593;
			if(power<=20){
			power = Math.min(20, Math.sqrt(a*a+b*b)/10);
			}
			//trace(">> power "+power);
			pow.power_txt.text=String(power);
			powerdrag.arrow.x=-power*10;
			powerdrag.rotation=degrees+180;
			ang.angle_txt.text=String(90-Math.round(degrees+90));
			stage.addEventListener(MouseEvent.MOUSE_UP, startThrow);
		}
		function startThrow(e:MouseEvent):void{
			if(gameStarted && !gamePaused){
				boy.b1.play();				
			}
		}
		public function throwBall(p_ball:Ball):void {
			if((mouseX<770) && (mouseY<350)){
				var addx:Number =  Math.cos(angleA) * power * 1.2;
				var addy:Number =  Math.sin(angleA) * power * 1.2;
				m_ball = p_ball;
				m_ball.x = m_ball.x - Math.cos(angleA) * 32;
				m_ball.y = m_ball.y - Math.sin(angleA) * 32;
				//trace("m_ball>> "+m_ball);
				m_ball.addx = -addx;
				m_ball.addy = addy;
				m_ball.init();
				//trace(p_ball.addx);
				powerdrag.arrow.x=0;
				stage.removeEventListener(MouseEvent.MOUSE_UP, throwBall);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, rotat);
				stage.addEventListener(Event.ENTER_FRAME, checkHit);
			}
		}
		function checkHit(e:Event):void {
			//trace(">> n1 = "+n1);
			//trace(">> n2 = "+n2);
			//trace(">> n3 = "+n3);
			//trace(">> n4 = "+n4);
			
			//trace(">> n6 = "+m_ball);
			
			if(m_ball.n.hitTestObject(n3)){
				m_ball.addx=-m_ball.addx;
				//trace("n3");
			}//trace(">> n5 = "+n5);
			if(m_ball.n.hitTestObject(n7)){
				droppingFromCircle1=true;
			}
			if(m_ball.n.hitTestObject(n2)){
				if(droppingFromCircle1){
					m_ball.addx=0;
				}
				net.play();
				droppingFromCircle2=true;
				//trace("n2");
			}
			if(m_ball.n.hitTestObject(n1)){
				m_ball.addx=-m_ball.addx;
				m_ball.addy=-m_ball.addy;
				//trace("n1");
				net.play();
			}
			if(m_ball.n.hitTestObject(n5)){
				m_ball.addx=-m_ball.addx;
				//trace("n1");
			}
			if(m_ball.n.hitTestObject(n4)){
				
				m_ball.addy=-m_ball.addy;
				//trace("n1");
			}
			//trace(">> n7 = "+n7);
			if(m_ball.n.hitTestObject(n6)){
				if(droppingFromCircle2){					
					if(gameStarted == true){
						addScore();
						lady_mc.play();
					}
					droppingFromCircle1=false;
					droppingFromCircle2=false;
				}else{
					net.play();
				}
			}
			
			if (m_ball.done) {
				stage.removeEventListener(Event.ENTER_FRAME, checkHit);
				//stage.addEventListener(Event.ENTER_FRAME, moveBoy);
				if(gameStarted){
					moveBoy();
				}								
				//stage.addEventListener(MouseEvent.MOUSE_UP, setPositionk);
			}
		}							
	}
}

