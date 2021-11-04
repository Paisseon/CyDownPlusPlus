#import <UIKit/UIKit.h>
#import <dlfcn.h>
#import <CommonCrypto/CommonDigest.h>

static bool didShowAlert;

@interface NSTask : NSObject
- (id) init;
- (void) launch;
- (void) setLaunchPath: (NSString*) arg1;
- (void) setArguments: (NSArray*) arg1;
@end

@interface CYDOWNMessageView : UIView
@property (nonatomic, strong, readwrite) NSString* title;
@property (nonatomic, strong, readwrite) NSString* subtitle;
- (void) fadeMeOut;
@end

@interface CyDownDBController : UITableViewController
- (NSString*) access_token;
- (void) saveTokens;
- (void) checkLogin;
@end

@interface NSData (AES256)
- (NSData*) aes256Encrypt: (NSString*) arg0 ;
- (NSData*) aes256Decrypt: (NSString*) arg0 ;
@end