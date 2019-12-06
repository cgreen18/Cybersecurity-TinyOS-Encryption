#include <Timer.h>
#include "CyberInsecureC.h"

configuration CyberSecureAppC{

}
implementation{
	components MainC;
	components LedsC;

	components CyberSecureC as App;

	components ActiveMessageC;
	components new AMSenderC(AM_PINGPONGTASK);
	components new AMReceiverWC(CyberMsg, AM_PINGPONGTASK);

	components LocalTimeMicroC as ElapsedTimer;

	components new TimerMilliC() as LinkFailedTimer;

	App.Boot -> MainC.Boot;

	App.Packet -> AMSenderC;
	App.AMPacket -> AMSenderC;
	App.AMControl -> ActiveMessageC;
	App.AMSend -> AMSenderC;
	App.ReceiveW -> AMReceiverWC;

	App.Leds -> LedsC;
	App.ElapsedT -> ElapsedTimer;
	App.LinkFailT -> LinkFailedTimer;


}


