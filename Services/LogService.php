<?php class LogService
{
	public function logData($input1 = null, $input2 = null, $input3 = null, $input4 = null, $input5 = null) {
		return logData(func_get_args());
	}

}

?>
