#line 1 "/Users/ttwj/Desktop/yopa/yopa/yopa.xm"
;
#define MobileInstallation "/System/Library/PrivateFrameworks/MobileInstallation.framework/MobileInstallation"

#import "substrate.h"
#import "MobileInstallation.h"
#import "YOPAPackage.h"



extern "C" {
    
    void MOXPCTransportOpen(const char* wow ,int idk);
    
    void MOXPCTransportResume(void* wow);
    
    void MOXPCTransportSetMessageHandler(void *wow);
    
    Boolean MOXPCTransportSendMessage(void* wow, CFDictionaryRef message);
    
    CFDictionaryRef MOXPCTransportReceiveMessage(void* wow,int idk);
}

void *MOXPCTransportClose(void*);































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
static __attribute__((constructor)) void _logosLocalCtor_18bd9d6c() {
    {}
    DebugLog(@"HOOKING ONTO MOBILEINSTALLATION!!!!");
    DebugLog(@"###############\n###############\n###############\n###############\n");
    MSHookFunction(MobileInstallationInstall, MSHake(MobileInstallationInstall));
    MSHookFunction(MobileInstallationLookup, MSHake(MobileInstallationLookup));
    MSHookFunction(MOXPCTransportOpen, MSHake(MOXPCTransportOpen));
    MSHookFunction(MOXPCTransportSendMessage, MSHake(MOXPCTransportSendMessage));
    MSHookFunction(MOXPCTransportSetMessageHandler, MSHake(MOXPCTransportSetMessageHandler));
    MSHookFunction(MOXPCTransportReceiveMessage, MSHake(MOXPCTransportReceiveMessage));
    
    
}
































