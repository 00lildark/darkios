// HMOOD__TG@i_8_f

#import "engine.h"
#include "menu.h"
#include "esp.h"
#import "mahoa.h"
#include "sys/mman.h"
#include "Tools.h"
#include <stdio.h>
#include <stdint.h>
#import <sys/utsname.h>
#include <string>
#include <vector>
#include <locale>
#include <codecvt>
#include <sys/sysctl.h>
#include <signal.h>
#include <unistd.h>
#include <math.h>
#include <cmath>
#include <limits>
#include <chrono>
#include <tuple>
#include <map>
#include <dlfcn.h>
#include <stdlib.h>
#include <filesystem>
#import "HideFunsion.h"

#include <string.h>
#include "Vector3.hpp"
#include "Vector2.hpp"
#import <Foundation/Foundation.h>
#import "UE4.h"
#import "PubgLoad.h"
#include "imgui.h"
#import "HeeeNoScreenShotView.h"
#import "ini_rw.h"

#define ImClamp(X, MIN, MAX) ((X) < (MIN) ? (MIN) : ((X) > (MAX) ? (MAX) : (X)))
#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define timer(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^

#define ICON_FA_EXCLAMATION_TRIANGLE "\xef\x81\xb1"

#define E(str) _xor_(str).c_str()

#define iPhone8P ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define HMOOD_METALBIEW_IMPLEMENTATION
#include "ESP/Engine_2.h"
#undef HMOOD_METALBIEW_IMPLEMENTATION

bool hideNameKillMsg = false;
float strokeIntensity = 1.0f;

SDK::ASTExtraPlayerController* g_LocalController = nullptr;
SDK::ASTExtraPlayerController* localPlayerController = nullptr;
SDK::ASTExtraPlayerCharacter* localPlayer = nullptr;

ImFont* mainFont = nullptr;
float globalHpAlphaF = 1.00f;

ImU32 COLOR_Distance = IM_COL32(255, 255, 255, 255);
ImColor borderColor = ImColor(0, 255, 0, 255);
ImColor bgColor = ImColor(0, 0, 0, 80);

bool ifismembotenable = false;

namespace Settings {
    bool isVisibilityCheck = true;
    bool ifismembotenable = false;
    bool BypassMode = false;

    namespace SettingsTab {
        bool BypassMode = false;
    }

    namespace Aimbot {
        bool Enable = false;
        bool Tick = false;
        int AimMethod = 0;
        std::atomic<int> TriggerMode{3};
        float FOV = 200.f;

        bool MemoryAimbot = false;
        bool SilentAim = false;

        namespace SilentAimSettings {
            bool Enable = true;
            bool AimKnocked = false;
            bool Highprecisiontracking = false;

            int Aimpositon = 0;
            bool Prediction = true;
            bool EnableFov = true;
            bool BypassFOVLimit = false;
            bool AimingLine = false;
            float MaxStepDeg = 2.0f;
            inline int LegitTrackSwitchrate = 6;
        }
    }
}

float ESPMaxDistance = 300.f;
float AlertRadius = 50.0f;
float SilentAimMaxDistance = 355.f;
int IsStyle = 1;

namespace imgui {
    bool ESP = false;
    bool Boxes = false;
    bool HideBot = false;
    bool Health = false;
    bool Line = false;
    bool Name = false;
    bool TeamID = false;
    bool Distance = false;
    bool EnemyCount = false;
    bool Weapon = false;
    bool Bone = false;
    bool GameInfo = false;
    bool Alert360 = false;
    bool EnemyAiming = false;
    bool Items = false;
    bool Lootbox = false;
    bool Vehicle = false;
    bool Grenade = false;
}

namespace itemesp {
    bool Enable = false;
    bool Vehicles = true;
    float MaxDistance = 200.0f;
}

bool IsEnglish = false;
bool ShowFov = false;

int 玩家 = 0, 人机 = 0;

bool 坐标追 = false;
bool 自动开火 = false;

bool 下雨 = false;
float 巨人 = 1.0f;
bool 人物变大 = false;
bool 重置游客 = false;

int 打击圈 = 0;
int CL = 1;

bool 瞄准线 = false;
bool AimBot = false;
int AimF = 3;
int value = 120;
int Aim = 0;

float 追踪概率 = 100.f;

bool FixShoot = false;
float Cross = 150.f;
float g_disstance = 150.0f;

bool IgnoreKnocked = false;
bool VisCheck = false;
bool IgnoreBot = false;

float RadarX = 30.f;
float RadarY = 10.f;
bool 对局信息 = true;
bool IsLogin = true;
bool Enable = false;

float crosshairSizeSlider = 0.0f;
bool IsCrossHair = false;

bool IsNocamerashake = false;
bool IsFastshoot = false;
bool IsFastSwitch = false;
bool IsNorecoil2 = false;
bool IsFastDrop = false;
bool IsHitXPL = false;
bool InstantHit = false;

float carx = 0.f;
float cary = 0.f;
float carz = 0.f;
bool CarFly = false;

bool tudongnhay = false;
bool chaynhanhv2 = false;
float tocdoquay = 0.f;
bool isSpinning = false;

float DanceValue = 0.f;
float DancerValue = 0.f;
float rainbowSpeed = 0.02f;

bool MaxStep = false;
bool good = false;
bool Blacksky = false;
bool 枪械变大 = false;
bool HitX = false;
bool ReCo = false;

float magicX = 23.f + 150.f;
float magicY = 25.f + 150.f;
float magicZ = 30.5f + 150.f;
bool MagicSDK = false;
bool Magic = false;

bool textBorder = true;
bool IsLaunch = false;
bool ResetGuest = false;
int SX = 0;

float Gun_Size = 2.5f;

bool 人物自杀 = false;
bool 据点 = false;

int currentLanguage = 0;

bool WideView = false;
bool MemoryFastScope = false;
bool MemoryZoom = false;
bool MemoryDamage = false;
bool MemoryRainbow = false;
bool MemoryCrossSpin = false;
float MemoryZoomFov = 40.f;
float MemoryRainbowSpeed = 1.6f;
float MemoryCrossSpinSpeed = 180.f;
int WideValue = 100;

bool initialized = false;
bool hideHacker = true;
HeeeNoScreenShotView* hideesp = nullptr;
kaddr module = Get_module_base();

namespace YN {
    int boxtype = 1;
    int healthbartype = 0;
    int Nationtype = 2;
    int DirectionLineSize = 70;
    int VehicleDirectionLineSize = 100;
    int offscreen_range = 40;
    int max_distance_offscreen = 400;
    int playersdistancessize = 600;
    bool esp_Outline = true;
    int distance_Radar = 150;
}

long l2 = 0xFFFFF;
int Radar = 0;
bool 下雪特效 = false;
sConfig Config{};
UISlider* Auto1 = nil;

int Interval = 1;
int counter = 0;
float AimSmooth = 5.0f;

int boxtype = 1;
int healthbartype = 0;
int Nationtype = 2;
int DirectionLineSize = 70;
int VehicleDirectionLineSize = 100;
int offscreen_range = 40;
int max_distance_offscreen = 400;
int playersdistancessize = 600;
bool esp_Outline = true;
int distance_Radar = 150;

int screenWidth = 0;
int screenHeight = 0;
char extra[30] = {0};
float density = -1.f;

namespace {
template <typename T>
inline bool IsValidObjPtr(const T* ptr) {
    return ptr != nullptr && Tools::IsPtrValid(const_cast<void*>(reinterpret_cast<const void*>(ptr)));
}

inline bool IsFiniteVec3(const FVector& v) {
    return std::isfinite(v.X) && std::isfinite(v.Y) && std::isfinite(v.Z);
}
}

// HMOOD__TG@i_8_f
static bool IsAimTriggerActive(const ASTExtraPlayerCharacter* player) {
    if (!IsValidObjPtr(player)) return false;
    const bool fire = player->bIsWeaponFiring;
    const bool ads = player->bIsGunADS;
    switch (Settings::Aimbot::TriggerMode.load(std::memory_order_relaxed)) {
        case 0: return fire;
        case 1: return ads;
        case 2: return fire && ads;
        case 3: return fire || ads;
        default: return false;
    }
}

@implementation metalbiew
INI* config = nullptr;

+ (void)showChange:(BOOL)open {
    MenDeal = (open == YES);
}

// HMOOD__TG@i_8_f
- (MTKView *)mtkView
{
    return (MTKView *)self.view;
}

// HMOOD__TG@i_8_f
- (void)loadView {
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
}

// HMOOD__TG@i_8_f
- (void)viewDidLoad {
    [super viewDidLoad];

    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;
}

// HMOOD__TG@i_8_f
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return nil;

    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"IMGUI.ini"];

    if (![fileManager fileExistsAtPath:filePath]) {
        [fileManager createFileAtPath:filePath contents:[NSData data] attributes:nil];
    }

    config = ini_load((char*)filePath.UTF8String);
    _device = MTLCreateSystemDefaultDevice();
    if (!_device) return self;

    _commandQueue = [_device newCommandQueue];

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGui::StyleColorsDark();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    ApplyImGuiStyle();

    InitializeMenuFonts(io);
    ImGui_ImplMetal_Init(_device);

    return self;
}

