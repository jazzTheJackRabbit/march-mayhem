<?php class UserService
{
	public function createUser($uid) {
		return createUser($uid);
	}

	public function getUser($uid){ 
		return getUser($uid);
	}

	public function nukeUser($uid){
		return nukeUser($uid);
	}

	public function addGameToInProgress($uid, $gamekey) {
		return addGameToInProgress($uid, $gamekey);
	}

	public function getGamesForUser($uid) {
		return getGamesForUser($uid);
	} 

	public function saveUser($uid,$data)
	{
		return saveUser($uid,$data);
	}
}

?>
