<?php
require_once ( dirname(__FILE__) . DIRECTORY_SEPARATOR . 'Gifts.php' );

function getNeighbors($token, $uid) {
	$paramUid = $uid;
	if(!$uid || $uid == "")
		return array();
	$uid = str_replace(SN_PREFIX,"",$uid);
	$result=array();
	$result['uid']=array();
	$result['first_name']=array();

	$me = $uid;
		
	$facebook = new Facebook(array(
			'appId'  => AppInfo::appID(),
			'secret' => AppInfo::appSecret(),
	));
	$facebook->setAccessToken($token);
	$user = $facebook->getUser();
	$friends = $facebook->api(array(
			'method' => 'fql.query',
			'query' => "SELECT uid, first_name, is_app_user FROM user WHERE uid in (SELECT uid2 FROM friend WHERE uid1 = me())",
	));

	$name_lookup = array();
	foreach ($friends as $friend) {
		$uid = idx($friend, 'uid');
		$key = SN_PREFIX.$uid;
		$name = idx($friend,'first_name');
		if(!$name || $name == "") {
			$name="Anonymous";
		}
		$is_user = idx($friend, 'is_app_user');
		$name_lookup[$key]=$name;
		$result['uid'][]=$key;
		$result['first_name'][] = $name;
		if($is_user == "1") {
			$result['plays'][]=true;
		} else {
			$result['plays'][]=false;
		}
	}

	return $result;
}


?>
