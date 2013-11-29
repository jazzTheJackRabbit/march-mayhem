<?php

function uploadData($uid, $key, $value) {
	global $fstore;
	if($fstore == null)
		$fstore = new S3Store();
	if(!$uid || $uid == "")
		return array();
	$uid = str_replace(SN_PREFIX,"",$uid);
	$key="UL".$uid.$key;
	if($fstore->setToStore($key,$value) != false)
	{
		return "ok";
	}
	return "not ok";
}

function downloadData($uid, $key) {
	global $fstore;
	if($fstore == null)
		$fstore = new S3Store();
	if(!$uid || $uid == "")
		return array();
	$uid = str_replace(SN_PREFIX,"",$uid);
	$key="UL".$uid.$key;
	$val = $fstore->getFromStore($key);
	return $val;
}

?>