static auto start = std::chrono::steady_clock::now();
static auto noww = std::chrono::high_resolution_clock::now();

namespace Settings
{
    int Tab = 0;
}

namespace Variables {
    int ActiveTab = 1;
}

// HMOOD__TG@i_8_f
- (void)drawInMTKView:(MTKView*)view
{
    if (!view || !self.commandQueue) return;

    [[HideFunsion sharedManager] addView:view
                         isStreaming:hideHacker
                             MenDeal:MenDeal];

    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;
    aimDisplayWidth.store(io.DisplaySize.x, std::memory_order_relaxed);
    aimDisplayHeight.store(io.DisplaySize.y, std::memory_order_relaxed);

    static bool s_configLoaded = false;
    if (!s_configLoaded) { [self readIniConfig]; s_configLoaded = true; }

#if TARGET_OS_OSX
    CGFloat framebufferScale = view.window.screen.backingScaleFactor ?: NSScreen.mainScreen.backingScaleFactor;
#else
    CGFloat framebufferScale = view.window.screen.nativeScale ?: [UIScreen mainScreen].nativeScale;
#endif
    if (framebufferScale <= 0.f) framebufferScale = 1.f;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    float fps = (float)(view.preferredFramesPerSecond ?: 60);
    io.DeltaTime = fps > 0.f ? (1.f / fps) : (1.f / 60.f);

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    if (!commandBuffer) return;

    if (MenDeal == true) {
        [self.view setUserInteractionEnabled:YES];
    } else if (MenDeal == false) {
        [self.view setUserInteractionEnabled:NO];
    }

    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil)
    {
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        if (renderEncoder) {
            [renderEncoder pushDebugGroup:@""];

            ImGui_ImplMetal_NewFrame(renderPassDescriptor);
            ImGui::NewFrame();
            if (imgui::ESP || Settings::Aimbot::Tick || Enable) {
                Drawesp();
            }

            DrawWorldEsp();
            RenderMenu();

            ImGui::Render();
            ImDrawData* draw_data = ImGui::GetDrawData();
            if (draw_data) {
                ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
            }

            [renderEncoder popDebugGroup];
            [renderEncoder endEncoding];
        }

        id<CAMetalDrawable> drawable = view.currentDrawable;
        if (drawable) {
            [commandBuffer presentDrawable:drawable];
        }
    }

    [commandBuffer commit];
}

// HMOOD__TG@i_8_f
-(void) readIniConfig {
    if (config) {
        ini_remove(config,(char*)"modSkin",nullptr);
        ini_remove(config,(char*)"modSwitch",nullptr);
    }
    imgui::ESP         = configManager::readBoolean(config, "ESP", "ESP", false);
    imgui::Health      = configManager::readBoolean(config, "ESP", "HEALTH", false);
    imgui::Line        = configManager::readBoolean(config, "ESP", "LINE", false);
    imgui::Name        = configManager::readBoolean(config, "ESP", "NAME", false);
    imgui::TeamID      = configManager::readBoolean(config, "ESP", "TEAM_ID", false);
    imgui::Distance    = configManager::readBoolean(config, "ESP", "DISTANCE", false);
    imgui::EnemyCount  = configManager::readBoolean(config, "ESP", "ENEMY_COUNT", false);
    imgui::Weapon      = configManager::readBoolean(config, "ESP", "WEAPON", false);
    imgui::Bone        = configManager::readBoolean(config, "ESP", "BONE", false);
    imgui::GameInfo    = configManager::readBoolean(config, "ESP", "GAME_INFO", false);
    imgui::EnemyAiming = configManager::readBoolean(config, "ESP", "ENEMY_AIMING", false);
    imgui::Alert360    = configManager::readBoolean(config, "ESP", "ALERT_360", false);
    IsStyle            = configManager::readInteger(config, "ESP", "STYLE", 1);
    imgui::Boxes       = configManager::readBoolean(config, "ESP", "BOXES", false);
    imgui::Items       = configManager::readBoolean(config, "ESP", "ITEMS", false);
    imgui::Lootbox     = configManager::readBoolean(config, "ESP", "LOOTBOX", false);
    imgui::Vehicle     = configManager::readBoolean(config, "ESP", "VEHICLE", false);
    globalHpAlphaF     = ImClamp(configManager::readFloat(config, "ESP", "HP_SCALE", 1.f), .5f, 5.f);
    strokeIntensity    = ImClamp(configManager::readFloat(config, "ESP", "STROKE_WIDTH", 1.f), .5f, 5.f);
    bgColor.Value.x    = ImClamp(configManager::readFloat(config, "ESP", "BORDER_R", bgColor.Value.x), 0.f, 1.f);
    bgColor.Value.y    = ImClamp(configManager::readFloat(config, "ESP", "BORDER_G", bgColor.Value.y), 0.f, 1.f);
    bgColor.Value.z    = ImClamp(configManager::readFloat(config, "ESP", "BORDER_B", bgColor.Value.z), 0.f, 1.f);
    bgColor.Value.w    = ImClamp(configManager::readFloat(config, "ESP", "BORDER_A", bgColor.Value.w), 0.f, 1.f);
    SetMenuLanguage(configManager::readInteger(config, "SYSTEM", "LANGUAGE", 0));
    const int triggerMode = configManager::readInteger(config, "AIMBOT", "TRIGGER_MODE", 3);
    Settings::Aimbot::TriggerMode.store(ImClamp(triggerMode, 0, 3), std::memory_order_relaxed);

    Settings::Aimbot::Tick = configManager::readBoolean(config, "AIMBOT", "ENABLED", false);
    Settings::Aimbot::AimMethod = ImClamp(configManager::readInteger(config, "AIMBOT", "MODE", 0), 0, 2);
    Enable = configManager::readBoolean(config, "AIMBOT", "SILENT_AIM", false) &&
             Settings::Aimbot::Tick && Settings::Aimbot::AimMethod != 0;
    Settings::Aimbot::SilentAim = Enable;
    Settings::Aimbot::SilentAimSettings::AimingLine = configManager::readBoolean(config, "AIMBOT", "AIM_LINE", false);
    Settings::Aimbot::SilentAimSettings::EnableFov = configManager::readBoolean(config, "AIMBOT", "SHOWFOV", true);
    Settings::Aimbot::SilentAimSettings::Prediction = configManager::readBoolean(config, "AIMBOT", "PREDICTION", true);
    Settings::Aimbot::SilentAimSettings::AimKnocked = configManager::readBoolean(config, "AIMBOT", "IGNOREKNOCKED", false);
    Settings::Aimbot::SilentAimSettings::Highprecisiontracking = configManager::readBoolean(config, "AIMBOT", "IGNOREBOTS", false);
    Settings::Aimbot::SilentAimSettings::Aimpositon = ImClamp(configManager::readInteger(config, "AIMBOT", "TARGET", 0), 0, 4);
    Settings::Aimbot::SilentAimSettings::MaxStepDeg = ImClamp(configManager::readFloat(config, "AIMBOT", "MAX_STEP", 2.f), .3f, 8.f);
    Settings::isVisibilityCheck = configManager::readBoolean(config, "AIMBOT", "VISCHECK", true);
    AimSmooth = ImClamp(configManager::readFloat(config, "AIMBOT", "SPEED", 5.f), 2.f, 30.f);
    Cross = ImClamp(configManager::readFloat(config, "AIMBOT", "FOV", 200.f), 30.f, 300.f);
    SilentAimMaxDistance = ImClamp(configManager::readFloat(config, "AIMBOT", "SILENT_DISTANCE", 150.f), 50.f, 355.f);
    追踪概率 = ImClamp(configManager::readFloat(config, "AIMBOT", "HITPROB", 100.f), 0.f, 100.f);
    自动开火 = configManager::readBoolean(config, "AIMBOT", "AUTOFIRE", false) && Settings::Aimbot::Tick;
    瞄准线 = configManager::readBoolean(config, "AIMBOT", "AIMLINE", false);
    ShowFov = Settings::Aimbot::SilentAimSettings::EnableFov;
    VisCheck = Settings::isVisibilityCheck;
    FixShoot = configManager::readBoolean(config, "AIMBOT", "FIXSHOOT", false);
    打击圈 = configManager::readInteger(config, "AIMBOT", "FOVSTYLE", 0);
    CL = configManager::readInteger(config, "AIMBOT", "CIRCLECOLOR", 1);
    AimF = configManager::readInteger(config, "AIMBOT", "ATTACKMETHOD", 1);
    g_disstance = configManager::readFloat(config, "AIMBOT", "DISTANCE", 300.f);

    MemoryFastScope = configManager::readBoolean(config, "MEMORY", "FASTSCOPE", false);
    MemoryZoom = configManager::readBoolean(config, "MEMORY", "ZOOM", false);
    MemoryDamage = configManager::readBoolean(config, "MEMORY", "DAMAGE", false);
    MemoryRainbow = configManager::readBoolean(config, "MEMORY", "RAINBOW", false);
    MemoryCrossSpin = configManager::readBoolean(config, "MEMORY", "CROSSSPIN", false);
    MemoryRainbowSpeed = ImClamp(configManager::readFloat(config, "MEMORY", "RAINBOW_SPEED", 1.6f), .1f, 2.4f);
    MemoryCrossSpinSpeed = ImClamp(configManager::readFloat(config, "MEMORY", "CROSSSPIN_SPEED", 180.f), 0.f, 180.f);
    MemoryZoomFov = ImClamp(configManager::readFloat(config, "MEMORY", "ZOOM_FOV", 40.f), 20.f, 90.f);
    WideView = configManager::readBoolean(config, "SETTINGS", "IPADVIEW", false);
    WideValue = ImClamp(configManager::readInteger(config, "SETTINGS", "TPP", 100), 80, 160);
    IsFastSwitch = configManager::readBoolean(config, "MEMORY", "FASTSWITCH", false);
    IsNocamerashake = configManager::readBoolean(config, "MEMORY", "NOCAMERASHAKE", false);
    IsNorecoil2 = configManager::readBoolean(config, "MEMORY", "NORECOIL2", false);
    IsFastshoot = configManager::readBoolean(config, "MEMORY", "FASTSHOOT", false);
    IsFastDrop = configManager::readBoolean(config,"MEMORY","FASTDROP",false);
    chaynhanhv2 = configManager::readBoolean(config,"MEMORY","SUPERRUN",false);
    isSpinning = configManager::readBoolean(config,"MEMORY","SPIN",false);
    tocdoquay = configManager::readFloat(config,"MEMORY","SPINSPEED",0.f);
    crosshairSizeSlider = ImClamp(configManager::readFloat(config,"MEMORY","CROSSSIZE",0.f), 0.f, 20.f);
    HitX = configManager::readBoolean(config,"MEMORY","HITX",false);
    IsCrossHair = configManager::readBoolean(config,"MEMORY","SMALLCROSS",false);

    hideHacker = configManager::readBoolean(config, "SYSTEM", "HIDERECORD", false);
}

