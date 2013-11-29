<?php

define ('USER_PREFIX', "user_CWF");

function createUser($uid) {
	global $rstore;
	if($rstore == null)
		$rstore = new RedisStore();
	if(!$uid || $uid == "")
		return array();
	$uid = str_replace(SN_PREFIX,"",$uid);
	$key=USER_PREFIX.$uid;
	if($rstore->inStore($key)) {
		return $rstore->getFromStore($key);
	}
	$value = array();
	$value['uid'] = SN_PREFIX.$uid;
	$value['score'] = 0;
	$value['coins'] = 0;
	$value['gamesInProgress']	= array();
	$value['gamesCompleted']	= array();
	if($rstore->setToStore($key,$value) != false)
	{
		return true;
	}
	return false;
}

function getUser($uid) {
	global $rstore;
	if($rstore == null)
		$rstore = new RedisStore();
	if(!$uid || $uid == "")
		return null;
	$uid = str_replace(SN_PREFIX,"",$uid);
	$key=USER_PREFIX."_".$uid;
	$value = false;
	if( ($value = $rstore->getFromStore($key)) != false)
	{
		return $value;
	}

	if($value = createUser($uid) != false)
		return $value;

	return null;
}

function nukeUser($uid)
{
	global $rstore;

	if($rstore == null)
		$rstore = new RedisStore();

	if(!$uid)
		return "ok";

	$uid = str_replace(SN_PREFIX,"",$uid);
	$key=USER_PREFIX."_".$uid;

	$rstore->removeFromStore($key);

	return "ok";

}

function addGameToInProgress($uid, $gameKey) {
	global $rstore;
	if($rstore == null)
		$rstore = new RedisStore();
	if(!$uid || $uid == "")
		return array();
	if(getUser($uid) == null)
		return "not ok";
	$uid = str_replace(SN_PREFIX,"",$uid);
	$key=USER_PREFIX."_".$uid;
	$value = false;
	if( ($value = $rstore->getFromStore($key)) != false)
	{
		if(in_array($gameKey, $value->gamesInProgress)) {
		} else {
			$value->gamesInProgress[] = $gameKey;
		}
		if($rstore->setToStore($key, $value) != false)
		{
			return "ok";
		}
	}
	return "not ok";
}

function getGamesForUser($uid)
{
	global $rstore;
	if($rstore == null)
		$rstore = new RedisStore();
	if(!$uid || $uid == "") 
		return array();
	$user = getUser($uid);
	if($user == null)
		return array();
	error_log(print_r($user, true));
	try{
		$result = array();
		foreach($user->gamesInProgress as $gameKey => $gameKeyValue)
		{
			$result[$gameKeyValue] = $rstore->getFromStore($gameKeyValue);
		}
	} catch(Exception $e) {
		$result = array();
	}
	return $result;
}

function saveUser($uid,$state = null) {
	global $rstore;
	if($rstore == null)
		$rstore = new RedisStore();
	if(!$uid || $uid == "") 
		return array();
	if(!$state)
		return false;

	$uid = str_replace(SN_PREFIX,"",$uid);
	$key=USER_PREFIX."_".$uid;

	if($rstore->setToStore($key,$state) != false)
	{   
		return true;
	}   
	return false;
}

?>
