<?php
define( 'CONFIG', dirname(__FILE__) . DIRECTORY_SEPARATOR . 'Lib' . DIRECTORY_SEPARATOR . 'Config' . DIRECTORY_SEPARATOR . 'config.php');
require_once(CONFIG);
?>
<?php
$facebook = new Facebook(array(
  'appId'  => AppInfo::appID(),
  'secret' => AppInfo::appSecret(),
));

$user_id = $facebook->getUser();
if(!$user_id) {
	FBUtils::login(AppInfo::getHome());
	exit();
} else {
  try {
    // Fetch the viewer's basic information
    $basic = $facebook->api('/me');
    $user_name = idx($basic, 'name', 'Anonymous');
  } catch (FacebookApiException $e) {
    // If the call fails we check if we still have a user. The user will be
    // cleared if the error is because of an invalid accesstoken
    if (!$facebook->getUser()) {
		//echo $_SERVER['REQUEST_URI'];
      header('Location: '. AppInfo::getUrl($_SERVER['REQUEST_URI']));
      exit();
    }
  }

  $access_token = $facebook->getAccessToken();

  // This fetches some things that you like . 'limit=*" only returns * values.
  // To see the format of the data you are retrieving, use the "Graph API
  // Explorer" which is at https://developers.facebook.com/tools/explorer/
  $likes = idx($facebook->api('/me/likes?limit=4'), 'data', array());

  // This fetches 4 of your friends.
  $friends = idx($facebook->api('/me/friends?limit=4'), 'data', array());

  // And this returns 16 of your photos.
  $photos = idx($facebook->api('/me/photos?limit=16'), 'data', array());

  // Here is an example of a FQL call that fetches all of your friends that are
  // using this app
  $app_using_friends = $facebook->api(array(
    'method' => 'fql.query',
    'query' => 'SELECT uid, name FROM user WHERE uid IN(SELECT uid2 FROM friend WHERE uid1 = me()) AND is_app_user = 1'
  ));
}

// Fetch the basic info of the app that they are using
$app_info = $facebook->api('/'. AppInfo::appID());
$app_name = idx($app_info, 'name', '');
?>

<!-- This following code is responsible for rendering the HTML   -->
<!-- content on the page.  Here we use the information generated -->
<!-- in the above requests to display content that is personal   -->
<!-- to whomever views the page.  You would rewrite this content -->
<!-- with your own HTML content.  Be sure that you sanitize any  -->
<!-- content that you will be displaying to the user.  idx() by  -->
<!-- default will remove any html tags from the value being      -->
<!-- and echoEntity() will echo the sanitized content.  Both of  -->
<!-- these functions are located and documented in 'utils.php'.  -->
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">

    <!-- We get the name of the app out of the information fetched -->
    <title><?php echo($app_name); ?></title>
    <link rel="stylesheet" href="<?php echo($styleURL); ?>/screen.css" media="screen">

    <!-- These are Open Graph tags.  They add meta data to your  -->
    <!-- site that facebook uses when your content is shared     -->
    <!-- over facebook.  You should fill these tags in with      -->
    <!-- your data.  To learn more about Open Graph, visit       -->
    <!-- 'https://developers.facebook.com/docs/opengraph/'       -->
    <meta property="og:title" content=""/>
    <meta property="og:type" content=""/>
    <meta property="og:url" content=""/>
    <meta property="og:image" content=""/>
    <meta property="og:site_name" content=""/>
    <script type="text/javascript" src="<?php echo($scriptsURL); ?>/swfobject.min.js"></script>
    <script type="text/javascript" src="<?php echo($scriptsURL); ?>/flashvars_js.js"></script>
    <?php echo('<meta property="fb:app_id" content="' . AppInfo::appID() . '" />'); ?>
    <script>
      function popup(pageURL, title,w,h) {
        var left = (screen.width/2)-(w/2);
        var top = (screen.height/2)-(h/2);
        var targetWin = window.open(
          pageURL,
          title,
          'toolbar=no, location=no, directories=no, status=no, menubar=no, scrollbars=no, resizable=no, copyhistory=no, width='+w+', height='+h+', top='+top+', left='+left
          );
      }
	  var flashvars = {};
		flashvars.gateway = "<?php echo($gatewayURL); ?>";
		flashvars.user_token = "<?php echo($access_token); ?>";
		flashvars.user = "<?php echo(SN_PREFIX.$user_id); ?>";
		flashvars.username = "<?php echo($user_name); ?>";
		flashvars.imagepath = "<?php echo $imagesURL; ?>";
		
	  var params = {};
		params.menu = "false";
		params.SCALE = "exactfit";
		params.wmode = "transparent";

	  var attributes = {};
		attributes.id = "myDynamicContent";
		attributes.name = "myDynamicContent";
		
	  swfobject.embedSWF("<?php echo($clientURL); ?>", "content", "1080", "707", "10.0.0","expressInstall.swf", flashvars, params, attributes);	  
    </script>
    <!--[if IE]>
      <script>
        var tags = ['header', 'section'];
        while(tags.length)
          document.createElement(tags.pop());
      </script>
    <![endif]-->
  </head>
  <body style="width:100%; height:100%; margin:0px; padding:0px;  background-color:#000000; text-align:center; color: #ffffff; font-family:sans-serif">
    <!-- <section id="game" class="clearfix"> -->	
	<div id="content" style="width:100%; height:100%; margin:0px; padding:0px;  background-color:#000000; text-align:center;"> 
			<span class="loadingGame">Loading Game...</span><br/>
			<img src="<?php echo $imagesURL; ?>/ProdSplashLogo.png" alt="<?php echo($app_name); ?>" border="0"/>
			<span class="upgradeFlash">If your game does not load within 10 seconds, you may need to upgrade your version of Flash.  Please do so by clicking <a target="_new" href="www.adobe.com/support/flashplayer/downloads.html">here</a></span>
	</div>
   <!-- </section> -->
   <div id="fb-root"></div>
  </body>
  </body>
</html>