// HMOOD__TG@i_8_f
- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
}

// HMOOD__TG@i_8_f
- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    if (!event || !self.view) return;
    UITouch *anyTouch = event.allTouches.anyObject;
    ImGuiIO &io = ImGui::GetIO();
    if (anyTouch) {
        CGPoint touchLocation = [anyTouch locationInView:self.view];
        io.MousePos = ImVec2(touchLocation.x, touchLocation.y);
    }

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches)
    {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
        {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

// HMOOD__TG@i_8_f
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

// HMOOD__TG@i_8_f
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

// HMOOD__TG@i_8_f
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

// HMOOD__TG@i_8_f
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self updateIOWithTouchEvent:event];
}

typedef uintptr_t kaddr;
using namespace std;
using namespace SDK;

struct sRegion {
    uintptr_t start, end;
};
std::vector<sRegion> trapRegions;

// HMOOD__TG@i_8_f
bool isObjectInvalid(UObject *obj) {
    if (!Tools::IsPtrValid(obj)) {
        return true;
    }

    if (!Tools::IsPtrValid(obj->ClassPrivate)) {
        return true;
    }

    if (obj->InternalIndex <= 0) {
        return true;
    }

    if (obj->NamePrivate.ComparisonIndex <= 0) {
        return true;
    }

    if ((uintptr_t)(obj) % sizeof(uintptr_t) != 0x0 && (uintptr_t)(obj) % sizeof(uintptr_t) != 0x4) {
        return true;
    }

    if (std::any_of(trapRegions.begin(), trapRegions.end(), [obj](sRegion region) { return ((uintptr_t) obj) >= region.start && ((uintptr_t) obj) <= region.end; }) ||
        std::any_of(trapRegions.begin(), trapRegions.end(), [obj](sRegion region) { return ((uintptr_t) obj->ClassPrivate) >= region.start && ((uintptr_t) obj->ClassPrivate) <= region.end; })) {
        return true;
    }

    return false;
}

// HMOOD__TG@i_8_f
kaddr getRealOffset(kaddr offset){
    uintptr_t base = (uintptr_t)Get_module_base();
    if (!base) return 0;
    return base + offset;
}

long obbbbl() {
    uintptr_t base = (uintptr_t)Get_module_base();
    if (!base) return 0;

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *BundID = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    if (!BundID) return 0;

    if([BundID containsString:@"com.tencent.ig"]){
        return (long)getRealOffset(0x10AAD3898);
    }
    if([BundID containsString:@"kr"]){
        return (long)getRealOffset(0x10A566580);
    }
    if([BundID containsString:@"rekoo"]){
        return (long)getRealOffset(0x10A545580);
    }
    if([BundID containsString:@"vn.vng.pubgmobile"]){
        return (long)getRealOffset(0x10A205B00);
    }
    if([BundID containsString:@"imobile"]){
        return (long)getRealOffset(0x1098bac80);
    }
    return 0;
}

UWorld *GEWorld = nullptr;
int GWorldNum = 0;
TUObjectArray gobjects;

#define TSL_FONT_DEFAULT_SIZE 26
static UFont *robotoFont = nullptr, *robotoTinyFont = nullptr, *tslFont = nullptr;

// HMOOD__TG@i_8_f
UWorld *GetFullWorld()
{
    if (!IsValidObjPtr(UObject::GUObjectArray)) {
        return nullptr;
    }

    if (GWorldNum == 0) {
        gobjects = UObject::GUObjectArray->ObjObjects;
        int count = gobjects.Num();
        if (count <= 0 || count > 2000000) return nullptr;
        for (int i = 0; i < count; i++) {
            auto obj = gobjects.GetByIndex(i);
            if (!isObjectInvalid(obj) && obj->IsA(UEngine::StaticClass())) {
                auto GEngine = (UEngine *) obj;
                if (IsValidObjPtr(GEngine)) {
                    tslFont = GEngine->MediumFont;
                    robotoTinyFont = GEngine->MediumFont;
                    robotoFont = GEngine->MediumFont;
                    auto ViewPort = GEngine->GameViewport;
                    if (IsValidObjPtr(ViewPort) && IsValidObjPtr(ViewPort->World)) {
                        GEWorld = ViewPort->World;
                        GWorldNum = i;
                        return ViewPort->World;
                    }
                }
            }
        }
    } else {
        auto GEngine = (UEngine *) (gobjects.GetByIndex(GWorldNum));
        if (!isObjectInvalid(GEngine) && GEngine->IsA(UEngine::StaticClass())) {
            tslFont = GEngine->MediumFont;
            robotoTinyFont = GEngine->MediumFont;
            robotoFont = GEngine->MediumFont;
            auto ViewPort = GEngine->GameViewport;
            if (IsValidObjPtr(ViewPort) && IsValidObjPtr(ViewPort->World)) {
                GEWorld = ViewPort->World;
                return ViewPort->World;
            }
        } else {
            GWorldNum = 0;
        }
    }
    return nullptr;
}

// HMOOD__TG@i_8_f
TNameEntryArray *GetGNames() {
    uintptr_t base = (uintptr_t)Get_module_base();
    if (!base) return nullptr;

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *BundID = [infoDictionary objectForKey:@"CFBundleIdentifier"];
    if (!BundID) return nullptr;

    uintptr_t fnAddr = 0;
    if([BundID containsString:@"ig"]){
        fnAddr = base + 0x10522AC98;
    } else if([BundID containsString:@"kr"]){
        fnAddr = base + 0x104D9FA14;
    } else if([BundID containsString:@"rekoo"]){
        fnAddr = base + 0x104D78AE0;
    } else if([BundID containsString:@"vn"]){
        fnAddr = base + 0x104B1AE24;
    } else if([BundID containsString:@"imobile"]){
        fnAddr = base + 0x10454d2a4;
    }

    if (!fnAddr || !Tools::IsPtrValid(reinterpret_cast<void*>(fnAddr))) {
        return nullptr;
    }
    return ((TNameEntryArray *(*)())fnAddr)();
}

// HMOOD__TG@i_8_f
std::vector<AActor *> getActorsSafe(UWorld* World)
{
    if (!IsValidObjPtr(World))
    {
        return {};
    }
    ULevel* PersistentLevel = World->PersistentLevel;
    if (!IsValidObjPtr(PersistentLevel))
    {
        return {};
    }

    uintptr_t actorsAddr = (uintptr_t)PersistentLevel + 0xa0;
    if (!Tools::IsPtrValid(reinterpret_cast<void*>(actorsAddr))) {
        return {};
    }

    const TArray<AActor *>& Actors = *(const TArray<AActor *> *)actorsAddr;
    int num = Actors.Num();
    if (num <= 0 || num > 100000) {
        return {};
    }

    std::vector<AActor *> ValidActors;
    ValidActors.reserve(num);
    for (int i = 0; i < num; i++)
    {
        auto* Actor = Actors[i];
        if (!isObjectInvalid(Actor) && !Actor->IsChildActor())
        {
            ValidActors.push_back(Actor);
        }
    }
    return ValidActors;
}

// HMOOD__TG@i_8_f
FVector GetBoneLocationByName(ASTExtraPlayerCharacter *Actor, const char *BoneName) {
    if (!IsValidObjPtr(Actor) || !BoneName || !IsValidObjPtr(Actor->Mesh)) return FVector{0, 0, 0};
    return Actor->GetBonePos(BoneName, FVector());
}

