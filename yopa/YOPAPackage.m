//
//  YOPAPackage.m
//  yopa
//

#import "YOPAPackage.h"


static NSString * genRandStringLength(int len) {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%c", [letters characterAtIndex: arc4random()%[letters length]]];
    }
    
    return randomString;
}


@implementation YOPAPackage

- (id)initWithPackagePath:(NSString*) packagePath {
    if (self = [super init]) {
        _packagePath = packagePath;
        _package = fopen([packagePath UTF8String], "r");
    }
    return self;
}
- (BOOL) isYOPA {
    uint32_t magic;
    fseek(_package, -4, SEEK_END);
    fread(&magic, 4, 1, _package);
    if (magic == YOPA_MAGIC) {
        fseek(_package, -4 - sizeof(struct YOPA_Header), SEEK_END);
        fread(&_header, sizeof(struct YOPA_Header), 1, _package);
        DebugLog(@"YOPA Magic detected!");
        return true;
    }
    else {
        DebugLog(@"Couldn't find YOPA Magic.. huh");
        fclose(_package);
        return false;
    }
}

-(NSString*) processPackage {
    switch(_header.compression_format) {
        case ZIP_COMPRESSION: {
            DebugLog(@"Normal zip compression, sending to installd");
            return _packagePath;
            break;
        }

        case SEVENZIP_COMPRESSION: {
            DebugLog(@"7zip compression, extracting");
            _tmpDir = [NSString stringWithFormat:@"/tmp/yopa-%@", genRandStringLength(8)];
            DebugLog(@"tmp dir %@", _tmpDir);
            if (![[NSFileManager defaultManager] removeItemAtPath:_tmpDir error:nil]) {
                DebugLog(@"Could not remove temporary directory? huh");
            }
            DebugLog(@"extract command: %@", [NSString stringWithFormat:@"7z x -o%@ \"%@\"", _tmpDir, _packagePath]);
            system([[NSString stringWithFormat:@"7z x -o%@ \"%@\"", _tmpDir, _packagePath] UTF8String]);
            NSString* item;
            for (item in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_tmpDir error:nil]) {
                DebugLog(@"item yo %@", item);
                DebugLog(@"item path extension %@", [[item pathExtension] lowercaseString]);
                if ([[[item pathExtension] lowercaseString] isEqualToString:@"ipa"]) {
                    DebugLog(@"found IPA in extracted 7z");
                    break;
                }
            }
            return [NSString stringWithFormat:@"%@/%@", _tmpDir, item];
            break;
        }
        default: {
            DebugLog(@"Unknown compression, sending to installd");
        }

    }
    return _packagePath;
}

-(NSString*)getTempDir {
    return _tmpDir;
}


@end