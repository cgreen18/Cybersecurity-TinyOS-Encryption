#include <Timer.h>
#include "HostC.h"

configuration HostAppC{

}
implementation{
	components MainC;
	components LedsC;

	components HostC as App;

	components ActiveMessageC;
	components new AMSenderC(AM_PINGPONGTASK);
	components new AMReceiverWC(CyberMsg, AM_PINGPONGTASK);

	components new TimerMilliC() as GetClient;
	components new TimerMilliC() as SendKeyToClient;
	components new TimerMilliC() as SendSuccess;
	

	App.Boot -> MainC.Boot;

	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.AMSend -> AMSenderC;
	App.ReceiveW -> AMReceiverWC;

	App.Leds -> LedsC;
	App.GetClient -> GetClient;
	App.SendKeyToClient -> SendKeyToClient;
	App.SendSuccess -> SendSuccess;


}


