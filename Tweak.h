#import <dlfcn.h>
#import <objc/runtime.h>
#import "RNCryptor/RNCryptor.h"
#import "RNCryptor/RNDecryptor.h"
#import "RNCryptor/RNEncryptor.h"
#import <UIKit/UIKit.h>


@interface NSTask : NSObject
- (id) init;
- (void) launch;
- (void) setLaunchPath: (NSString*) arg1;
- (void) setArguments: (NSArray*) arg1;
- (void) waitUntilExit;
@end

@interface CYDOWNMessageView : UIView
@property (nonatomic, strong, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSString *subtitle;
- (void) fadeMeOut;
@end

@interface CyDownDBController: UITableViewController
- (NSString *) access_token;
- (void) saveTokens;
- (void) checkLogin;
@end