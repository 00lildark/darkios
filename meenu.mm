// HMOOD__TG@i_8_f

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <sys/utsname.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <SystemConfiguration/SystemConfiguration.h>
#include <chrono>
#include <atomic>
#include <array>
#include <unordered_map>
#include <utility>
#import <Metal/Metal.h>
#include <string>
#import "Engine.h"
#import "mahoa.h"
#include "Tools.h"
#import "PubgLoad.h"
#include "imgui.h"
#include "imgui_internal.h"
#include "font_awesome_5.h"
#include "fa_solid_900.h"
#include "ini_rw.h"
#include "menu.h"
#import <sys/sysctl.h>
#import <sys/stat.h>
#include <dlfcn.h>
#include <mach-o/dyld.h>
#include <pthread.h>
#include "ESP/menu_detail_assets.h"
#include "ESP/menu_navigation_assets.h"
#include <cmath>
#include <cfloat>
#include <cstdio>
#include <vector>
#include <mach/mach.h>
#include <mach/mach_host.h>
#include <mach/vm_statistics.h>

using namespace SDK;

extern std::string SDKvaT(const std::string& __in);
extern bool hideNameKillMsg;
extern bool textBorder;
extern bool hideHacker;
extern bool Enable;
extern bool 自动开火;
extern float 追踪概率;
extern bool ifismembotenable;
extern bool MagicSDK;
extern bool IsFastSwitch;
extern bool IsFastDrop;
extern bool chaynhanhv2;
extern bool IsNocamerashake;
extern bool IsNorecoil2;
extern bool IsFastshoot;
extern bool IsCrossHair;
extern bool isSpinning;
extern bool WideView;
extern bool MemoryFastScope, MemoryZoom, MemoryDamage, MemoryRainbow, MemoryCrossSpin;
extern float MemoryZoomFov;
extern float MemoryRainbowSpeed, MemoryCrossSpinSpeed;
extern bool HitX;
extern int WideValue;
extern float tocdoquay;
extern float crosshairSizeSlider;

extern float ESPMaxDistance;
extern float globalHpAlphaF;
extern int IsStyle;
extern float AlertRadius;
extern float strokeIntensity;
extern float SilentAimMaxDistance;
extern float Cross;
extern float AimSmooth;
extern float magicX;
extern float magicY;
extern float magicZ;

extern ImU32 COLOR_Distance;
extern ImColor bgColor;
extern INI* config;
extern ASTExtraPlayerController* localPlayerController;

namespace Settings {
    extern int Tab;
    extern bool isVisibilityCheck;
    namespace SettingsTab {
        extern bool BypassMode;
    }
    namespace Aimbot {
        extern bool Tick;
        extern int AimMethod;
        extern std::atomic<int> TriggerMode;
        extern bool MemoryAimbot;
        extern bool SilentAim;
        namespace SilentAimSettings {
            extern bool AimKnocked;
            extern bool Highprecisiontracking;
            extern int Aimpositon;
            extern bool Prediction;
            extern bool EnableFov;
            extern bool BypassFOVLimit;
            extern bool AimingLine;
            extern float MaxStepDeg;
            extern int LegitTrackSwitchrate;
        }
    }
}

namespace imgui {
    extern bool ESP;
    extern bool Boxes;
    extern bool HideBot;
    extern bool Health;
    extern bool Line;
    extern bool Name;
    extern bool TeamID;
    extern bool Distance;
    extern bool EnemyCount;
    extern bool Weapon;
    extern bool Bone;
    extern bool GameInfo;
    extern bool Alert360;
    extern bool EnemyAiming;
    extern bool Items;
    extern bool Lootbox;
    extern bool Vehicle;
}

extern void ResetGuestAccount();
extern "C" void OpenNewMenu(void);
extern "C" void RenderNewMenuOverlay(void);

extern ImFont* mainFont;
ImFont* mainFont = nullptr;

bool MenDeal = false;
ImFont* cyberMenuFont = nullptr;

bool IsLogin = false;
bool hideNameKillMsg = false;
bool textBorder = false;
bool hideHacker = false;
bool Enable = false;
bool 自动开火 = false;
float 追踪概率 = 0.f;
bool ifismembotenable = false;
bool MagicSDK = false;
bool IsFastSwitch = false;
bool IsFastDrop = false;
bool chaynhanhv2 = false;
bool IsNocamerashake = false;
bool IsNorecoil2 = false;
bool IsFastshoot = false;
bool IsCrossHair = false;
bool isSpinning = false;
bool WideView = false;
bool MemoryFastScope = false;
bool MemoryZoom = false;
bool MemoryDamage = false;
bool MemoryRainbow = false;
bool MemoryCrossSpin = false;
float MemoryZoomFov = 60.f;
float MemoryRainbowSpeed = 1.f;
float MemoryCrossSpinSpeed = 0.f;
bool HitX = false;
int WideValue = 110;
float tocdoquay = 0.f;
float crosshairSizeSlider = 5.f;

float ESPMaxDistance = 300.f;
float globalHpAlphaF = 1.f;
int IsStyle = 0;
float AlertRadius = 50.f;
float strokeIntensity = 1.f;
float SilentAimMaxDistance = 250.f;
float Cross = 100.f;
float AimSmooth = 5.f;
float magicX = 0.f;
float magicY = 0.f;
float magicZ = 0.f;

float AimF = 0.f;
bool Blacksky = false;
bool CL = false;
bool CarFly = false;
bool Config = false;
float DanceValue = 0.f;
float DancerValue = 0.f;
bool FixShoot = false;
float Gun_Size = 0.f;
bool IsHitXPL = false;
bool IsLaunch = false;
bool Radar = false;
float RadarX = 0.f;
float RadarY = 0.f;
bool ReCo = false;
bool ResetGuest = false;
bool ShowFov = false;
bool VisCheck = false;
void* g_LocalController = nullptr;
float g_disstance = 0.f;
bool initialized = false;
int screenWidth = 0;
int screenHeight = 0;
float carx = 0.f, cary = 0.f, carz = 0.f;
bool tudongnhay = false;
bool 下雨 = false;
bool 下雪特效 = false;
bool 人物变大 = false;
bool 人物自杀 = false;
bool 坐标追 = false;
bool 巨人 = false;
bool 打击圈 = false;
bool 据点 = false;
bool 枪械变大 = false;
bool 瞄准线 = false;
bool 重置游客 = false;

ImU32 COLOR_Distance = IM_COL32(255, 255, 255, 255);
ImColor bgColor = ImColor(1.f, 1.f, 1.f, 1.f);

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
}

namespace Settings {
    bool isVisibilityCheck = true;
    namespace SettingsTab {
        bool BypassMode = false;
    }
    namespace Aimbot {
        bool Tick = false;
        int AimMethod = 0;
        std::atomic<int> TriggerMode{0};
        bool MemoryAimbot = false;
        bool SilentAim = false;
        namespace SilentAimSettings {
            bool AimKnocked = false;
            bool Highprecisiontracking = false;
            int Aimpositon = 0;
            bool Prediction = false;
            bool EnableFov = false;
            bool BypassFOVLimit = false;
            bool AimingLine = false;
            float MaxStepDeg = 2.f;
            int LegitTrackSwitchrate = 0;
        }
    }
}

static NSString *const kDarkIOSVerifyEndpoint = @"https://darkios.onrender.com/index.php?verify=1";
static bool g_DarkIOSServerVerified = false;
static bool g_DarkIOSNewMenuOpen = false;

static bool IsValidDarkIOSKeyFormat(NSString* key) {
    if (![key isKindOfClass:[NSString class]] || key.length < 10) return NO;
    if (![key hasPrefix:@"DARKIOS-"]) return NO;
    NSArray<NSString*>* parts = [key componentsSeparatedByString:@"-"];
    return parts.count >= 3 && parts[1].length > 0 && parts[2].length >= 4;
}

static bool IsESPKeyVerifiedMenu() {
    if (g_DarkIOSServerVerified || IsLogin) return true;
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    return [defs boolForKey:@"ESP_Key_Verified_v1"] || [defs boolForKey:@"DARKIOS_Key_Verified_v1"];
}

static NSString *DarkIOS_MachineID(void) {
    struct utsname sysInfo;
    uname(&sysInfo);
    return [NSString stringWithCString:sysInfo.machine encoding:NSUTF8StringEncoding] ?: @"Unknown";
}

static NSString *DarkIOS_ModelName(NSString *machine) {
    NSDictionary *map = @{
        @"iPhone17,1": @"iPhone 16 Pro",
        @"iPhone17,2": @"iPhone 16 Pro Max",
        @"iPhone17,3": @"iPhone 16",
        @"iPhone17,4": @"iPhone 16 Plus",
        @"iPhone16,1": @"iPhone 15 Pro",
        @"iPhone16,2": @"iPhone 15 Pro Max",
        @"iPhone15,4": @"iPhone 15",
        @"iPhone15,5": @"iPhone 15 Plus",
        @"iPhone15,2": @"iPhone 14 Pro",
        @"iPhone15,3": @"iPhone 14 Pro Max",
        @"iPhone14,2": @"iPhone 13 Pro",
        @"iPhone14,3": @"iPhone 13 Pro Max",
        @"iPhone14,5": @"iPhone 13"
    };
    return map[machine] ?: machine;
}

static NSString *DarkIOS_LocalIP(void) {
    NSString *address = @"Unknown";
    struct ifaddrs *interfaces = NULL;
    if (getifaddrs(&interfaces) == 0) {
        for (struct ifaddrs *addr = interfaces; addr != NULL; addr = addr->ifa_next) {
            if (addr->ifa_addr && addr->ifa_addr->sa_family == AF_INET) {
                NSString *name = [NSString stringWithUTF8String:addr->ifa_name];
                if ([name isEqualToString:@"en0"] || [name isEqualToString:@"pdp_ip0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)addr->ifa_addr)->sin_addr)];
                    break;
                }
            }
        }
        freeifaddrs(interfaces);
    }
    return address;
}

static NSString *DarkIOS_NetworkType(void) {
    SCNetworkReachabilityRef reach = SCNetworkReachabilityCreateWithName(NULL, "8.8.8.8");
    SCNetworkReachabilityFlags flags = 0;
    BOOL ok = reach && SCNetworkReachabilityGetFlags(reach, &flags);
    if (reach) CFRelease(reach);
    if (!ok || !(flags & kSCNetworkReachabilityFlagsReachable)) return @"Offline";
    if (flags & kSCNetworkReachabilityFlagsIsWWAN) return @"Cellular (4G/5G)";
    return @"Wi-Fi";
}

static NSDictionary *DarkIOS_CollectRealTelemetry(NSString *key) {
    UIDevice *dev = [UIDevice currentDevice];
    dev.batteryMonitoringEnabled = YES;

    float bat = dev.batteryLevel;
    NSString *batStr = (bat >= 0.f) ? [NSString stringWithFormat:@"%.0f%%", bat * 100.f] : @"Unknown";

    NSString *batState = @"Unknown";
    if (dev.batteryState == UIDeviceBatteryStateUnplugged) batState = @"Unplugged";
    else if (dev.batteryState == UIDeviceBatteryStateCharging) batState = @"Charging";
    else if (dev.batteryState == UIDeviceBatteryStateFull) batState = @"Full";

    NSString *machine = DarkIOS_MachineID();
    NSString *model = DarkIOS_ModelName(machine);
    NSString *hwid = dev.identifierForVendor.UUIDString ?: @"Unknown";

    NSProcessInfo *proc = [NSProcessInfo processInfo];
    double totalRamGB = (double)proc.physicalMemory / (1024.0 * 1024.0 * 1024.0);

    NSDictionary *fs = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    double freeDiskGB = [fs[NSFileSystemFreeSize] doubleValue] / (1024.0 * 1024.0 * 1024.0);
    double totalDiskGB = [fs[NSFileSystemSize] doubleValue] / (1024.0 * 1024.0 * 1024.0);

    UIScreen *scr = [UIScreen mainScreen];
    CGRect bounds = scr.nativeBounds;
    NSString *jb = [[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"] ||
                   [[NSFileManager defaultManager] fileExistsAtPath:@"/var/jb"] ? @"Jailbroken" : @"Non-Jailbroken";
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];

    return @{
        @"key": key ?: @"",
        @"hwid": hwid,
        @"deviceModel": model,
        @"deviceName": dev.name ?: @"iPhone",
        @"machineId": machine,
        @"iosVersion": [NSString stringWithFormat:@"iOS %@", dev.systemVersion ?: @""],
        @"systemName": dev.systemName ?: @"iOS",
        @"battery": batStr,
        @"batteryState": batState,
        @"lowPowerMode": proc.isLowPowerModeEnabled ? @"ON" : @"OFF",
        @"network": DarkIOS_NetworkType(),
        @"localIp": DarkIOS_LocalIP(),
        @"architecture": @"arm64e",
        @"cpuCores": [NSString stringWithFormat:@"%lu", (unsigned long)proc.processorCount],
        @"ramTotal": [NSString stringWithFormat:@"%.1f GB", totalRamGB],
        @"ramUsed": @"Active",
        @"storageTotal": [NSString stringWithFormat:@"%.1f GB", totalDiskGB],
        @"storageFree": [NSString stringWithFormat:@"%.1f GB", freeDiskGB],
        @"screenRes": [NSString stringWithFormat:@"%.0fx%.0f", bounds.size.width, bounds.size.height],
        @"refreshRate": [NSString stringWithFormat:@"%ld Hz", (long)scr.maximumFramesPerSecond],
        @"brightness": [NSString stringWithFormat:@"%.0f%%", scr.brightness * 100.f],
        @"timezone": [NSTimeZone localTimeZone].name ?: @"Unknown",
        @"locale": [NSLocale currentLocale].localeIdentifier ?: @"Unknown",
        @"uptime": [NSString stringWithFormat:@"%.1f hours", proc.systemUptime / 3600.0],
        @"bundleId": [[NSBundle mainBundle] bundleIdentifier] ?: @"Unknown",
        @"appVersion": info[@"CFBundleShortVersionString"] ?: @"Unknown",
        @"jailbreakStatus": jb
    };
}

extern "C" void DarkIOS_VerifyKeyOnline(const char *cKey, void (^completion)(bool ok, const char *message)) {
    NSString *key = cKey ? [[NSString stringWithUTF8String:cKey] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] : @"";
    if (key.length == 0) {
        if (completion) completion(false, "Key daxil edin");
        return;
    }

    NSURL *url = [NSURL URLWithString:kDarkIOSVerifyEndpoint];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:20.0];
    req.HTTPMethod = @"POST";
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSDictionary *payload = DarkIOS_CollectRealTelemetry(key);
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];

    [[[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *resp, NSError *err) {
        NSInteger statusCode = [(NSHTTPURLResponse *)resp statusCode];
        bool ok = false;
        NSString *msg = @"Server cavab vermədi";

        if (err) {
            msg = err.localizedDescription ?: @"Şəbəkə xətası";
        } else if (data.length > 0) {
            NSString *raw = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
            NSRange brace = [raw rangeOfString:@"{"];
            if (brace.location != NSNotFound) {
                NSData *slice = [[raw substringFromIndex:brace.location] dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:slice options:0 error:nil];
                if ([obj isKindOfClass:[NSDictionary class]]) {
                    ok = [obj[@"valid"] boolValue] || [obj[@"status"] isEqualToString:@"ok"];
                    if ([obj[@"message"] isKindOfClass:[NSString class]]) {
                        msg = obj[@"message"];
                    } else {
                        msg = ok ? @"Verified" : @"Key etibarsızdır";
                    }
                }
            } else if (statusCode >= 200 && statusCode < 300 && [raw.lowercaseString containsString:@"valid"]) {
                ok = true;
                msg = @"Verified";
            } else {
                // HTML və ya qeyri-JSON cavab gələndə parse xətası əvəzinə səbəbi göstər
                msg = [NSString stringWithFormat:@"Server HTTP %ld (JSON deyil)", (long)statusCode];
            }
        }

        if (ok) {
            g_DarkIOSServerVerified = true;
            IsLogin = true;
            MenDeal = false;
            NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
            [defs setBool:YES forKey:@"DARKIOS_Key_Verified_v1"];
            [defs setBool:YES forKey:@"ESP_Key_Verified_v1"];
            [defs setObject:key forKey:@"DARKIOS_Saved_Key_v1"];
            [defs synchronize];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) completion(ok, msg.UTF8String);
        });
    }] resume];
}

