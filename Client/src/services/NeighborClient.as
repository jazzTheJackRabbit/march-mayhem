package services
{
	import data.Config;
	
	public class NeighborClient
	{
		private static var instance:NeighborClient;

		function NeighborClient()
		{	
		}
		
		public static function getInstance():NeighborClient
		{
			if(instance == null)
				instance = new NeighborClient();
			return instance;
		}
		
		public function getNeighbors(callback:Function):void{
			var remote:RemoteCall = new RemoteCall(callback);
			remote.call("NeighborService.getNeighbors", Config.user_token, Config.user);
		}
						
	}
}
