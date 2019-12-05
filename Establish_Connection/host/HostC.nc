module HostC{
	uses interface Boot;
	uses interface Leds;

	uses interface Timer<TMilli> as GetClient;
	uses interface Timer<TMilli> as SendKeyToClient;

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

	massage_t pkt;

	void delay(){
		int a,b;
		for(a=1;a<10000;a++){
			for(b=1;b<10000;b++){
			
			}
		}

	}

	void checkPass(){
		if(temp_pass ^ clientKey == PASSWD){
			login_success = TRUE;
			tellClientSuccess();
		}
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

	void setupHost(){
		delay();

		call GetClient.startPeriodic(RESEND_PERIOD);
	
	}

	void sendKey(){
		delay();
		
		call SendKeyToClient.startPeriodic(RESEND_PERIOD);
	}

	void tellHostSuccess(){
		call SendSuccess.startPeriodic(RESEND_PERIOD);
	}

	event GetClient.fired(){
		if(clientKey == 0){
			post sendMsg_GetClient();
		}
		else{
			GetClient.stop();
		}
	}

	event SendKeyToClient.fired(){
		if(clientPassword == 0 ){
			post sendMsg_KeyToClient();
		}
		else{
			SendKeyToClient.stop();
		}
	}

	event SendSuccess.fired(){
		post sendMsg_LoginSuccess();
	}

	task void sendMsg_GetClient(){
		if(!busy){
			CyberMsg* btrpkt = (CyberMsg*)(call Packet.getPayload(&pkt,sizeof(cyberMsg)))
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

	task void sendMsg_KeyToClient(){
		if(!busy){
			CyberMsg* btrpkt = (CyberMsg*)(call Packet.getPayload(&pkt,sizeof(cyberMsg)))
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

	task void sendMsg_LoginSuccess(){
		if(!busy){
			CyberMsg* btrpkt = (CyberMsg*)(call Packet.getPayload(&pkt,sizeof(cyberMsg)))
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

	event void ReceiveW.receive(CyberMsg msg){
		if(msg.mode == FINDHOSTMODE && msg.destination == TOS_NODE_ID){	
			clientID = msg.from;
			setupHost();
		}
		else if (msg.mode == SENDKEYMODE && msg.destination == TOS_NODE_ID){
			clientkey = msg.key;
			sendKey();		
		}
		else if(msg.mode == SENDPASSMODE && msg.destination == TOS_NODE_ID){
			temp_pass = msg.password;
			call Leds.led2On();
			checkPass();
		}
	}


}
