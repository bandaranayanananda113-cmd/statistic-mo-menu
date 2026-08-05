export THEOS=/var/mobile/theos
ARCHS = arm64
DEBUG = 0
FINALPACKAGE = 1
FOR_RELEASE = 1
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = 34306jit

$(TWEAK_NAME)_CCFLAGS = -std=c++17 -fno-rtti -DNDEBUG -Wall -Wno-unused-variable -Wno-unused-function -Wno-unused-value -fvisibility=hidden
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wall -Wno-unused-variable -Wno-unused-function -Wno-unused-value -fvisibility=hidden



$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation Security QuartzCore CoreGraphics CoreText AVFoundation Accelerate GLKit SystemConfiguration GameController

34306jit_LDFLAGS += Other/libdobby_fixed.a

$(TWEAK_NAME)_FILES = ImGuiDrawView.mm \
                      oxorany/oxorany.cpp \
                      $(wildcard Esp/*.mm) \
                      $(wildcard Esp/*.m) \
                      $(wildcard IMGUI/*.cpp) \
                      $(wildcard IMGUI/*.mm) \
                      $(wildcard Hosts/*.m)

include $(THEOS_MAKE_PATH)/tweak.mk