#ifndef CYBER_INSECURE_C_H
#define CYBER_INSECURE_C_H

enum {
	AM_PINGPONGTASK = 6,
	ID_THAT_THROWS_FIRST = 7,
	FIRST_TIMEOUT = 1000,
	NODE_ID1 = 0x2,
	NODE_ID2 = 0x3,
	PASSWD = 0x80081355
};

typedef nx_struct CyberMsg {
	nx_uint8_t nodeid;
	nx_uint32_t password;
} CyberMsg;

#endif /* CYBER_INSECURE_C_H */
