<?php

function sendGift ($token, $from, $to, $item, $count, $nonce)
{
	if (!$from || $from == "")
		return array ();
	if (!$to || $to == "")
		return array ();
	if (!$item || $item == "")
		$item = "item";
	global $rstore;
	if($rstore == null)
		$rstore = new RedisStore();
	$from = str_replace (SN_PREFIX, "", $from);
	$to = str_replace (SN_PREFIX, "", $to);
	$key = "viral_".$to;
	$obj = getFromStore ($key);
	if ($obj == false)
	{
		$obj = array ();
	}
	if (!isset ($obj[$from]))
	{
		$obj[$from] = array ();
	}
	if (!isset ($obj[$from][$item]))
	{
		$obj[$from][$item] = 0;
	}
	$obj[$from][$item] += $count;

	if ($rstore->setToStore ($key, $obj) == false)
	{
		return "not ok";
	}
	return "ok";
}

function getGifts ($token, $uid)
{
	if (!$uid || $uid == "")
		return array ();
	global $rstore;
	if($rstore == null)
		$rstore = new RedisStore();
	$uid = str_replace (SN_PREFIX, "", $uid);
	$key = "viral_".$uid;
	$obj = $rstore->getFromStore ($key);
	return $obj;
}

function nukeGifts ($token, $uid)
{
	if (!$uid || $uid == "")
		return array ();
	global $rstore;
	if($rstore == null)
		$rstore = new RedisStore();
	$uid = str_replace (SN_PREFIX, "", $uid);
	$key = "viral_".$uid;
	if ($rstore->removeFromStore ($key) == false)
	{
		return "not ok";
	}
	return "ok";
}

?>
