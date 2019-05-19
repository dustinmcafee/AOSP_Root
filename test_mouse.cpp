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

const struct input_value input_struct = {
    .type = EV_KEY,
    .code = BTN_LEFT
//    .type = 3,			//For Emulator-goldfish
//    .code = 57			//For Emulator-goldfish
};

#include "stdio.h"
#include "unistd.h"
#include "inttypes.h"

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

int esm_epoll(){
        int sfd, s;
        int efd;
        struct epoll_event event;
        struct epoll_event *events;
        int done = 0;
	const char* dev_path = "/dev/input/mice";

        sfd = open(dev_path, O_RDONLY);
        if (sfd == -1) {
                printf("open_port: Unable to open %s\n", dev_path);
                return (-1);
        }
        make_socket_non_blocking(sfd);

        char name[256] = "Unknown";
        ioctl(sfd, EVIOCGNAME(sizeof(name)), name);
        printf("Reading from device : %s\n", dev_path);

        efd = epoll_create1(0);
        if (efd == -1) {
                perror("epoll_create");
                abort();
        }

        event.data.fd = sfd;
        event.events = EPOLLIN | EPOLLET;
        s = epoll_ctl(efd, EPOLL_CTL_ADD, sfd, &event);
        if (s == -1) {
                perror("epoll_ctl");
                abort();
        }

        //Buffer where events are returned
        events = (struct epoll_event*)calloc(MAXEVENTS, sizeof event);

//        while (1) {
                int n, i;
                n = epoll_wait(efd, events, MAXEVENTS, 5000);
                for (i = 0; i < n; i++) {
                        if ((events[i].events & EPOLLERR) ||
                            (events[i].events & EPOLLHUP) || (!(events[i].events & EPOLLIN))) {

                                printf("epoll error\n");
                                close(events[i].data.fd);
                                continue;
                        }

                        else if (sfd == events[i].data.fd) {
                                while (1) {
                                        int len = 0;
                                        struct input_event key_press[64];
                                        if ((len = read(sfd, &key_press, sizeof key_press)) != -1) {
                                                printf("len: %d\n",len);
                                                printf("Type %d Code %d Val %s \n", key_press[1].type, key_press[1].code, evval[key_press[1].value]);

                                        }
                                        break;
                                }
                                continue;
                        } else {
                                int done = 0;
                                if (done) {
                                        printf("Closed on descriptor %d\n", events[i].data.fd);
                                        close(events[i].data.fd);
                                }
                        }
                }
//        }

        free(events);

        close(sfd);
        return EXIT_SUCCESS;
}

int main(){
	int err = esm_epoll();
	return err;
}
