<?php class GiftService
{

	public function sendGift ($token, $from, $to, $item, $count, $nonce)
	{
		return sendGift ($token, $from, $to, $item, $count, $nonce);
	}
	
	public function getGifts ($token, $uid)
	{
		return getGifts($token, $uid);
	}
	
	public function nukeGifts ($token, $uid)
	{
		return nukeGifts($token, $uid);
	}
	

}

?>