// HMOOD__TG@i_8_f
bool WriteAddr(void *addr, void *buffer, size_t length) {
    if (!addr || !buffer || length == 0 || !Tools::IsPtrValid(addr)) return false;
    unsigned long page_size = sysconf(_SC_PAGESIZE);
    if (page_size == 0) page_size = 16384;
    uintptr_t uAddr = (uintptr_t)addr;
    uintptr_t alignedStart = uAddr - (uAddr % page_size);
    size_t alignedLen = ((uAddr + length - alignedStart + page_size - 1) / page_size) * page_size;
    if (mprotect((void *)alignedStart, alignedLen, PROT_EXEC | PROT_READ | PROT_WRITE) != 0) {
        return false;
    }
    memcpy(addr, buffer, length);
    return true;
}

class Rect2 {
public:
    float x;
    float y;
    float width;
    float height;

    Rect2() : x(0), y(0), width(0), height(0) {}

    Rect2(float x, float y, float width, float height)
        : x(x), y(y), width(width), height(height) {}

    bool operator==(const Rect2 &src) const {
        return (src.x == this->x && src.y == this->y && src.height == this->height &&
                src.width == this->width);
    }

    bool operator!=(const Rect2 &src) const {
        return !(*this == src);
    }
};

struct FLinearColor visCol;
ASTExtraPlayerCharacter *g_LocalPlayer = nullptr;
ASTExtraPlayerController *g_PlayerController = nullptr;

#define COLOR_BLACK FLinearColor(0, 0, 0, 1.f)
#define COLOR_WHITE FLinearColor(1.f, 1.f, 1.f, 1.f)
#define COLOR_RED   FLinearColor(1.f, 0, 0, 1.f)
#define COLOR_LIME  FLinearColor(0, 1.f, 0, 1.f)
#define COLOR_BLUE  FLinearColor(0, 0, 1.f, 1.f)
#define COLOR_CAR   FLinearColor(1.f, 0.5f, 1.f, 1.f)
#define GREEN       FLinearColor(0 / 255.f, 153 / 255.f, 0 / 255.f, 1.f)
#define ABU         FLinearColor(0 / 255.f, 204 / 255.f, 204 / 255.f, 1.f)
#define COLOR_GREEN FLinearColor(0, 0.5f, 0, 1.f)
#define COLOR_PLAYER FLinearColor(1.000f, 0.620f, 0.150f, 1.000f)
#define COLOR_YELLOW FLinearColor(1.000f, 1.000f, 0.000f, 1.000f)
#define 黑色 FLinearColor(0, 0, 0, 1.f)
#define 白色 FLinearColor(1.f, 1.f, 1.f, 1.f)
#define 灰色 FLinearColor(0, 1.f, 0, 1.f)
#define 红色 FLinearColor(1.f, 0, 0, 0.7f)
#define 绿色 FLinearColor(0, 0.5f, 0, 1.f)
#define 黄色 FLinearColor(1.00f, 1.00f, 0.0f, 1.0f)
#define 青色 FLinearColor(0.0f, 1.00f, 1.00f, 1.0f)
#define 橄榄绿 FLinearColor(0.5f, 0.5f, 0.0f, 1.0f)
#define 棕色 FLinearColor(0.6f, 0.3f, 0.1f, 1.0f)
#define 紫色 FLinearColor(0.894f, 0.0f, 0.671f, 1.0f)
#define 橙色 FLinearColor(1.00f, 0.45f, 0.0f, 1.0f)
#define 粉色 FLinearColor(1.00f, 0.39f, 0.78f, 1.0f)
#define 蓝色 FLinearColor(0, 2, 2.f, 0.f)

#define W2S(w, s) UGameplayStatics::ProjectWorldToScreen(g_PlayerController, w, false, s)

// HMOOD__TG@i_8_f
FVector2D WorldToRadar(float Yaw, FVector Origin, FVector LocalOrigin, float PosX, float PosY,
                       FVector Size, bool &outbuff)
{
    bool flag = false;
    double num2 = (double)Yaw * 0.017453292519943295;
    float num3 = (float)std::cos(num2);
    float num4 = (float)std::sin(num2);
    float num5 = Origin.X - LocalOrigin.X;
    float num6 = Origin.Y - LocalOrigin.Y;
    FVector2D vector;
    vector.X = (num6 * num3 - num5 * num4) / 150.f;
    vector.Y = (num5 * num3 + num6 * num4) / 150.f;
    FVector2D vector2;
    vector2.X = vector.X + PosX + Size.X / 2.f;
    vector2.Y = -vector.Y + PosY + Size.Y / 2.f;
    if (vector2.X > PosX + Size.X) {
        vector2.X = PosX + Size.X;
    } else if (vector2.X < PosX) {
        vector2.X = PosX;
    }
    if (vector2.Y > PosY + Size.Y) {
        vector2.Y = PosY + Size.Y;
    } else if (vector2.Y < PosY) {
        vector2.Y = PosY;
    }
    if (vector2.Y == PosY || vector2.X == PosX || vector2.Y == PosY + Size.Y || vector2.X == PosX + Size.X) {
        flag = true;
    }
    outbuff = flag;
    return vector2;
}

// HMOOD__TG@i_8_f
FVector WorldToRadar(float Yaw, FVector Origin, FVector LocalOrigin, float PosX, float PosY,
                     Vector3 Size, bool &outbuff)
{
    FVector2D res = WorldToRadar(Yaw, Origin, LocalOrigin, PosX, PosY, FVector{Size.X, Size.Y, Size.Z}, outbuff);
    return FVector{res.X, res.Y, 0.f};
}

// HMOOD__TG@i_8_f
FVector2D rotateCoord(float angle, FVector2D coord) {
    float s = sin(angle * M_PI / 180.f);
    float c = cos(angle * M_PI / 180.f);

    return {coord.X * c + coord.Y * s, -coord.X * s + coord.Y * c};
}

// HMOOD__TG@i_8_f
float DegreeToRadian(float degree){
    return degree * (M_PI / 180.f);
}

// HMOOD__TG@i_8_f
void DrawFilledRectangle(AHUD *HUD, FVector2D Pos, float Width, float Height, FLinearColor Color) {
    if (!IsValidObjPtr(HUD)) return;
    HUD->DrawRect(Color, Pos.X, Pos.Y, Width, Height);
}

// HMOOD__TG@i_8_f
void DrawLine(AHUD *HUD, FVector2D posFrom, FVector2D posTo, float Thickness, FLinearColor Color) {
    if (!IsValidObjPtr(HUD)) return;
    HUD->DrawLine(posFrom.X, posFrom.Y, posTo.X, posTo.Y, Color, Thickness);
}

// HMOOD__TG@i_8_f
void DrawCircle(UCanvas *Canvas, int x, int y, int radius, int numsides, FLinearColor OutlineColor){
    if (!IsValidObjPtr(Canvas) || numsides <= 0) return;
    if (numsides > 127) numsides = 127;
    float Step = (float)(M_PI * 2.0 / numsides);
    for (float a = 0.f; a < (float)(M_PI * 2.0); a += Step)
    {
        float X1 = radius * cosf(a) + x;
        float Y1 = radius * sinf(a) + y;
        float X2 = radius * cosf(a + Step) + x;
        float Y2 = radius * sinf(a + Step) + y;
        Canvas->K2_DrawLine(FVector2D{X1, Y1}, FVector2D{X2, Y2}, 1.f, OutlineColor);
    }
}

// HMOOD__TG@i_8_f
void DrawCircle(AHUD *HUD, int x, int y, int radius, int numsides, FLinearColor OutlineColor){
    if (!IsValidObjPtr(HUD) || !IsValidObjPtr(HUD->Canvas)) return;
    DrawCircle(HUD->Canvas, x, y, radius, numsides, OutlineColor);
}

// HMOOD__TG@i_8_f
void *LoadFont() {
    if (!IsValidObjPtr(UObject::GUObjectArray) || !FName::GNames) {
        return nullptr;
    }
    if (!tslFont) tslFont = UObject::FindObject<UFont>("Font TSLFont.TSLFont");
    if (!robotoFont) robotoFont = UObject::FindObject<UFont>("Font Roboto.Roboto");
    if (!robotoTinyFont) robotoTinyFont = UObject::FindObject<UFont>("Font RobotoTiny.RobotoTiny");
    return nullptr;
}

// HMOOD__TG@i_8_f
bool _read(kaddr addr, void *buffer, int len)
{
    if (!addr || !buffer || len <= 0 || !IsValidAddress(addr)) return false;
    vm_size_t size = 0;
    kern_return_t error = vm_read_overwrite(mach_task_self(), (vm_address_t)addr, len, (vm_address_t)buffer, &size);
    if(error != KERN_SUCCESS || size != (vm_size_t)len)
    {
        return false;
    }
    return true;
}

void (*orig_Broadcast)(ASTExtraPlayerController* thiz, FFatalDamageParameter* FatalDamageParameter) = nullptr;

