module ClientC{
	uses interface Boot;
	uses interface Leds;
	uses interface Timer<TMilli> as LookForHost;
	uses interface Timer<TMilli> as SendKey;
	uses interface Timer<TMilli> as SendPass;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface ReceiveW<CyberMsg>;
	uses interface SplitControl as AMControl;
}
implementation{
	
	uint32_t password;
	uint32_t key = KEY_CLIENT;
	uint32_t host_key = 0;

	bool login_success = FALSE;

	uint8_t hostID = 0;

	bool busy = FALSE;

	massage_t pkt;

	event void Boot.booted(){
		call AMControl.start();
	}

	event void AMControl.startDone(error_t err){
		if(err == SUCCESS){
			establishHost();
		}
		else{
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err){}

	event void AMSend.sendDone(message_t* msg, error_t err){
		if(&pkt == msg){
			busy = FALSE;	
		}
	}

	task void sendMsg_FindHost(){
		if(!busy){
			CyberMsg* btrpkt = (CyberMsg*)(call Packet.getPayload(&pkt,sizeof(cyberMsg)))
			if(btrpkt == NULL){
				return;
			}
			
			btrpkt->mode = SENDHOSTMODE;
			btrpkt->from = TOS_NODE_ID;
			btrpkt->destination = 0;
			btrpkt->key = 0;
			btrpkt->password = 0;	

			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CyberMsg)) == SUCCESS){
				busy = TRUE;
			}		
		}
	}

	task void sendMsg_AgreeKey(){
		if(!busy){
			CyberMsg* btrpkt = (CyberMsg*)(call Packet.getPayload(&pkt,sizeof(cyberMsg)))
			if(btrpkt == NULL){
				return;
			}
			
			btrpkt->mode = SENDKEYMODE;
			btrpkt->from = TOS_NODE_ID;
			btrpkt->destination = hostID;
			btrpkt->key = key;
			btrpkt->password = 0;	

			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CyberMsg)) == SUCCESS){
				busy = TRUE;
			}		
		}
	}

	task void sendMsg_SendyPassy(){
		if(!busy){
			CyberMsg* btrpkt = (CyberMsg*)(call Packet.getPayload(&pkt,sizeof(cyberMsg)))
			if(btrpkt == NULL){
				return;
			}
			
			btrpkt->mode = SENDPASSMODE;
			btrpkt->from = TOS_NODE_ID;
			btrpkt->destination = hostID;
			btrpkt->key = 0;
			btrpkt->password = password;	

			if(call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CyberMsg)) == SUCCESS){
				busy = TRUE;
			}		
		}
	}

	void establishHost(){
		call Leds.led0Off();
		call LookForHost.startPeriodic(RESEND_PERIOD);
	}

	void establishKey(){
		call SendKey.startPeriodic(RESEND_PERIOD);
	}

	void sendPassword(){
		call SendPass.startPeriodic(RESEND_PERIOD);
	}

	void encryptPass(){
		password = PASSWD ^ key;
	}
	
	event LookForHost.fired(){
		call Leds.led1Toggle();
		if(hostID == 0){
			post sendMsg_FindHost();
		}
		else{
			LookForHost.stop();
			establishKey();
		}
	}

	event SendKey.fired(){
		if(host_key == 0){
			post sendMsg_AgreeKey();
		}
		else{
			SendKey.stop();
			sendPassword();
		}
	}

	event SendPass.fired(){
		if(login_success == FALSE){
			post sendMsg_SendyPassy();
		}
		else{
			SendPass.stop();
		}
	}

	event void ReceiveW.receive(CyberMsg msg){
		if(msg.mode == GETHOSTMODE && msg.destination == TOS_NODE_ID){
			hostID = msg.from;
			call Leds.led0On();
			call Leds.led1Off();
		}
		else if (msg.mode == GETKEYMODE && msg.destination == TOS_NODE_ID){
			host_key = msg.key;
			encryptPass();
			call Leds.led1On();		
		}
		else if(msg.mode == GETLOGIN && msg.destination == TOS_NODE_ID){
			login_success = TRUE;
			call Leds.led2On();
		}
	}


}
