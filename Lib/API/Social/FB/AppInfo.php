<?php

/**
 * This class provides static methods that return pieces of data specific to
 * your app
 */
class AppInfo {

  /*****************************************************************************
   *
   * These functions provide the unique identifiers that your app users.  These
   * have been pre-populated for you, but you may need to change them at some
   * point.  They are currently being stored in 'Environment envariables'.  To
   * learn more about these, visit
   *   'http://php.net/manual/en/function.getenv.php'
   *
   ****************************************************************************/

  /**
   * @return the appID for this app
   */
  public static function appID() {
    $envar = getenv('FACEBOOK_APP_ID');
    if(!$envar) 
               $envar = '328768520520831';
     return $envar;
   }
 
   public static function appSecret() {
     $envar = getenv('FACEBOOK_SECRET');
        if(!$envar)
               $envar = 'dcae2e4464cd12541f9b1d03ac4c60d6';
    return $envar;
  }
  /**
   * @return the protocol
   */ 
  public static function getProtocol($path = '/') {
    if (isset($_SERVER['HTTPS']) && ($_SERVER['HTTPS'] == 'on' || $_SERVER['HTTPS'] == 1)
      || isset($_SERVER['HTTP_X_FORWARDED_PROTO']) && $_SERVER['HTTP_X_FORWARDED_PROTO'] == 'https'
    ) {
      $protocol = 'https://';
    }
    else {
      $protocol = 'http://';
    }

    return $protocol;
  }
  /**
   * @return the url
   */
  public static function getUrl($path = '/') {
    $protocol = self::getProtocol();
    return $protocol . $_SERVER['HTTP_HOST'] . $path;
  }

  /**
   * @return the home URL for this site
   */
  public static function getHome () {
    $protocol = self::getProtocol();
    $envar = getenv('FACEBOOK_APP_URL');
    if(!$envar) $envar = 'apps.facebook.com/perilmayhem';
    return $protocol . $envar.'/';
  }

}