// HMOOD__TG@i_8_f
void hk_Broadcast(ASTExtraPlayerController* thiz, FFatalDamageParameter* FatalDamageParameter)
{
    if (!orig_Broadcast) return;
    if (!IsValidObjPtr(thiz) || !Tools::IsPtrValid(FatalDamageParameter))
        return orig_Broadcast(thiz, FatalDamageParameter);

    if (!IsValidObjPtr(g_PlayerController) || !IsValidObjPtr(g_LocalPlayer))
        return orig_Broadcast(thiz, FatalDamageParameter);

    if (g_PlayerController->PlayerKey == 0)
        return orig_Broadcast(thiz, FatalDamageParameter);

    if (hideNameKillMsg && g_PlayerController->PlayerKey == FatalDamageParameter->CauserKey) {
        static uint16_t hideBuf[] = { '?','?','?', 0 };
        struct FStr16 { uint16_t *D; int32_t C; int32_t M; };
        FStr16 *r;
        r = reinterpret_cast<FStr16*>(&FatalDamageParameter->String.causerName);
        if (Tools::IsPtrValid(r)) { r->D = hideBuf; r->C = r->M = 4; }
        r = reinterpret_cast<FStr16*>(&FatalDamageParameter->String.FuzzyCauserName);
        if (Tools::IsPtrValid(r)) { r->D = hideBuf; r->C = r->M = 4; }
        r = reinterpret_cast<FStr16*>(&FatalDamageParameter->String.RealKillerName);
        if (Tools::IsPtrValid(r)) { r->D = hideBuf; r->C = r->M = 4; }
    }

    return orig_Broadcast(thiz, FatalDamageParameter);
}

int glWidth = 0, glHeight = 0;

// HMOOD__TG@i_8_f
static FVector ResolveAimPosition(ASTExtraPlayerCharacter* player, ASTExtraPlayerController* controller);

// HMOOD__TG@i_8_f
ASTExtraPlayerCharacter* GetTargetByCrossDist() {
    auto* player = g_LocalPlayer;
    auto* controller = g_PlayerController;
    if (!IsLogin || !IsValidObjPtr(player) || !IsValidObjPtr(controller) || !IsValidObjPtr(player->RootComponent) || glWidth <= 0 || glHeight <= 0)
        return nullptr;
    const float displayWidth = aimDisplayWidth.load(std::memory_order_relaxed);
    const float displayHeight = aimDisplayHeight.load(std::memory_order_relaxed);
    if (displayWidth <= 0.f || displayHeight <= 0.f || !std::isfinite(Cross) || Cross <= 0.f)
        return nullptr;
    int viewportWidth = 0, viewportHeight = 0;
    controller->GetViewportSize(&viewportWidth, &viewportHeight);
    if (viewportWidth <= 0 || viewportHeight <= 0) return nullptr;
    const float scaleX = displayWidth / viewportWidth, scaleY = displayHeight / viewportHeight;
    const float centerX = displayWidth * .5f, centerY = displayHeight * .5f;
    const bool bulletTrack = Enable;
    float nearest = bulletTrack ? std::numeric_limits<float>::infinity() : Cross * Cross;
    ASTExtraPlayerCharacter* result = nullptr;
    std::vector<ASTExtraPlayerCharacter*> players;
    GetAllActors(players);
    for (auto* candidate : players) {
        if (!IsValidObjPtr(candidate) || candidate == player || candidate->PlayerKey == player->PlayerKey ||
            candidate->TeamID == player->TeamID || candidate->bDead || candidate->bHidden ||
            !IsValidObjPtr(candidate->Mesh) || !IsValidObjPtr(candidate->RootComponent))
            continue;
        if (Settings::Aimbot::SilentAimSettings::AimKnocked && candidate->Health <= 0.f)
            continue;
        if (Settings::Aimbot::SilentAimSettings::Highprecisiontracking && (candidate->bEnsure || candidate->bIsAI))
            continue;
        const float distance = player->GetDistanceTo(candidate) / 100.f;
        if (!std::isfinite(distance) || distance > SilentAimMaxDistance)
            continue;
        if (Settings::isVisibilityCheck && !controller->LineOfSightTo(candidate, {0, 0, 0}, true))
            continue;
        const FVector point = ResolveAimPosition(candidate, controller);
        if (!IsFiniteVec3(point) || (!(point.X || point.Y || point.Z))) continue;
        float metric = distance * distance;
        if (!bulletTrack) {
            FVector2D screen;
            if (!UGameplayStatics::ProjectWorldToScreen(controller, point, false, &screen)) continue;
            const float x = screen.X * scaleX, y = screen.Y * scaleY;
            if (!std::isfinite(x) || !std::isfinite(y) || x < 0.f || x > displayWidth || y < 0.f || y > displayHeight)
                continue;
            const float dx = x - centerX, dy = y - centerY;
            metric = dx * dx + dy * dy;
            if (metric > Cross * Cross) continue;
        }
        if (metric <= nearest) {
            nearest = metric;
            result = candidate;
        }
    }
    return result;
}

// HMOOD__TG@i_8_f
auto VIP_Fov_Based() -> ASTExtraPlayerCharacter* { return GetTargetByCrossDist(); }

// HMOOD__TG@i_8_f
static void UpdateAutoFire(ASTExtraPlayerCharacter* player, ASTExtraPlayerController* controller) {
    static uintptr_t previousController = 0;
    static bool pressed = false;
    const uintptr_t identity = (uintptr_t)controller;
    if (previousController != identity) { pressed = false; previousController = identity; }
    bool fire = IsLogin && Settings::Aimbot::Tick && 自动开火 && IsValidObjPtr(player) && IsValidObjPtr(controller) &&
                IsValidObjPtr(player->RootComponent) && !player->bDead;
    if (fire) {
        auto* manager = player->WeaponManagerComponent;
        fire = IsValidObjPtr(manager) && IsValidObjPtr(manager->CurrentWeaponReplicated);
        if (fire) {
            const int slot = (int)manager->GetCurrentUsingPropSlot().GetValue();
            fire = slot >= 1 && slot <= 3 &&
                   manager->CurrentWeaponReplicated->IsA(ASTExtraShootWeapon::StaticClass());
        }
        const int trigger = Settings::Aimbot::TriggerMode.load(std::memory_order_relaxed);
        if ((trigger == 1 || trigger == 2) && !player->bIsGunADS) fire = false;
        if (fire) fire = GetTargetByCrossDist() != nullptr;
    }
    if (fire && !pressed) {
        if (IsValidObjPtr(controller)) { controller->OnPressFire(); pressed = true; }
    } else if (!fire && pressed) {
        if (IsValidObjPtr(controller)) controller->OnReleaseFire();
        pressed = false;
    }
}

bool  VehicleAimNearCrosshair = false;
bool  VehicleVisCheck         = false;

float VehicleAimConeDeg   = 8.0f;
float VehicleAimHeightZ   = 50.0f;
float SilentAimPingMs     = 0.0f;

// HMOOD__TG@i_8_f
static inline float Dot3(const FVector& a, const FVector& b){ return a.X*b.X + a.Y*b.Y + a.Z*b.Z; }
// HMOOD__TG@i_8_f
static inline float Len (const FVector& v){ return sqrtf(v.X*v.X + v.Y*v.Y + v.Z*v.Z); }
// HMOOD__TG@i_8_f
static inline float DegToRad(float d){ return d * 0.017453292519943295f; }

// HMOOD__TG@i_8_f
static float GetPingSeconds(APlayerController* ) {
    float ms = SilentAimPingMs;
    if (ms < 0.f)   ms = 0.f;
    if (ms > 400.f) ms = 400.f;
    return ms * 0.001f;
}

// HMOOD__TG@i_8_f
static bool IsPartiallyVisible(APlayerController* PC, AActor* Other, const FVector& viewLoc){
    if (!IsValidObjPtr(PC) || !IsValidObjPtr(Other)) return false;
    if (PC->LineOfSightTo(Other, viewLoc, true)) return true;

    FVector to = UKismetMathLibrary::Subtract_VectorVector(Other->K2_GetActorLocation(), viewLoc);
    float   d  = Len(to);
    if (d > 1.f && d <= 12000.f) {
        FRotator rot = PC->GetControlRotation();
        FVector fwd  = UKismetMathLibrary::GetForwardVector(rot);
        FVector dir  = { to.X/d, to.Y/d, to.Z/d };
        float   cosT = Dot3(fwd, dir);
        if (cosT > cosf(DegToRad(6.0f))) return true;
    }
    return false;
}

// HMOOD__TG@i_8_f
static bool IsVisiblePoint(APlayerController* PC, AActor* Target, const FVector& from, const FVector& to) {
    (void)from;
    if (!IsValidObjPtr(PC) || !IsValidObjPtr(Target)) return false;
    return PC->LineOfSightTo(Target, to, true);
}

// HMOOD__TG@i_8_f
static FVector GetBestBonePosVisible(ASTExtraPlayerCharacter* P, APlayerController* PC, const FVector& viewLoc){
    if (!IsValidObjPtr(P) || !IsValidObjPtr(P->Mesh)) return FVector{0,0,0};

    static const char* bones[] = {
        "Head","neck_01","spine_03","spine_02",
        "hand_r","hand_l","lowerarm_r","lowerarm_l","upperarm_r","upperarm_l",
        "foot_r","foot_l","calf_r","calf_l","thigh_r","thigh_l",
        "spine_01","pelvis"
    };

    FVector fallback{0,0,0};
    for (int i=0;i<(int)(sizeof(bones)/sizeof(bones[0])); ++i) {
        FVector p = P->GetBonePos(bones[i], {});
        if (!IsFiniteVec3(p) || (!(p.X||p.Y||p.Z))) continue;
        if (IsVisiblePoint(PC, (AActor*)P, viewLoc, p)) {
            return p;
        }
        if (!(fallback.X||fallback.Y||fallback.Z)) fallback = p;
    }
    if (fallback.X||fallback.Y||fallback.Z) return fallback;
    FVector h = P->GetBonePos("Head", {}); if (IsFiniteVec3(h) && (h.X||h.Y||h.Z)) return h;
    return P->GetBonePos("pelvis", {});
}

