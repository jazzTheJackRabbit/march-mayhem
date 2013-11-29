<?php

require_once ( dirname(__FILE__) . DIRECTORY_SEPARATOR . 'Store.php' );

//Needs to be Changed for Zynga.
class MemcacheStore extends Store
{
	private static $mcServerPool = array();	
	private static $mcStore = array();
	
	function __construct() {
		global $mcServerPool;
		$mcServerPool =  array(
			0 => "".$_SERVER['MEMCACHE_SERVERS'].":11211,".$_SERVER['MEMCACHE_USERNAME'].",".$_SERVER['MEMCACHE_PASSWORD'] ,
			);
	}
	
	function getServers()
	{
		global $mcServerPool;
		return $mcServerPool;
	}

	function initializeStore($server)
	{
		global $mcStore;
		if($mcStore[$server] != null)
			return;
		try {
			list($mc_server, $secret_key, $name) = explode(',',$server);
			$mc = null;
			if($secret_key || $name) {
				//Do Stuff.
				$mc = null;
			}
			$mcStore[$server] = $mc;
		} catch (Exception $e) {
			$mcStore[$server] = null;
			die("Unable to initialize Memcache.");
		}
	}

	function getFromStore($key)
	{
		global $mcStore;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		$serializedValue = $mcStore[$server]->get($key);
		return unserialize($serializedValue);
	}


	function setExpiry($key, $value)
	{
		global $mcStore;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		$mcStore[$server]->expire($key,$value);
	}

	function getKeyTTL($key)
	{
		global $mcStore;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		return $mcStore[$server]->ttl($key);
	}

	function inStore($key)
	{
		global $mcStore;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		return $mcStore[$server]->exists($key);
	}

	function setToStore($key,$value)
	{
		global $mcStore;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		$serializedValue = serialize ($value);
		return $mcStore[$server]->set($key,$serializedValue);
	}

	function removeFromStore($key)
	{
		global $mcStore;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		return $mcStore[$server]->del($key);
	}
}
?>
