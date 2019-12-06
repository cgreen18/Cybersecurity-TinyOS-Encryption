#include <Timer.h>
#include "ClientC.h"

configuration ClientAppC{

}
implementation{
	components MainC;
	components LedsC;

	components ClientC as App;

	components ActiveMessageC;
	components new AMSenderC(AM_PINGPONGTASK);
	components new AMReceiverWC(CyberMsg, AM_PINGPONGTASK);


	components new TimerMilliC() as LookForHost;
	components new TimerMilliC() as SendKey;
	components new TimerMilliC() as SendPass;

	App.Boot -> MainC.Boot;

	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.AMSend -> AMSenderC;
	App.ReceiveW -> AMReceiverWC;

	App.Leds -> LedsC;
	App.LookForHost -> LookForHost;
	App.SendKey -> SendKey;
	App.SendPass -> SendPass;


}