UIImage* GetMenuBadgeImage() {
    static UIImage* badge = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSData* data = [[NSData alloc] initWithBase64EncodedString:
            [NSString stringWithUTF8String:kCyberDetailedBrand] options:0];
        UIImage* source = data ? [UIImage imageWithData:data] : nil;
        if (!source.CGImage) return;
        CGImageRef crop = CGImageCreateWithImageInRect(source.CGImage, CGRectMake(44, 134, 448, 448));
        if (!crop) return;
        UIImage* circle = [UIImage imageWithCGImage:crop];
        UIGraphicsImageRendererFormat* format = [UIGraphicsImageRendererFormat defaultFormat];
        format.scale = 1.f;
        format.opaque = NO;
        UIGraphicsImageRenderer* renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(448, 448) format:format];
        badge = [renderer imageWithActions:^(UIGraphicsImageRendererContext* context) {
            (void)context;
            [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 448, 448)] addClip];
            [circle drawInRect:CGRectMake(0, 0, 448, 448)];
        }];
        CGImageRelease(crop);
    });
    return badge;
}

typedef int (*ptrace_ptr_t)(int, pid_t, caddr_t, int);
#define PT_DENY_ATTACH 31
static void pg_deny_debugger(void) {
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t pt = (ptrace_ptr_t)dlsym(handle, "ptrace");
    if (pt)
        pt(PT_DENY_ATTACH, 0, 0, 0);
}

@interface PauseGuard : NSObject
+ (void)installInWindow:(UIWindow*)window;
@end

@implementation PauseGuard
+ (void)installInWindow:(UIWindow*)window {
    (void)window;
    pg_deny_debugger();
}
@end

namespace ImGui {
    inline void MergeIconsWithLatestFont(float font_size, bool FontDataOwnedByAtlas = false) {
        static const ImWchar icons_ranges[] = {ICON_MIN_FA, ICON_MAX_FA, 0};
        ImFontConfig icons_config;
        icons_config.MergeMode = true;
        icons_config.PixelSnapH = true;
        icons_config.FontDataOwnedByAtlas = FontDataOwnedByAtlas;
        GetIO().Fonts->AddFontFromMemoryTTF((void*)fa_solid_900, sizeof(fa_solid_900), font_size,
                                            &icons_config, icons_ranges);
    }
}

static int CyberMenuFontFace(NSString* path, NSString* postScriptName) {
    NSData* data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nullptr];
    const unsigned char* bytes = (const unsigned char*)data.bytes;
    const size_t length = data.length;
    if (!bytes || length < 12)
        return -1;
    auto u16 = [&](size_t p) -> uint16_t {
        return p <= length - 2 ? (uint16_t)((bytes[p] << 8) | bytes[p + 1]) : 0;
    };
    auto u32 = [&](size_t p) -> uint32_t {
        return p <= length - 4 ? ((uint32_t)bytes[p] << 24) | ((uint32_t)bytes[p + 1] << 16) |
                                     ((uint32_t)bytes[p + 2] << 8) | bytes[p + 3]
                               : 0;
    };
    const bool collection = u32(0) == 0x74746366;
    const uint32_t faces = collection ? u32(8) : 1;
    if (faces > 128 || (collection && 12 + (size_t)faces * 4 > length))
        return -1;
    for (uint32_t face = 0; face < faces; ++face) {
        const size_t offset = collection ? u32(12 + face * 4) : 0;
        if (offset > length - 12)
            continue;
        const uint16_t tables = u16(offset + 4);
        if (offset + 12 + (size_t)tables * 16 > length)
            continue;
        for (uint16_t t = 0; t < tables; ++t) {
            const size_t record = offset + 12 + (size_t)t * 16;
            if (u32(record) != 0x6e616d65)
                continue;
            const size_t name = u32(record + 8), tableLength = u32(record + 12);
            if (name > length || tableLength > length - name || tableLength < 6)
                continue;
            const uint16_t count = u16(name + 2), strings = u16(name + 4);
            if (6 + (size_t)count * 12 > tableLength)
                continue;
            for (uint16_t n = 0; n < count; ++n) {
                const size_t entry = name + 6 + (size_t)n * 12;
                if (u16(entry + 6) != 6)
                    continue;
                const size_t start = (size_t)strings + u16(entry + 10), size = u16(entry + 8);
                if (start > tableLength || size > tableLength - start)
                    continue;
                const uint16_t platform = u16(entry);
                NSStringEncoding encoding = (platform == 0 || platform == 3) ? NSUTF16BigEndianStringEncoding
                                                                             : NSMacOSRomanStringEncoding;
                NSString* value = [[NSString alloc] initWithBytes:bytes + name + start
                                                           length:size
                                                         encoding:encoding];
                if ([value isEqualToString:postScriptName])
                    return (int)face;
            }
        }
    }
    return -1;
}

void InitializeMenuFonts(ImGuiIO& io) {
    ImFontConfig font_cfg;

    NSString* FontPath = @"/System/Library/Fonts/Core/AvenirNext.ttc";
    io.ConfigWindowsMoveFromTitleBarOnly = true;

    constexpr float menuFontBakeSize = 48.f;
    font_cfg.OversampleH = 2;
    font_cfg.OversampleV = 2;
    mainFont = io.Fonts->AddFontFromFileTTF(FontPath.UTF8String, menuFontBakeSize, &font_cfg,
                                            io.Fonts->GetGlyphRangesVietnamese());
    if (mainFont)
        mainFont->Scale = 13.f / menuFontBakeSize;

    ImGui::MergeIconsWithLatestFont(12.f * menuFontBakeSize / 13.f, false);

    NSString* homePath = nil;
    int homeFace = -1;
    NSArray<NSString*>* homeCandidates = @[
        @"/System/Library/Fonts/Core/Helvetica.ttc", @"/System/Library/Fonts/CoreUI/Helvetica.ttc",
        @"/System/Library/Fonts/Helvetica.ttc", @"/System/Library/Fonts/Cache/Helvetica.ttc"
    ];
    for (NSString* candidate in homeCandidates) {
        const int face = CyberMenuFontFace(candidate, @"Helvetica-Bold");
        if (face >= 0) {
            homePath = candidate;
            homeFace = face;
            break;
        }
    }
    if (homeFace < 0) {
        NSString* directory = @"/System/Library/Fonts";
        NSDirectoryEnumerator* entries = [[NSFileManager defaultManager] enumeratorAtPath:directory];
        for (NSString* relative in entries) {
            NSString* extension = relative.pathExtension.lowercaseString;
            if (![extension isEqualToString:@"ttc"] && ![extension isEqualToString:@"ttf"] &&
                ![extension isEqualToString:@"otf"])
                continue;
            NSString* candidate = [directory stringByAppendingPathComponent:relative];
            const int face = CyberMenuFontFace(candidate, @"Helvetica-Bold");
            if (face >= 0) {
                homePath = candidate;
                homeFace = face;
                break;
            }
        }
    }
    cyberMenuFont = mainFont;
    if (homePath && homeFace >= 0) {
        ImFontConfig home_cfg;
        home_cfg.FontNo = homeFace;
        home_cfg.OversampleH = 2;
        home_cfg.OversampleV = 2;
        ImFont* selected = io.Fonts->AddFontFromFileTTF(homePath.UTF8String, menuFontBakeSize, &home_cfg,
                                                        io.Fonts->GetGlyphRangesVietnamese());
        if (selected) {
            selected->Scale = 13.f / menuFontBakeSize;
            cyberMenuFont = selected;
            ImGui::MergeIconsWithLatestFont(12.f * menuFontBakeSize / 13.f, false);
        }
    }
}

void ApplyImGuiStyle() {
    ImGuiStyle& s = ImGui::GetStyle();
    s.WindowPadding = {0, 0};
    s.WindowRounding = 12.f;
    s.WindowBorderSize = 0.f;
    s.ChildRounding = 8.f;
    s.ChildBorderSize = 0.f;
    s.FramePadding = {8, 5};
    s.FrameRounding = 3.f;
    s.FrameBorderSize = 0.f;
    s.ItemSpacing = {8, 7};
    s.ScrollbarSize = 4.f;
    s.ScrollbarRounding = 4.f;
    s.GrabMinSize = 6.f;
    s.GrabRounding = 3.f;
    s.PopupRounding = 4.f;
    s.TabRounding = 6.f;
    s.WindowTitleAlign = {0.5f, 0.5f};
    s.ButtonTextAlign = {0.5f, 0.5f};

    auto* c = s.Colors;
    c[ImGuiCol_Text] = {1.f, 1.f, 1.f, 1.f};
    c[ImGuiCol_TextDisabled] = {0.557f, 0.557f, 0.620f, 1.f};
    c[ImGuiCol_WindowBg] = {0.031f, 0.035f, 0.055f, 0.f};
    c[ImGuiCol_ChildBg] = {0.051f, 0.059f, 0.086f, 1.f};
    c[ImGuiCol_PopupBg] = {0.043f, 0.047f, 0.071f, 0.98f};
    c[ImGuiCol_Border] = {0.f, 0.f, 0.f, 0.f};
    c[ImGuiCol_BorderShadow] = {0.f, 0.f, 0.f, 0.f};
    c[ImGuiCol_FrameBg] = {0.075f, 0.082f, 0.122f, 1.f};
    c[ImGuiCol_FrameBgHovered] = {0.098f, 0.106f, 0.157f, 1.f};
    c[ImGuiCol_FrameBgActive] = {0.118f, 0.129f, 0.192f, 1.f};
    c[ImGuiCol_TitleBg] = {0.031f, 0.035f, 0.055f, 1.f};
    c[ImGuiCol_TitleBgActive] = {0.031f, 0.035f, 0.055f, 1.f};
    c[ImGuiCol_TitleBgCollapsed] = {0.031f, 0.035f, 0.055f, 1.f};
    c[ImGuiCol_ScrollbarBg] = {0.f, 0.f, 0.f, 0.f};
    c[ImGuiCol_ScrollbarGrab] = {0.110f, 0.118f, 0.180f, 1.f};
    c[ImGuiCol_ScrollbarGrabHovered] = {0.820f, 0.071f, 0.188f, 0.5f};
    c[ImGuiCol_ScrollbarGrabActive] = {0.820f, 0.071f, 0.188f, 1.f};
    c[ImGuiCol_CheckMark] = {0.820f, 0.071f, 0.188f, 1.f};
    c[ImGuiCol_SliderGrab] = {0.820f, 0.071f, 0.188f, 1.f};
    c[ImGuiCol_SliderGrabActive] = {1.f, 0.380f, 0.490f, 1.f};
    c[ImGuiCol_Button] = {0.075f, 0.082f, 0.122f, 1.f};
    c[ImGuiCol_ButtonHovered] = {0.820f, 0.071f, 0.188f, 0.18f};
    c[ImGuiCol_ButtonActive] = {0.820f, 0.071f, 0.188f, 0.35f};
    c[ImGuiCol_Header] = {0.820f, 0.071f, 0.188f, 0.15f};
    c[ImGuiCol_HeaderHovered] = {0.820f, 0.071f, 0.188f, 0.25f};
    c[ImGuiCol_HeaderActive] = {0.820f, 0.071f, 0.188f, 0.40f};
    c[ImGuiCol_Separator] = {0.110f, 0.118f, 0.180f, 1.f};
    c[ImGuiCol_SeparatorHovered] = {0.820f, 0.071f, 0.188f, 0.5f};
    c[ImGuiCol_SeparatorActive] = {0.820f, 0.071f, 0.188f, 1.f};
    c[ImGuiCol_Tab] = {0.051f, 0.059f, 0.086f, 1.f};
    c[ImGuiCol_TabHovered] = {0.820f, 0.071f, 0.188f, 0.20f};
    c[ImGuiCol_TabActive] = {0.820f, 0.071f, 0.188f, 0.30f};
    c[ImGuiCol_TableHeaderBg] = {0.031f, 0.035f, 0.055f, 1.f};
    c[ImGuiCol_TableBorderStrong] = {0.110f, 0.118f, 0.180f, 1.f};
    c[ImGuiCol_TableBorderLight] = {0.075f, 0.082f, 0.122f, 1.f};
    c[ImGuiCol_TableRowBg] = {0.f, 0.f, 0.f, 0.f};
    c[ImGuiCol_TableRowBgAlt] = {1.f, 1.f, 1.f, 0.025f};
}

