
static NSString *kILMPreferencesPlistPath = @"/var/mobile/Library/Preferences/com.eswick.iconlayoutmanager.plist";
static NSString *kSelectedStateKey = @"selectedState";
static NSString *kSelectedStateDefaultKey = @"Default";
static NSString *kSpringBoardIconStateDirectory = @"/var/mobile/Library/SpringBoard/";

static char kIconLayoutSelectionChangedKey[] = "com.eswick.iconlayoutmanager.selectionchanged";

@interface ILMPrefs : NSObject {
  NSString *_selectedState;
}

@property (nonatomic, retain) NSString *selectedState;

+ (ILMPrefs*)sharedInstance;

- (NSString*)selectedPlistName;
- (NSURL*)selectedPlistURL;
- (NSURL*)selectedDesiredPlistURL;

@end
