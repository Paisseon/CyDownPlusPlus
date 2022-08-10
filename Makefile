SYSROOT = $(THEOS)/sdks/iPhoneOS14.4.sdk/
ARCHS = arm64
TARGET = iphone:clang:latest:11.0

FINALPACKAGE = 1
DEBUG = 0
THEOS_LEAN_AND_MEAN = 1

TWEAK_NAME = CyDownPP
$(TWEAK_NAME)_FILES = Tweak.x $(wildcard RNCryptor/*.m)
$(TWEAK_NAME)_FRAMEWORKS = Security UIKit
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