namespace MenuLocale {
    static int language = 0;
    static const char* languageNames[] = {"English", "کوردی (سۆرانی)", "简体中文", "Русский", "العربية", "हिन्दी", "Türkçe"};
    static bool rtl() { return language == 1 || language == 4; }
    static std::string key(const char* value) {
        std::string result = value ? value : "";
        for (char& c : result)
            if (c >= 'A' && c <= 'Z') c += 'a' - 'A';
        return result;
    }

    static const char* tr(const char* value) {
        if (!value) return "";
        if (language == 0) return value;
        static const std::unordered_map<std::string, std::array<const char*, 6>> phrases = {
            {"home", {{"سەرەکی", "主页", "ГЛАВНАЯ", "الرئيسية", "मुख्य पृष्ठ", "ANA SAYFA"}}},
            {"esp radar", {{"ڕاداری بینین", "透视雷达", "ESP РАДАР", "رادار العرض", "ईएसपी रडार", "ESP RADARI"}}},
            {"aimbot", {{"ئامانجگیری", "辅助瞄准", "Автоприцел", "التصويب التلقائي", "स्वचालित निशाना", "Otomatik nişan"}}},
            {"memory", {{"بیرگە", "内存", "Память", "الذاكرة", "मेमोरी", "Bellek"}}},
            {"settings", {{"ڕێکخستنەکان", "设置", "Настройки", "الإعدادات", "सेटिंग्स", "Ayarlar"}}},
            {"enabled", {{"چالاک کرا", "已启用", "Включено", "تم التفعيل", "चालू", "Etkin"}}},
            {"disabled", {{"ناچالاک کرا", "已关闭", "Выключено", "تم الإيقاف", "बंद", "Devre dışı"}}},
            {"close menu", {{"داخستنی لیستە", "关闭菜单", "Закрыть меню", "إغلاق القائمة", "मेन्यू बंद करें", "Menüyü kapat"}}},
            {"language", {{"زمان", "语言", "Язык", "اللغة", "भाषा", "Dil"}}},
            {"reset guest", {{"ڕیسێتی میوان", "重置游客", "Сбросить гостя", "إعادة ضبط الضيف", "अतिथि रीसेट", "Misafiri sıfırla"}}},
        };
        const auto found = phrases.find(key(value));
        return found == phrases.end() ? value : found->second[language - 1];
    }
    static bool native(const char* value) {
        if (language != 0) return true;
        for (const unsigned char* p = (const unsigned char*)value; p && *p; ++p)
            if (*p >= 0x80) return true;
        return false;
    }
    struct TextImage {
        __strong id<MTLTexture> texture = nil;
        ImVec2 content{0, 0};
        float padding = 3.f;
    };
    static std::unordered_map<std::string, TextImage>& textCache() {
        static std::unordered_map<std::string, TextImage> cache;
        return cache;
    }
    static void beginFrame() {
        static int previousLanguage = -1;
        if (previousLanguage != language || textCache().size() > 1024) {
            textCache().clear();
            previousLanguage = language;
        }
    }
    static const TextImage& image(const char* value, float fontSize, float wrap = 0.f) {
        const int points = ImMax(12, (int)ceilf(fontSize * 2.f));
        const int wrapPoints = wrap > 0.f ? (int)ceilf(wrap) : 0;
        const std::string cacheKey = std::to_string(language) + ":" + std::to_string(points) + ":" +
                                     std::to_string(wrapPoints) + ":" + (value ? value : "");
        auto& cache = textCache();
        const auto found = cache.find(cacheKey);
        if (found != cache.end()) return found->second;
        TextImage result;
        @autoreleasepool {
            NSString* string = [NSString stringWithUTF8String:value ? value : ""];
            UIFont* font = [UIFont fontWithName:@"Helvetica-Bold" size:points * .5f];
            if (!font) font = [UIFont boldSystemFontOfSize:points * .5f];
            NSMutableParagraphStyle* paragraph = [NSMutableParagraphStyle new];
            paragraph.baseWritingDirection = rtl() ? NSWritingDirectionRightToLeft : NSWritingDirectionNatural;
            paragraph.alignment = NSTextAlignmentNatural;
            paragraph.lineBreakMode = NSLineBreakByWordWrapping;
            NSAttributedString* text = [[NSAttributedString alloc] initWithString:string ?: @""
                attributes:@{NSFontAttributeName: font, NSForegroundColorAttributeName: UIColor.whiteColor,
                             NSParagraphStyleAttributeName: paragraph}];
            const NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
            CGRect bounds = [text boundingRectWithSize:CGSizeMake(wrapPoints > 0 ? wrapPoints : 4096.f, CGFLOAT_MAX)
                                               options:options context:nil];
            result.content = ImVec2(fmaxf(1.f, ceilf(bounds.size.width)), fmaxf(1.f, ceilf(bounds.size.height)));
            CGSize size = CGSizeMake(result.content.x + result.padding * 2.f, result.content.y + result.padding * 2.f);
            UIGraphicsImageRendererFormat* format = [UIGraphicsImageRendererFormat defaultFormat];
            format.scale = 2.f;
            format.opaque = NO;
            UIGraphicsImageRenderer* renderer = [[UIGraphicsImageRenderer alloc] initWithSize:size format:format];
            const float padding = result.padding;
            const CGFloat contentWidth = result.content.x, contentHeight = result.content.y;
            UIImage* bitmap = [renderer imageWithActions:^(UIGraphicsImageRendererContext* context) {
                (void)context;
                [text drawWithRect:CGRectMake(padding - bounds.origin.x, padding - bounds.origin.y,
                                             contentWidth, contentHeight)
                           options:options context:nil];
            }];
            CGImageRef source = bitmap.CGImage;
            static id<MTLDevice> device = MTLCreateSystemDefaultDevice();
            if (source && device) {
                const size_t width = CGImageGetWidth(source), height = CGImageGetHeight(source);
                std::vector<uint8_t> rgba(width * height * 4);
                CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
                CGContextRef context = space ? CGBitmapContextCreate(rgba.data(), width, height, 8, width * 4,
                    space, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big) : nullptr;
                if (context) {
                    CGContextDrawImage(context, CGRectMake(0, 0, width, height), source);
                    CGContextFlush(context);
                    for (size_t i = 0; i < width * height; ++i)
                        rgba[i * 4] = rgba[i * 4 + 1] = rgba[i * 4 + 2] = 255;
                    MTLTextureDescriptor* descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                        width:width height:height mipmapped:NO];
                    descriptor.usage = MTLTextureUsageShaderRead;
                    descriptor.storageMode = MTLStorageModeShared;
                    result.texture = [device newTextureWithDescriptor:descriptor];
                    [result.texture replaceRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0
                                         withBytes:rgba.data() bytesPerRow:width * 4];
                    CGContextRelease(context);
                }
                if (space) CGColorSpaceRelease(space);
            }
        }
        return cache.emplace(cacheKey, std::move(result)).first->second;
    }
    static ImVec2 measure(const char* value, float fontSize, float wrap = 0.f) {
        const char* label = tr(value);
        if (!native(label)) return ImGui::GetFont()->CalcTextSizeA(fontSize, FLT_MAX, wrap, label);
        return image(label, fontSize, wrap).content;
    }
    static void draw(ImDrawList* list, const char* value, ImVec2 position, float fontSize, ImU32 color,
                      float maxWidth = 0.f, bool rightAlign = false, float wrap = 0.f) {
        const char* label = tr(value);
        if (!native(label)) {
            const float width = measure(label, fontSize).x;
            if (maxWidth > 0.f && width > maxWidth) fontSize *= maxWidth / width;
            list->AddText(ImGui::GetFont(), fontSize, position, color, label);
            return;
        }
        const TextImage& text = image(label, fontSize, wrap);
        if (!text.texture) return;
        const float factor = maxWidth > 0.f && text.content.x > maxWidth ? maxWidth / text.content.x : 1.f;
        if (rightAlign && maxWidth > 0.f) position.x += maxWidth - text.content.x * factor;
        const float padding = text.padding * factor;
        list->AddImage((__bridge ImTextureID)text.texture,
            ImVec2(position.x - padding, position.y - padding),
            ImVec2(position.x + text.content.x * factor + padding, position.y + text.content.y * factor + padding),
            ImVec2(0, 0), ImVec2(1, 1), color);
    }
    static void text(const char* value, float wrap = 0.f) {
        const char* label = tr(value);
        if (!native(label)) { ImGui::TextUnformatted(label); return; }
        const float fs = ImGui::GetFontSize();
        const ImVec2 size = measure(value, fs, wrap), position = ImGui::GetCursorScreenPos();
        ImGui::Dummy(size);
        draw(ImGui::GetWindowDrawList(), value, position, fs, ImGui::GetColorU32(ImGuiCol_Text), wrap,
             rtl(), wrap);
    }
    static void tooltip(const char* value) {
        if (!native(tr(value))) { ImGui::SetTooltip("%s", tr(value)); return; }
        ImGui::BeginTooltip();
        text(value, ImMin(360.f, ImGui::GetIO().DisplaySize.x * .75f));
        ImGui::EndTooltip();
    }
    static bool selectable(const char* value, bool selected) {
        const char* label = tr(value);
        if (!native(label)) return ImGui::Selectable(label, selected);
        const ImVec2 position = ImGui::GetCursorScreenPos();
        const float fs = ImGui::GetFontSize(), height = ImGui::GetFrameHeight() * 1.2f;
        const float width = ImMax(190.f, measure(value, fs).x + 20.f);
        const std::string id = "##locale_select_" + std::string(value);
        const bool pressed = ImGui::Selectable(id.c_str(), selected, 0, ImVec2(width, height));
        draw(ImGui::GetWindowDrawList(), value, ImVec2(position.x + 5.f, position.y + (height - measure(value, fs).y) * .5f),
             fs, ImGui::GetColorU32(ImGuiCol_Text), width - 10.f, rtl());
        return pressed;
    }
    static void widgetLabel(const char* value) {
        const float width = ImGui::GetFontSize() * 12.f;
        const ImVec2 position = ImGui::GetCursorScreenPos();
        ImGui::Dummy(ImVec2(width, ImGui::GetFrameHeight()));
        draw(ImGui::GetWindowDrawList(), value, ImVec2(position.x, position.y + ImGui::GetStyle().FramePadding.y),
             ImGui::GetFontSize(), ImGui::GetColorU32(ImGuiCol_Text), width, rtl());
    }
    static bool checkbox(const char* value, bool* state) {
        if (!native(tr(value))) return ImGui::Checkbox(value, state);
        ImGui::PushID(value);
        ImGui::BeginGroup();
        bool changed = ImGui::Checkbox("##check", state);
        ImGui::SameLine();
        const float width = ImMax(160.f, measure(value, ImGui::GetFontSize()).x);
        const ImVec2 position = ImGui::GetCursorScreenPos();
        if (ImGui::InvisibleButton("##label", ImVec2(width, ImGui::GetFrameHeight()))) {
            *state = !*state;
            changed = true;
        }
        draw(ImGui::GetWindowDrawList(), value, ImVec2(position.x, position.y + ImGui::GetStyle().FramePadding.y),
             ImGui::GetFontSize(), ImGui::GetColorU32(ImGuiCol_Text), width, rtl());
        ImGui::EndGroup();
        ImGui::PopID();
        return changed;
    }
    static bool sliderFloat(const char* label, float* value, float low, float high, const char* format = "%.3f") {
        if (!native(tr(label))) return ImGui::SliderFloat(label, value, low, high, format);
        ImGui::PushID(label);
        ImGui::BeginGroup();
        ImGui::SetNextItemWidth(ImGui::GetFontSize() * 14.f);
        const bool changed = ImGui::SliderFloat("##value", value, low, high, format);
        ImGui::SameLine();
        widgetLabel(label);
        ImGui::EndGroup();
        ImGui::PopID();
        return changed;
    }
    static bool colorEdit(const char* label, float* value) {
        if (!native(tr(label))) return ImGui::ColorEdit4(label, value);
        ImGui::PushID(label);
        ImGui::BeginGroup();
        if (ImGui::ColorButton("##color", ImVec4(value[0], value[1], value[2], value[3]),
                                ImGuiColorEditFlags_NoTooltip, ImVec2(52.f, ImGui::GetFrameHeight())))
            ImGui::OpenPopup("##colors");
        ImGui::SameLine();
        widgetLabel(label);
        bool changed = false;
        if (ImGui::BeginPopup("##colors")) {
            const char* components[] = {"Red", "Green", "Blue", "Opacity"};
            for (int i = 0; i < 4; ++i)
                changed = sliderFloat(components[i], &value[i], 0.f, 1.f, "%.2f") || changed;
            ImGui::EndPopup();
        }
        ImGui::EndGroup();
        ImGui::PopID();
        return changed;
    }
    static bool button(const char* label, ImVec2 size) {
        if (!native(tr(label))) return ImGui::Button(label, size);
        const ImVec2 position = ImGui::GetCursorScreenPos();
        const std::string id = "##locale_button_" + std::string(label);
        const bool pressed = ImGui::Button(id.c_str(), size);
        const ImVec2 textSize = measure(label, ImGui::GetFontSize());
        const float factor = textSize.x > size.x - 12.f ? (size.x - 12.f) / textSize.x : 1.f;
        draw(ImGui::GetWindowDrawList(), label,
             ImVec2(position.x + (size.x - textSize.x * factor) * .5f,
                    position.y + (size.y - textSize.y * factor) * .5f),
             ImGui::GetFontSize(), ImGui::GetColorU32(ImGuiCol_Text), size.x - 12.f);
        return pressed;
    }
}

