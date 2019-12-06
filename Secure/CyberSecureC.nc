module CyberSecureC{
	uses interface Boot;
	uses interface Leds;
	uses interface LocalTime<TMicro> as ElapsedT;
	uses interface Timer<TMilli> as LinkFailT;
	uses interface Packet;
	uses interface AMPacket;
	uses interface AMSend;
	uses interface ReceiveW<CyberMsg>;
	uses interface SplitControl as AMControl;
}
implementation{
	

	uint32_t timeout = FIRST_TIMEOUT;

	uint32_t password;
	uint32_t key = KEYCARD;

	bool busy = FALSE;

	message_t pkt;

	void delay(){
		int a,b;
		for(a=1;a<10000;a++){
			for(b=1;b<10000;b++){
			
			}
		}


	}

	void encryptPass(){
		password = PASSWD ^ key;

	}

	task void sendTask();

	event void Boot.booted(){
		call AMControl.start();
        }


	event void AMControl.startDone(error_t err){
		if (err == SUCCESS){
			call LinkFailT.startPeriodic(timeout);
			if(TOS_NODE_ID == ID_THAT_THROWS_FIRST){
				
				post sendTask();
			}
		}
		else {
			call AMControl.start();
		}
	}

	event void AMControl.stopDone(error_t err){}

	event void AMSend.sendDone(message_t* msg, error_t err){
		if(&pkt == msg){
			
			call Leds.led0Off();
			call LinkFailT.startPeriodic(timeout);
			busy = FALSE;	
		}
	}
	
	event void ReceiveW.receive(CyberMsg msg){
		if(msg.nodeid == NODE_ID1 || msg.nodeid == NODE_ID2){
			call Leds.led1Off();

			call Leds.led0On();

			post sendTask();
			
		}
	}

	event void LinkFailT.fired(){
		call Leds.led1On();
		if(TOS_NODE_ID == ID_THAT_THROWS_FIRST){
			post sendTask();
		}
	}

	task void sendTask(){

		delay();

		encryptPass();
		

		if (!busy) {
			CyberMsg* btrpkt = (CyberMsg*)(call Packet.getPayload(&pkt, sizeof(CyberMsg)));
			if (btrpkt == NULL) {
				return;
			}
			btrpkt->nodeid = TOS_NODE_ID;
			btrpkt->password = plain_text_password;
			if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(CyberMsg)) == SUCCESS) {
				busy = TRUE;
			}
		}
	}
}
