<?php

//Initialize Variables So We can Send it to Client.
$clientProfile="release";

//Server Protocol.
if($_SERVER) {
    $serverProto = (@$_SERVER["HTTPS"] == "on") ? "https" : "http";
    $serverProto = (@$_SERVER['HTTP_X_FORWARDED_PROTO'] ?: "http");
    try {
        $serverURL = $serverProto;
        $serverURL .= "://".@$_SERVER["SERVER_NAME"];
        if (@$_SERVER["SERVER_PORT"] != "80" && @$_SERVER["SERVER_PORT"] != "443")
        {    
            $serverURL .= ":.".@$_SERVER["SERVER_PORT"];
        }
    } catch (Exception $e) {
    $serverURL = "";
    }
}

if("true" == @$_REQUEST['debug']) {
	$clientProfile="debug";
}

$imagesURL=$serverURL."/Content/images/";
$scriptsURL=$serverURL."/Content/scripts/";
$clientURL=$serverURL."/Client/bin-".$clientProfile."/Main.swf";
$assetsURL=$serverURL."/Client/assets/";
$styleURL=$serverURL."/Content/stylesheets/";
$gatewayURL=$serverURL."/Gateway/";

if(!defined('LIBPATH')) {
	define('LIBPATH', dirname(__FILE__) . DIRECTORY_SEPARATOR . '..' . DIRECTORY_SEPARATOR);
}
define( 'API_ROOTPATH', LIBPATH . DIRECTORY_SEPARATOR . 'API'. DIRECTORY_SEPARATOR);

define('SN_PREFIX', 'FB:');

//Provide Access to FB.
define( 'FB_ROOTPATH', LIBPATH . DIRECTORY_SEPARATOR . 'FBSDK'. DIRECTORY_SEPARATOR . 'src'. DIRECTORY_SEPARATOR);
require_once(FB_ROOTPATH .'facebook.php');

// Provides Access to Redis to Go.
define( 'PREDIS_ROOTPATH', LIBPATH . DIRECTORY_SEPARATOR . 'Predis'. DIRECTORY_SEPARATOR);
require_once(PREDIS_ROOTPATH .'Predis.php');

// Provides Access to AWS.
define( 'AWS_ROOTPATH', LIBPATH . DIRECTORY_SEPARATOR . 'AWS'. DIRECTORY_SEPARATOR);
require_once(AWS_ROOTPATH .'sdk.class.php');

// Provides Access to Our API.
require_once(API_ROOTPATH .'API.php'); 
