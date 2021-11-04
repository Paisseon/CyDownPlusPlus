#import "CyPwn.h"

// i just got this from stackoverflow, idk how it works lol 
// https://stackoverflow.com/a/18409200
static NSString* md5(NSString* arg0) {
	const char* cInput = [arg0 UTF8String];
	unsigned char digest[16];
	CC_MD5(cInput, strlen(cInput), digest);
	NSMutableString* output = [NSMutableString string];
	for (int i = 0; i < 16; i++) {
		[output appendFormat:@"%02x", digest[i]];
	}
	return output;
}

static NSString* getUDID() {
	static CFStringRef (*$MGCopyAnswer)(CFStringRef); // get a reference to mgcopyanswer
	void *gestalt = dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_GLOBAL | RTLD_LAZY); // open the mg dylib with lazy binding and global symbols
	$MGCopyAnswer = (dlsym(gestalt, "MGCopyAnswer")); // get the symbol for mgcopyanswer
	return (__bridge NSString *)$MGCopyAnswer(CFSTR("UniqueDeviceID")); // return the mgcopyanswer result for udid and bridge it to an nsstring
}

// SUCCESSFULLY: Encrypts the data and writes it to the plist
// FAILS TO: Actually read and decrypt the encrypted data so it loads an empty DropBox

%hook CyDownDBController
- (NSString*) access_token {
	NSString* result = nil;
	NSString* key = md5(getUDID()); // get the md5sum of the udid
	NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.julioverne.cydown.plist"]; // this is the plist that CyDown uses
	NSData* data = [dict objectForKey:@"db-access_token"]; // the specific data
	NSData* encrypted = nil;
	if (data.length == 64) {
		encrypted = [data aes256Encrypt:key]; // encrypt as aes256
		if (encrypted) {
			[dict setObject:encrypted forKey:@"db-access_token"]; // change plain data to encrypted data
			[dict writeToFile:@"/var/mobile/Library/Preferences/com.julioverne.cydown.plist" atomically:false]; // override the original plist with our encrypted one
			result = [[encrypted aes256Decrypt:key] base64EncodedStringWithOptions:0];
		}
	}
	result = [[data aes256Decrypt:key] base64EncodedStringWithOptions:0];
	[result writeToFile:@"/var/mobile/Documents/access_token.txt" atomically:false];
	if (!data && !result) return @"[CyDown++] Error 1"; // Error data and result are nil
	if (!data) return nil;
	if (!result) return @"[CyDown++] Error 2"; // Error result is nil
	return result;
}
%end

%hook CyDownUtilHelper
+ (void) runCmd: (NSString*) arg0 {
	if ([arg0 containsString:@"rm -rf"] && [arg0 containsString:@".deb"]) return; // if CyDown tries to delete a temporary deb, keep the deb in stasis
	%orig;
}
%end

%hook NSURLRequest
- (id) initWithURL: (NSURL*) arg0 {
	if ([[arg0 absoluteString] containsString:@"cbox.ws"]) arg0 = [NSURL URLWithString:@"https://discord.gg/cZ2gBRZvwW"]; // CyDown chat is hosted on cbox.ws. redirect that to discord
	return %orig;
}
%end

%hook CYDOWNMessageView
- (void) didMoveToWindow {
	%orig;
	if ([self.subtitle containsString:@"MD5Sum verification error"] || [self.subtitle containsString:@"Loop install"]) { // if the error occurring is one that CyDown++ fixes
		self.hidden = true; // hide the error banner
		if (!didShowAlert) {
			didShowAlert = true; // hopefully fixes the endless alert bug?
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
		}
	}
	if ([self.title containsString:@"Started"]) [self fadeMeOut]; // this prevents a 5 second wait time for the alert to show
}
%end

%ctor {
	%init;
	didShowAlert = false;
}