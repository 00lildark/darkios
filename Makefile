export THEOS ?= $(HOME)/theos
THEOS_MAKE_PATH ?= $(THEOS)/makefiles

THEOS_DEVICE_IP = 127.0.0.1
ARCHS = arm64
TARGET = iphone:clang:latest:15.0

INSTALL_TARGET_PROCESSES = ShadowTrackerExtra

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ESP

SDK_CPP_FILES = $(wildcard SDK/*.cpp)
SDK_MM_FILES  = $(wildcard SDK/*.mm)

ESP_FILES = Engine.mm \
            Esp.mm \
            Menu.mm \
            meenu.mm \
            new.mm \
            KeySystem.mm \
            $(SDK_CPP_FILES) \
            $(SDK_MM_FILES) \
            ESP/HeeeNoScreenShotView.m \
            ESP/HideFunsion.m \
            ESP/PubgLoad.mm \
            ESP/ini_rw.cpp \
            ESP/imgui/Tools.cpp \
            ESP/imgui/imgui.cpp \
            ESP/imgui/imgui_draw.cpp \
            ESP/imgui/imgui_impl_metal.mm \
            ESP/imgui/imgui_tables.cpp \
            ESP/imgui/imgui_widgets.cpp

ESP_CFLAGS = -fobjc-arc -w -I. -IESP -IESP/imgui -ISDK
ESP_CCFLAGS = -std=c++17 -fno-rtti -fno-exceptions -w -I. -IESP -IESP/imgui -ISDK

ESP_FRAMEWORKS = UIKit Foundation Metal MetalKit QuartzCore CoreGraphics CoreText Security AVFoundation
ESP_LIBRARIES = c++ z

include $(THEOS_MAKE_PATH)/tweak.mk

before-stage::
	@python3 -c 'import glob, os; lua_file = "Skin.lua" if os.path.isfile("Skin.lua") else next(iter(sorted(glob.glob("*.lua"))), None); data = open(lua_file, "rb").read() if lua_file else b"-- empty"; open("SkinLua.h", "w").write("static const unsigned char Skin_lua[] = {" + ",".join(str(b) for b in data) + "};\nstatic const unsigned int Skin_lua_len = " + str(len(data)) + ";\n")'
