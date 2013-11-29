package classes{
	import flash.display.MovieClip;

	public class SetupWinners extends MovieClip{
		
		public var eastBracket:Array;
		public var westBracket:Array;
		public var southEastBracket:Array;
		public var southWestBracket:Array;
		public function SetupWinners(){
			eastBracket = new Array();
			eastBracket[1] = ["Albany Great Danes","Hartford Hawks","Maine Black Bears","Stony Brook Seawolves","Vermont Catamounts","Charlotte 49ers","Duquesne Dukes","La Salle Explorers"]; 
			eastBracket[2] = ["Hartford Hawks","Stony Brook Seawolves","Charlotte 49ers","La Salle Explorers"];
			eastBracket[3] = ["Hartford Hawks","Charlotte 49ers"];
			eastBracket[4] = ["Hartford Hawks"];			
		}
		
		public function setWinningBracket(){
			
		}			
	}
}