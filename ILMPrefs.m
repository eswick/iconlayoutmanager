#import "ILMPrefs.h"
#import <notify.h>

@implementation ILMPrefs

- (NSURL*)selectedDesiredPlistURL {
  NSURL *directory = [NSURL fileURLWithPath:kSpringBoardIconStateDirectory];
  NSURL *desiredIconStateURL = [directory URLByAppendingPathComponent:[@"Desired" stringByAppendingString:[self selectedPlistName]]];

  return desiredIconStateURL;
}

- (NSURL*)selectedPlistURL {
  NSURL *directory = [NSURL fileURLWithPath:kSpringBoardIconStateDirectory];
  NSURL *iconStateURL = [directory URLByAppendingPathComponent:[self selectedPlistName]];

  return iconStateURL;
}

- (NSString*)selectedPlistName {
  NSString *plistName = nil;

  if ([self.selectedState isEqualToString:kSelectedStateDefaultKey]) {
    plistName = @"IconState.plist";
  } else {
    plistName = [NSString stringWithFormat:@"IconState_%@.plist", self.selectedState];
  }

  return plistName;
}

- (NSString*)selectedState {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:kILMPreferencesPlistPath];

	if (!dict) {
		self.selectedState = kSelectedStateDefaultKey;
	}

	if (!dict[kSelectedStateKey]) {
		self.selectedState = kSelectedStateDefaultKey;
	} else {
		return dict[kSelectedStateKey];
	}

	return _selectedState;
}

- (void)setSelectedState:(NSString*)selectedState {
	NSError *error = nil;
	[@{kSelectedStateKey : selectedState} writeToURL:[NSURL fileURLWithPath:kILMPreferencesPlistPath] error:&error];

	if (error) {
		NSLog(@"%@", error);
	}

  if (![_selectedState isEqualToString:selectedState]) {
    notify_post(kIconLayoutSelectionChangedKey);
  }

	_selectedState = selectedState;
}

+ (ILMPrefs*)sharedInstance {
  static ILMPrefs *_sharedInstance;

  if (!_sharedInstance) {
    _sharedInstance = [ILMPrefs new];
  }

  return _sharedInstance;
}

@end
