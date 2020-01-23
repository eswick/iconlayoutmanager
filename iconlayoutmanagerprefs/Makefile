include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = IconLayoutManagerPrefs

IconLayoutManagerPrefs_FILES = ILMRootListController.m ../ILMPrefs.m
IconLayoutManagerPrefs_INSTALL_PATH = /Library/PreferenceBundles
IconLayoutManagerPrefs_FRAMEWORKS = UIKit
IconLayoutManagerPrefs_PRIVATE_FRAMEWORKS = Preferences
IconLayoutManagerPrefs_CFLAGS = -fno-objc-arc
IconLayoutManagerPrefs_LDFLAGS = -F$(THEOS)/sdks/iPhoneOS.sdk/System/Library/PrivateFrameworks

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/IconLayoutManagerPrefs.plist$(ECHO_END)
