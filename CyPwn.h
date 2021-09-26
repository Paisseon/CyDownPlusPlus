#import <UIKit/UIKit.h>

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