void SetMenuLanguage(int language) { MenuLocale::language = language < 0 ? 0 : language > 6 ? 6 : language; }
int GetMenuLanguage() { return MenuLocale::language; }
const char* TranslateMenuText(const char* value) { return MenuLocale::tr(value); }

namespace CyberMenu {

    static const ImU32 Red = IM_COL32(195, 12, 41, 255);
    static const ImU32 White = IM_COL32(203, 204, 209, 255);
    static const ImU32 Muted = IM_COL32(112, 120, 130, 255);
    static const ImU32 Cyan = IM_COL32(17, 178, 201, 255);
    static const ImU32 Green = IM_COL32(37, 216, 125, 255);

    struct Canvas {
        ImDrawList* dl;
        ImVec2 origin;
        float scale;
        float stretchX = 1.f;
        float stretchY = 1.f;
        float switchReveal = 1.f;
        double animationTime = 0.0;
        ImVec2 p(float x, float y) const {
            return {origin.x + x * scale * stretchX, origin.y + y * scale * stretchY};
        }
        ImVec2 size(float w, float h) const {
            return {w * scale * stretchX, h * scale * stretchY};
        }
        void rect(float x, float y, float w, float h, ImU32 color, float radius = 0.f) const {
            dl->AddRectFilled(p(x, y), p(x + w, y + h), color, radius * scale);
        }
        void line(float x, float y, float xx, float yy, ImU32 color, float width = 1.f) const {
            dl->AddLine(p(x, y), p(xx, yy), color, width * scale);
        }
        void text(float x, float y, const char* label, float height = 20.f, ImU32 color = White,
                  float maxWidth = 0.f) const {
            float fs = height * scale;
            if (MenuLocale::native(MenuLocale::tr(label))) {
                MenuLocale::draw(dl, label, p(x, y), fs, color,
                                  maxWidth > 0.f ? maxWidth * scale * stretchX : 0.f, MenuLocale::rtl());
                return;
            }
            ImFont* font = ImGui::GetFont();
            if (maxWidth > 0.f) {
                float width = font->CalcTextSizeA(fs, FLT_MAX, 0.f, label).x;
                if (width > maxWidth * scale * stretchX)
                    fs *= maxWidth * scale * stretchX / width;
            }
            dl->AddText(font, fs, p(x, y), color, label);
        }
    };

    struct PageMotion {
        int page = -1;
        bool shown = false;
        bool opening = false;
        double started = 0.0;
        double lastFrame = 0.0;
        float age = 0.f;

        void update(int selected) {
            const double now =
                std::chrono::duration<double>(std::chrono::steady_clock::now().time_since_epoch()).count();
            if (!shown || selected != page) {
                opening = !shown;
                page = selected;
                started = now;
            }
            age = ImMax(0.f, (float)(now - started));
            shown = true;
            lastFrame = now;
        }

        float offset() const {
            if (opening && page == 0)
                return 0.f;
            static const float residual[] = {1.f, .707f, .467f, .280f, .147f, .080f,
                                             .013f, -.013f, -.013f, -.013f, -.013f, 0.f};
            const int last = (int)(sizeof(residual) / sizeof(residual[0])) - 1;
            const float sample = age * 60.f;
            if (sample >= last)
                return 0.f;
            const int index = (int)sample;
            const float t = sample - index;
            return -88.f * (residual[index] + (residual[index + 1] - residual[index]) * t);
        }

        float opacity() const {
            if (page != 0 && page != 4)
                return 1.f;
            const float t = ImClamp(age / .20f, 0.f, 1.f);
            const float fade = 1.f - (1.f - t) * (1.f - t);
            return opening && page == 0 ? .72f + .28f * fade : fade;
        }

        float switches() const {
            return age >= .08f ? 1.f : 1.f - std::exp(-age * 80.f);
        }
    };

    static void fadeContent(ImDrawList* draw, int first, float opacity) {
        if (opacity >= 1.f)
            return;
        for (int i = first; i < draw->VtxBuffer.Size; ++i) {
            ImU32& color = draw->VtxBuffer[i].col;
            const ImU32 alpha = (color & IM_COL32_A_MASK) >> IM_COL32_A_SHIFT;
            color = (color & ~IM_COL32_A_MASK) | ((ImU32)(alpha * opacity + .5f) << IM_COL32_A_SHIFT);
        }
    }

    struct Reference {
        id<MTLTexture> texture;
        float w, h, x, y;
    };

    static Reference& artwork(int index) {
        static Reference textures[3] = {};
        static bool attempted[3] = {};
        Reference& result = textures[index];
        if (attempted[index])
            return result;
        attempted[index] = true;
        @autoreleasepool {
            const char* bytes[] = {kCyberDetailedFrame, kCyberDetailedBrand, kCyberDetailedBrand};
            const CGRect crops[] = {CGRectMake(8, 8, 1528, 978), CGRectMake(60, 156, 2060, 403), CGRectMake(0, 0, 448, 448)};
            NSString* encoded = [[NSString alloc] initWithUTF8String:bytes[index]];
            NSData* data = [[NSData alloc] initWithBase64EncodedString:encoded options:0];
            UIImage* decoded = index == 2 ? GetMenuBadgeImage() : (data ? [UIImage imageWithData:data] : nil);
            CGImageRef image =
                decoded.CGImage ? CGImageCreateWithImageInRect(decoded.CGImage, crops[index]) : nullptr;
            id<MTLDevice> device = MTLCreateSystemDefaultDevice();
            if (!image || !device) {
                if (image)
                    CGImageRelease(image);
                return result;
            }
            const size_t width = CGImageGetWidth(image), height = CGImageGetHeight(image);
            std::vector<uint8_t> rgba(width * height * 4);
            CGColorSpaceRef space = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
            CGContextRef context =
                space ? CGBitmapContextCreate(rgba.data(), width, height, 8, width * 4, space,
                                              kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big)
                      : nullptr;
            if (context) {
                CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
                CGContextFlush(context);
                for (size_t i = 0; i < width * height; ++i) {
                    uint8_t* pixel = rgba.data() + i * 4;
                    const unsigned alpha = pixel[3];
                    if (alpha < 4) {
                        pixel[0] = pixel[1] = pixel[2] = pixel[3] = 0;
                        continue;
                    }
                    for (int k = 0; k < 3; ++k)
                        pixel[k] = (uint8_t)ImMin(255u, (pixel[k] * 255u + alpha / 2u) / alpha);
                }
                MTLTextureDescriptor* descriptor =
                    [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatRGBA8Unorm
                                                                       width:width
                                                                      height:height
                                                                   mipmapped:NO];
                descriptor.usage = MTLTextureUsageShaderRead;
                descriptor.storageMode = MTLStorageModeShared;
                result.texture = [device newTextureWithDescriptor:descriptor];
                if (result.texture)
                    [result.texture replaceRegion:MTLRegionMake2D(0, 0, width, height)
                                      mipmapLevel:0
                                        withBytes:rgba.data()
                                      bytesPerRow:width * 4];
                result.w = (float)width;
                result.h = (float)height;
                CGContextRelease(context);
            }
            if (space)
                CGColorSpaceRelease(space);
            CGImageRelease(image);
        }
        return result;
    }

    static bool hit(const Canvas& c, const char* id, float x, float y, float w, float h,
                    bool available = true, const char* reason = nullptr) {
        ImGui::SetCursorScreenPos(c.p(x, y));
        ImGui::BeginDisabled(!available);
        bool clicked = ImGui::InvisibleButton(id, c.size(w, h));
        bool hovered = ImGui::IsItemHovered(ImGuiHoveredFlags_AllowWhenDisabled);
        ImGui::EndDisabled();
        if (hovered && reason)
            MenuLocale::tooltip(reason);
        return clicked;
    }

    enum IconKind {
        Player = 0, Target, List, Box, Warning, Group, Ruler, Bolt, NameCard, Question,
        Information, Health, Compass, Bone, Robot, Shield, Loot, Items, Car, Wand,
        Flame, Skull, Fov, Gauge, Percent, PaperPlane, Headset, Link, Cloud, Eye,
        Gear, Globe, Reset, Gamepad, Phone, Calendar, Check, Database, MemoryChip
    };

    static void icon(const Canvas& c, int kind, float x, float y, float size, ImU32 color = Red) {
        if (kind < 0)
            return;
        static const char* const symbols[] = {
            ICON_FA_USER, ICON_FA_CROSSHAIRS, ICON_FA_LIST, ICON_FA_VECTOR_SQUARE,
            ICON_FA_EXCLAMATION_TRIANGLE, ICON_FA_USERS, ICON_FA_RULER, ICON_FA_BOLT,
            ICON_FA_ADDRESS_CARD, ICON_FA_QUESTION, ICON_FA_INFO_CIRCLE, ICON_FA_HEARTBEAT,
            ICON_FA_COMPASS, ICON_FA_BONE, ICON_FA_ROBOT, ICON_FA_SHIELD_ALT,
            ICON_FA_BOX_OPEN, ICON_FA_BOXES, ICON_FA_CAR, ICON_FA_MAGIC,
            ICON_FA_FIRE, ICON_FA_SKULL, ICON_FA_EXPAND, ICON_FA_TACHOMETER_ALT,
            ICON_FA_PERCENT, ICON_FA_PAPER_PLANE, ICON_FA_HEADSET, ICON_FA_LINK,
            ICON_FA_CLOUD, ICON_FA_EYE, ICON_FA_COG, ICON_FA_GLOBE,
            ICON_FA_SYNC_ALT, ICON_FA_GAMEPAD, ICON_FA_MOBILE_ALT, ICON_FA_CALENDAR_ALT,
            ICON_FA_CHECK_CIRCLE, ICON_FA_DATABASE, ICON_FA_MEMORY
        };
        if (kind >= IM_ARRAYSIZE(symbols))
            return;
        const unsigned char* utf8 = (const unsigned char*)symbols[kind];
        const ImWchar code = (ImWchar)(((utf8[0] & 15) << 12) | ((utf8[1] & 63) << 6) | (utf8[2] & 63));
        ImFont* font = ImGui::GetFont();
        const ImFontGlyph* glyph = font->FindGlyphNoFallback(code);
        if (!glyph) {
            c.dl->AddCircle(c.p(x + size * .5f, y + size * .5f), size * .36f * c.scale, color, 24,
                            1.8f * c.scale);
            return;
        }
        const float width = glyph->X1 - glyph->X0, height = glyph->Y1 - glyph->Y0;
        if (width <= 0 || height <= 0)
            return;
        const float fit = ImMin(size * c.scale * c.stretchX / width, size * c.scale * c.stretchY / height);
        const ImVec2 origin = c.p(x, y);
        const ImVec2 position = {
            origin.x + (size * c.scale * c.stretchX - width * fit) * .5f - glyph->X0 * fit,
            origin.y + (size * c.scale * c.stretchY - height * fit) * .5f - glyph->Y0 * fit};
        c.dl->AddText(font, font->FontSize * fit, position, color, symbols[kind]);
    }

    static void panel(const Canvas& c, float x, float y, float w, float h, ImU32 accent = Red) {
        c.dl->AddRectFilledMultiColor(c.p(x, y), c.p(x + w, y + h), IM_COL32(16, 8, 13, 255),
                                      IM_COL32(12, 8, 12, 255), IM_COL32(8, 9, 12, 255),
                                      IM_COL32(8, 9, 12, 255));
        (void)accent;
    }

    static void heading(const Canvas& c, const char* title, float x, float y, float w, int glyph = Target) {
        panel(c, x, y, w, 29);
        c.rect(x + 1, y + 3, 3, 23, Red, 1);
        icon(c, glyph, x + 12, y + 6, 16, White);
        c.text(x + 38, y + 4, title, 19, White, w - 48);
    }