// HMOOD__TG@i_8_f
static FVector ResolveAimPosition(ASTExtraPlayerCharacter* player, ASTExtraPlayerController* controller) {
    if (!IsValidObjPtr(player) || !IsValidObjPtr(player->Mesh)) return FVector{0, 0, 0};
    const char* bones[] = {"Head", "neck_01", "spine_03", "pelvis"};
    const int target = Settings::Aimbot::SilentAimSettings::Aimpositon;
    if (target >= 0 && target < 4) return player->GetBonePos(bones[target], {});
    FVector view = IsValidObjPtr(g_LocalPlayer) ? g_LocalPlayer->GetBonePos("Head", {}) : FVector{0, 0, 0};
    view.Z += 10.f;
    return GetBestBonePosVisible(player, controller, view);
}

// HMOOD__TG@i_8_f
static ASTExtraVehicleBase* PickVehicleNearCrosshair(
    APlayerController* PC, const FVector& start, const FRotator& shotRot, float coneDeg, bool doVis)
{
    if (!IsValidObjPtr(PC) || !IsValidObjPtr(g_LocalPlayer)) return nullptr;

    TArray<AActor*> all;
    UGameplayStatics::GetAllActorsOfClass((UObject*)PC, AActor::StaticClass(), &all);
    if (all.Num() <= 0 || all.Num() > 100000) return nullptr;

    FVector aimDir = UKismetMathLibrary::GetForwardVector(shotRot);
    float l2 = aimDir.X*aimDir.X + aimDir.Y*aimDir.Y + aimDir.Z*aimDir.Z;
    if (l2 < 0.5f && IsValidObjPtr(PC->PlayerCameraManager))
        aimDir = UKismetMathLibrary::GetForwardVector(PC->PlayerCameraManager->GetCameraRotation());

    const float coneCos = cosf(DegToRad(coneDeg>0.f?coneDeg:10.f));
    FVector viewLoc = g_LocalPlayer->GetBonePos("Head", {}); viewLoc.Z += 10.f;

    float best = 1e9f;
    ASTExtraVehicleBase* bestVeh = nullptr;

    for (int i=0;i<all.Num();++i){
        AActor* a = all[i];
        if (!IsValidObjPtr(a) || !a->IsA(ASTExtraVehicleBase::StaticClass())) continue;

        auto* V = (ASTExtraVehicleBase*)a;
        if (!IsValidObjPtr(V->RootComponent)) continue;
        if (doVis && !IsPartiallyVisible(PC, V, viewLoc)) continue;

        FVector to = UKismetMathLibrary::Subtract_VectorVector(V->K2_GetActorLocation(), start);
        float d = Len(to); if (d < 1.f) continue;

        FVector dir = { to.X/d, to.Y/d, to.Z/d };
        float dot = Dot3(aimDir, dir);
        if (dot < coneCos) continue;

        float score = (1.f - dot)*1000.f + (d * 0.001f);
        if (score < best){ best = score; bestVeh = V; }
    }
    return bestVeh;
}

// HMOOD__TG@i_8_f
static ASTExtraPlayerCharacter* FindVehicleOccupant(ASTExtraVehicleBase* Veh){
    if (!IsValidObjPtr(Veh)) return nullptr;

    TArray<AActor*> allP;
    UGameplayStatics::GetAllActorsOfClass((UObject*)Veh, ASTExtraPlayerCharacter::StaticClass(), &allP);
    if (allP.Num() <= 0 || allP.Num() > 100000) return nullptr;

    ASTExtraPlayerCharacter* best = nullptr;
    float bestD = 1e9f;

    FVector cam = IsValidObjPtr(g_LocalPlayer) ? g_LocalPlayer->GetBonePos("Head", {}) : FVector();
    cam.Z += 10.f;

    for (int i=0;i<allP.Num();++i){
        auto* P = (ASTExtraPlayerCharacter*)allP[i];
        if (!IsValidObjPtr(P) || P==g_LocalPlayer) continue;
        if (P->bDead) continue;
        if (P->CurrentVehicle != Veh) continue;

        float d = Len(UKismetMathLibrary::Subtract_VectorVector(P->K2_GetActorLocation(), cam));
        if (d < bestD){ bestD = d; best = P; }
    }
    return best;
}

void (*orig_shoot_event)(USTExtraShootWeaponComponent *thiz, FVector start, FRotator rot, void *unk1, int unk2) = nullptr;

// HMOOD__TG@i_8_f
void shoot_event(USTExtraShootWeaponComponent *thiz, FVector start, FRotator rot, ASTExtraShootWeapon *weapon, int unk1) {
    if (!orig_shoot_event) return;
    if (!Enable || !Settings::Aimbot::Tick || Settings::Aimbot::AimMethod == 0 ||
        !IsLogin || !IsValidObjPtr(g_LocalPlayer) || !IsValidObjPtr(g_PlayerController) || !IsValidObjPtr(thiz))
        return orig_shoot_event(thiz, start, rot, weapon, unk1);
    const float probability = std::isfinite(追踪概率) ? ImClamp(追踪概率, 0.f, 100.f) : 0.f;
    if (probability <= 0.f || (probability < 100.f && arc4random_uniform(10000) >= (uint32_t)(probability * 100.f)))
        return orig_shoot_event(thiz, start, rot, weapon, unk1);
    UKismetMathLibrary* UMC = (UKismetMathLibrary*)UKismetMathLibrary::StaticClass();
    if (!IsValidObjPtr(UMC))
        return orig_shoot_event(thiz, start, rot, weapon, unk1);

    ASTExtraPlayerCharacter* Target = nullptr;

    if (Enable) Target = VIP_Fov_Based();

    if (Target && g_LocalPlayer) {
        float dist = g_LocalPlayer->GetDistanceTo(Target) / 100.0f;
        if (!std::isfinite(dist) || dist > SilentAimMaxDistance) {
            Target = nullptr;
        }
    }

    ASTExtraVehicleBase* VehicleChosen = nullptr;
    if (!Target && VehicleAimNearCrosshair && IsValidObjPtr(g_LocalController)) {
        float cone = (VehicleAimConeDeg>0.f?VehicleAimConeDeg:8.f);
        VehicleChosen = PickVehicleNearCrosshair(g_LocalController, start, rot, cone, VehicleVisCheck);
        if (VehicleChosen) {
            if (ASTExtraPlayerCharacter* occ = FindVehicleOccupant(VehicleChosen)) {
                Target = occ;
                VehicleChosen = nullptr;
            }
        }
    }

    if (Target && g_LocalPlayer) {
        float dist = g_LocalPlayer->GetDistanceTo(Target) / 100.0f;
        if (!std::isfinite(dist) || dist > SilentAimMaxDistance) {
            Target = nullptr;
        }
    }

    if (Target || VehicleChosen) {
        bool triggerOk = IsAimTriggerActive(g_LocalPlayer);

        if (triggerOk) {
            FVector targetAimPos{};

            if (Target) {
                FVector bonePos = ResolveAimPosition(Target, g_PlayerController);

                if (!IsFiniteVec3(bonePos) || (!(bonePos.X || bonePos.Y || bonePos.Z)))
                    return orig_shoot_event(thiz, start, rot, weapon, unk1);

                auto SW = thiz->ShootWeaponEntityComponent;
                if (IsValidObjPtr(SW)) {
                    float spd = SW->BulletFireSpeed;
                    if (std::isfinite(spd) && spd > 1.f && Settings::Aimbot::SilentAimSettings::Prediction) {
                        ASTExtraVehicleBase* curVeh = IsValidObjPtr(Target->CurrentVehicle) ? Target->CurrentVehicle : nullptr;
                        FVector tgtVel = curVeh ? curVeh->ReplicatedMovement.LinearVelocity
                                                : Target->GetVelocity();

                        const bool airborneish = fabsf(tgtVel.Z) > 120.f;

                        float dist = Len(UMC->Subtract_VectorVector(bonePos, start));
                        float t = dist/spd + GetPingSeconds(g_LocalController);
                        if (airborneish) t += 0.05f;

                        targetAimPos = UMC->Add_VectorVector(bonePos, UMC->Multiply_VectorFloat(tgtVel, t));
                        targetAimPos.Z += 0.5f * 980.f * t * t;

                        if (airborneish && (bonePos.Z - start.Z) > 600.f) {
                            targetAimPos.Z += 15.f;
                        }
                    } else {
                        targetAimPos = bonePos;
                    }
                } else {
                    targetAimPos = bonePos;
                }
            }
            else if (VehicleChosen && IsValidObjPtr(VehicleChosen->RootComponent)) {
                targetAimPos = VehicleChosen->K2_GetActorLocation();
                targetAimPos.Z += (VehicleAimHeightZ != 0.f ? VehicleAimHeightZ : 50.f);

                auto SW = thiz->ShootWeaponEntityComponent;
                if (IsValidObjPtr(SW)) {
                    float spd = SW->BulletFireSpeed;
                    if (std::isfinite(spd) && spd > 1.f && Settings::Aimbot::SilentAimSettings::Prediction) {
                        FVector vel = VehicleChosen->ReplicatedMovement.LinearVelocity;
                        float dist = g_LocalPlayer->GetDistanceTo(VehicleChosen);
                        float t = dist/spd + GetPingSeconds(g_LocalController);

                        targetAimPos = UMC->Add_VectorVector(targetAimPos, UMC->Multiply_VectorFloat(vel, t));
                        targetAimPos.Z += 0.5f * 980.f * t * t;
                    }
                }
            }

            if (!IsFiniteVec3(targetAimPos))
                return orig_shoot_event(thiz, start, rot, weapon, unk1);
            FVector fDir = UMC->Subtract_VectorVector(targetAimPos, start);
            rot = UMC->Conv_VectorToRotator(fDir);
            return orig_shoot_event(thiz, targetAimPos, rot, weapon, unk1);
        }
    }

    return orig_shoot_event(thiz, start, rot, weapon, unk1);
}

