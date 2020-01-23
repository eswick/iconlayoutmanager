#include "ILMPrefs.h"
#include <notify.h>

#define prefs [ILMPrefs sharedInstance]

@protocol SBIconModelStore

- (id)init;

@end

@interface SBIconModelPropertyListFileStore : NSObject <SBIconModelStore>

@end

@interface SBHIconModel : NSObject

@property(readonly, nonatomic) id <SBIconModelStore> store;

- (void)importDesiredIconState:(NSDictionary*)arg1;
- (void)reloadIcons;
- (void)layout;

@end

@interface SBHIconModel ()

@property (nonatomic, assign) BOOL ilm_disableSave;

@end

%hook SBIconModelPropertyListFileStore

- (id)initWithIconStateURL:(id)arg1 desiredIconStateURL:(id)arg2 {
  return %orig([prefs selectedPlistURL], [prefs selectedDesiredPlistURL]);
}

%end



%hook SBHIconModel

%property (nonatomic, assign) BOOL ilm_disableSave;

- (void)_saveIconState {
  if (self.ilm_disableSave) {
    return;
  }

  %orig;
}

- (id)initWithStore:(id)arg1 {
  self = %orig;

  if (self) {
    int token, status;

    status = notify_register_dispatch(kIconLayoutSelectionChangedKey, &token,
      dispatch_get_main_queue(), ^(int t) {
        self.ilm_disableSave = YES;

        MSHookIvar<id<SBIconModelStore>>(self, "_store") = [[%c(SBIconModelPropertyListFileStore) alloc] init];

        NSDictionary *newState = [NSDictionary dictionaryWithContentsOfURL:[prefs selectedPlistURL]];
        [self importDesiredIconState:newState];
        [self reloadIcons];
        [self layout];

        self.ilm_disableSave = NO;
    });
  }

  return self;
}

%end
