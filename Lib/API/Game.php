<?php

define ('GAME_PREFIX', "gameCWF");

function nukeGame($fromid, $toid = "NONE") {
	global $rstore;
	if($rstore == null)
		$rstore = new RedisStore();
	if(!$fromid || $fromid == "")
		return array();
	if(!$toid || $toid == "")
		return array();
	$fromid = str_replace(SN_PREFIX,"",$fromid);
	$toid = str_replace(SN_PREFIX,"",$toid);
	$key = GAME_PREFIX;
	if(strcmp($fromid, $toid) <= 0) {
		$key .= "_".$fromid;
		$key .= "_".$toid;		
	} else {
		$key .= "_".$toid;
		$key .= "_".$fromid;
	}
	if($rstore->removeFromStore($key) != false)
		return "ok";
	return "not ok";
}

function saveGame($fromid, $state = null, $toid = "NONE") {
	global $rstore;

	if($rstore == null)
		$rstore = new RedisStore();
	if(!$fromid || $fromid == "")
		return array();
	if(!$toid || $toid == "")
		return array();
	$fromid = str_replace(SN_PREFIX,"",$fromid);
	$toid = str_replace(SN_PREFIX,"",$toid);
	$key = GAME_PREFIX;
	if(strcmp($fromid, $toid) <= 0) {
		$key .= "_".$fromid;
		$key .= "_".$toid;		
	} else {
		$key .= "_".$toid;
		$key .= "_".$fromid;
	}
	$newGame = false;
	if(!$rstore->inStore($key))
	{
		// new game
		$newGame = true;
	}
		
	if($rstore->setToStore($key,$state) != false)
	{
		if($newGame)
		{
			if($fromid != "NONE")
			addGameToInProgress($fromid,$key);
			if($toid != "NONE")
			addGameToInProgress($toid,$key);
		}
		return "ok";
	}
	return "not ok";
}

function loadGame($fromid, $toid = "NONE") {
	global $rstore;
	if($rstore == null)
		$rstore = new RedisStore();
	if(!$fromid || $fromid == "")
		return array();
	if(!$toid || $toid == "")
		return array();
	$fromid = str_replace(SN_PREFIX,"",$fromid);
	$toid = str_replace(SN_PREFIX,"",$toid);
	$key = GAME_PREFIX;
	if(strcmp($fromid, $toid) <= 0) {
		$key .= "_".$fromid;
		$key .= "_".$toid;		
	} else {
		$key .= "_".$toid;
		$key .= "_".$fromid;
	}	
	$val = $rstore->getFromStore($key);

	return $val;
}

?>
