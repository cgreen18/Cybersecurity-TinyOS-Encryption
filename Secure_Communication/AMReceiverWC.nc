#include "AM.h"

generic configuration AMReceiverWC(typedef t, am_id_t amId){
	provides interface ReceiveW<t>;
}

implementation{
	components new AMReceiverC(amId);
	components new AMReceiverWP(t);
	
	AMReceiverC.Receive <- AMReceiverWP.ReceiveLowerL;
	ReceiveW = AMReceiverWP.ReceiveUpperL;
}