// HMOOD__TG@i_8_f
const char *GetVehicleName(ASTExtraVehicleBase *Vehicle)
{
    if (!IsValidObjPtr(Vehicle)) return "Vehicle";
    switch (Vehicle->VehicleShapeType)
    {
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Motorbike:
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Motorbike_SideCart:
        return "Motorbike";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Dacia:
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_HeavyDacia:
        return "Dacia";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_MiniBus:
        return "Mini Bus";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_PickUp:
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_PickUp01:
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_HeavyPickup:
        return "Pick Up";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Buggy:
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_HeavyBuggy:
        return "Buggy";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_UAZ:
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_UAZ01:
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_UAZ02:
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_UAZ03:
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_HeavyUAZ:
        return "UAZ";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_PG117:
        return "PG117";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Aquarail:
        return "Aquarail";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Mirado:
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Mirado01:
        return "Mirado";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Rony:
        return "Rony";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Scooter:
        return "Scooter";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_SnowMobile:
        return "Snow Mobile";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_TukTukTuk:
        return "Tuk Tuk";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_SnowBike:
        return "Snow Bike";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Surfboard:
        return "Surf Board";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Snowboard:
        return "Snow Board";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Amphibious:
        return "Amphibious";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_LadaNiva:
        return "Lada Niva";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_UAV:
        return "UAV";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_MegaDrop:
        return "Mega Drop";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Lamborghini:
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_Lamborghini01:
        return "Lamborghini";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_GoldMirado:
        return "Gold Mirado";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_BigFoot:
        return "Big Foot";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_HeavyUH60:
        return "UH60";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_CoupeRB:
        return "CoupeRB";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_UTV:
        return "UTV";
    case ESTExtraVehicleShapeType::ESTExtraVehicleShapeType__VST_WingMan:
        return "Helicopter";
    default:
        return "Vehicle";
    }
}

// HMOOD__TG@i_8_f
void ResetGuestAccount() {
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:[NSString stringWithFormat:@"%@/Documents/ano_tmp", NSHomeDirectory()] error:nil];
    [fm removeItemAtPath:[NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()] error:nil];
    [fm removeItemAtPath:[NSString stringWithFormat:@"%@/Library", NSHomeDirectory()] error:nil];
    [fm removeItemAtPath:[NSString stringWithFormat:@"%@/tmp", NSHomeDirectory()] error:nil];

    NSString *prefsPath = [NSString stringWithFormat:@"%@/Library/Preferences", NSHomeDirectory()];
    NSArray *prefsFiles = [fm contentsOfDirectoryAtPath:prefsPath error:nil];

    NSArray *bundleIdentifiersToRemove = @[
        @"tencent",
        @"ig",
        @"rekoo",
        @"vn",
        @"imobile",
        @"korean"
    ];

    for (NSString *file in prefsFiles) {
        for (NSString *bundleId in bundleIdentifiersToRemove) {
            if ([file containsString:bundleId] || [file hasSuffix:@".plist"]) {
                [fm removeItemAtPath:[prefsPath stringByAppendingPathComponent:file] error:nil];
                break;
            }
        }
    }

    UIWindow *window = nil;
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]] && scene.activationState == UISceneActivationStateForegroundActive) {
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *w in windowScene.windows) {
                if (w.isKeyWindow) {
                    window = w;
                    break;
                }
            }
            if (window) break;
        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (!window) window = [UIApplication sharedApplication].keyWindow;
#pragma clang diagnostic pop

    UIViewController *rootVC = window.rootViewController;
    if (rootVC) {
        UIAlertController *done = [UIAlertController alertControllerWithTitle:[NSString stringWithUTF8String:
            TranslateMenuText("Guest reset complete. Game will exit in 5s.")]
                                                                      message:nil
                                                               preferredStyle:UIAlertControllerStyleAlert];
        [rootVC presentViewController:done animated:YES completion:nil];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        exit(0);
    });
}

// HMOOD__TG@i_8_f
static void ApplyMemoryReferenceOptions(ASTExtraPlayerCharacter* player, ASTExtraPlayerController* controller) {
    if (!IsValidObjPtr(player) || !IsValidObjPtr(controller)) return;
    struct Value { float original = 0.f; bool applied = false; };
    struct IntegerValue { int original = 0; bool applied = false; };
    using Key = std::tuple<uintptr_t, int, uintptr_t>;
    static std::map<Key, Value> floats;
    static std::map<Key, IntegerValue> integers;
    static uintptr_t previousController = 0;
    if (previousController != (uintptr_t)controller) {
        floats.clear(); integers.clear(); previousController = (uintptr_t)controller;
    }
    auto changeFloat = [&](UObject* owner, float& field, bool enabled, float value) {
        if (!IsValidObjPtr(owner) || !Tools::IsPtrValid(&field)) return;
        const Key key((uintptr_t)owner, owner->InternalIndex, (uintptr_t)&field);
        if (!enabled && floats.find(key) == floats.end()) return;
        auto& saved = floats[key];
        if (enabled) {
            if (!saved.applied) saved.original = field;
            field = value;
            saved.applied = true;
        } else if (saved.applied) { field = saved.original; saved.applied = false; }
    };
    auto changeInteger = [&](UObject* owner, int& field, bool enabled, int value) {
        if (!IsValidObjPtr(owner) || !Tools::IsPtrValid(&field)) return;
        const Key key((uintptr_t)owner, owner->InternalIndex, (uintptr_t)&field);
        if (!enabled && integers.find(key) == integers.end()) return;
        auto& saved = integers[key];
        if (enabled) {
            if (!saved.applied) saved.original = field;
            field = value;
            saved.applied = true;
        } else if (saved.applied) { field = saved.original; saved.applied = false; }
    };
    static const auto started = std::chrono::steady_clock::now();
    const float elapsed = std::chrono::duration<float>(std::chrono::steady_clock::now() - started).count();
    static float previousTime = elapsed, phase = 0.f, spinAngle = 0.f;
    const float delta = ImClamp(elapsed - previousTime, 0.f, .1f);
    previousTime = elapsed;
    if (MemoryRainbow) phase = fmodf(phase + delta * ImClamp(MemoryRainbowSpeed, .1f, 2.4f), 6.2831853f);
    if (MemoryCrossSpin) spinAngle = fmodf(spinAngle - delta * ImClamp(MemoryCrossSpinSpeed, 0.f, 180.f), 360.f);
    changeFloat(controller, controller->CrossHairColor.R, MemoryRainbow, .5f + .5f * sinf(phase));
    changeFloat(controller, controller->CrossHairColor.G, MemoryRainbow, .5f + .5f * sinf(phase + 2.094395f));
    changeFloat(controller, controller->CrossHairColor.B, MemoryRainbow, .5f + .5f * sinf(phase + 4.18879f));
    changeFloat(controller, controller->CrossHairColor.A, MemoryRainbow, 1.f);
    changeInteger(controller, controller->GameReplayType, MemoryDamage, player->bIsWeaponFiring ? 2 : 1);
    if (auto* camera = player->ScopeCameraComp) {
        if (IsValidObjPtr(camera) && Tools::IsPtrValid((void*)((uintptr_t)&camera->OrthoWidth - sizeof(float)))) {
            float& fov = *(float*)((uintptr_t)&camera->OrthoWidth - sizeof(float));
            changeFloat(camera, fov, MemoryZoom && player->bIsGunADS, ImClamp(MemoryZoomFov, 20.f, 90.f));
        }
    }
    auto* manager = player->WeaponManagerComponent;
    if (!IsValidObjPtr(manager) || !IsValidObjPtr(manager->CurrentWeaponReplicated) ||
        !manager->CurrentWeaponReplicated->IsA(ASTExtraShootWeapon::StaticClass())) return;
    auto* weapon = (ASTExtraShootWeapon*)manager->CurrentWeaponReplicated;
    if (auto* entity = weapon->ShootWeaponEntityComp) {
        if (IsValidObjPtr(entity))
            changeFloat(entity, entity->WeaponAimInTime, MemoryFastScope, .01f);
    }
    if (auto* cross = weapon->CachedCrossHairComponent) {
        if (IsValidObjPtr(cross))
            changeFloat(cross, cross->RotateAngle, MemoryCrossSpin, spinAngle);
    }
}

