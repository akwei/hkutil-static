//
//  MyIp.m
//  huoku_paidui
//
//  Created by 伟 袁 on 12-7-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HKMyIp.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <sys/sockio.h>
#include <net/if.h>
#include <errno.h>
#include <net/if_dl.h>
#include <net/ethernet.h>

#define min(a,b) ((a) < (b) ? (a) : (b))
#define max(a,b) ((a) > (b) ? (a) : (b))
#define BUFFERSIZE 4000

#define MAXADDRS 32

@implementation HKMyIp

//char *if_names[MAXADDRS];
//char *ip_names[MAXADDRS];
//char *hw_addrs[MAXADDRS];
//unsigned long ip_addrs[MAXADDRS];
//
//static int   nextAddr = 0;

void InitAddresses(char *if_names[],char *ip_names[],char *hw_addrs[],unsigned long ip_addrs[])
{
    int i;
    for (i=0; i<MAXADDRS; ++i)
    {
        if_names[i] = ip_names[i] = hw_addrs[i] = NULL;
        ip_addrs[i] = 0;
    }
}

void FreeAddresses(char *if_names[],char *ip_names[],char *hw_addrs[],unsigned long ip_addrs[])
{
    int i;
    for (i=0; i<MAXADDRS; ++i)
    {
        if (if_names[i] != 0) free(if_names[i]);
        if (ip_names[i] != 0) free(ip_names[i]);
        if (hw_addrs[i] != 0) free(hw_addrs[i]);
        ip_addrs[i] = 0;
    }
    
    InitAddresses(if_names,ip_names,hw_addrs,ip_addrs);
}

void GetIPAddresses(char *if_names[],char *ip_names[],char *hw_addrs[],unsigned long ip_addrs[])
{
    int                 i, len, flags;
    char                buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifconf       ifc;
    struct ifreq        *ifr, ifrcopy;
    struct sockaddr_in *sin;
    char temp[80];
    int sockfd;
    int nextAddr=0;
    for (i=0; i<MAXADDRS; ++i)
    {
        if_names[i] = ip_names[i] = NULL;
        ip_addrs[i] = 0;
    }
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("socket failed");
        return;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0)
    {
        perror("ioctl error");
        return;
    }
    lastname[0] = 0;
    for (ptr = buffer; ptr < buffer + ifc.ifc_len; )
    {
        ifr = (struct ifreq *)ptr;
        len = max(sizeof(struct sockaddr), ifr->ifr_addr.sa_len);
        ptr += sizeof(ifr->ifr_name) + len; // for next one in buffer
        if (ifr->ifr_addr.sa_family != AF_INET)
        {
            continue; // ignore if not desired address family
        }
        
        if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL)
        {
            *cptr = 0; // replace colon will null
        }
        
        if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0)
        {
            continue; /* already processed this interface */
        }
        memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
        ifrcopy = *ifr;
        ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
        flags = ifrcopy.ifr_flags;
        if ((flags & IFF_UP) == 0)
        {
            continue; // ignore if interface not up
        }
        void* np = malloc(strlen(ifr->ifr_name)+1);
        if_names[nextAddr] = (char *)np;
        if (if_names[nextAddr] == NULL)
        {
            return;
        }
        
        strcpy(if_names[nextAddr], ifr->ifr_name);
        sin = (struct sockaddr_in *)&ifr->ifr_addr;
        strcpy(temp, inet_ntoa(sin->sin_addr));
        void* np1=(char *)malloc(strlen(temp)+1);
        ip_names[nextAddr] = np1;
        
        if (ip_names[nextAddr] == NULL)
        {
            return;
        }
        strcpy(ip_names[nextAddr], temp);
        ip_addrs[nextAddr] = sin->sin_addr.s_addr;
        ++nextAddr;
        free(np);
        free(np1);
    }
    
    close(sockfd);
    
}

void GetHWAddresses(char *if_names[],char *ip_names[],char *hw_addrs[],unsigned long ip_addrs[])
{
    struct ifconf ifc;
    struct ifreq *ifr;
    int i, sockfd;
    char buffer[BUFFERSIZE], *cp, *cplim;
    char temp[80];
    for (i=0; i<MAXADDRS; ++i)
    {
        hw_addrs[i] = NULL;
    }
    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("socket failed");
        return;
    }
    
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    if (ioctl(sockfd, SIOCGIFCONF, (char *)&ifc) < 0)
    {
        perror("ioctl error");
        close(sockfd);
        return;
    }
    
//    ifr = ifc.ifc_req;
    cplim = buffer + ifc.ifc_len;
    for (cp=buffer; cp < cplim; )
    {
        ifr = (struct ifreq *)cp;
        if (ifr->ifr_addr.sa_family == AF_LINK)
        {
            struct sockaddr_dl *sdl = (struct sockaddr_dl *)&ifr->ifr_addr;
            int a,b,c,d,e,f;
            int i;
            strcpy(temp, (char *)ether_ntoa((const struct ether_addr *)LLADDR(sdl)));
            sscanf(temp, "%x:%x:%x:%x:%x:%x", &a, &b, &c, &d, &e, &f);
            sprintf(temp, "%02X:%02X:%02X:%02X:%02X:%02X",a,b,c,d,e,f);
            for (i=0; i<MAXADDRS; ++i)
            {
                if ((if_names[i] != NULL) && (strcmp(ifr->ifr_name, if_names[i]) == 0))
                {
                    if (hw_addrs[i] == NULL)
                    {
                        hw_addrs[i] = (char *)malloc(strlen(temp)+1);
                        strcpy(hw_addrs[i], temp);
                        break;
                    }
                }
            }
        }
        cp += sizeof(ifr->ifr_name) + max(sizeof(ifr->ifr_addr), ifr->ifr_addr.sa_len);
    }
    close(sockfd);
}

//Somewhere in your code
- (NSString *)deviceIPAdress {
    char *if_names[MAXADDRS];
    char *ip_names[MAXADDRS];
    char *hw_addrs[MAXADDRS];
    unsigned long ip_addrs[MAXADDRS];
    InitAddresses(if_names,ip_names,hw_addrs,ip_addrs);
    GetIPAddresses(if_names,ip_names,hw_addrs,ip_addrs);
    GetHWAddresses(if_names,ip_names,hw_addrs,ip_addrs);
    return [NSString stringWithFormat:@"%s", ip_names[1]];
}

@end
