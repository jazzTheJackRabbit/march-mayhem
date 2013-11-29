<?php
class GameService {
	
	public function nukeGame($fromid, $toid = "NONE") {
		return nukeGame($fromid, $toid);
	}
		
	public function saveGame($fromid, $state, $toid = "NONE") {
		return saveGame($fromid, $state, $toid);
	}
	
	public function loadGame($fromid, $toid = "NONE") {
		return loadGame($fromid, $toid);
	}
	
}
?>
