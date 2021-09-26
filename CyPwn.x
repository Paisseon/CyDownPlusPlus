#import "CyPwn.h"

%hook CyDownUtilHelper
+ (void) runCmd: (NSString*) arg1 {
	if ([arg1 containsString:@"rm -rf"] && [arg1 containsString:@".deb"]) return; // if CyDown tries to delete a temporary deb, keep the deb in stasis
	%orig;
}
%end

%hook NSURLRequest
- (id) initWithURL: (NSURL*) arg1 {
	if ([[arg1 absoluteString] containsString:@"cbox.ws"]) arg1 = [NSURL URLWithString:@"https://discord.gg/cZ2gBRZvwW"]; // CyDown chat is hosted on cbox.ws. redirect that to discord
	return %orig;
}
%end

%hook CYDOWNMessageView
- (void) didMoveToWindow {
	%orig;
	if ([self.subtitle containsString:@"MD5Sum verification error"] || [self.subtitle containsString:@"Loop install"]) { // if the error occurring is one that CyDown++ fixes
		self.hidden = true; // hide the error banner
		if (!didShowAlert) {
			UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"CyDown++" message:@"Open Filza to install this tweak?" preferredStyle:UIAlertControllerStyleAlert]; // add an alert on the screen
			UIAlertAction* okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action) {
				NSTask* task = [[NSTask alloc] init];
				[task setLaunchPath:@"/bin/bash"]; // use bash
				[task setArguments:[NSArray arrayWithObjects:@"/var/mobile/Documents/CyDown/_CyPwn", nil]]; // and use the CyPwn script (thanks Sudo!)
				[task launch]; // run the script
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"filza://view/var/mobile/Documents/CyDown/_CyPwn"]]; // open Filza directly to /var/mobile/Documents/CyDown
				[alert dismissViewControllerAnimated:true completion:nil]; // hide the alert
			}];
			UIAlertAction* cancelButton = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action) {
				[alert dismissViewControllerAnimated:true completion:nil]; // hide the alert
			}];
			[alert addAction:okButton]; // add the CyPwn script button
			[alert addAction:cancelButton]; // add the cancel button
			[[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alert animated:true completion:nil]; // actually display the alert for users
			didShowAlert = true;
		}
	}
	if ([self.title containsString:@"Started"]) [self fadeMeOut]; // this prevents a 5 second wait time for the alert to show
}
%end

%ctor {
	didShowAlert = false;
	%init;
}