    struct FeatureNotice {
        std::string label;
        int glyph;
        bool enabled;
        double started;
        float y = -1.f;
    };
    static std::vector<FeatureNotice>& notices() {
        static std::vector<FeatureNotice> items;
        return items;
    }
    static void notifyFeature(const char* label, int glyph, bool enabled) {
        auto& items = notices();
        if (items.size() >= 8)
            items.erase(items.begin());
        items.push_back({label, glyph, enabled, ImGui::GetTime(), -1.f});
    }
    static bool featureCheckbox(const char* label, bool* value, int glyph) {
        const bool changed = MenuLocale::checkbox(label, value);
        if (changed)
            notifyFeature(label, glyph, *value);
        return changed;
    }
    static void renderNotices() {
        auto& items = notices();
        const double now = ImGui::GetTime();
        for (auto i = items.begin(); i != items.end();) {
            if (now - i->started >= 2.25)
                i = items.erase(i);
            else
                ++i;
        }
        if (items.empty())
            return;
        const ImGuiIO& io = ImGui::GetIO();
        if (io.DisplaySize.x < 1.f || io.DisplaySize.y < 1.f)
            return;
        const float scale = ImClamp(io.DisplaySize.y / 592.f, .55f, 1.4f);
        const float width = ImMin(265.f * scale, io.DisplaySize.x - 24.f * scale);
        const float height = 44.f * scale, spacing = 8.f * scale;
        const float top =
            ImMin((items.back().glyph == Globe ? 40.f : 62.f) * scale, ImMax(8.f * scale, io.DisplaySize.y - 4 * (height + spacing) - 8.f * scale));
        ImGui::PushFont(cyberMenuFont ? cyberMenuFont : ImGui::GetFont());
        ImDrawList* draw = ImGui::GetForegroundDrawList();
        draw->PushClipRect(ImVec2(0, 0), io.DisplaySize, true);
        for (size_t i = 0; i < items.size() && i < 4; ++i) {
            FeatureNotice& n = items[i];
            const float age = (float)(now - n.started);
            const float enter = ImClamp(age / .28f, 0.f, 1.f);
            const float fade = 1.f - ImClamp((age - 1.95f) / .30f, 0.f, 1.f);
            const float remaining = 1.f - enter;
            const float offset = (width + 24.f * scale) * remaining * remaining * remaining;
            const float desired = top + i * (height + spacing);
            if (n.y < 0)
                n.y = desired;
            n.y += (desired - n.y) * (1.f - std::exp(-ImMin(io.DeltaTime, .1f) * 20.f));
            const float x = io.DisplaySize.x - 20.f * scale - width + offset;
            Canvas c{draw, ImVec2(x, n.y), scale};
            const float w = width / scale;
            const int first = draw->VtxBuffer.Size;
            const ImU32 accent = n.enabled ? IM_COL32(0, 238, 155, 255) : IM_COL32(233, 21, 57, 255);
            c.rect(-1, 1, w + 2, 45, IM_COL32(0, 0, 0, 45), 7);
            c.rect(0, 0, w, 44, n.enabled ? IM_COL32(3, 19, 15, 235) : IM_COL32(25, 5, 10, 235), 6);
            c.rect(3, 5, 5, 34, n.enabled ? IM_COL32(0, 226, 136, 45) : IM_COL32(255, 12, 52, 45), 2);
            c.rect(4, 5, 3, 34, accent, 1.5f);
            icon(c, n.glyph, 16, 7, 16, accent);
            c.text(40, 6, n.label.c_str(), 14, IM_COL32(234, 238, 239, 255), w - 50);
            c.text(40, 24, n.enabled ? "ENABLED" : "DISABLED", 11.5f, accent, w - 50);
            fadeContent(draw, first, fade);
        }
        draw->PopClipRect();
        ImGui::PopFont();
    }

    struct SwitchMotion {
        float value = 0.f;
        float from = 0.f;
        bool target = false;
        double started = 0.;
        int frame = -2;
    };

    static float switchPosition(ImGuiID key, bool enabled, double now) {
        static std::unordered_map<ImGuiID, SwitchMotion> motions;
        SwitchMotion& motion = motions[key];
        const int frame = ImGui::GetFrameCount();
        if (motion.frame < frame - 1) {
            motion.value = motion.from = enabled ? 1.f : 0.f;
            motion.target = enabled;
            motion.started = now - .14;
        }
        const float elapsed = ImClamp((float)((now - motion.started) / .14), 0.f, 1.f);
        const float eased = 1.f - (1.f - elapsed) * (1.f - elapsed) * (1.f - elapsed);
        motion.value = motion.from + ((motion.target ? 1.f : 0.f) - motion.from) * eased;
        if (enabled != motion.target) {
            motion.from = motion.value;
            motion.target = enabled;
            motion.started = now;
        }
        motion.frame = frame;
        return motion.value;
    }

    static bool toggle(const Canvas& c, const char* label, const char* id, bool* value, float x, float y,
                       float w, int glyph, bool available = true,
                       const char* reason = "Not available in the current project") {
        bool changed = hit(c, id, x, y, w, 36, available, available ? nullptr : reason);
        if (changed) {
            *value = !*value;
            notifyFeature(label, glyph, *value);
        }
        ImU32 fg = available ? White : IM_COL32(106, 107, 113, 255);
        icon(c, glyph, x + 3, y + 6, 23, available ? Red : IM_COL32(104, 20, 38, 255));
        const float switchX = x + w - 52;
        c.text(x + 37, y + 4, label, 23, fg, w - 96);
        const ImGuiID key = ImGui::GetID(id);
        const float position = switchPosition(key, *value, c.animationTime) * c.switchReveal;
        const float light = available ? position : 0.f;
        const float cy = y + 18.5f;
        const ImU32 track =
            IM_COL32((int)(35 + 214 * light), (int)(37 * (1.f - light)), (int)(44 - 2 * light), 255);
        c.rect(switchX, y + 5, 49, 27, track, 13.5f);
        const float knobX = switchX + 12 + 25 * position;
        c.dl->AddCircleFilled(c.p(knobX, cy + .7f), 11.2f * c.scale, IM_COL32(0, 0, 0, 65), 32);
        c.dl->AddCircleFilled(c.p(knobX, cy), 12.7f * c.scale, IM_COL32(255, 220, 226, (int)(45 * light)),
                              32);
        c.dl->AddCircleFilled(c.p(knobX, cy), 11.2f * c.scale, IM_COL32(220, 222, 226, available ? 110 : 40),
                              32);
        c.dl->AddCircleFilled(c.p(knobX, cy), 10.2f * c.scale,
                              available ? IM_COL32(253, 253, 253, 255) : IM_COL32(133, 134, 137, 255), 32);
        return changed;
    }

    static bool actionRowButton(const Canvas& c, const char* label, const char* badgeText, const char* id,
                                float x, float y, float w, int glyph) {
        const bool clicked = hit(c, id, x, y, w, 33, true, nullptr);
        const bool hovered = ImGui::IsItemHovered();
        icon(c, glyph, x + 3, y + 5, 21, Red);
        c.text(x + 37, y + 4, label, 21, White, w - 110);
        c.rect(x + w - 64, y + 5, 62, 23,
               hovered ? IM_COL32(195, 12, 41, 255) : IM_COL32(42, 14, 22, 255), 6.f);
        c.text(x + w - 53, y + 7, badgeText, 14.f, White, 44);
        return clicked;
    }

    static bool slider(const Canvas& c, const char* id, const char* label, float* value, float low,
                       float high, float x, float y, float w, int glyph, bool available = true,
                       const char* disabledReason = "Not available, or controlled by the selected preset") {
        panel(c, x, y, w, 37);
        icon(c, glyph, x + 10, y + 9, 19, available ? Red : IM_COL32(103, 23, 40, 255));
        c.text(x + 37, y + 9, label, glyph == Percent ? 12.5f : 17.f, available ? White : Muted, 77);
        const float tx = x + 124, tw = w - 142, cy = y + 19;
        float t = ImClamp((*value - low) / (high - low), 0.f, 1.f);
        const float knob = tx + tw * t;
        hit(c, id, tx - 8, y, tw + 16, 37, available,
            available ? nullptr : disabledReason);
        ImGuiID key = ImGui::GetID(id);
        ImGuiStorage* storage = ImGui::GetStateStorage();
        if (ImGui::IsItemActivated()) {
            float dx = ImGui::GetIO().MousePos.x - c.p(knob, cy).x;
            storage->SetFloat(key, std::fabs(dx) <= 14 * c.scale ? dx : 0.f);
        }
        if (available && ImGui::IsItemActive() && ImGui::GetIO().MouseDown[0]) {
            float pos = (ImGui::GetIO().MousePos.x - storage->GetFloat(key) - c.p(tx, cy).x) /
                        (tw * c.scale * c.stretchX);
            float next = low + (high - low) * ImClamp(pos, 0.f, 1.f);
            if (next != *value) {
                *value = next;
                ImGui::MarkItemEdited(key);
            }
            t = ImClamp((*value - low) / (high - low), 0.f, 1.f);
            char hint[256];
            snprintf(hint, sizeof(hint), "%s: %.1f", MenuLocale::tr(label), *value);
            MenuLocale::tooltip(hint);
        }
        bool committed = ImGui::IsItemDeactivatedAfterEdit();
        c.rect(tx, cy - 2.25f, tw, 4.5f, IM_COL32(41, 26, 33, 255), 3);
        c.rect(tx, cy - 2.25f, tw * t, 4.5f, available ? Red : IM_COL32(115, 23, 42, 255), 3);
        c.dl->AddCircleFilled(c.p(tx + tw * t, cy), 6.3f * c.scale, IM_COL32(237, 236, 239, 255), 20);
        c.dl->AddCircleFilled(c.p(tx + tw * t, cy), 3.2f * c.scale, Red, 16);
        return committed;
    }