// HMOOD__TG@i_8_f
void RenderESP(AHUD *HUD, int ScreenWidth, int ScreenHeight) {
    if (!IsValidObjPtr(HUD) || ScreenWidth <= 0 || ScreenHeight <= 0) return;

    ASTExtraPlayerCharacter *localPlayer = nullptr;
    ASTExtraPlayerController *localPlayerController = nullptr;
    screenWidth = ScreenWidth;
    screenHeight = ScreenHeight;

    glWidth = ScreenWidth;
    glHeight = ScreenHeight;
    UCanvas *Canvas = HUD->Canvas;
    if (IsValidObjPtr(Canvas) && IsLogin) {

        static bool loadFont = false;
        if (!loadFont && IsLogin) {
            LoadFont();
            if (tslFont) loadFont = true;
        }

        if (!tslFont)
            return;

        UKismetMathLibrary* UMC = (UKismetMathLibrary*)UKismetMathLibrary::StaticClass();

        auto GWorld = GetFullWorld();

        if (IsValidObjPtr(GWorld) && IsLogin) {
            UNetDriver *NetDriver = GWorld->NetDriver;
            if (IsValidObjPtr(NetDriver)) {
                UNetConnection *ServerConnection = NetDriver->ServerConnection;
                if (IsValidObjPtr(ServerConnection) && IsValidObjPtr(ServerConnection->PlayerController)) {
                    localPlayerController = (ASTExtraPlayerController *) ServerConnection->PlayerController;
                }
            }

            if (IsValidObjPtr(localPlayerController)) {
                std::vector<ASTExtraPlayerCharacter *> PlayerCharacterList;
                GetAllActors(PlayerCharacterList);

                for (auto* Actor : PlayerCharacterList) {
                    if (!IsValidObjPtr(Actor)) continue;
                    if (Actor->PlayerKey == localPlayerController->PlayerKey) {
                        localPlayer = Actor;
                        break;
                    }
                }

                if (IsValidObjPtr(localPlayer)) {
                    g_LocalPlayer = localPlayer;
                    g_PlayerController = localPlayerController;
                    g_LocalController = localPlayerController;

                    if (hideNameKillMsg) {
                        int its = 1002;
                        auto VTable = (void**)localPlayerController->VTable;
                        if (Tools::IsPtrValid(VTable) && Tools::IsPtrValid(&VTable[its]) && (VTable[its] != (void*)hk_Broadcast)) {
                            if (!orig_Broadcast) {
                                orig_Broadcast = decltype(orig_Broadcast)(VTable[its]);
                            }
                            WriteAddr(&VTable[its], (void *)&hk_Broadcast, sizeof(void*));
                        }
                    }

                    auto* camera = localPlayer->ThirdPersonCameraComponent;
                    static uintptr_t previousCamera = 0;
                    static float originalView = 90.f;
                    static bool viewApplied = false;
                    if (IsValidObjPtr(camera) && Tools::IsPtrValid((void*)((uintptr_t)&camera->OrthoWidth - sizeof(float)))) {
                        float* view = (float*)((uintptr_t)&camera->OrthoWidth - sizeof(float));
                        if (previousCamera != (uintptr_t)camera) {
                            previousCamera = (uintptr_t)camera;
                            originalView = *view;
                            viewApplied = false;
                        }
                        if (WideView) {
                            if (!viewApplied) originalView = *view;
                            *view = (float)ImClamp(WideValue, 80, 160);
                            viewApplied = true;
                        } else if (viewApplied) {
                            *view = originalView;
                            viewApplied = false;
                        }
                    }

                    if (Blacksky) {
                        g_LocalPlayer->SetWeaponShootType(ESTEWeaponShootType::ESTEWeaponShootType__Auto);
                    }

                    if (IsValidObjPtr(localPlayer->MeshContainer)) {
                        if (localPlayer->bIsGunADS) {
                            localPlayer->MeshContainer->RelativeRotation = { 0,360,0 };
                        } else {
                            if (!localPlayer->bIsWeaponFiring) {
                                localPlayer->MeshContainer->RelativeRotation = { 0,360,0 };
                            } else if (isSpinning) {
                                localPlayer->MeshContainer->RelativeRotation = { 0,DanceValue ,0 };
                                DanceValue += DancerValue + tocdoquay;
                                if (DanceValue >= 360.0f)
                                    DanceValue = fmodf(DanceValue, 360.0f);
                            }
                        }
                    }

                    if (下雨 && IsValidObjPtr(g_LocalPlayer->STPlayerController)) {
                        g_LocalPlayer->STPlayerController->SetIsRainy(true);
                    }

                    if (下雪特效 && IsValidObjPtr(g_LocalPlayer->STPlayerController)) {
                        g_LocalPlayer->STPlayerController->SetIsSnowy(true);
                    }

                    if (人物自杀 && IsLogin && IsValidObjPtr(g_LocalPlayer->STPlayerController)) {
                        g_LocalPlayer->STPlayerController->RPC_GiveUpGame();
                    }

                    if (重置游客) {
                        重置游客 = false;
                        ResetGuestAccount();
                    }
                    if (ResetGuest) {
                        ResetGuest = false;
                        ResetGuestAccount();
                    }

                    if (人物变大 && IsValidObjPtr(g_LocalPlayer->MeshContainer)) {
                        USceneComponent* MeshContainer = g_LocalPlayer->MeshContainer;
                        MeshContainer->SetWorldScale3D({巨人, 巨人, 巨人});
                    }

                    if (Settings::Aimbot::Tick && !Enable && IsValidObjPtr(UMC)) {
                        ASTExtraPlayerCharacter *Target = GetTargetByCrossDist();

                        if (IsValidObjPtr(Target) && IsValidObjPtr(Target->RootComponent)) {
                            bool triggerOk = IsAimTriggerActive(localPlayer);

                            if (triggerOk && IsValidObjPtr(localPlayerController->PlayerCameraManager)) {
                                FVector targetAimPos = ResolveAimPosition(Target, localPlayerController);
                                auto WeaponManagerComponent = localPlayer->WeaponManagerComponent;
                                if (IsValidObjPtr(WeaponManagerComponent))
                                {
                                    auto propSlot = WeaponManagerComponent->GetCurrentUsingPropSlot();
                                    if ((int)propSlot.GetValue() >= 1 && (int)propSlot.GetValue() <= 3)
                                    {
                                        auto CurrentWeaponReplicated = (ASTExtraShootWeapon *)WeaponManagerComponent->CurrentWeaponReplicated;
                                        if (IsValidObjPtr(CurrentWeaponReplicated) && CurrentWeaponReplicated->IsA(ASTExtraShootWeapon::StaticClass()))
                                        {
                                            auto ShootWeaponComponent = CurrentWeaponReplicated->ShootWeaponComponent;
                                            if (IsValidObjPtr(ShootWeaponComponent))
                                            {
                                                UShootWeaponEntity *ShootWeaponEntityComponent = ShootWeaponComponent->ShootWeaponEntityComponent;

                                                if (IsValidObjPtr(ShootWeaponEntityComponent) && ShootWeaponEntityComponent->BulletFireSpeed > 1.f && Settings::Aimbot::SilentAimSettings::Prediction) {
                                                    ASTExtraVehicleBase *CurrentVehicle = IsValidObjPtr(Target->CurrentVehicle) ? Target->CurrentVehicle : nullptr;
                                                    if (CurrentVehicle) {
                                                        FVector LinearVelocity = CurrentVehicle->ReplicatedMovement.LinearVelocity;
                                                        float dist = g_LocalPlayer->GetDistanceTo(Target);
                                                        auto timeToTravel = dist / ShootWeaponEntityComponent->BulletFireSpeed;
                                                        targetAimPos = UMC->Add_VectorVector(targetAimPos, UMC->Multiply_VectorFloat(LinearVelocity, timeToTravel));
                                                    } else {
                                                        FVector Velocity = Target->GetVelocity();
                                                        float dist = g_LocalPlayer->GetDistanceTo(Target);
                                                        auto timeToTravel = dist / ShootWeaponEntityComponent->BulletFireSpeed;
                                                        targetAimPos = UMC->Add_VectorVector(targetAimPos, UMC->Multiply_VectorFloat(Velocity, timeToTravel));
                                                    }
                                                }

                                                FVector fDir = UKismetMathLibrary::Subtract_VectorVector(
                                                    targetAimPos,
                                                    localPlayerController->PlayerCameraManager->CameraCache.POV.Location
                                                );

                                                FRotator Yaptr = UKismetMathLibrary::Conv_VectorToRotator(fDir);
                                                FRotator CpYaT = localPlayerController->PlayerCameraManager->CameraCache.POV.Rotation;

                                                Yaptr.Yaw = std::remainder(Yaptr.Yaw - CpYaT.Yaw, 360.f);
                                                Yaptr.Pitch -= CpYaT.Pitch;
                                                Yaptr.Roll = 0.f;

                                                
