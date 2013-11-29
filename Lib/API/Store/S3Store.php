<?php
require_once ( dirname(__FILE__) . DIRECTORY_SEPARATOR . 'Store.php' );

class S3Store extends Store
{	
	private static $s3Pool = array();	
	private static $s3Store = array();
	
	function __construct() {
		global $s3Pool;		
		$account = "account";
		$password = "password";
		$domain = "domain.com";
		$region = AmazonS3::REGION_US_E1;
		$s3Pool = array(0 => "account password domain region");
	}
	
	function getServers(){
		global $s3Pool;
		return $s3Pool;	
	}
	
	function getBucket(){
		return 'bucket'.$this->getStorePrefix();
	}
	
	function initializeStore($server)
	{
		global $s3Store;
		if($s3Store[$server] != null)
			return;
		try {
			list($access_key, $secret_key, $name, $region) = explode(' ',$server);
			if (!class_exists('CFRuntime')) 
				die('Unable to Inititalize CFRuntime.');			
			CFCredentials::set(array(
					'development' => array(
							'key' => $access_key,
							'secret' => $secret_key,
							'default_cache_config' => '',
							'certificate_authority' => true
					),
					'@default' => 'development'
			));
			$s3 = new AmazonS3();
			$s3Store[$server] = $s3;
			$bucket = $this->getBucket();
			$exists = $s3->if_bucket_exists($bucket);
			if($exists) {
				return;
			}
			$response = $s3->create_bucket($bucket, $region);
			if($response->isOK()) {
				do {
					$exists = $s3->if_bucket_exists($bucket);
					sleep(1);
				} while(!$exists);				
			} else {
				$s3Store[$server] = null;
				print_r($response);
				die("Unable to initialize S3.");
			}			
		} catch (Exception $e) {			
			$s3Store[$server] = null;
			die("Unable to initialize S3: " . $e->getMessage());
		}
	}
	
	function getFromStore($key) {
		global $s3Store;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		$s3 = $s3Store[$server];		
		$bucket = $this->getBucket();
		$url = $s3->get_object_url($bucket, $key, '5 minutes');
		if ($url != null)
			return file_get_contents($url);
		else
			return null;
	}
	
	function setToStore($key, $value){
		global $s3Store;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		$s3 = $s3Store[$server];	
		$bucket = $this->getBucket();
		$s3->batch()->create_object($bucket, $key, array('body' => $value, 'contentType' => 'application/x-unknown', 'x-amz-acl' => AmazonS3::ACL_PUBLIC));
		$response = $s3->batch()->send();
		if($response->areOK()) {
			$url = $s3->get_object_url($bucket, $key, '5 minutes');
		}
		return $key;
	}
	
	function removeFromStore($key){
		global $s3Store;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		$s3 = $s3Store[$server];
		$bucket = $this->getBucket();
		$response = $s3->delete_object($bucket, $key);
	}
	
	function inStore($key){
		global $s3Store;
		$keyPrefix = $this->getStorePrefix();
		$key = $keyPrefix . $key;
		$server = $this->getServer($key);
		$this->initializeStore($server);
		$s3 = $s3Store[$server];		
		$bucket = $this->getBucket();
		return $s3->if_object_exists($bucket, $key);
	}
}

?>
