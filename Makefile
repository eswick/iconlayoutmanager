INSTALL_TARGET_PROCESSES = SpringBoard

ifdef SIMULATOR
export TARGET = simulator:clang::13.0
export ARCHS = x86_64
else
export TARGET = iphone:clang::13.0
export ARCHS = arm64 arm64e
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = IconLayoutManager

IconLayoutManager_FILES = Tweak.xm ILMPrefs.m
IconLayoutManager_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += iconlayoutmanagerprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
