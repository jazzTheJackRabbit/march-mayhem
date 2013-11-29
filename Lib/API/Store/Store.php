<?php

abstract class Store
{
	abstract protected function getServers();

	protected function getServer($key)
	{
		$serverPool = $this->getServers();
		$serverIndex = crc32 ($key) % count($serverPool);
		return $serverPool[$serverIndex];
	}

	protected function getStorePrefix()
	{
		$keyPrefix = getenv('FACEBOOK_APP_ID');
		if(!$keyPrefix)
			$keyPrefix = 'default';
		return $keyPrefix;
	}

	abstract public function getFromStore($key);
	abstract public function setToStore($key, $value);
	abstract public function removeFromStore($key);
	abstract public function inStore($key);
}
?>