    static bool combo(const Canvas& c, const char* id, int* current, const char* const* items, int count,
                      float x, float y, float w, float h = 32.f) {
        c.rect(x, y, w, h, IM_COL32(18, 12, 18, 255), 3);
        const int selected = ImClamp(*current, 0, count - 1);
        c.text(x + 11, y + 5, items[selected], 19, White, w - 42);
        c.dl->AddTriangleFilled(c.p(x + w - 23, y + h * .42f), c.p(x + w - 11, y + h * .42f),
                                c.p(x + w - 17, y + h * .65f), Red);
        if (hit(c, id, x, y, w, h))
            ImGui::OpenPopup(id);
        bool changed = false;
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(8, 8));
        if (ImGui::BeginPopup(id)) {
            for (int i = 0; i < count; ++i)
                if (MenuLocale::selectable(items[i], *current == i)) {
                    *current = i;
                    changed = true;
                }
            ImGui::EndPopup();
        }
        ImGui::PopStyleVar();
        return changed;
    }

    static void frame(const Canvas& c) {
        c.rect(52, 151, 920, 445, IM_COL32(7, 8, 11, 245), 6);
    }

    static bool closeButton(const Canvas& c) {
        const bool clicked = hit(c, "##cyber_close", 928, 155, 36, 32, true, "Close menu");
        const bool hovered = ImGui::IsItemHovered();
        c.rect(932, 158, 28, 26, hovered ? IM_COL32(107, 6, 25, 245) : IM_COL32(55, 5, 15, 235), 3);
        const ImU32 color = hovered ? IM_COL32(255, 57, 77, 255) : IM_COL32(239, 19, 46, 255);
        c.line(940, 165, 952, 177, color, 2.f);
        c.line(952, 165, 940, 177, color, 2.f);
        return clicked;
    }

    static void navigation(const Canvas& c, int& page) {
        const float dstY[] = {159, 247, 335, 423, 511};
        const char* ids[] = {"##cyber_home", "##cyber_visual", "##cyber_aim", "##cyber_memory",
                             "##cyber_settings"};
        const char* labels[] = {"HOME", "ESP RADAR", "AIMBOT", "Memory", "SETTINGS"};
        for (int i = 0; i < 5; ++i)
            if (hit(c, ids[i], 64, dstY[i], 166, 79))
                page = i;
        for (int i = 0; i < 5; ++i) {
            const bool selected = page == i;
            c.rect(64, dstY[i], 166, 79,
                   selected ? IM_COL32(24, 24, 28, 255) : IM_COL32(13, 13, 16, 255), 6.f);
            c.text(80, dstY[i] + 26, labels[i], 21, selected ? White : Muted, 142);
        }
    }

    struct Stats {
        std::string device, ios, time, date;
        float fps = 0, appMB = -1, freeGB = -1, totalGB = 0, battery = -1;
    };
    static const Stats& stats() {
        static Stats st;
        static double last = -10;
        if (ImGui::GetTime() - last < 1.0)
            return st;
        last = ImGui::GetTime();
        struct utsname si;
        uname(&si);
        st.device = si.machine;
        st.ios = [UIDevice currentDevice].systemVersion.UTF8String;
        [UIDevice currentDevice].batteryMonitoringEnabled = YES;
        st.battery = [UIDevice currentDevice].batteryLevel;
        st.fps = ImGui::GetIO().Framerate;
        st.totalGB = (float)[NSProcessInfo processInfo].physicalMemory / (1024.f * 1024.f * 1024.f);
        mach_task_basic_info_data_t task = {};
        mach_msg_type_number_t count = MACH_TASK_BASIC_INFO_COUNT;
        if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&task, &count) == KERN_SUCCESS)
            st.appMB = task.resident_size / (1024.f * 1024.f);
        host_t host = mach_host_self();
        vm_statistics64_data_t vm = {};
        count = HOST_VM_INFO64_COUNT;
        vm_size_t page = 0;
        if (host_page_size(host, &page) == KERN_SUCCESS &&
            host_statistics64(host, HOST_VM_INFO64, (host_info64_t)&vm, &count) == KERN_SUCCESS)
            st.freeGB = (vm.free_count + vm.inactive_count) * (double)page / (1024. * 1024. * 1024.);
        mach_port_deallocate(mach_task_self(), host);
        static NSDateFormatter* tf = nil;
        static NSDateFormatter* df = nil;
        if (!tf) {
            tf = [NSDateFormatter new];
            tf.dateFormat = @"HH:mm";
            df = [NSDateFormatter new];
            df.dateFormat = @"yyyy/MM/dd";
        }
        NSDate* now = [NSDate date];
        st.time = [tf stringFromDate:now].UTF8String;
        st.date = [df stringFromDate:now].UTF8String;
        return st;
    }

    static const ImU32 HomeCyan = IM_COL32(27, 205, 223, 255);
    static const ImU32 HomeLabel = IM_COL32(141, 150, 159, 255);

    static void homeText(const Canvas& c, float x, float y, const char* text, float nominalSize, ImU32 color,
                         float maxWidth = 0.f, float visibleCap = 0.f, bool centered = false) {
        if (MenuLocale::native(MenuLocale::tr(text))) {
            const float fs = (visibleCap > 0.f ? visibleCap / .76f : nominalSize) * c.scale;
            ImVec2 position = c.p(x, y);
            const float room = maxWidth > 0.f ? maxWidth * c.scale * c.stretchX : 0.f;
            const ImVec2 measured = MenuLocale::measure(text, fs);
            if (centered) position.x -= (room > 0.f ? ImMin(measured.x, room) : measured.x) * .5f;
            MenuLocale::draw(c.dl, text, position, fs, color, room, MenuLocale::rtl() && !centered);
            return;
        }
        ImFont* font = cyberMenuFont ? cyberMenuFont : ImGui::GetFont();
        const ImFontGlyph* capital = font->FindGlyphNoFallback('H');
        if (!capital || capital->Y1 <= capital->Y0) {
            c.text(x, y, text, nominalSize, color, maxWidth);
            return;
        }
        const float cap = visibleCap > 0 ? visibleCap : nominalSize * .76f;
        const float ratio = cap * c.scale / (capital->Y1 - capital->Y0);
        const float fontSize = font->FontSize * ratio;
        const float naturalWidth = font->CalcTextSizeA(fontSize, FLT_MAX, 0, text).x;
        const float horizontal = maxWidth > 0 && naturalWidth > 0
                                     ? ImMin(1.f, maxWidth * c.scale * c.stretchX / naturalWidth)
                                     : 1.f;
        ImVec2 origin = c.p(x, y);
        if (centered)
            origin.x -= naturalWidth * horizontal * .5f;
        const float anchor = origin.x;
        origin.y += capital->Y0 * (nominalSize * c.scale / font->FontSize - ratio);
        const int first = c.dl->VtxBuffer.Size;
        c.dl->AddText(font, fontSize, origin, color, text);
        if (horizontal < 1.f)
            for (int i = first; i < c.dl->VtxBuffer.Size; ++i)
                c.dl->VtxBuffer[i].pos.x = anchor + (c.dl->VtxBuffer[i].pos.x - anchor) * horizontal;
    }

    static void homePanel(const Canvas& c, float x, float y, float w, float h) {
        const float r = 4.5f;
        c.rect(x, y, w, h, IM_COL32(10, 8, 12, 255), r);
        c.dl->AddRectFilledMultiColor(c.p(x + 3, y + 3), c.p(x + w - 3, y + h - 3), IM_COL32(18, 8, 13, 255),
                                      IM_COL32(15, 8, 12, 255), IM_COL32(8, 9, 11, 255),
                                      IM_COL32(8, 9, 11, 255));
    }

    static void homeAction(const Canvas& c, float x, float y, float w, float h) {
        const float r = 3.f;
        c.rect(x, y, w, h, IM_COL32(26, 8, 14, 255), r);
        c.dl->AddRectFilledMultiColor(c.p(x + 2, y + 2), c.p(x + w - 2, y + h - 2), IM_COL32(43, 9, 17, 255),
                                      IM_COL32(37, 8, 16, 255), IM_COL32(27, 8, 14, 255),
                                      IM_COL32(32, 9, 16, 255));
    }

    static void statusTile(const Canvas& c, float x, float y, float w, const char* title, const char* value,
                           ImU32 accent, int glyph) {
        const bool status = glyph < 0, active = accent == Green;
        const float r = 4.f;
        c.rect(x, y, w, 39, status ? IM_COL32(5, 25, 18, 255) : IM_COL32(6, 17, 26, 255), r);
        if (status) {
            if (active)
                c.dl->AddCircleFilled(c.p(x + 13, y + 20), 6 * c.scale, IM_COL32(23, 228, 126, 28), 24);
            c.dl->AddCircleFilled(c.p(x + 13, y + 20), 3.5f * c.scale, accent, 24);
        } else
            icon(c, glyph, x + 7.5f, y + 13, 13, glyph == Shield ? Green : glyph == Link ? HomeCyan : accent);
        homeText(c, x + 29, y + (status ? 4.f : 8.f), title, 9, HomeLabel, w - 35);
        const ImU32 valueColor = accent == Muted ? IM_COL32(159, 166, 173, 255)
                                 : accent == Cyan || accent == HomeCyan || accent == White
                                     ? IM_COL32(213, 216, 220, 255)
                                     : accent;
        homeText(c, x + 29, y + (status ? 19.f : 23.f), value, 11.8f, valueColor, w - 35, 8.5f);
    }

    static void openChannel() {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL* url = [NSURL URLWithString:@"https://t.me/hmoodhack"];
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        });
    }

    static void home(const Canvas& canvas) {
        Canvas c = canvas;
        c.origin = canvas.p(261, 158);
        c.scale = canvas.scale * (419.f / 373.f);
        c.stretchX = (699.f / 604.f) / (419.f / 373.f);
        c.stretchY = 1.f;
        const Stats& st = stats();
        char fps[32];
        snprintf(fps, sizeof(fps), "%.0f FPS", st.fps);
        homePanel(c, 12, 15, 328, 219);
        homePanel(c, 355, 15, 240, 219);
        c.dl->AddRectFilledMultiColor(c.p(17, 22), c.p(335, 59), IM_COL32(23, 7, 13, 255),
                                      IM_COL32(25, 7, 14, 255), IM_COL32(31, 6, 14, 255),
                                      IM_COL32(28, 6, 13, 255));
        homeText(c, 28, 31, "DARK IOS", 17.5f, White, 274);
        c.dl->AddCircleFilled(c.p(308.5f, 39.5f), 9 * c.scale, IM_COL32(0, 235, 126, 14), 28);
        icon(c, Check, 302, 33, 13, IM_COL32(0, 224, 119, 255));
        NSString* savedKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"DARKIOS_Saved_Key_v1"];
        const char* keyStateText = IsValidDarkIOSKeyFormat(savedKey) ? savedKey.UTF8String : "VERIFIED";
        statusTile(c, 27, 68, 296, "SERVER", "DARKIOS.ONRENDER.COM", Green, -1);
        statusTile(c, 27, 120, 141, "FPS", fps, HomeCyan, Gauge);
        statusTile(c, 183, 120, 140, "LICENSE", keyStateText, Green, Shield);
        statusTile(c, 27, 172, 141, "SUBSCRIPTION", "ACTIVE", HomeCyan, Cloud);
        statusTile(c, 183, 172, 140, "DEVICE LINK", st.device.c_str(), White, Link);
        for (int i = 0; i < 10; ++i) {
            const float x = 28 + i * 29.5f;
            c.rect(x, 221, 26, 3, HomeCyan, .5f);
        }
        homeText(c, 369, 32, "CONTACT", 15, Red, 207);
        homeAction(c, 369, 82, 211, 40);
        icon(c, PaperPlane, 381, 94, 14);
        homeText(c, 412, 94, "TELEGRAM", 14, IM_COL32(174, 177, 184, 255), 162);
        if (hit(c, "##telegram_channel", 369, 82, 211, 40))
            openChannel();
        homeAction(c, 369, 136, 211, 40);
        icon(c, Headset, 381, 148, 14);
        homeText(c, 412, 148, "SUPPORT", 14, IM_COL32(174, 177, 184, 255), 162);
        if (hit(c, "##support_channel", 369, 136, 211, 40))
            openChannel();
        c.rect(369, 186, 211, 39, IM_COL32(7, 21, 30, 255), 3);
        icon(c, Gamepad, 380, 198, 17, HomeCyan);
        homeText(c, 408, 190, "CLOUD AUTH", 10, HomeLabel, 166);
        homeText(c, 408, 207, hideHacker ? "STREAM: ON" : "STREAM: OFF", 10.5f, White, 166);

        homePanel(c, 12, 263, 189, 96);
        homePanel(c, 212, 263, 184, 96);
        homePanel(c, 407, 263, 188, 96);
        c.dl->AddCircleFilled(c.p(27, 278), 3.3f * c.scale, Green, 18);
        homeText(c, 40, 270, "DARK IOS", 12.5f, Red, 148);
        homeText(c, 27, 305, st.device.c_str(), 14, White, 160);
        homeText(c, 27, 333, (std::string(MenuLocale::tr("OS")) + " iOS " + st.ios).c_str(), 11.5f, IM_COL32(154, 139, 90, 255),
                 161);
        for (int i = 0; i < 5; ++i)
            c.rect(220 + i * 4.5f, 280 - i * 3, 2.8f, 4 + i * 3, Green, .5f);
        homeText(c, 251, 271, "DEVICE", 10, Muted, 95);
        homeText(c, 355, 271, "LIVE", 10, HomeCyan, 44);
        auto center = [&](float x, float y, const char* text, float height, ImU32 color, float cap = 0.f) {
            homeText(c, x, y, text, height, color, 0, cap, true);
        };
        center(304, 292, st.time.c_str(), 21, White, 12.8f);
        center(304, 319, "ONLINE", 10.5f, HomeCyan);
        center(304, 342, st.date.c_str(), 10.5f, Muted);
        char battery[24];
        if (st.battery >= 0)
            snprintf(battery, sizeof(battery), "%.0f%%", st.battery * 100);
        else
            snprintf(battery, sizeof(battery), "--");
        const float charge = ImClamp(st.battery, 0.f, 1.f);
        const ImU32 batteryColor = charge <= .2f ? Red : charge <= .4f ? IM_COL32(200, 177, 72, 255) : Green;
        c.rect(443, 276, 2, 4, IM_COL32(132, 138, 141, 255), .5f);
        if (st.battery >= 0)
            for (int i = 0; i < 5; ++i) {
                const float portion = ImClamp(charge * 5 - i, 0.f, 1.f);
                if (portion > 0)
                    c.rect(421 + i * 4.1f, 275, 3.1f * portion, 6, batteryColor, .45f);
            }
        homeText(c, 450, 271, battery, 11, Green, 51);
        homeText(c, 507, 271, fps, 11.5f, HomeCyan, 78);
        char ram[40];
        if (st.freeGB >= 0)
            snprintf(ram, sizeof(ram), "%s: %.2f GB", MenuLocale::tr("RAM"), st.freeGB);
        else
            snprintf(ram, sizeof(ram), "%s: --", MenuLocale::tr("RAM"));
        homeText(c, 421, 305, ram, 12.5f, White, 158);
        c.rect(421, 335, 156, 8, IM_COL32(9, 28, 36, 255), 2);
        const float freeFraction =
            st.totalGB > 0 && st.freeGB >= 0 ? ImClamp(st.freeGB / st.totalGB, 0.f, 1.f) : 0.f;
        const float fill = 156 * freeFraction;
        if (fill > 0)
            c.rect(421, 335, fill, 8, HomeCyan, 2);
    }

    static void visual(const Canvas& c) {
        panel(c, 279, 164, 689, 38);
        icon(c, Shield, 290, 175, 20);
        c.text(324, 173, "ESP Style", 20);
        const char* styles[] = {"BASIC", "VIP CYBER VERTICAL"};
        if (combo(c, "##cyber_style", &IsStyle, styles, 2, 657, 169, 297, 28))
            configManager::putInteger(config, "ESP", "STYLE", IsStyle);
        if (hit(c, "##esp_extra", 279, 164, 330, 44, true, "Open additional existing display settings"))
            ImGui::OpenPopup("Display options");
        struct Row {
            const char* label;
            const char* id;
            bool* value;
            const char* key;
            int glyph;
        };
        Row left[] = {{"PLAYER ESP", "##v_esp", &imgui::ESP, "ESP", 0},
                      {"DRAW NAMES", "##v_names", &imgui::Name, "NAME", NameCard},
                      {"DRAW WEAPON", "##v_weapon", &imgui::Weapon, "WEAPON", Question},
                      {"GAME INFO", "##v_info", &imgui::GameInfo, "GAME_INFO", Information},
                      {"DRAW DISTANCE", "##v_distance", &imgui::Distance, "DISTANCE", 6},
                      {"DRAW HEALTH", "##v_health", &imgui::Health, "HEALTH", Health},
                      {"360 ALERT", "##v_360", &imgui::Alert360, "ALERT_360", Compass},
                      {"SNAP LINES", "##v_lines", &imgui::Line, "LINE", 7}};
        for (int i = 0; i < 8; ++i) {
            if (toggle(c, left[i].label, left[i].id, left[i].value, 282, 215 + i * 37.f, 329, left[i].glyph))
                configManager::putBoolean(config, "ESP", left[i].key, *left[i].value);
        }
        static bool unavailable = false;
        Row right[] = {{"DRAW BOXES", "##v_boxes", &imgui::Boxes, "BOXES", 3},
                       {"DRAW BONES", "##v_bones", &imgui::Bone, "BONE", Bone},
                       {"TEST MENU", "##v_test_menu", nullptr, nullptr, Gear},
                       {"HIDE BOTS", "##v_bots", &imgui::HideBot, nullptr, Robot},
                       {"ENEMY COUNT", "##v_count", &imgui::EnemyCount, "ENEMY_COUNT", 5},
                       {"PLAYER TEAM ID", "##v_team", &imgui::TeamID, "TEAM_ID", Shield},
                       {"ENEMY AIMING", "##v_aiming", &imgui::EnemyAiming, "ENEMY_AIMING", 1},
                       {"LOOTBOX", "##v_loot", &imgui::Lootbox, "LOOTBOX", Loot},
                       {"ITEMS ESP", "##v_items", &imgui::Items, "ITEMS", Items},
                       {"VEHICLE ESP", "##v_vehicle", &imgui::Vehicle, "VEHICLE", Car}};
        for (int i = 0; i < 10; ++i) {
            Row& r = right[i];
            const bool isTestMenuRow = (strcmp(r.id, "##v_test_menu") == 0);
            if (isTestMenuRow) {
                if (actionRowButton(c, r.label, "OPEN", r.id, 633, 215 + i * 33.f, 329, r.glyph)) {
                    g_DarkIOSNewMenuOpen = true;
                    OpenNewMenu();
                }
                continue;
            }
            bool changed = toggle(c, r.label, r.id, r.value ? r.value : &unavailable, 633, 215 + i * 33.f,
                                  329, r.glyph, r.value != nullptr);
            if (changed && r.key) {
                configManager::putBoolean(config, "ESP", r.key, *r.value);
            }
        }
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(12, 12));
        if (ImGui::BeginPopup("Display options")) {
            MenuLocale::text("Existing display settings");
            ImGui::Separator();
            MenuLocale::sliderFloat("ESP distance", &ESPMaxDistance, 1.f, 450.f, "%.0f m");
            if (MenuLocale::sliderFloat("HP scale", &globalHpAlphaF, .5f, 5.f, "%.1f"))
                configManager::putFloat(config, "ESP", "HP_SCALE", globalHpAlphaF);
            MenuLocale::sliderFloat("Alert radius", &AlertRadius, 1.f, 200.f, "%.0f m");
            if (MenuLocale::sliderFloat("Stroke width", &strokeIntensity, .5f, 5.f, "%.1f"))
                configManager::putFloat(config, "ESP", "STROKE_WIDTH", strokeIntensity);
            featureCheckbox("Text border", &textBorder, NameCard);
            if (featureCheckbox("Hide name", &hideNameKillMsg, NameCard))
                configManager::putBoolean(config, "ESP", "HIDE_NAME_KILL", hideNameKillMsg);
            ImVec4 distance = ImGui::ColorConvertU32ToFloat4(COLOR_Distance);
            if (MenuLocale::colorEdit("Distance color", &distance.x))
                COLOR_Distance = ImGui::ColorConvertFloat4ToU32(distance);
            if (MenuLocale::colorEdit("Border color", &bgColor.Value.x)) {
                configManager::putFloat(config, "ESP", "BORDER_R", bgColor.Value.x);
                configManager::putFloat(config, "ESP", "BORDER_G", bgColor.Value.y);
                configManager::putFloat(config, "ESP", "BORDER_B", bgColor.Value.z);
                configManager::putFloat(config, "ESP", "BORDER_A", bgColor.Value.w);
            }
            ImGui::EndPopup();
        }
        ImGui::PopStyleVar();
    }

    static void saveAimSettings() {
        Settings::Aimbot::SilentAim = Enable;
        configManager::putBoolean(config, "AIMBOT", "ENABLED", Settings::Aimbot::Tick);
        configManager::putBoolean(config, "AIMBOT", "SILENT_AIM", Enable);
        configManager::putBoolean(config, "AIMBOT", "AUTOFIRE", 自动开火);
        configManager::putInteger(config, "AIMBOT", "MODE", Settings::Aimbot::AimMethod);
        configManager::putBoolean(config, "AIMBOT", "AIM_LINE", Settings::Aimbot::SilentAimSettings::AimingLine);
        configManager::putBoolean(config, "AIMBOT", "VISCHECK", Settings::isVisibilityCheck);
        configManager::putBoolean(config, "AIMBOT", "IGNOREBOTS", Settings::Aimbot::SilentAimSettings::Highprecisiontracking);
        configManager::putBoolean(config, "AIMBOT", "IGNOREKNOCKED", Settings::Aimbot::SilentAimSettings::AimKnocked);
        configManager::putBoolean(config, "AIMBOT", "SHOWFOV", Settings::Aimbot::SilentAimSettings::EnableFov);
        configManager::putBoolean(config, "AIMBOT", "PREDICTION", Settings::Aimbot::SilentAimSettings::Prediction);
        configManager::putInteger(config, "AIMBOT", "TARGET", Settings::Aimbot::SilentAimSettings::Aimpositon);
        configManager::putFloat(config, "AIMBOT", "FOV", Cross);
        configManager::putFloat(config, "AIMBOT", "SILENT_DISTANCE", SilentAimMaxDistance);
        configManager::putFloat(config, "AIMBOT", "SPEED", AimSmooth);
        configManager::putFloat(config, "AIMBOT", "MAX_STEP", Settings::Aimbot::SilentAimSettings::MaxStepDeg);
        configManager::putFloat(config, "AIMBOT", "HITPROB", 追踪概率);
    }

    static void applyAimPreset(int mode) {
        Settings::Aimbot::AimMethod = ImClamp(mode, 0, 2);
        if (mode != 2) {
            const bool safe = mode == 0;
            Cross = safe ? 80.f : 150.f;
            AimSmooth = safe ? 18.f : 8.f;
            SilentAimMaxDistance = safe ? 180.f : 250.f;
            Settings::Aimbot::SilentAimSettings::MaxStepDeg = safe ? 1.5f : 4.f;
            Settings::Aimbot::SilentAimSettings::Aimpositon = safe ? 1 : 4;
            Settings::Aimbot::SilentAimSettings::AimKnocked = true;
            Settings::Aimbot::SilentAimSettings::Highprecisiontracking = safe;
            Settings::Aimbot::SilentAimSettings::Prediction = true;
            Settings::isVisibilityCheck = true;
            if (safe) Enable = false;
        }
        saveAimSettings();
    }

    static void aim(const Canvas& c) {
        heading(c, "AIM SETTINGS", 287, 164, 289);
        heading(c, "AIM CONTROL", 603, 164, 365, List);
        if (hit(c, "##aim_extra", 287, 164, 289, 35, true,
                "Open existing SAFE / RISK / CUSTOM modes and additional settings"))
            ImGui::OpenPopup("Aim options");
        static bool absent = false;
        struct Row {
            const char* name;
            const char* id;
            bool* value;
            int glyph;
        };
        Row rows[] = {
            {"Aimbot", "##a_enable", &Settings::Aimbot::Tick, Target},
            {"Silent Aim", "##a_silent", &Enable, Wand},
            {"Macro", "##a_macro", nullptr, Bolt},
            {"Aim Line", "##a_line", &Settings::Aimbot::SilentAimSettings::AimingLine, List},
            {"Auto Fire", "##a_auto", &自动开火, Flame},
            {"Visibility Check", "##a_vis", &Settings::isVisibilityCheck, Shield},
            {"Ignore Bots", "##a_bot", &Settings::Aimbot::SilentAimSettings::Highprecisiontracking, Robot},
            {"Ignore Knocked", "##a_knock", &Settings::Aimbot::SilentAimSettings::AimKnocked, Skull},
            {"Enable FOV", "##a_fov", &Settings::Aimbot::SilentAimSettings::EnableFov, Fov},
            {"Prediction", "##a_prediction", &Settings::Aimbot::SilentAimSettings::Prediction, PaperPlane}
        };
        for (int i = 0; i < 10; ++i) {
            Row& row = rows[i];
            const bool available = row.value && (i != 1 || (Settings::Aimbot::Tick && Settings::Aimbot::AimMethod != 0)) &&
                                   (i != 4 || Settings::Aimbot::Tick);
            if (toggle(c, row.name, row.id, row.value ? row.value : &absent, 287, 201 + i * 37.f,
                       289, row.glyph, available,
                       i == 1 ? "Enable Aimbot and select RISK or CUSTOM to use Silent Aim"
                              : i == 4 ? "Enable Aimbot first" : "Not available in the current project")) {
                if (i == 0 && !Settings::Aimbot::Tick) { Enable = false; 自动开火 = false; }
                if (i == 5 || i == 6 || i == 7 || i == 9)
                    Settings::Aimbot::AimMethod = 2;
                saveAimSettings();
            }
        }
        panel(c, 603, 201, 365, 43);
        icon(c, List, 615, 213, 20);
        c.text(643, 212, "Mode", 19, White, 119);
        const char* modes[] = {"SAFE", "RISK", "CUSTOM"};
        int mode = Settings::Aimbot::AimMethod;
        if (combo(c, "##aim_mode", &mode, modes, 3, 785, 207, 169))
            applyAimPreset(mode);
        panel(c, 603, 250, 365, 43);
        icon(c, Target, 615, 262, 20);
        c.text(643, 261, "Aim Target", 19, White, 119);
        const char* bones[] = {"Head", "Neck", "Body", "Pelvis", "Auto"};
        if (combo(c, "##cyber_bone", &Settings::Aimbot::SilentAimSettings::Aimpositon, bones, 5,
                  785, 256, 169)) {
            Settings::Aimbot::AimMethod = 2;
            saveAimSettings();
        }
        c.rect(603, 299, 365, 57, IM_COL32(11, 12, 16, 255));
        const char* triggers[] = {"Fire", "ADS", "Fire + ADS", "Fire or ADS"};
        const char* triggerIDs[] = {"##trigger_fire", "##trigger_ads", "##trigger_both", "##trigger_either"};
        int triggerMode = Settings::Aimbot::TriggerMode.load(std::memory_order_relaxed);
        for (int i = 0; i < 4; ++i) {
            const float x = 630 + (i % 2) * 152, y = 303 + (i / 2) * 27;
            if (hit(c, triggerIDs[i], x - 25, y - 2, 151, 26)) {
                triggerMode = i;
                Settings::Aimbot::TriggerMode.store(i, std::memory_order_relaxed);
                configManager::putInteger(config, "AIMBOT", "TRIGGER_MODE", i);
            }
            const bool selected = triggerMode == i;
            c.dl->AddCircle(c.p(x - 14, y + 10), 7 * c.scale,
                           selected ? Red : IM_COL32(96, 38, 50, 255), 24, 1.2f * c.scale);
            if (selected) c.dl->AddCircleFilled(c.p(x - 14, y + 10), 4.5f * c.scale, Red, 24);
            c.text(x, y, triggers[i], 18, selected ? White : Muted, 126);
        }
        const bool enabled = Settings::Aimbot::Tick;
        bool changed = slider(c, "##a_radius", "FOV", &Cross, 30, 300, 603, 365, 365, Target, enabled && !Enable, "FOV applies to camera aim");
        changed = slider(c, "##a_range", "Distance", &SilentAimMaxDistance, 50, 355,
                         603, 411, 365, PaperPlane, enabled) || changed;
        changed = slider(c, "##a_speed", "Aim Speed", &AimSmooth, 2, 30,
                         603, 457, 365, Gauge, enabled && !Enable, "Disable Silent Aim to adjust camera movement") || changed;
        if (changed) {
            Settings::Aimbot::AimMethod = 2;
            saveAimSettings();
        }
        if (slider(c, "##a_probability", "Hit Probability", &追踪概率, 0, 100,
                   603, 503, 365, Percent, enabled && Enable, "Enable Silent Aim to adjust hit probability"))
            saveAimSettings();
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(12, 12));
        if (ImGui::BeginPopup("Aim options")) {
            ImGui::BeginDisabled(!enabled || Enable);
            if (MenuLocale::sliderFloat("Max step", &Settings::Aimbot::SilentAimSettings::MaxStepDeg,
                                        .3f, 8.f, "%.1f deg"))
                Settings::Aimbot::AimMethod = 2;
            if (ImGui::IsItemDeactivatedAfterEdit()) saveAimSettings();
            ImGui::EndDisabled();
            if (MagicSDK) {
                ImGui::BeginDisabled();
                MenuLocale::sliderFloat("Magic X", &magicX, 0, 500);
                MenuLocale::sliderFloat("Magic Y", &magicY, 0, 500);
                MenuLocale::sliderFloat("Magic Z", &magicZ, 0, 500);
                ImGui::EndDisabled();
            }
            ImGui::EndPopup();
        }
        ImGui::PopStyleVar();
    }

    static void memory(const Canvas& c) {
        static bool absent = false;
        struct Row {
            const char* label;
            const char* id;
            bool* value;
            int glyph;
            const char* key;
        };
        Row left[] = {{"Auto Tap", "##m_tap", nullptr, Flame, nullptr},
                      {"Fast Shoot", "##m_shoot", &IsFastshoot, Bolt, "FASTSHOOT"},
                      {"Fast Scope", "##m_scope", &MemoryFastScope, Eye, "FASTSCOPE"},
                      {"Fast Gun", "##m_switch", &IsFastSwitch, Target, "FASTSWITCH"},
                      {"Spin", "##m_spin", &isSpinning, Reset, "SPIN"},
                      {"Zoom", "##m_zoom", &MemoryZoom, Fov, "ZOOM"},
                      {"iPad", "##m_ipad", &WideView, Phone, nullptr}};
        Row right[] = {{"No Recoil", "##m_recoil", &IsNorecoil2, Shield, "NORECOIL2"},
                       {"No Shake", "##m_shake", &IsNocamerashake, Box, "NOCAMERASHAKE"},
                       {"HitX", "##m_hitx", &HitX, Target, "HITX"},
                       {"Damage", "##m_damage", &MemoryDamage, Health, "DAMAGE"},
                       {"Small Cross", "##m_crosshair", &IsCrossHair, Target, "SMALLCROSS"},
                       {"Rainbow", "##m_rainbow", &MemoryRainbow, Wand, "RAINBOW"},
                       {"Cross Spin", "##m_cross_spin", &MemoryCrossSpin, Reset, "CROSSSPIN"}};
        for (int column = 0; column < 2; ++column)
            for (int i = 0; i < 7; ++i) {
                Row& r = column ? right[i] : left[i];
                const bool changed =
                    toggle(c, r.label, r.id, r.value ? r.value : &absent, column ? 638.f : 287.f,
                           164 + i * 37.f, 315.f, r.glyph, r.value != nullptr);
                if (changed && r.key)
                    configManager::putBoolean(config, "MEMORY", r.key, *r.value);
                if (changed && r.value == &WideView)
                    configManager::putBoolean(config, "SETTINGS", "IPADVIEW", WideView);
            }
        if (WideView) {
            float view = (float)WideValue;
            const bool committed = slider(c, "##ipad_view_inline", "Wide", &view, 80.f, 160.f,
                                           287, 430, 315, Phone);
            WideValue = ImClamp((int)std::lround(view), 80, 160);
            if (committed) configManager::putInteger(config, "SETTINGS", "TPP", WideValue);
        }
        float rightY = 430.f;
        if (IsCrossHair) {
            if (slider(c, "##memory_cross_size", "Cross Size", &crosshairSizeSlider, 0.f, 20.f,
                       638, rightY, 315, Target))
                configManager::putFloat(config, "MEMORY", "CROSSSIZE", crosshairSizeSlider);
            rightY += 48.f;
        }
        if (MemoryRainbow) {
            if (slider(c, "##memory_rainbow_speed", "Rainbow", &MemoryRainbowSpeed, .1f, 2.4f,
                       638, rightY, 315, Wand))
                configManager::putFloat(config, "MEMORY", "RAINBOW_SPEED", MemoryRainbowSpeed);
            rightY += 48.f;
        }
        if (MemoryCrossSpin) {
            if (slider(c, "##memory_cross_spin_speed", "Spin Speed", &MemoryCrossSpinSpeed, 0.f, 180.f,
                       638, rightY, 315, Reset))
                configManager::putFloat(config, "MEMORY", "CROSSSPIN_SPEED", MemoryCrossSpinSpeed);
        }
        icon(c, Gear, 576, 556, 18, Muted);
        if (hit(c, "##memory_more", 564, 545, 38, 38, true, "More memory options"))
            ImGui::OpenPopup("Memory options");
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(12, 12));
        if (ImGui::BeginPopup("Memory options")) {
            if (MemoryZoom) {
                MenuLocale::sliderFloat("Zoom", &MemoryZoomFov, 20.f, 90.f, "%.0f deg");
                if (ImGui::IsItemDeactivatedAfterEdit())
                    configManager::putFloat(config, "MEMORY", "ZOOM_FOV", MemoryZoomFov);
            }
            if (featureCheckbox("Fast Drop", &IsFastDrop, Bolt))
                configManager::putBoolean(config, "MEMORY", "FASTDROP", IsFastDrop);
            if (featureCheckbox("Super Run", &chaynhanhv2, Player))
                configManager::putBoolean(config, "MEMORY", "SUPERRUN", chaynhanhv2);
            if (MenuLocale::sliderFloat("Spin speed", &tocdoquay, 0.f, 30.f, "%.1f"))
                configManager::putFloat(config, "MEMORY", "SPINSPEED", tocdoquay);
            ImGui::EndPopup();
        }
        ImGui::PopStyleVar();
    }

    static void settings(const Canvas& c) {
        const Stats& st = stats();
        panel(c, 278, 168, 329, 187);
        panel(c, 626, 168, 350, 187);
        panel(c, 278, 373, 329, 203);
        panel(c, 626, 373, 350, 203);
        icon(c, NameCard, 294, 184, 18, Cyan);
        c.text(325, 182, "LICENSE", 18, Cyan, 260);
        c.text(295, 226, "EXPIRES", 16, Muted, 106);
        c.text(412, 226, "ACTIVE", 16, Green);
        c.text(295, 264, "DEVICE", 16, Muted, 106);
        c.text(412, 264, st.device.c_str(), 16, White, 180);
        c.text(295, 303, "KEY", 16, Muted, 106);
        NSString* savedKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"DARKIOS_Saved_Key_v1"];
        c.text(412, 303, IsValidDarkIOSKeyFormat(savedKey) ? savedKey.UTF8String : "VERIFIED", 15, Green, 180);
        icon(c, Gamepad, 645, 184, 18);
        c.text(676, 182, "GAME MODE", 18, Red, 278);
        c.text(645, 226, "CLOUD MODE", 19, White, 300);
        c.text(645, 262, "DARKIOS.ONRENDER.COM", 15, Green, 300);
        panel(c, 644, 302, 313, 38);
        icon(c, Gamepad, 656, 312, 17);
        c.text(685, 311, "OPEN MODE", 17, Muted, 260);
        hit(c, "##mode_absent", 644, 302, 313, 38, false, "Connected to DARKIOS Panel");
        icon(c, Gauge, 295, 389, 19, Cyan);
        c.text(325, 387, "RAM BOOSTER", 18, Cyan, 265);
        char app[40], freeMem[40];
        snprintf(app, sizeof(app), "%.0f MB", st.appMB);
        snprintf(freeMem, sizeof(freeMem), "%.1f GB", st.freeGB);
        c.text(295, 426, "App", 17, White, 102);
        c.text(409, 426, app, 17, White);
        c.text(295, 457, "Free", 17, White, 102);
        c.text(409, 457, freeMem, 17, White);
        panel(c, 294, 489, 135, 39);
        char fps[32];
        snprintf(fps, sizeof(fps), "%.0f FPS", st.fps);
        c.text(315, 500, fps, 17, White, 105);
        panel(c, 440, 489, 151, 39);
        icon(c, 7, 452, 499, 18);
        c.text(482, 500, "PURGE", 16, Muted, 100);
        hit(c, "##purge_absent", 440, 489, 151, 39, false,
            "The current project has no memory purge operation");
        panel(c, 294, 535, 297, 30);
        c.text(315, 542, "AUTO-CLEAN: OFF", 16, Muted, 265);
        hit(c, "##clean_absent", 294, 535, 297, 30, false, "Automatic cleaning is not configured");
        icon(c, Gear, 645, 389, 19);
        c.text(676, 387, "Preferences", 18, Red, 276);
        panel(c, 644, 424, 313, 40);
        icon(c, Eye, 656, 435, 18);
        c.text(686, 435, hideHacker ? "STREAM: ON" : "STREAM: OFF", 18, White, 260);
        if (hit(c, "##stream_mode", 644, 424, 313, 40)) {
            hideHacker = !hideHacker;
            notifyFeature("Stream", Eye, hideHacker);
            configManager::putBoolean(config, "SYSTEM", "HIDERECORD", hideHacker);
        }
        panel(c, 644, 473, 313, 40);
        icon(c, Globe, 656, 484, 18);
        const std::string languageLabel = std::string(MenuLocale::tr("Language")) + ": " +
                                          MenuLocale::languageNames[GetMenuLanguage()];
        c.text(686, 484, languageLabel.c_str(), 18, White, 260);
        if (hit(c, "##language_select", 644, 473, 313, 40)) {
            static const int order[] = {0, 4, 5, 2, 3, 1, 6};
            int position = 0;
            for (int i = 0; i < 7; ++i) if (order[i] == GetMenuLanguage()) position = i;
            const int next = order[(position + 1) % 7];
            SetMenuLanguage(next);
            configManager::putInteger(config, "SYSTEM", "LANGUAGE", next);
            notifyFeature(MenuLocale::languageNames[next], Globe, true);
        }
        panel(c, 644, 522, 313, 40);
        icon(c, Reset, 656, 533, 18);
        c.text(686, 533, "RESET GUEST", 18, White, 260);
        if (hit(c, "##reset_guest", 644, 522, 313, 40))
            ImGui::OpenPopup("Reset guest account?");
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(16, 16));
        if (ImGui::BeginPopupModal("Reset guest account?", nullptr,
                                   ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoTitleBar)) {
            MenuLocale::text("Reset guest account?");
            ImGui::Separator();
            MenuLocale::text("This deletes local game data, settings and account data.", 340.f);
            MenuLocale::text("The game will exit after the reset.", 340.f);
            ImGui::Spacing();
            if (MenuLocale::button("Cancel", ImVec2(110, 30)))
                ImGui::CloseCurrentPopup();
            ImGui::SameLine();
            if (MenuLocale::button("Reset guest", ImVec2(110, 30))) {
                ImGui::CloseCurrentPopup();
                ResetGuestAccount();
            }
            ImGui::EndPopup();
        }
        ImGui::PopStyleVar();
    }

    static void render() {
        static PageMotion motion;
        if (!IsESPKeyVerifiedMenu()) {
            MenDeal = false;
            motion.shown = false;
            return;
        }
        if (!MenDeal) {
            motion.shown = false;
            renderNotices();
            return;
        }
        ImGuiIO& io = ImGui::GetIO();
        if (io.DisplaySize.x < 1 || io.DisplaySize.y < 1)
            return;
        ImGui::PushFont(cyberMenuFont ? cyberMenuFont : ImGui::GetFont());
        const float scale =
            ImMin(ImMin(io.DisplaySize.x * .98f / 1024.f, io.DisplaySize.y * .98f / 676.f), 1.20f);
        ImVec2 size(1024 * scale, 676 * scale);
        ImGui::SetNextWindowPos({(io.DisplaySize.x - size.x) * .5f, (io.DisplaySize.y - size.y) * .5f},
                                ImGuiCond_Always);
        ImGui::SetNextWindowSize(size, ImGuiCond_Always);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0, 0));
        ImGui::PushStyleVar(ImGuiStyleVar_WindowBorderSize, 0);
        ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 0);
        ImGui::PushStyleColor(ImGuiCol_WindowBg, ImVec4(0, 0, 0, 0));
        bool visible =
            ImGui::Begin("##flexmenu", &MenDeal,
                         ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove |
                             ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoScrollbar |
                             ImGuiWindowFlags_NoScrollWithMouse | ImGuiWindowFlags_NoSavedSettings);
        ImGui::PopStyleColor();
        ImGui::PopStyleVar(3);
        if (visible) {
            Canvas c{ImGui::GetWindowDrawList(), ImGui::GetWindowPos(), scale};
            ImGui::SetWindowFontScale(ImClamp(scale * 1.5f, .7f, 1.5f));
            static int page = 0;
            frame(c);
            navigation(c, page);
            if (closeButton(c))
                MenDeal = false;
            motion.update(page);
            Canvas pageCanvas = c;
            pageCanvas.origin.x += motion.offset() * scale;
            pageCanvas.switchReveal = motion.switches();
            pageCanvas.animationTime = motion.lastFrame;
            Canvas content = pageCanvas;
            content.stretchX = .954f;
            content.origin.x += 253.f * (1.f - content.stretchX) * scale;
            content.stretchY = .98f;
            content.origin.y += 164.f * (1.f - content.stretchY) * scale;
            const int firstContentVertex = c.dl->VtxBuffer.Size;
            switch (page) {
            case 0:
                home(pageCanvas);
                break;
            case 1:
                visual(content);
                break;
            case 2:
                aim(content);
                break;
            case 3:
                memory(content);
                break;
            default:
                settings(content);
                break;
            }
            fadeContent(c.dl, firstContentVertex, motion.opacity());
            if (!MenDeal)
                motion.shown = false;
        }
        ImGui::End();
        ImGui::PopFont();
        renderNotices();
    }
}

