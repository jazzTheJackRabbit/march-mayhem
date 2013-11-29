<?php

function logData() {
 	$retStr = print_r(func_get_args(), true);
	error_log($retStr);
	return $retStr;
}

?>
