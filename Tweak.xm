#import <UIKit/UIKit.h>
#import <ifaddrs.h>
#import <arpa/inet.h>



%hook SBAwayLockBar

-(void)_setLabel:(id)label {
NSMutableDictionary *plist = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.bengerard.ipslider.plist"];

static BOOL value = NO;

value = [[plist objectForKey:@"enabled"]boolValue];

if(!value){
return %orig;
}

    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    NSString *wifiAddress = (id)[plist objectForKey:@"label"];
    NSString *cellAddress = nil;

    // retrieve the current interfaces - returns 0 on success
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                NSString *name = [NSString stringWithUTF8String:temp_addr->ifa_name];
                NSString *addr = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; // pdp_ip0     
                //NSLog(@"NAME: \"%@\" addr: %@", name, addr); // see for yourself

                if([name isEqualToString:@"en0"]) {
                    // Interface is the wifi connection on the iPhone
                    wifiAddress = addr;    
                } 
            }
            temp_addr = temp_addr->ifa_next;
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSString *addr = wifiAddress ? wifiAddress : cellAddress;
    


label = addr;

%orig;
}






%end