void DrawMenuHudBadge(ImDrawList* draw, ImVec2 center, float diameter) {
    if (!IsESPKeyVerifiedMenu()) return;
    auto& badge = CyberMenu::artwork(2);
    if (!badge.texture || diameter <= 0.f) return;
    const float radius = diameter * .5f;
    draw->AddImage((__bridge ImTextureID)badge.texture,
                   ImVec2(center.x - radius, center.y - radius),
                   ImVec2(center.x + radius, center.y + radius));
}

void RenderMenu() {
    if (!IsESPKeyVerifiedMenu()) {
        MenDeal = false;
        g_DarkIOSNewMenuOpen = false;
        return;
    }

    MenuLocale::beginFrame();
    ImVec2 scr = ImGui::GetIO().DisplaySize;
    ImVec2 winSz = ImVec2(635, 300);

    ImGui::SetNextWindowPos(ImVec2(scr.x * 0.5f - winSz.x * 0.5f, scr.y * 0.5f - winSz.y * 0.5f),
                            ImGuiCond_FirstUseEver);

    ImGui::SetNextWindowSize(winSz, ImGuiCond_FirstUseEver);
    ImGui::GetStyle().WindowRounding = 3.5;
    CyberMenu::render();

    if (g_DarkIOSNewMenuOpen) {
        RenderNewMenuOverlay();
    }
}

extern "C" void OpenMeenu(void) {
    if (!IsESPKeyVerifiedMenu()) {
        MenDeal = false;
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        MenDeal = !MenDeal;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MeenuOpenRequested" object:nil];
    });
}
