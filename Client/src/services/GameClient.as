﻿package services{	import data.Config;		public class GameClient	{		private static var instance:GameClient;		function GameClient()		{			}				public static function getInstance():GameClient		{			if(instance == null)				instance = new GameClient();			return instance;		}				public function loadGame(user:String, callback:Function):void{			var remote:RemoteCall = new RemoteCall(callback);			if(user == null)				user = Config.user;			remote.call("GameService.loadGame", user);		}				public function saveGame(user:String, state:Object, callback:Function):void{			var remote:RemoteCall = new RemoteCall(callback);			if(user == null)				user = Config.user;			remote.call("GameService.saveGame", user, state);		}				public function nukeGame (user:String, callback:Function):void{			var remote:RemoteCall = new RemoteCall(callback);			if(user == null)				user = Config.user;			remote.call("GameService.nukeGame", user);		}	}}