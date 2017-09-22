THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 arm64
TARGET = iphone:latest:7.0

include theos/makefiles/common.mk

SRC = $(wildcaard src/*.m)

TWEAK_NAME = WeChatRedEnvelop
WeChatRedEnvelop_FILES = $(wildcard src/*.m) $(wildcard src/*.xm)
WeChatRedEnvelop_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"

