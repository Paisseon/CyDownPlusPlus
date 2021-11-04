#import "CyPwn.h"
#import <CommonCrypto/CommonCryptor.h>

@implementation NSData (AES256)
- (NSData*) aes256Encrypt: (NSString*) arg0 {
	char key[kCCKeySizeAES256 +1];
	bzero(key, sizeof(key));
	[arg0 getCString:key maxLength:sizeof(key) encoding:NSUTF8StringEncoding];
	NSUInteger dataLength = [self length];
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void* buffer = malloc(bufferSize);
	size_t bytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
										  kCCAlgorithmAES128,
										  kCCOptionPKCS7Padding|kCCOptionECBMode,
										  key,
										  kCCKeySizeAES256,
										  NULL,
										  [self bytes],
										  dataLength,
										  buffer,
										  bufferSize,
										  &bytesEncrypted);
	
	
	
	if (cryptStatus == kCCSuccess) {
		return [NSData dataWithBytesNoCopy:buffer length:bytesEncrypted];
	}
	free(buffer);
	return nil;
}

- (NSData*) aes256Decrypt: (NSString*) arg0 {
	char key[kCCKeySizeAES256+1 ];
	bzero(key, sizeof(key));
	[arg0 getCString:key maxLength:sizeof(key) encoding:NSUTF8StringEncoding];
	NSUInteger dataLength = [self length];
	size_t bufferSize = dataLength + kCCBlockSizeAES128;
	void* buffer = malloc(bufferSize);
	size_t bytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
										  kCCAlgorithmAES128,
										  kCCOptionPKCS7Padding|kCCOptionECBMode,
										  key,
										  kCCKeySizeAES256,
										  NULL,
										  [self bytes],
										  dataLength,
										  buffer,
										  bufferSize,
										  &bytesDecrypted);
	if (cryptStatus == kCCSuccess) {
		return [NSData dataWithBytesNoCopy:buffer length:bytesDecrypted];
	}
	free(buffer);
	return nil;
}
@end