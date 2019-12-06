generic module AMReceiverWP(typedef t){
	uses interface Receive as ReceiveLowerL;
	provides interface ReceiveW<t> as ReceiveUpperL;
}
implementation{
	t RxMessage;

	event message_t* ReceiveLowerL.receive(message_t* msg, void* payload, uint8_t len){
		if (len == sizeof(t)){
			t* btrpkt = (t*)payload;
			RxMessage = *btrpkt;
			//memcpy(&RxMessage,msg,len);
			signal ReceiveUpperL.receive(RxMessage);
			
		}
		return msg;
	}


}
