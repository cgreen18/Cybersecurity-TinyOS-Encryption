module HostC{
	uses interface Boot;
	uses interface Leds;

	uses interface Timer<TMilli> as GetClient;
	uses interface Timer<TMilli> as SendKeyToClient;
	uses interface Timer<TMilli> as SendSuccess;

	uses interface Timer<TMilli> as Delay;

	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface ReceiveW<CyberMsg>;
	uses interface SplitControl as AMControl;
}
implementation{
	
	bool busy = FALSE;

	uint8_t clientID = 0;
	uint32_t clientKey = 0;

	uint32_t clientPassword = 0;

	uint32_t temp_pass = 0;

	bool login_success = FALSE;

	message_t pkt;


	void delay(){
		call Delay.startOneShot(1000);

	}


	void tellClientSuccess(){
		call SendSuccess.startPeriodic(RESEND_PERIOD);
	}

	void checkPass(){
		if(((temp_pass) ^ (clientKey)) == PASSWD){
			login_success = TRUE;
			tellClientSuccess();
		}
	}

	void setupHost(){
		delay();

		
	
	}

	event void Delay.fired(){
		call GetClient.startPeriodic(RESEND_PERIOD);
	}

	void sendKey(){
		delay();
		
		call SendKeyToClient.startPeriodic(RESEND_PERIOD);
	}

	




	

	event void AMControl.stopDone(error_t err){}

	event void AMSend.sendDone(message_t* msg, error_t err){
		if(&pkt == msg){
			busy = FALSE;	
		}
	}


	event void Boot.booted(){
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err){
		if(err == SUCCESS){
			
		}
		else{
			call AMControl.start();
		}
	}

	task void sendMsg_GetClient(){
		if(!busy){
			CyberMsg* btrpkt = (CyberMsg*)(call Packet.getPayload(&pkt,sizeof(CyberMsg)));
			if(btrpkt == NULL){
				return;
			}
			
			btrpkt->mode = GETHOSTMODE;
			btrpkt->from = TOS_NODE_ID;
			btrpkt->destination = clientID;
			btrpkt->key = 0;
			btrpkt->password = 0;	

			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CyberMsg)) == SUCCESS){
				busy = TRUE;
			}		
		}
	}	



	event void GetClient.fired(){
		if(clientKey == 0){
			post sendMsg_GetClient();
		}
		else{
			call GetClient.stop();
		}
	}


	task void sendMsg_KeyToClient(){
		if(!busy){
			CyberMsg* btrpkt = (CyberMsg*)(call Packet.getPayload(&pkt,sizeof(CyberMsg)));
			if(btrpkt == NULL){
				return;
			}
			
			btrpkt->mode = GETKEYMODE;
			btrpkt->from = TOS_NODE_ID;
			btrpkt->destination = clientID;
			btrpkt->key = KEY_HOST;
			btrpkt->password = 0;	

			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CyberMsg)) == SUCCESS){
				busy = TRUE;
			}		
		}
	}

	event void SendKeyToClient.fired(){
		if(clientPassword == 0 ){
			post sendMsg_KeyToClient();
		}
		else{
			call SendKeyToClient.stop();
		}
	}


	task void sendMsg_LoginSuccess(){
		if(!busy){
			CyberMsg* btrpkt = (CyberMsg*)(call Packet.getPayload(&pkt,sizeof(CyberMsg)));
			if(btrpkt == NULL){
				return;
			}
			
			btrpkt->mode = GETLOGIN;
			btrpkt->from = TOS_NODE_ID;
			btrpkt->destination = clientID;
			btrpkt->key = 0;
			btrpkt->password = 0;	

			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CyberMsg)) == SUCCESS){
				busy = TRUE;
			}		
		}
	}

	event void SendSuccess.fired(){
		post sendMsg_LoginSuccess();
	}

	

	

	

	event void ReceiveW.receive(CyberMsg msg){
		if(msg.mode == SENDHOSTMODE){	
			clientID = msg.from;
			call Leds.led2On();
			setupHost();
		}
		else if (msg.mode == SENDKEYMODE && msg.destination == TOS_NODE_ID){
			clientKey = msg.key;
			sendKey();		
		}
		else if(msg.mode == SENDPASSMODE && msg.destination == TOS_NODE_ID){
			temp_pass = msg.password;
			call Leds.led2On();
			checkPass();
		}
	}


}
