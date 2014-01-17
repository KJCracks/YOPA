%config(generator=MobileSubstrate);
#define MobileInstallation "/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation"

#import "substrate.h"
#import "MobileInstallation.h"
#import "YOPAPackage.h"
//#import "itunesstored/InstallSoftwareOperation.h"
//#import "xpc.h"

extern "C" {
    
    void MOXPCTransportOpen(const char* wow ,int idk);
    
    void MOXPCTransportResume(void* wow);
    
    void MOXPCTransportSetMessageHandler(void *wow);
    
    Boolean MOXPCTransportSendMessage(void* wow, CFDictionaryRef message);
    
    CFDictionaryRef MOXPCTransportReceiveMessage(void* wow,int idk);
}

void *MOXPCTransportClose(void*);


/*%hook InstallSoftwareOperation
-(BOOL)_installPackage:(id*)package {
    DebugLog(@"#####################");
    DebugLog(@"installing package!!!");
    return %orig;
}
-(void)run {
    DebugLog(@"#####################");
    DebugLog(@"running install software operation!");
    return %orig;
}
-(id)initWithSoftwareProperties:(id)softwareProperties {
    DebugLog(@"#####################");
    DebugLog(@"initwithsoftawreporoperties %@", softwareProperties);
    return %orig;
}
%end*/


//typedef void (*MobileInstallationCallback)(CFDictionaryRef information);

//extern int MobileInstallationInstall(CFStringRef path, CFDictionaryRef parameters, MobileInstallationCallback callback, void *unknown);


/*MSHook(void, xpc_set_event_stream_handler, const char *stream, dispatch_queue_t targetq, xpc_handler_t handler) {
 DebugLog(@"xpc_set_event_stream called!!!!!");
 return _xpc_set_event_stream_handler(stream, targetq, handler);
 }*/

NSString* tempDir;

MSHook(CFDictionaryRef, MOXPCTransportReceiveMessage, void* wow,int idk) {
    CFDictionaryRef msg = _MOXPCTransportReceiveMessage(wow, idk);
    DebugLog(@"################################## transportreceivemsg");
    DebugLog(@"MOXPCTransportReceiveMessage %@", msg);
    NSDictionary* dict = (NSDictionary*) msg;
    if ([[dict objectForKey:@"Status"] isEqualToString:@"Complete"]) {
        DebugLog(@"wow such complete!");
        if (![[NSFileManager defaultManager] removeItemAtPath:tempDir error:nil]) {
            DebugLog(@"could not remove tempDir, weird!!");
        }
    }
    return msg;
}

MSHook(void, MOXPCTransportSetMessageHandler, void *wow) {
    DebugLog(@"################################## set message handler yo");
    DebugLog(@"SET MESSAGE HANDLER");
    return _MOXPCTransportSetMessageHandler(wow);
}

MSHook(void, MOXPCTransportOpen, const char* wow, int idk) {
    DebugLog(@"################################## transportopen");
    DebugLog(@"MOXPCTransportOpen!!!!");
    DebugLog(@"##################################");
    return _MOXPCTransportOpen(wow, idk);
}

MSHook(Boolean, MOXPCTransportSendMessage, void* wow, CFDictionaryRef message) {
    DebugLog(@"################################## transportsendmsg");
    DebugLog(@"MOXPCTransportSendMessage %@", message);
    DebugLog(@"##################################");
    NSDictionary* dict = (NSDictionary*) message;
    DebugLog(@"YO YOYO YOPA!!!");
    NSMutableDictionary* mutabledict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    YOPAPackage* package = [[YOPAPackage alloc] initWithPackagePath:[dict objectForKey:@"PackagePath"]];
    if ([package isYOPA]) {
        [mutabledict setObject:[package processPackage] forKey:@"PackagePath"];
        tempDir = [package getTempDir];
        return _MOXPCTransportSendMessage(wow, (CFDictionaryRef) mutabledict);
    }
    return _MOXPCTransportSendMessage(wow, message);
}


MSHook(CFDictionaryRef, MobileInstallationLookup, CFDictionaryRef properties) {
    DebugLog(@"MOBILEINSTALLATION LOOKUP!!!");
    DebugLog(@"########\n###############");
    return _MobileInstallationLookup(properties);
}

MSHook(int, MobileInstallationInstall, CFStringRef path, CFDictionaryRef parameters, MobileInstallationCallback callback, void *unknown) {
    
    DebugLog(@"mobileinstallation install!!!");
    DebugLog(@"installpath %@", path);
    DebugLog(@"parameters %@", parameters);
    
    
    
    return _MobileInstallationInstall(path, parameters, callback, unknown);
    
}
%ctor {
    %init();
    DebugLog(@"HOOKING ONTO MOBILEINSTALLATION!!!!");
    DebugLog(@"###############\n###############\n###############\n###############\n");
    MSHookFunction(MobileInstallationInstall, MSHake(MobileInstallationInstall));
    MSHookFunction(MobileInstallationLookup, MSHake(MobileInstallationLookup));
    MSHookFunction(MOXPCTransportOpen, MSHake(MOXPCTransportOpen));
    MSHookFunction(MOXPCTransportSendMessage, MSHake(MOXPCTransportSendMessage));
    MSHookFunction(MOXPCTransportSetMessageHandler, MSHake(MOXPCTransportSetMessageHandler));
    MSHookFunction(MOXPCTransportReceiveMessage, MSHake(MOXPCTransportReceiveMessage));
    //MSHookFunction((int)MobileInstallationInstall, (int)replaced_MobileInstallationInstall, (int**)&MobileInstallationInstallOld);
    
}


