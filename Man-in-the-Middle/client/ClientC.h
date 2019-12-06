#ifndef CLIENT_C_H
#define CLIENT_C_H

enum {
	AM_PINGPONGTASK = 6,
	RESEND_PERIOD = 1000,
	SENDHOSTMODE = 1,
	GETHOSTMODE = 2,
	SENDKEYMODE = 3,
	GETKEYMODE = 4,
	SENDPASSMODE = 5,
	GETLOGIN  =6,
	PASSWD = 0x80081355,
	KEY_CLIENT = 0x12345678
};

typedef nx_struct CyberMsg {
	nx_uint8_t mode;
	nx_uint8_t from;
	nx_uint8_t destination;
	nx_uint32_t key;
	nx_uint32_t password;
} CyberMsg;

#endif /* CLIENT_C_H */
