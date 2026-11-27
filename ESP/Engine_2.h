// HMOOD__TG@i_8_f
#pragma once

#include <atomic>
#include <cmath>
#include <chrono>
#include <iostream>
#include <string>
#include <thread>
#include <dyld/dyld.h>
#include <UIKit/UIKit.h>

#ifndef HMOOD_METALBIEW_IMPLEMENTATION
#error "Engine_2.h must only be included when HMOOD_METALBIEW_IMPLEMENTATION is defined"
#endif

typedef uintptr_t kaddr;

namespace SDK {
class ASTExtraPlayerController;
class ASTExtraPlayerCharacter;
}

class HeeeNoScreenShotView;

inline float Z = 0.5f;
inline std::atomic<float> aimDisplayWidth{0.f};
inline std::atomic<float> aimDisplayHeight{0.f};

@interface metalbiew () <MTKViewDelegate>
@property(nonatomic, strong) IBOutlet MTKView* mtkView;
@property(nonatomic, strong) id<MTLDevice> device;
@property(nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property(nonatomic, weak) NSTimer* timer;
@property(nonatomic, assign) NSInteger aimcir;
@property(nonatomic, assign) NSInteger rpr;
@end

// HMOOD__TG@i_8_f
static uintptr_t Get_module_base() {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char* rawPath = _dyld_get_image_name(i);
        if (!rawPath) continue;
        std::string path(rawPath);
        if (path.find("ShadowTrackerExtra.app/ShadowTrackerExtra") != std::string::npos) {
            return (uintptr_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

// HMOOD__TG@i_8_f
inline bool IsValidAddress(kaddr addr) {
    return addr > 0x100000000ULL && addr < 0x2000000000ULL;
}

extern bool aPVQRIF;
extern bool zQkX8A;
extern bool MxVsd;
extern bool MXValQy;

extern UIView* menuIconView;
extern float menuIconAlpha;

inline bool hideNameKillMsg = false;
inline float strokeIntensity = 1.0f;

inline SDK::ASTExtraPlayerController* g_LocalController = nullptr;
inline SDK::ASTExtraPlayerController* localPlayerController = nullptr;
inline SDK::ASTExtraPlayerCharacter* localPlayer = nullptr;

inline ImFont* mainFont = nullptr;
inline float globalHpAlphaF = 1.00f;

inline ImU32 COLOR_Distance = IM_COL32(255, 255, 255, 255);
inline ImColor borderColor = ImColor(0, 255, 0, 255);
inline ImColor bgColor = ImColor(0, 0, 0, 80);

inline bool ifismembotenable = false;

namespace Settings {
    inline bool isVisibilityCheck = true;
    inline bool ifismembotenable = false;
    inline bool BypassMode = false;

    namespace SettingsTab {
        inline bool BypassMode = false;
    }

    namespace Aimbot {
        inline bool Enable = false;
        inline bool Tick = false;
        inline int AimMethod = 0;
        inline std::atomic<int> TriggerMode{3};
        inline float FOV = 200.f;

        inline bool MemoryAimbot = false;
        inline bool SilentAim = false;

        namespace SilentAimSettings {
            inline bool Enable = true;
            inline bool AimKnocked = false;
            inline bool Highprecisiontracking = false;

            inline int Aimpositon = 0;
            inline bool Prediction = true;
            inline bool EnableFov = true;
            inline bool BypassFOVLimit = false;
            inline bool AimingLine = false;
            inline float MaxStepDeg = 2.0f;
            inline int LegitTrackSwitchrate = 6;
        }
    }
}

inline float ESPMaxDistance = 300.f;
inline float AlertRadius = 50.0f;
inline float SilentAimMaxDistance = 355.f;
inline int IsStyle = 1;

namespace imgui {
    inline bool ESP = false;
    inline bool Boxes = false;
    inline bool HideBot = false;
    inline bool Health = false;
    inline bool Line = false;
    inline bool Name = false;
    inline bool TeamID = false;
    inline bool Distance = false;
    inline bool EnemyCount = false;
    inline bool Weapon = false;
    inline bool Bone = false;
    inline bool GameInfo = false;
    inline bool Alert360 = false;
    inline bool EnemyAiming = false;
    inline bool Items = false;
    inline bool Lootbox = false;
    inline bool Vehicle = false;
    inline bool Grenade = false;
}

namespace itemesp {
    inline bool Enable = false;
    inline bool Vehicles = true;
    inline float MaxDistance = 200.0f;
}

inline bool IsEnglish = false;
inline bool ShowFov = false;

inline int 玩家 = 0, 人机 = 0;

inline bool 坐标追 = false;
inline bool 自动开火 = false;

constexpr float offset = 21.0f;

inline bool 下雨 = false;
inline float 巨人 = 1.0f;
inline bool 人物变大 = false;
inline bool 重置游客 = false;

inline int 打击圈 = 0;
inline int CL = 1;

inline bool 瞄准线 = false;
inline bool AimBot = false;
inline int AimF = 3;
inline int value = 120;
inline int Aim = 0;

inline float 追踪概率 = 100.f;

inline bool FixShoot = false;
inline float Cross = 150.f;
inline float g_disstance = 150.0f;

inline bool IgnoreKnocked = false;
inline bool VisCheck = false;
inline bool IgnoreBot = false;

inline float RadarX = 30.f;
inline float RadarY = 10.f;
inline bool 对局信息 = true;
inline bool IsLogin = true;
inline bool Enable = false;

inline float crosshairSizeSlider = 0.0f;
inline bool IsCrossHair = false;

inline bool IsNocamerashake = false;
inline bool IsFastshoot = false;
inline bool IsFastSwitch = false;
inline bool IsNorecoil2 = false;
inline bool IsFastDrop = false;
inline bool IsHitXPL = false;
inline bool InstantHit = false;

inline float carx = 0.f;
inline float cary = 0.f;
inline float carz = 0.f;
inline bool CarFly = false;

inline bool tudongnhay = false;
inline bool chaynhanhv2 = false;
inline float tocdoquay = 0.f;
inline bool isSpinning = false;

inline float DanceValue = 0.f;
inline float DancerValue = 0.f;
inline float rainbowSpeed = 0.02f;

inline bool MaxStep = false;
inline bool good = false;
inline bool Blacksky = false;
inline bool 枪械变大 = false;
inline bool HitX = false;
inline bool ReCo = false;

inline float magicX = 23.f + 150.f;
inline float magicY = 25.f + 150.f;
inline float magicZ = 30.5f + 150.f;
inline bool MagicSDK = false;
inline bool Magic = false;

inline bool textBorder = true;
inline bool IsLaunch = false;
inline bool ResetGuest = false;
inline int SX = 0;

inline float Gun_Size = 2.5f;

inline bool 人物自杀 = false;
inline bool 据点 = false;

inline int currentLanguage = 0;

inline bool WideView = false;
inline bool MemoryFastScope = false;
inline bool MemoryZoom = false;
inline bool MemoryDamage = false;
inline bool MemoryRainbow = false;
inline bool MemoryCrossSpin = false;
inline float MemoryZoomFov = 40.f;
inline float MemoryRainbowSpeed = 1.6f;
inline float MemoryCrossSpinSpeed = 180.f;
inline int WideValue = 100;

inline bool initialized = false;

// HMOOD__TG@i_8_f
inline void InitializeMemoryProtection() {
    if (!initialized) {
        initialized = true;
    }
}

inline bool hideHacker = true;
inline HeeeNoScreenShotView* hideesp = nullptr;

inline kaddr module = Get_module_base();

namespace YN {
    inline int boxtype = 1;
    inline int healthbartype = 0;
    inline int Nationtype = 2;
    inline int DirectionLineSize = 70;
    inline int VehicleDirectionLineSize = 100;
    inline int offscreen_range = 40;
    inline int max_distance_offscreen = 400;
    inline int playersdistancessize = 600;
    inline bool esp_Outline = true;
    inline int distance_Radar = 150;
}

inline long l2 = 0xFFFFF;

using namespace std;
using namespace SDK;
using namespace ImGui;

inline int Radar = 0;
inline bool 下雪特效 = false;

struct sConfig {
    struct sESPMenu {
        bool Health;
        bool Name;
        bool Distance;
        bool TeamID;
        bool 对局信息;
        bool Weapon;
        bool Vehicle;
        bool IgnoreBot;
    };
    sESPMenu ESPMenu{false, false, false, false, false, false, false, false};
};

inline sConfig Config{};
inline UISlider* Auto1 = nil;

inline int Interval = 1;
inline int counter = 0;
inline float AimSmooth = 5.0f;

inline int boxtype = 1;
inline int healthbartype = 0;
inline int Nationtype = 2;
inline int DirectionLineSize = 70;
inline int VehicleDirectionLineSize = 100;
inline int offscreen_range = 40;
inline int max_distance_offscreen = 400;
inline int playersdistancessize = 600;
inline bool esp_Outline = true;
inline int distance_Radar = 150;

#define SLEEP_TIME (1000LL / 120LL)
#define TORAD(x) ((x) * (M_PI / 180.f))

inline int screenWidth = 0;
inline int screenHeight = 0;

inline char extra[30] = {0};
inline float density = -1.f;

#ifndef PI
#define PI 3.14159265358979323846
#endif

#ifndef __fastcall
#define __fastcall
#endif
