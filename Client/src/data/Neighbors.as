package data
{
	import services.RemoteCall;
	
	public class Neighbors
	{
		private static var instance:Neighbors;

		function Neighbors()
		{	
		}
		
		public static function getInstance():Neighbors
		{
			if(instance == null)
				instance = new Neighbors();
			return instance;
		}
		
		public function getNeighbors(callback:Function):void{
			var remote:RemoteCall = new RemoteCall(callback);
			remote.call("NeighborService.getNeighbors", Config.user_token, Config.user);
		}
						
	}
}
