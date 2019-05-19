#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <linux/input-event-codes.h>	//for EV_* and BTN_* macros
#include <sys/syscall.h>		//for SYS_esm_register and SYS_esm_wait

#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <netdb.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/epoll.h>
#include <errno.h>

#include <linux/input.h>

#define MAXEVENTS 10

struct input_value {
    __u16 type;
    __u16 code;
    unsigned int value;
};

const struct input_value input_click = {
    .type = EV_KEY,
    .code = BTN_LEFT
//    .type = 3,			//For Emulator-goldfish
//    .code = 57			//For Emulator-goldfish
};

const struct input_value input_k = {
    .type = EV_KEY,
    .code = KEY_K
};

#include "stdio.h"
#include "unistd.h"
#include "inttypes.h"

void click_handler(__u16 type, __u16 code, int32_t value){
    printf("Click Handler: %d\n", value);
}
void k_handler(__u16 type, __u16 code, int32_t value){
    printf("Key K Handler: %d\n", value);
}


static int make_socket_non_blocking(int sfd){
        int flags, s;

        flags = fcntl(sfd, F_GETFL, 0);
        if (flags == -1) {
                printf("fcntl get flags");
                return -1;
        }

        flags |= O_NONBLOCK;
        s = fcntl(sfd, F_SETFL, flags);
        if (s == -1) {
                printf("fcntl2 set nonblocking flag");
                return -1;
        }

        return 0;
}

static const char *const evval[3] = {
        "RELEASED",
        "PRESSED ",
        "REPEATED"
};

static int my_esm_wait(struct input_id inpid) {
        struct input_value input_buff[MAXEVENTS];
        const int pid = getpid();
	int fd;

        int err = syscall(334, input_buff, MAXEVENTS);
        if (err < 0) {
             printf("error with esm wait\n");
             return err;
        }

        for(int i = 0; i < err; i++){
                struct input_value in = input_buff[i];
                printf("esm wait returned with type: %d, code: %d, value: %d\n", in.type, in.code, in.value);
                click_handler(in.type, in.code, in.value);
        }

        return EXIT_SUCCESS;
}
static int my_esm_register(struct input_id inpid){
	const int pid = getpid();

        int err = syscall(333, &inpid, pid, MAXEVENTS);
	if (err < 1) {return err;}

        return EXIT_SUCCESS;
}

static int my_esm_deregister(struct input_id inpid) {
        const int pid = getpid();
        int err = syscall(333, &inpid, pid, 0);
        if(err == -1){printf("error with unregistering input device with esm\n");}
	return err;
}
/*
        uint8_t evtype_bitmask[EV_MAX/8 + 1];           //Event Type
        uint8_t keytype_bitmask[KEY_MAX/8 + 1];         //Key Type
        uint8_t reltype_bitmask[REL_MAX/8 + 1];         //Relative Axis
        uint8_t abstype_bitmask[ABS_MAX/8 + 1];         //Absolute Axis
        uint8_t msctype_bitmask[MSC_MAX/8 + 1];         //Miscellaneous Events
        uint8_t ledtype_bitmask[LED_MAX/8 + 1];         //LED Events
        uint8_t sndtype_bitmask[SND_MAX/8 + 1];         //Sound Events
        uint8_t fftype_bitmask[FF_MAX/8 + 1];           //Force Feedback
        uint8_t swtype_bitmask[SW_MAX/8 + 1];           //Switches
        //Read all possible Event Types and store in evtype_bitmask array
        if(ioctl(fd, EVIOCGBIT(0, sizeof(evtype_bitmask)), evtype_bitmask) < 0){
                printf("error reading event types\n");
        }
        if(ioctl(fd, EVIOCGBIT(EV_KEY, sizeof(keytype_bitmask)), keytype_bitmask) < 0){
                printf("error reading event key types\n");
        }
        if(ioctl(fd, EVIOCGBIT(EV_REL, sizeof(reltype_bitmask)), reltype_bitmask) < 0){
                printf("error reading event relative axis\n");
        }
        if(ioctl(fd, EVIOCGBIT(EV_ABS, sizeof(abstype_bitmask)), abstype_bitmask) < 0){
                printf("error reading event absolute axis\n");
        }
        if(ioctl(fd, EVIOCGBIT(EV_MSC, sizeof(msctype_bitmask)), msctype_bitmask) < 0){
                printf("error reading miscellaneous events\n");
        }
        if(ioctl(fd, EVIOCGBIT(EV_SW, sizeof(swtype_bitmask)), swtype_bitmask) < 0){
                printf("error reading device switches\n");
        }
        if(ioctl(fd, EVIOCGBIT(EV_LED, sizeof(ledtype_bitmask)), ledtype_bitmask) < 0){
                printf("error reading LEDs\n");
        }
        if(ioctl(fd, EVIOCGBIT(EV_SND, sizeof(sndtype_bitmask)), sndtype_bitmask) < 0){
                printf("error reading sound events\n");
        }
        if(ioctl(fd, EVIOCGBIT(EV_FF, sizeof(fftype_bitmask)), fftype_bitmask) < 0){
                printf("error reading force feedback events\n");
        }
*/

int main(){
	struct input_id inpid;
	const char* dev_path = "/dev/input/event1";
        int fd = open(dev_path, O_RDONLY);
        if (fd == -1) {
                printf("open_port: Unable to open %s\n", dev_path);
                return (-1);
        }
        make_socket_non_blocking(fd);

        char name[256] = "Unknown";
        ioctl(fd, EVIOCGNAME(sizeof(name)), name);
        printf("Reading from device : %s\n", dev_path);

	if (ioctl(fd, EVIOCGID, &inpid) < 0) {
		if (errno == EBADF) printf("error reading input event device ID: EBADF\n");
		if (errno == EFAULT) printf("error reading input event device ID: EFAULT\n");
		if (errno == ENOTTY) printf("error reading input event device ID: ENOTTY\n");
		if (errno == EINVAL) printf("error reading input event device ID: EINVAL\n");
		else {printf("unknown error reading input event device ID\n");}
	}

	int err = my_esm_register(inpid);
	if(err < 0){close(fd); return err;}
	err = my_esm_wait(inpid);
	if(err < 0){close(fd); return err;}
        err = my_esm_deregister(inpid);
	if(err < 0){close(fd); return err;}

        if(close(fd) < 0) {
                int _errno = errno;
                printf("Failed closing file: %d\n", _errno);
                return -1;
        }
	return 0;
}
