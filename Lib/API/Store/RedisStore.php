<?php

require_once ( dirname(__FILE__) . DIRECTORY_SEPARATOR . 'Store.php' );

class RedisStore extends Store
{
	function __construct() {
		global $redisServerPool;
		$redisServerPool =  array(
			/* 0 => $_SERVER['REDISTOGO_URL'], */			 	
0 => "redis://redistogo:6c46750e1c357c31b127cf46e6c57347@scat.redistogo.com:9836/",
1 => "redis://redistogo:e2496f77b3b0795caa08babf7e8165fd@scat.redistogo.com:9837/",
2 => "redis://redistogo:676ed4ab130e98a58a894eeabe86e453@scat.redistogo.com:9838/",
3 => "redis://redistogo:101202ee6af584a70d8a5c4b8b3422e6@scat.redistogo.com:9839/",
4 => "redis://redistogo:b76ef0c01c8e492e3272f3764c326efd@scat.redistogo.com:9840/",
5 => "redis://redistogo:554a8b05267435bf83f7eae2558f9c63@slimehead.redistogo.com:9264/",
6 => "redis://redistogo:8a549a79ca50fba69c6e10501f3b3c9a@scat.redistogo.com:9841/",
7 => "redis://redistogo:5942195ecc29c28f6e35996ba2cb5915@scat.redistogo.com:9842/",
8 => "redis://redistogo:14df5a18f62b559071cf27e670dfe643@slimehead.redistogo.com:9691/",
9 => "redis://redistogo:b60b033f7cf483fd04e9a7ba936c11ad@slimehead.redistogo.com:9694/",
10 => "redis://redistogo:c32f425de049bd4ac9c3e1c9344f4029@scat.redistogo.com:9843/",
11 => "redis://redistogo:5619aa56ebd18efdf278698c6b22c1a4@scat.redistogo.com:9844/",
12 => "redis://redistogo:61a13d4b2a542617a10d988a362d5b7f@slimehead.redistogo.com:9695/",
13 => "redis://redistogo:280afc3eb3c0584a76d192c2b6c143c2@slimehead.redistogo.com:9696/",
14 => "redis://redistogo:5bfa46061febdc7de88ec19fb5ae44f7@slimehead.redistogo.com:9697/",
15 => "redis://redistogo:285acb1976e725499fbf3f287b6d536e@scat.redistogo.com:9845/",
16 => "redis://redistogo:aa317d142d5c9c5af124971479ebb098@scat.redistogo.com:9846/",
17 => "redis://redistogo:a5f7fbfae76470cd541661f1f1fce064@slimehead.redistogo.com:9698/",
18 => "redis://redistogo:19750e6c698882de6b197466b617ceee@scat.redistogo.com:9847/",
19 => "redis://redistogo:0f25ea5e872308cadf431242788e3fb2@slimehead.redistogo.com:9699/",
		);
	}
	
	function getServers()
	{
		global $redisServerPool;
		return $redisServerPool;
	}

	function initializeStore($server)
	{
		global $redisStore;
		if(@$redisStore[$server] != null)
			return;
		try {
			$redisURL=$server;
			$redisURLParts=parse_url ( $redisURL );
			$redisServer='localhost';
			$redisPort=6379;
			$redisUser='redistogo';
			$redisPassword=null;
			if(!empty($redisURLParts['host']))
			{
				$redisServer=$redisURLParts['host'];
			}
			if(!empty($redisURLParts['port']))
			{
				$redisPort=$redisURLParts['port'];
			}
			if (!empty($redisURLParts['user']))
			{
				$redisUser=$redisURLParts['user'];
			}
			if (!empty($redisURLParts['pass']))
			{
				$redisPassword=$redisURLParts['pass'];
			}
			$redisStore[$server] = new Predis_Client(
					array(
							'host' => $redisServer,
							'port' => $redisPort,
							'user' => $redisUser,
							'password' => $redisPassword,
					)
			);
			$redisStore[$server]->connect();
			return;
		} catch (Exception $e) {
			$redisStore[$server] = null;
			die("Unable to initialize Redis Server: ".$server);
		}
	}

	function getFromStore($key)
	{
		global $redisStore;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		if($redisStore[$server] == null)
			return null;
		$serializedValue = $redisStore[$server]->get($key);
		return unserialize($serializedValue);
	}


	function setExpiry($key, $value)
	{
		global $redisStore;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		if($redisStore[$server] == null)
			return false;
		$redisStore[$server]->expire($key,$value);
	}

	function getKeyTTL($key)
	{
		global $redisStore;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		if($redisStore[$server] == null)
			return 0;
		return $redisStore[$server]->ttl($key);
	}

	function inStore($key)
	{
		global $redisStore;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		if($redisStore[$server] == null)
			return false;
		return $redisStore[$server]->exists($key);
	}

	function setToStore($key,$value)
	{
		global $redisStore;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		if($redisStore[$server] == null)
			return false;
		$serializedValue = serialize ($value);
		return $redisStore[$server]->set($key,$serializedValue);
	}

	function removeFromStore($key)
	{
		global $redisStore;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		if($redisStore[$server] == null)
			return false;
		return $redisStore[$server]->del($key);
	}
}
?>
