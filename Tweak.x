#import "Tweak.h"

// Get NSString from NSData

static inline NSString *string_from_data(NSData *arg0) {
    return [arg0 base64EncodedStringWithOptions: 0];
}

// Get UDID as NSString

static NSString *get_udid() {
    static CFStringRef (*$MGCopyAnswer)(CFStringRef);
    
    void *gestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_GLOBAL | RTLD_LAZY);
    $MGCopyAnswer = (dlsym(gestalt, "MGCopyAnswer"));
    
    return (__bridge NSString *)$MGCopyAnswer(CFSTR("UniqueDeviceID"));
}

// Encrypt data with RNCryptor

static inline NSData *enc_data(NSData *arg0) {
    NSString *udid    = get_udid();
    NSData *encrypted = [RNEncryptor encryptData: arg0 withSettings: kRNCryptorAES256Settings password: udid error: NULL];
    
    return encrypted;
}

// Decrypt data with RNCryptor

static inline NSData *dec_data(NSData *arg0) {
    NSString *udid    = get_udid();
    NSData *decrypted = [RNDecryptor decryptData: arg0 withPassword: udid error: NULL];
    
    return decrypted;
}

// Run a shell command

void run_cmd(NSString *arg0) {
    NSTask *task  = [NSTask new];
    NSArray *args = @[@"-c", arg0];
    
    [task setLaunchPath: @"/bin/bash"];
    [task setArguments: args];
    [task launch];
    [task waitUntilExit];
}

// Encrypt Dropbox password instead of storing it in plaintext

%hook CyDownDBController
- (NSString *) access_token {
    NSString *result  = nil;
    NSData *encrypted = nil;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile: @"/var/mobile/Library/Preferences/com.julioverne.cydown.plist"];
    NSData *data              = dict[@"db-access_token"];
    
    // If the data is NOT encrypted, encrypt it. Otherwise leave it alone
    
    if (data.length == 64) {
        encrypted = enc_data(data);
        
        if (encrypted) {
            [dict setObject: encrypted forKey: @"db-access_token"];
            [dict writeToFile: @"/var/mobile/Library/Preferences/com.julioverne.cydown.plist" atomically: true];
            result = string_from_data(dec_data(encrypted));
        }
    }
    
    return (result != nil) ? result : @"ERROR";
}
%end

// Prevent deletion of debs

%hook CyDownUtilHelper
+ (void) runCmd: (NSString *) arg0 {
    if ([arg0 containsString: @"rm -rf"] && [arg0 containsString: @".deb"])
        return;
    
    %orig;
}
%end

// Replace 0 IQ CyDown chat with 413 IQ CyPwn's link tree

%hook NSURLRequest
- (id) initWithURL: (NSURL *) arg0 {
    if ([[arg0 absoluteString] containsString: @"cbox.ws"])
        arg0 = [NSURL URLWithString: @"https://repo.cypwn.xyz/cydown"];
    
    return %orig;
}
%end

// Hide banners when CD++ prevents the error from occurring

%hook CYDOWNMessageView
- (void) didMoveToWindow {
    %orig;
    
    if ([self.subtitle containsString: @"MD5Sum verification error"] ||
        [self.subtitle containsString: @"Loop install"]) {
            self.hidden = true;
            
            // Fix the partial deb files using Bash Magic™️ from Sudo and go to them in Filza
            
            run_cmd(@"/var/mobile/Documents/CyDown/_CyPwn");
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: @"filza://view/var/mobile/Documents/CyDown/_CyPwn"] options: @{} completionHandler: nil];
        }
    
    if ([self.title containsString: @"Started"])
        [self fadeMeOut];
}
%end