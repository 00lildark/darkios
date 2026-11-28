#define IMGUI_DEFINE_MATH_OPERATORS
#define LocalPlayer g_LocalPlayer
// #import "API/APIClient.h"
// #import "PUBG/core/MenuLoad/DrawView.h"
#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <sys/utsname.h>
#include "ESP/imgui/imgui.h"
#include "ESP/imgui/imgui_impl_metal.h"
#include "ESP/imgui/imgui_internal.h"
// #include "ESP/xor.h"
#include <algorithm>
#include <cmath>
#include <vector>
#include <string>
#include <map>
#include "ESP/Tools.h"
#include "ESP/Vector3.hpp"
#include "ESP/Vector2.hpp"
// #include "PUBG/core/Vector/monoString.h"
#include "SDK.hpp"
// #include "Settings.h"
// #include "gui/mywings/gui.hpp"
// #include "gui/trash/hashes.hpp"
// #include "gui/blur/blur.hpp"
// #include "gui/trash/bytes.hpp"

#ifndef ENCRYPT
#define ENCRYPT(str) (str)
#endif

#ifndef ICON_MIN_FA
#define ICON_MIN_FA 0xf000
#endif
#ifndef ICON_MAX_FA
#define ICON_MAX_FA 0xf0ff
#endif
#ifndef ICON_FA_SAVE
#define ICON_FA_SAVE ""
#endif
#ifndef ICON_FA_SEARCH
#define ICON_FA_SEARCH ""
#endif
#ifndef ICON_FA_COG
#define ICON_FA_COG ""
#endif
#ifndef ICON_FA_CROSSHAIRS
#define ICON_FA_CROSSHAIRS ""
#endif
#ifndef ICON_FA_GHOST
#define ICON_FA_GHOST ""
#endif
#ifndef ICON_FA_MOUSE
#define ICON_FA_MOUSE ""
#endif
#ifndef ICON_FA_USER
#define ICON_FA_USER ""
#endif
#ifndef ICON_FA_PALLET
#define ICON_FA_PALLET ""
#endif
#ifndef ICON_FA_HAMMER
#define ICON_FA_HAMMER ""
#endif
#ifndef ICON_FA_CODE
#define ICON_FA_CODE ""
#endif

static unsigned char museo500_binary[] = { 0 };
static unsigned char museo900_binary[] = { 0 };
static unsigned char font_awesome_binary[] = { 0 };

#define STR(str) ENCRYPT(str)
using namespace ImGui;
using namespace SDK;
#define ALPHA (ImGuiColorEditFlags_NoTooltip|ImGuiColorEditFlags_NoInputs|ImGuiColorEditFlags_NoLabel|ImGuiColorEditFlags_AlphaBar|ImGuiColorEditFlags_InputRGB|ImGuiColorEditFlags_Float|ImGuiColorEditFlags_NoDragDrop|ImGuiColorEditFlags_PickerHueBar|ImGuiColorEditFlags_NoBorder)
#define NO_ALPHA (ImGuiColorEditFlags_NoTooltip|ImGuiColorEditFlags_NoInputs|ImGuiColorEditFlags_NoLabel|ImGuiColorEditFlags_NoAlpha|ImGuiColorEditFlags_InputRGB|ImGuiColorEditFlags_Float|ImGuiColorEditFlags_NoDragDrop|ImGuiColorEditFlags_PickerHueBar|ImGuiColorEditFlags_NoBorder)

struct AimSettings {
    bool enabled = false;
    bool silent = false;
    bool show_fov = false;
    bool silent_show_fov = false;
    bool prediction = false;
    bool vis_check = false;
    bool silent_vis_check = false;
    bool grenade_warning = false;
    bool vehicle_aim = false;
    bool closest_priority = false;
    float fov_size = 120.f;
    float max_distance = 300.f;
    float silent_distance = 300.f;
    float smooth = 2.5f;
    float silent_smooth = 1.0f;
    float silent_fov = 90.f;
    int target_bone = 0;
    int trigger_mode = 0;
    int silent_bone = 0;
};

struct VisSettings {
    bool boxes = false;
    bool health = false;
    bool skeleton = false;
    bool names = false;
    bool distance = false;
    bool snapline = false;
    bool indicators = false;
    bool indicator_fill = false;
    bool self_skeleton = false;
    bool draw_bots = false;
    float indicator_size = 20.f;
    float indicator_width = 50.f;
    float indicator_distance = 180.f;
    float line_width = 1.5f;
    float box_color[4] = {1.f, 1.f, 1.f, 1.f};
    float skeleton_color[4] = {1.f, 1.f, 1.f, 1.f};
    float snapline_color[4] = {1.f, 1.f, 1.f, 1.f};
    float indicator_color[4] = {1.f, 1.f, 1.f, 1.f};
    float silent_color[4] = {1.f, 0.f, 0.f, 1.f};
};

struct ItemEspSettings {
    bool vehicles = false;
    bool metro_chests = false;
    bool snow = false;
    float max_distance = 200.f;
};

struct LootEspSettings {
    bool enabled = false;
    bool weapons = false;
    bool attachments = false;
    bool scopes = false;
    bool ammo = false;
    bool health = false;
    bool backpacks = false;
    bool helmets = false;
    bool vests = false;
    bool metro_items = false;
    bool rare_only = false;
    float max_distance = 150.f;
};

struct FallbackColor {
    float r = 1.f, g = 1.f, b = 1.f, a = 1.f;
    ImU32 to_im_color() const { return ImGui::ColorConvertFloat4ToU32(ImVec4(r, g, b, a)); }
};

struct FallbackGui {
    int m_tab = 0;
    float m_anim = 0.f;
    FallbackColor accent_color{1.f, 1.f, 1.f, 1.f};
    FallbackColor text{1.f, 1.f, 1.f, 1.f};
    FallbackColor text_disabled{0.6f, 0.6f, 0.6f, 1.f};
    void group_title(const char* t) { ImGui::TextUnformatted(t); }
    bool tab(const char*, const char* label, bool active) {
        if (active) ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.3f, 0.3f, 0.3f, 0.8f));
        bool clicked = ImGui::Button(label, ImVec2(135, 28));
        if (active) ImGui::PopStyleColor();
        return clicked;
    }
    void group_box(const char* title, ImVec2 sz) {
        ImGui::BeginChild(title, sz, true);
        ImGui::TextUnformatted(title);
        ImGui::Separator();
    }
    void end_group_box() { ImGui::EndChild(); }
};

static AimSettings aim;
static VisSettings vis;
static ItemEspSettings itemEsp;
static LootEspSettings lootEsp;
static FallbackGui gui;

static inline FString ToFString(const std::wstring& ws) {
    return FString(ws.c_str());
}

static inline std::wstring FStringToWString(const FString& fs) {
    if (!fs.IsValid()) return L"";
    std::wstring out;
    int len = fs.Num();
    if (len <= 0) return out;
    out.reserve((size_t)len);
    for (int i = 0; i < len; ++i) {
        wchar_t ch = fs[i];
        if (ch == L'\0') break;
        out.push_back(ch);
    }
    return out;
}

ASTExtraPlayerCharacter* g_LocalPlayer = nullptr;
ASTExtraPlayerController* g_PlayerController = nullptr;
UFont* tslFont = nullptr;
int enemyCount = 0;
bool menu_open = false;

@interface ImGuiDrawView : UIViewController <MTKViewDelegate>
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) MTKView *mtkView;
+ (void)showChange:(BOOL)o;
+ (BOOL)isMenuShowing;
@end

static ImGuiDrawView *g_ImGuiDrawView = nil;
static UIWindow *g_ImGuiWindow = nil;

extern "C" void OpenNewMenu(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!g_ImGuiDrawView) {
            g_ImGuiDrawView = [[ImGuiDrawView alloc] init];
        }
        menu_open = !menu_open;
        [ImGuiDrawView showChange:menu_open];

        UIWindowScene *activeScene = nil;
        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                    activeScene = (UIWindowScene *)scene;
                    break;
                }
            }
        }

        if (!g_ImGuiWindow) {
            CGRect bounds = activeScene ? activeScene.coordinateSpace.bounds : [UIScreen mainScreen].bounds;
            if (@available(iOS 13.0, *)) {
                g_ImGuiWindow = activeScene ? [[UIWindow alloc] initWithWindowScene:activeScene] : [[UIWindow alloc] initWithFrame:bounds];
            } else {
                g_ImGuiWindow = [[UIWindow alloc] initWithFrame:bounds];
            }
            g_ImGuiWindow.frame = bounds;
            g_ImGuiWindow.backgroundColor = [UIColor clearColor];
            if (@available(iOS 13.0, *)) {
                g_ImGuiWindow.windowLevel = UIWindowLevelAlert + 1;
            } else {
                g_ImGuiWindow.windowLevel = UIWindowLevelStatusBar + 1;
            }
            g_ImGuiWindow.rootViewController = g_ImGuiDrawView;
        } else if (activeScene && g_ImGuiWindow.windowScene != activeScene) {
            if (@available(iOS 13.0, *)) {
                g_ImGuiWindow.windowScene = activeScene;
            }
            g_ImGuiWindow.frame = activeScene.coordinateSpace.bounds;
        }

        g_ImGuiDrawView.view.frame = g_ImGuiWindow.bounds;
        [g_ImGuiDrawView.view setUserInteractionEnabled:menu_open];
        g_ImGuiWindow.userInteractionEnabled = menu_open;
        g_ImGuiWindow.hidden = !menu_open;
        if (menu_open) {
            [g_ImGuiWindow makeKeyAndVisible];
        }
    });
}

extern "C" void RenderNewMenuOverlay(void) {
    OpenNewMenu();
}

void (*orig_shoot_event)(USTExtraShootWeaponComponent*, FVector, FRotator, ASTExtraShootWeapon*, int) = nullptr;
void (*orig_throw_grenade)(ASTExtraWeapon*, FVector, FRotator) = nullptr;
void (*orig_shoot_underbarrel)(ASTExtraWeapon*, FVector, FRotator) = nullptr;
void (*orig_process_event)(UObject*, UFunction*, void*) = nullptr;

uint64_t getBaseAddress(const char* n) {
    for (int i = 0; i < (int)_dyld_image_count(); i++) {
        if (strstr(_dyld_get_image_name(i), n)) return _dyld_get_image_vmaddr_slide(i);
    }
    return 0;
}
uint64_t getRealOffset(uint64_t o) { return getBaseAddress(ENCRYPT("ShadowTrackerExtra")) + o; }
long GetGlobalObjectsOffset() { return (long)getRealOffset(0x10A7F93E0); }
TNameEntryArray* GetGlobalNames() { return ((TNameEntryArray*(*)())(getRealOffset(0x105014128)))(); }

UWorld* GEWorld = nullptr;
int GWorldNum = 0;
TUObjectArray gobjects;

UWorld* GetFullWorld() {
    @try {
        if (GWorldNum == 0) {
            gobjects = UObject::GUObjectArray->ObjObjects;
            for (int i = 0; i < gobjects.Num(); i++) {
                @try {
                    if (auto o = gobjects.GetByIndex(i); o && o->IsA(UEngine::StaticClass())) {
                        auto e = (UEngine*)o;
                        if (e && e->GameViewport) {
                            tslFont = e->MediumFont;
                            auto v = e->GameViewport;
                            if (v && v->World) {
                                GEWorld = v->World;
                                GWorldNum = i;
                                return v->World;
                            }
                        }
                    }
                } @catch (...) {}
            }
        } else {
            @try {
                auto e = (UEngine*)gobjects.GetByIndex(GWorldNum);
                if (e) {
                    if (!tslFont && e->MediumFont) tslFont = e->MediumFont;
                    auto v = e->GameViewport;
                    if (v && v->World) {
                        GEWorld = v->World;
                        return v->World;
                    }
                }
            } @catch (...) {
                GWorldNum = 0;
                return GetFullWorld();
            }
        }
    } @catch (...) {}
    return nullptr;
}

template<class T>
void GetAllActorsInGame(std::vector<T*>& a) {
    @try {
        auto w = GetFullWorld();
        if (!w) return;
        auto s = (UGameplayStatics*)UGameplayStatics::StaticClass();
        if (!s) return;
        TArray<AActor*> arr;
        s->GetAllActorsOfClass((UObject*)w, T::StaticClass(), &arr);
        for (int i = 0; i < arr.Num(); i++) {
            @try {
                if (arr[i]) a.push_back((T*)arr[i]);
            } @catch (...) {}
        }
    } @catch (...) {}
}

float FVectorSize(const FVector& v) { return sqrtf(v.X * v.X + v.Y * v.Y + v.Z * v.Z); }
void NormalizeAngles(FRotator& a) {
    while (a.Pitch > 180) a.Pitch -= 360;
    while (a.Pitch < -180) a.Pitch += 360;
    if (a.Pitch > 89) a.Pitch = 89;
    if (a.Pitch < -89) a.Pitch = -89;
    while (a.Yaw > 180) a.Yaw -= 360;
    while (a.Yaw < -180) a.Yaw += 360;
    a.Roll = 0;
}
FVector GetCameraLocation(ASTExtraPlayerController* pc) {
    @try {
        if (pc && pc->PlayerCameraManager) return pc->PlayerCameraManager->CameraCache.POV.Location;
    } @catch (...) {}
    return FVector();
}
FRotator GetCameraRotation(ASTExtraPlayerController* pc) {
    @try {
        if (pc && pc->PlayerCameraManager) return pc->PlayerCameraManager->CameraCache.POV.Rotation;
    } @catch (...) {}
    return FRotator();
}

std::wstring GetItemNameFromID(int id) {
    static std::map<int, std::wstring> m = {
        {101001, L"akm"}, {101002, L"m16a4"}, {101003, L"scar-l"}, {101004, L"m416"},
        {101005, L"groza"}, {101006, L"aug"}, {101007, L"g36c"}, {101008, L"pp-19 bizon"},
        {101009, L"mp5k"}, {101010, L"qbu"}, {101011, L"m762"}, {101012, L"mk12"},
        {101013, L"ump45"}, {101014, L"pp-19"}, {101015, L"p90"}, {101016, L"mp7a2"},
        {102001, L"micro uzi"}, {102002, L"vector"}, {102003, L"thompson"}, {102004, L"pp-19"},
        {102005, L"ump45"}, {102006, L"mp5k"}, {103001, L"kar98k"}, {103002, L"m24"},
        {103003, L"awm"}, {103004, L"win94"}, {103005, L"mosin nagant"}, {103006, L"amr"},
        {104001, L"s12k"}, {104002, L"s686"}, {104003, L"s1897"}, {104004, L"dbs"},
        {104005, L"spas-12"}, {105001, L"mini 14"}, {105002, L"slr"}, {105003, L"mk14 ebr"},
        {105004, L"vss"}, {105005, L"qbu"}, {105006, L"sks"}, {201001, L"compensator"},
        {201002, L"compensator ar"}, {201003, L"compensator sr"}, {201004, L"flash hider"},
        {201005, L"flash hider ar"}, {201006, L"suppressor"}, {201007, L"suppressor ar"},
        {201008, L"suppressor sr"}, {202001, L"angled grip"}, {202002, L"vertical grip"},
        {202003, L"half grip"}, {202004, L"thumb grip"}, {202005, L"laser sight"},
        {203001, L"red dot"}, {203002, L"holographic"}, {203003, L"2x scope"},
        {203004, L"4x scope"}, {203005, L"6x scope"}, {203006, L"8x scope"},
        {203007, L"3x scope"}, {301001, L"9mm"}, {302001, L"7.62mm"}, {303001, L"5.56mm"},
        {304001, L"12 gauge"}, {305001, L".300 magnum"}, {306001, L"40mm he"},
        {306002, L"40mm smoke"}, {401001, L"crossbow"}, {402001, L"bolt"},
        {403001, L"arrow"}, {501001, L"backpack lv1"}, {501002, L"backpack lv2"},
        {501003, L"backpack lv3"}, {501004, L"backpack lv1"}, {501005, L"backpack lv2"},
        {501006, L"backpack lv3"}, {502001, L"helmet lv1"}, {502002, L"helmet lv2"},
        {502003, L"helmet lv3"}, {502004, L"helmet lv1"}, {502005, L"helmet lv2"},
        {502006, L"helmet lv3"}, {503001, L"vest lv1"}, {503002, L"vest lv2"},
        {503003, L"vest lv3"}, {503004, L"vest lv1"}, {503005, L"vest lv2"},
        {503006, L"vest lv3"}, {601001, L"bandage"}, {601002, L"med kit"},
        {601003, L"first aid"}, {601004, L"energy drink"}, {601005, L"first aid kit"},
        {601006, L"painkiller"}, {601007, L"painkiller"}, {601008, L"adrenaline syringe"},
        {601009, L"syringe"}, {601010, L"pills"}, {602001, L"frag grenade"},
        {602002, L"smoke grenade"}, {602003, L"molotov"}, {602004, L"frag grenade"},
        {602005, L"stun grenade"}, {602006, L"c4"}, {603001, L"flare gun"},
        {603002, L"marker"}, {604001, L"gas can"}, {106001, L"metro ak"},
        {106002, L"metro m4"}, {106003, L"metro scar"}, {106004, L"metro groza"},
        {106005, L"metro mp5"}, {106006, L"metro ump"}, {206001, L"metro scope"},
        {206002, L"metro suppressor"}, {206003, L"metro grip"}, {306001, L"metro ammo"},
        {306002, L"metro ammo"}, {406001, L"metro helmet"}, {406002, L"metro vest"},
        {406003, L"metro backpack"}, {107001, L"pan"}, {107002, L"machete"},
        {107003, L"crowbar"}, {107004, L"sickle"}, {107005, L"cleaver"},
        {107006, L"pipe wrench"}, {109001, L"sticky bomb"}, {109002, L"spike trap"},
        {111001, L"jammer"}, {111002, L"battering ram"}
    };
    auto it = m.find(id);
    if (it != m.end()) return it->second;
    if (id >= 101001 && id <= 199999) return L"weapon";
    if (id >= 201001 && id <= 299999) return L"attachment";
    if (id >= 301001 && id <= 399999) return L"ammo";
    if (id >= 401001 && id <= 499999) return L"throwable";
    if (id >= 501001 && id <= 599999) return L"armor";
    if (id >= 601001 && id <= 699999) return L"medical";
    if (id >= 701001 && id <= 799999) return L"key";
    if (id >= 801001 && id <= 899999) return L"upgrade";
    if (id >= 901001 && id <= 999999) return L"skin";
    return L"item #" + std::to_wstring(id);
}

void DrawLine(AHUD* h, FVector2D a, FVector2D b, float t, FLinearColor c) {
    @try {
        if (h && h->Canvas) h->Canvas->K2_DrawLine(a, b, t, c);
    } @catch (...) {}
}

void DrawTriangleIndicatorCanvas(AHUD* h, float cx, float cy, float hgt, float wd, float angle, FLinearColor col, bool fill) {
    @try {
        if (!h || !h->Canvas) return;
        float p1x = cx + hgt * cosf(angle);
        float p1y = cy + hgt * sinf(angle);
        float p2x = cx + wd * cosf(angle + 1.8f);
        float p2y = cy + wd * sinf(angle + 1.8f);
        float p3x = cx + wd * cosf(angle - 1.8f);
        float p3y = cy + wd * sinf(angle - 1.8f);
        if (fill) {
            float minX = std::min({p1x, p2x, p3x});
            float maxX = std::max({p1x, p2x, p3x});
            float minY = std::min({p1y, p2y, p3y});
            float maxY = std::max({p1y, p2y, p3y});
            for (int px = (int)minX; px <= (int)maxX; px++) {
                for (int py = (int)minY; py <= (int)maxY; py++) {
                    float d1 = (p2x - p1x) * (py - p1y) - (p2y - p1y) * (px - p1x);
                    float d2 = (p3x - p2x) * (py - p2y) - (p3y - p2y) * (px - p2x);
                    float d3 = (p1x - p3x) * (py - p3y) - (p1y - p3y) * (px - p3x);
                    if ((d1 >= 0 && d2 >= 0 && d3 >= 0) || (d1 <= 0 && d2 <= 0 && d3 <= 0)) {
                        h->Canvas->K2_DrawLine(FVector2D((float)px, (float)py), FVector2D((float)(px + 1), (float)py), 1.f, col);
                    }
                }
            }
        } else {
            h->Canvas->K2_DrawLine(FVector2D(p1x, p1y), FVector2D(p2x, p2y), 1.5f, col);
            h->Canvas->K2_DrawLine(FVector2D(p2x, p2y), FVector2D(p3x, p3y), 1.5f, col);
            h->Canvas->K2_DrawLine(FVector2D(p3x, p3y), FVector2D(p1x, p1y), 1.5f, col);
        }
    } @catch (...) {}
}

void DrawFOVCircle(AHUD* h, int x, int y, int r, FLinearColor c) {
    if (!h || !h->Canvas) return;
    float s = (float)(M_PI * 2.0 / 32.0);
    for (float a = 0; a < (float)(M_PI * 2.0); a += s) {
        h->Canvas->K2_DrawLine(
            FVector2D(r * cosf(a) + x, r * sinf(a) + y),
            FVector2D(r * cosf(a + s) + x, r * sinf(a + s) + y),
            1.f, c
        );
    }
}

void DrawText(AHUD* h, FString t, FVector2D p, FLinearColor c, bool cx) {
    @try {
        if (h && h->Canvas && tslFont) {
            h->Canvas->K2_DrawText(tslFont, t, p, c, 1.f, FLinearColor(0, 0, 0, 0), FVector2D(0, 0), cx, false, false, FLinearColor(0, 0, 0, 0));
        }
    } @catch (...) {}
}

void DrawSkeleton(AHUD* h, ASTExtraPlayerCharacter* pl, ASTExtraPlayerController* pc, UGameplayStatics* s, FLinearColor c) {
    @try {
        if (!pl || !pl->Mesh) return;
        const char* n[] = {
            "Head", "neck_01", "spine_03", "spine_02", "spine_01", "pelvis",
            "upperarm_r", "lowerarm_r", "hand_r", "upperarm_l", "lowerarm_l", "hand_l",
            "thigh_r", "calf_r", "foot_r", "thigh_l", "calf_l", "foot_l"
        };
        FVector2D p[18];
        bool ok[18] = {};
        for (int i = 0; i < 18; i++) {
            FVector w = pl->GetBonePos(n[i], FVector(0, 0, 0));
            if (s->ProjectWorldToScreen(pc, w, false, &p[i])) ok[i] = true;
        }
        int conn[17][2] = {
            {0, 1}, {1, 2}, {2, 3}, {3, 4}, {4, 5},
            {1, 6}, {6, 7}, {7, 8}, {1, 9}, {9, 10}, {10, 11},
            {5, 12}, {12, 13}, {13, 14}, {5, 15}, {15, 16}, {16, 17}
        };
        for (auto& pr : conn) {
            if (ok[pr[0]] && ok[pr[1]]) DrawLine(h, p[pr[0]], p[pr[1]], vis.line_width, c);
        }
    } @catch (...) {}
}

ASTExtraPlayerCharacter* FindBestTarget(float fov, float maxD, int bone, bool checkVis, bool closestFirst, FRotator& outRot) {
    @try {
        if (!g_LocalPlayer || !g_PlayerController) return nullptr;
        std::vector<ASTExtraPlayerCharacter*> p;
        GetAllActorsInGame(p);
        ASTExtraPlayerCharacter* best = nullptr;
        float bestVal = FLT_MAX;
        FVector camLoc = GetCameraLocation(g_PlayerController);
        FRotator camRot = GetCameraRotation(g_PlayerController);
        for (auto e : p) {
            if (!e || e->GetCurrentVehicle() || e->PlayerKey == g_LocalPlayer->PlayerKey || e->TeamID == g_LocalPlayer->TeamID || e->bDead || e->bHidden) continue;
            if (!vis.draw_bots && e->bEnsure) continue;
            float dist = e->GetDistanceTo(g_LocalPlayer) / 100.f;
            if (dist > maxD) continue;
            const char* bn = bone == 0 ? "Head" : (bone == 1 ? "neck_01" : (bone == 2 ? "spine_03" : "pelvis"));
            FVector bp = e->GetBonePos(bn, FVector(0, 0, 0));
            if (checkVis && !g_PlayerController->LineOfSightTo(e, bp, true)) continue;
            FVector dir = bp - camLoc;
            FRotator tr = UKismetMathLibrary::Conv_VectorToRotator(dir);
            NormalizeAngles(tr);
            float da = sqrtf(powf(tr.Pitch - camRot.Pitch, 2.f) + powf(tr.Yaw - camRot.Yaw, 2.f));
            if (da > fov) continue;
            float val = closestFirst ? dist : da;
            if (val < bestVal) {
                bestVal = val;
                best = e;
                outRot = tr;
            }
        }
        return best;
    } @catch (...) {
        return nullptr;
    }
}

float GetBulletSpeed() {
    @try {
        float bs = 800;
        auto wm = g_LocalPlayer->WeaponManagerComponent;
        if (wm) {
            auto cw = (ASTExtraShootWeapon*)wm->CurrentWeaponReplicated;
            if (cw && cw->ShootWeaponEntityComp) bs = cw->ShootWeaponEntityComp->BulletFireSpeed;
        }
        return bs;
    } @catch (...) {
        return 800;
    }
}

void PredictTarget(FVector& tp, ASTExtraPlayerCharacter* t, FVector origin) {
    @try {
        FVector vel = t->GetVelocity();
        ASTExtraVehicleBase* v = t->GetCurrentVehicle();
        if (v) {
            FVector vv = v->GetVelocity();
            if (FVectorSize(vv) > 0) vel = vv;
        }
        float bs = GetBulletSpeed();
        float dist = FVectorSize(tp - origin);
        float tt = dist / bs;
        tp.X += vel.X * tt;
        tp.Y += vel.Y * tt;
        tp.Z += vel.Z * tt;
    } @catch (...) {}
}

bool HasWeaponEquipped() {
    @try {
        if (!g_LocalPlayer) return false;
        auto wm = g_LocalPlayer->WeaponManagerComponent;
        if (!wm) return false;
        int slotVal = (int)wm->GetCurrentUsingPropSlot().GetValue();
        return (slotVal >= 1 && slotVal <= 3);
    } @catch (...) {
        return false;
    }
}

void HookedShootEvent(USTExtraShootWeaponComponent* c, FVector s, FRotator r, ASTExtraShootWeapon* w, int u) {
    @try {
        FRotator tr;
        ASTExtraPlayerCharacter* t = FindBestTarget(aim.silent_fov, aim.silent_distance, aim.silent_bone, aim.silent_vis_check, false, tr);
        if (!t || !aim.silent) {
            if (orig_shoot_event) orig_shoot_event(c, s, r, w, u);
            return;
        }
        FVector tp = (aim.silent_bone == 0) ? t->GetBonePos("Head", FVector(0, 0, 0)) : t->GetBonePos(aim.silent_bone == 1 ? "neck_01" : (aim.silent_bone == 2 ? "spine_03" : "pelvis"), FVector(0, 0, 0));
        if (aim.prediction) PredictTarget(tp, t, s);
        FRotator nr = UKismetMathLibrary::Conv_VectorToRotator(tp - s);
        NormalizeAngles(nr);
        if (orig_shoot_event) orig_shoot_event(c, s, nr, w, u);
    } @catch (...) {
        if (orig_shoot_event) orig_shoot_event(c, s, r, w, u);
    }
}

void HookedThrowGrenade(ASTExtraWeapon* w, FVector s, FRotator r) {
    @try {
        FRotator tr;
        ASTExtraPlayerCharacter* t = FindBestTarget(aim.silent_fov, aim.silent_distance, aim.silent_bone, aim.silent_vis_check, false, tr);
        if (!t || !aim.silent) {
            if (orig_throw_grenade) orig_throw_grenade(w, s, r);
            return;
        }
        FVector tp = t->K2_GetActorLocation();
        if (aim.prediction) {
            FVector vel = t->GetVelocity();
            float tt = FVectorSize(tp - s) / 15.f;
            tp.X += vel.X * tt;
            tp.Y += vel.Y * tt;
            tp.Z += vel.Z * tt;
        }
        FVector d = tp - GetCameraLocation(g_PlayerController);
        d.Z += 150;
        FRotator nr = UKismetMathLibrary::Conv_VectorToRotator(d);
        NormalizeAngles(nr);
        if (orig_throw_grenade) orig_throw_grenade(w, s, nr);
    } @catch (...) {
        if (orig_throw_grenade) orig_throw_grenade(w, s, r);
    }
}

void HookedShootUnderbarrel(ASTExtraWeapon* w, FVector s, FRotator r) {
    @try {
        FRotator tr;
        ASTExtraPlayerCharacter* t = FindBestTarget(aim.silent_fov, aim.silent_distance, aim.silent_bone, aim.silent_vis_check, false, tr);
        if (!t || !aim.silent) {
            if (orig_shoot_underbarrel) orig_shoot_underbarrel(w, s, r);
            return;
        }
        FVector tp = t->K2_GetActorLocation();
        if (aim.prediction) {
            FVector vel = t->GetVelocity();
            float tt = FVectorSize(tp - s) / 75.f;
            tp.X += vel.X * tt;
            tp.Y += vel.Y * tt;
            tp.Z += vel.Z * tt;
        }
        FVector d = tp - GetCameraLocation(g_PlayerController);
        d.Z += 50;
        FRotator nr = UKismetMathLibrary::Conv_VectorToRotator(d);
        NormalizeAngles(nr);
        if (orig_shoot_underbarrel) orig_shoot_underbarrel(w, s, nr);
    } @catch (...) {
        if (orig_shoot_underbarrel) orig_shoot_underbarrel(w, s, r);
    }
}

void SaveSettings() {
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    [d setBool:aim.enabled forKey:@"ae"];
    [d setBool:aim.silent forKey:@"as"];
    [d setBool:aim.show_fov forKey:@"af"];
    [d setBool:aim.silent_show_fov forKey:@"asf"];
    [d setBool:aim.prediction forKey:@"ap"];
    [d setBool:aim.vis_check forKey:@"av"];
    [d setBool:aim.silent_vis_check forKey:@"asv"];
    [d setBool:aim.grenade_warning forKey:@"ag"];
    [d setBool:aim.vehicle_aim forKey:@"ava"];
    [d setBool:aim.closest_priority forKey:@"acp"];
    [d setFloat:aim.fov_size forKey:@"afs"];
    [d setFloat:aim.max_distance forKey:@"am"];
    [d setFloat:aim.silent_distance forKey:@"asd"];
    [d setFloat:aim.smooth forKey:@"asm"];
    [d setFloat:aim.silent_smooth forKey:@"ass"];
    [d setFloat:aim.silent_fov forKey:@"asfo"];
    [d setInteger:aim.target_bone forKey:@"at"];
    [d setInteger:aim.trigger_mode forKey:@"atm"];
    [d setInteger:aim.silent_bone forKey:@"asb"];
    [d setBool:vis.boxes forKey:@"vb"];
    [d setBool:vis.health forKey:@"vh"];
    [d setBool:vis.skeleton forKey:@"vs"];
    [d setBool:vis.names forKey:@"vn"];
    [d setBool:vis.distance forKey:@"vd"];
    [d setBool:vis.snapline forKey:@"vsp"];
    [d setBool:vis.indicators forKey:@"vi"];
    [d setBool:vis.indicator_fill forKey:@"vif"];
    [d setFloat:vis.indicator_size forKey:@"visz"];
    [d setFloat:vis.indicator_width forKey:@"viw"];
    [d setFloat:vis.indicator_distance forKey:@"vid"];
    [d setBool:vis.self_skeleton forKey:@"vss"];
    [d setBool:vis.draw_bots forKey:@"vdb"];
    [d setFloat:vis.line_width forKey:@"vl"];
    [d setBool:itemEsp.vehicles forKey:@"iv"];
    [d setBool:itemEsp.metro_chests forKey:@"imc"];
    [d setBool:itemEsp.snow forKey:@"is"];
    [d setFloat:itemEsp.max_distance forKey:@"im"];
    [d setBool:lootEsp.enabled forKey:@"le"];
    [d setBool:lootEsp.weapons forKey:@"lw"];
    [d setBool:lootEsp.attachments forKey:@"la"];
    [d setBool:lootEsp.scopes forKey:@"ls"];
    [d setBool:lootEsp.ammo forKey:@"lam"];
    [d setBool:lootEsp.health forKey:@"lh"];
    [d setBool:lootEsp.backpacks forKey:@"lb"];
    [d setBool:lootEsp.helmets forKey:@"lhl"];
    [d setBool:lootEsp.vests forKey:@"lv"];
    [d setBool:lootEsp.metro_items forKey:@"lm"];
    [d setBool:lootEsp.rare_only forKey:@"lr"];
    [d setFloat:lootEsp.max_distance forKey:@"lmd"];
    [d synchronize];
}

void LoadSettings() {
    NSUserDefaults* d = [NSUserDefaults standardUserDefaults];
    aim.enabled = [d boolForKey:@"ae"];
    aim.silent = [d boolForKey:@"as"];
    aim.show_fov = [d boolForKey:@"af"];
    aim.silent_show_fov = [d boolForKey:@"asf"];
    aim.prediction = [d boolForKey:@"ap"];
    aim.vis_check = [d boolForKey:@"av"];
    aim.silent_vis_check = [d boolForKey:@"asv"];
    aim.grenade_warning = [d boolForKey:@"ag"];
    aim.vehicle_aim = [d boolForKey:@"ava"];
    aim.closest_priority = [d boolForKey:@"acp"];
    aim.fov_size = [d floatForKey:@"afs"];
    aim.max_distance = [d floatForKey:@"am"];
    aim.silent_distance = [d floatForKey:@"asd"];
    aim.smooth = [d floatForKey:@"asm"];
    aim.silent_smooth = [d floatForKey:@"ass"];
    aim.silent_fov = [d floatForKey:@"asfo"];
    aim.target_bone = (int)[d integerForKey:@"at"];
    aim.trigger_mode = (int)[d integerForKey:@"atm"];
    aim.silent_bone = (int)[d integerForKey:@"asb"];
    vis.boxes = [d boolForKey:@"vb"];
    vis.health = [d boolForKey:@"vh"];
    vis.skeleton = [d boolForKey:@"vs"];
    vis.names = [d boolForKey:@"vn"];
    vis.distance = [d boolForKey:@"vd"];
    vis.snapline = [d boolForKey:@"vsp"];
    vis.indicators = [d boolForKey:@"vi"];
    vis.indicator_fill = [d boolForKey:@"vif"];
    vis.indicator_size = [d floatForKey:@"visz"];
    vis.indicator_width = [d floatForKey:@"viw"];
    vis.indicator_distance = [d floatForKey:@"vid"];
    vis.self_skeleton = [d boolForKey:@"vss"];
    vis.draw_bots = [d boolForKey:@"vdb"];
    vis.line_width = [d floatForKey:@"vl"];
    itemEsp.vehicles = [d boolForKey:@"iv"];
    itemEsp.metro_chests = [d boolForKey:@"imc"];
    itemEsp.snow = [d boolForKey:@"is"];
    itemEsp.max_distance = [d floatForKey:@"im"];
    lootEsp.enabled = [d boolForKey:@"le"];
    lootEsp.weapons = [d boolForKey:@"lw"];
    lootEsp.attachments = [d boolForKey:@"la"];
    lootEsp.scopes = [d boolForKey:@"ls"];
    lootEsp.ammo = [d boolForKey:@"lam"];
    lootEsp.health = [d boolForKey:@"lh"];
    lootEsp.backpacks = [d boolForKey:@"lb"];
    lootEsp.helmets = [d boolForKey:@"lhl"];
    lootEsp.vests = [d boolForKey:@"lv"];
    lootEsp.metro_items = [d boolForKey:@"lm"];
    lootEsp.rare_only = [d boolForKey:@"lr"];
    lootEsp.max_distance = [d floatForKey:@"lmd"];
    if (aim.fov_size == 0) aim.fov_size = 120;
    if (aim.max_distance == 0) aim.max_distance = 300;
    if (aim.silent_distance == 0) aim.silent_distance = 300;
    if (aim.smooth == 0) aim.smooth = 2.5f;
    if (aim.silent_fov == 0) aim.silent_fov = 90;
    if (aim.silent_smooth == 0) aim.silent_smooth = 1.0f;
    if (vis.indicator_size == 0) vis.indicator_size = 20;
    if (vis.indicator_width == 0) vis.indicator_width = 50;
    if (vis.indicator_distance == 0) vis.indicator_distance = 180;
    if (vis.line_width == 0) vis.line_width = 1.5f;
    if (itemEsp.max_distance == 0) itemEsp.max_distance = 200;
    if (lootEsp.max_distance == 0) lootEsp.max_distance = 150;
}

void RenderESP(AHUD* hud, int w, int h) {
    @try {
        if (!tslFont) {
            GetFullWorld();
            if (!tslFont) return;
        }
        auto s = (UGameplayStatics*)UGameplayStatics::StaticClass();
        auto world = GetFullWorld();
        ASTExtraPlayerController* pc = nullptr;
        if (world && world->NetDriver && world->NetDriver->ServerConnection) {
            pc = (ASTExtraPlayerController*)world->NetDriver->ServerConnection->PlayerController;
        }
        if (!pc) return;
        std::vector<ASTExtraPlayerCharacter*> pl;
        GetAllActorsInGame(pl);
        ASTExtraPlayerCharacter* lp = nullptr;
        for (auto p : pl) {
            if (p && p->PlayerKey == pc->PlayerKey) {
                lp = p;
                break;
            }
        }
        if (!lp) return;
        g_LocalPlayer = lp;
        g_PlayerController = pc;
        bool hasWeapon = HasWeaponEquipped();
        auto wm = lp->WeaponManagerComponent;
        if (wm && aim.silent) {
            auto slot = wm->GetCurrentUsingPropSlot();
            if ((int)slot.GetValue() >= 1 && (int)slot.GetValue() <= 3) {
                auto cw = (ASTExtraShootWeapon*)wm->CurrentWeaponReplicated;
                if (cw) {
                    if (cw->ShootWeaponComponent) {
                        auto sc = cw->ShootWeaponComponent;
                        auto vt = *(void***)sc;
                        if (vt && vt[174] != (void*)HookedShootEvent) {
                            orig_shoot_event = (decltype(orig_shoot_event))vt[174];
                            vt[174] = (void*)HookedShootEvent;
                        }
                    }
                    if (cw->IsA(ASTExtraWeapon::StaticClass())) {
                        auto vt2 = *(void***)cw;
                        if (vt2 && vt2[235] != (void*)HookedThrowGrenade) {
                            orig_throw_grenade = (decltype(orig_throw_grenade))vt2[235];
                            vt2[235] = (void*)HookedThrowGrenade;
                        }
                        if (vt2 && vt2[236] != (void*)HookedShootUnderbarrel) {
                            orig_shoot_underbarrel = (decltype(orig_shoot_underbarrel))vt2[236];
                            vt2[236] = (void*)HookedShootUnderbarrel;
                        }
                    }
                }
            }
        }
        if (vis.self_skeleton) DrawSkeleton(hud, lp, pc, s, FLinearColor(1, 1, 1, 0.5f));
        if (aim.grenade_warning) {
            std::vector<ASTExtraGrenadeBase*> gs;
            GetAllActorsInGame(gs);
            for (auto g : gs) {
                if (!g || g->bHidden || g->GetDistanceTo(lp) / 100.f > 15) continue;
                if (!g->HasBeenThrowedOut()) continue;
                FVector2D sp;
                if (s->ProjectWorldToScreen(pc, g->K2_GetActorLocation(), false, &sp)) {
                    int id = g->ItemDefineID.TypeSpecificID;
                    std::wstring nm = (id == 602002) ? L"smoke" : (id == 602003) ? L"fire" : (id == 602004 || id == 602005) ? L"nade" : L"grenade";
                    if (g->GetDistanceTo(lp) / 100.f < 10) {
                        tslFont->LegacyFontSize = 22;
                        DrawText(hud, ToFString(nm + L" near"), FVector2D(w / 2.f, h - 40.f), FLinearColor(1, 0, 0, 1), true);
                    }
                    tslFont->LegacyFontSize = 11;
                    DrawText(hud, ToFString(nm), FVector2D(sp.X, sp.Y - 18.f), FLinearColor(1, 1, 1, 1), true);
                    DrawFOVCircle(hud, (int)sp.X, (int)sp.Y, 12, FLinearColor(1, 0, 0, 0.6f));
                }
            }
        }
        enemyCount = 0;
        for (auto e : pl) {
            if (!e || (!vis.draw_bots && e->bEnsure) || e->PlayerKey == lp->PlayerKey || e->TeamID == lp->TeamID || e->bDead || e->bHidden) continue;
            enemyCount++;
            float dist = e->GetDistanceTo(lp) / 100.f;
            if (dist > 400 || !e->Mesh || !e->RootComponent) continue;
            bool visb = pc->LineOfSightTo(e, FVector(0, 0, 0), true);
            float hp = e->Health / e->HealthMax;
            FLinearColor hpCol = visb ? (hp > 0.6f ? FLinearColor(0, 1, 0, 1) : (hp > 0.3f ? FLinearColor(1, 1, 0, 1) : FLinearColor(1, 0, 0, 1))) : FLinearColor(1, 1, 1, 1);
            FVector head = e->GetBonePos("Head", FVector(0, 0, 0));
            FVector foot = e->GetBonePos("foot_l", FVector(0, 0, 0));
            head.Z += 10;
            FVector2D hs, fs;
            if (s->ProjectWorldToScreen(pc, head, false, &hs) && s->ProjectWorldToScreen(pc, foot, false, &fs)) {
                float bh = fabsf(hs.Y - fs.Y);
                if (bh < 1) continue;
                float bw = bh * 0.52f;
                float bx = hs.X - bw / 2.f;
                float by = hs.Y;
                FLinearColor skelCol = FLinearColor(vis.skeleton_color[0], vis.skeleton_color[1], vis.skeleton_color[2], vis.skeleton_color[3]);
                if (!visb) skelCol = FLinearColor(0.3f, 0.3f, 0.3f, 1);
                if (vis.skeleton) DrawSkeleton(hud, e, pc, s, skelCol);
                if (vis.health) {
                    float barW = 40, barH = 5;
                    DrawLine(hud, FVector2D(hs.X - barW / 2.f - 1.f, by - 12.f), FVector2D(hs.X + barW / 2.f + 1.f, by - 12.f), barH + 2, FLinearColor(0, 0, 0, 1));
                    if (hp > 0) DrawLine(hud, FVector2D(hs.X - barW / 2.f, by - 12.f), FVector2D(hs.X - barW / 2.f + barW * hp, by - 12.f), barH, hpCol);
                }
                if (vis.snapline) {
                    DrawLine(hud, FVector2D(w / 2.f, 135.f), FVector2D(hs.X, by - 20.f), vis.line_width, FLinearColor(vis.snapline_color[0], vis.snapline_color[1], vis.snapline_color[2], vis.snapline_color[3]));
                }
                if (vis.boxes) {
                    float lw = vis.line_width;
                    float bo = lw * 1.5f;
                    FLinearColor bc = FLinearColor(vis.box_color[0], vis.box_color[1], vis.box_color[2], vis.box_color[3]);
                    DrawLine(hud, FVector2D(bx - bo, by - bo), FVector2D(bx + bw + bo, by - bo), bo, FLinearColor(0, 0, 0, 1));
                    DrawLine(hud, FVector2D(bx - bo, by + bh + bo), FVector2D(bx + bw + bo, by + bh + bo), bo, FLinearColor(0, 0, 0, 1));
                    DrawLine(hud, FVector2D(bx - bo, by - bo), FVector2D(bx - bo, by + bh + bo), bo, FLinearColor(0, 0, 0, 1));
                    DrawLine(hud, FVector2D(bx + bw + bo, by - bo), FVector2D(bx + bw + bo, by + bh + bo), bo, FLinearColor(0, 0, 0, 1));
                    DrawLine(hud, FVector2D(bx, by), FVector2D(bx + bw, by), lw, bc);
                    DrawLine(hud, FVector2D(bx, by + bh), FVector2D(bx + bw, by + bh), lw, bc);
                    DrawLine(hud, FVector2D(bx, by), FVector2D(bx, by + bh), lw, bc);
                    DrawLine(hud, FVector2D(bx + bw, by), FVector2D(bx + bw, by + bh), lw, bc);
                    DrawLine(hud, FVector2D(bx + bo, by + bo), FVector2D(bx + bw - bo, by + bo), bo, FLinearColor(0, 0, 0, 1));
                    DrawLine(hud, FVector2D(bx + bo, by + bh - bo), FVector2D(bx + bw - bo, by + bh - bo), bo, FLinearColor(0, 0, 0, 1));
                    DrawLine(hud, FVector2D(bx + bo, by + bo), FVector2D(bx + bo, by + bh - bo), bo, FLinearColor(0, 0, 0, 1));
                    DrawLine(hud, FVector2D(bx + bw - bo, by + bo), FVector2D(bx + bw - bo, by + bh - bo), bo, FLinearColor(0, 0, 0, 1));
                }
                if (vis.names) {
                    tslFont->LegacyFontSize = 13;
                    std::wstring nm = e->bEnsure ? L"bot" : (e->PlayerName.IsValid() ? FStringToWString(e->PlayerName) : L"player");
                    DrawText(hud, ToFString(nm), FVector2D(hs.X, by + bh + 4.f), FLinearColor(1, 1, 1, 1), true);
                }
                if (vis.distance) {
                    tslFont->LegacyFontSize = 11;
                    DrawText(hud, ToFString(std::to_wstring((int)dist) + L"m"), FVector2D(hs.X, by + bh + 18.f), FLinearColor(1, 1, 1, 1), true);
                }
            }
            if (vis.indicators) {
                FVector ePos = e->K2_GetActorLocation();
                FVector lPos = lp->K2_GetActorLocation();
                FVector dir = ePos - lPos;
                float yaw = atan2f(dir.Y, dir.X);
                float a = yaw - pc->PlayerCameraManager->CameraCache.POV.Rotation.Yaw * 0.0174533f;
                float x = w / 2.f + vis.indicator_distance * sinf(a);
                float y = h / 2.f - vis.indicator_distance * cosf(a);
                float isz = vis.indicator_size;
                x = std::clamp(x, isz + 10.f, w - isz - 10.f);
                y = std::clamp(y, isz + 10.f, h - isz - 10.f);
                float angleToCenter = atan2f(y - h / 2.f, x - w / 2.f);
                DrawTriangleIndicatorCanvas(hud, x, y, isz, vis.indicator_width, angleToCenter, FLinearColor(vis.indicator_color[0], vis.indicator_color[1], vis.indicator_color[2], vis.indicator_color[3]), vis.indicator_fill);
                tslFont->LegacyFontSize = 12;
                DrawText(hud, ToFString(std::to_wstring((int)dist) + L"m"), FVector2D(x, y + isz + 4.f), FLinearColor(1, 1, 1, 1), true);
            }
        }
        tslFont->LegacyFontSize = 10;
        std::vector<ASTExtraGrenadeBase*> grens;
        GetAllActorsInGame(grens);
        for (auto g : grens) {
            if (!g || g->bHidden || g->GetDistanceTo(lp) / 100.f > lootEsp.max_distance || !g->HasBeenThrowedOut()) continue;
            FVector2D sp;
            if (!s->ProjectWorldToScreen(pc, g->K2_GetActorLocation(), false, &sp)) continue;
            int gid = g->ItemDefineID.TypeSpecificID;
            std::wstring gnm = (gid == 602002 || gid == 602009) ? L"smoke" : (gid == 602003 || gid == 602010) ? L"fire" : (gid == 602004 || gid == 602005 || gid == 602001) ? L"nade" : (gid == 602006) ? L"c4" : L"grenade";
            FLinearColor gcol = (gid == 602002 || gid == 602009) ? FLinearColor(1, 1, 0, 1) : FLinearColor(1, 0, 0, 1);
            DrawFOVCircle(hud, (int)sp.X, (int)sp.Y, 15, gcol);
            DrawText(hud, ToFString(gnm + L" " + std::to_wstring((int)(g->GetDistanceTo(lp) / 100.f)) + L"m"), FVector2D(sp.X, sp.Y + 18.f), FLinearColor(1, 1, 0.5f, 1), true);
        }
        if (itemEsp.vehicles) {
            std::vector<ASTExtraVehicleBase*> vehs;
            GetAllActorsInGame(vehs);
            for (auto v : vehs) {
                if (!v || v->bHidden || v->GetDistanceTo(lp) / 100.f > itemEsp.max_distance) continue;
                FVector2D sp;
                if (!s->ProjectWorldToScreen(pc, v->K2_GetActorLocation(), false, &sp)) continue;
                float vhp = UAIUtilsLibrary::GetVehicleHP(v);
                float vhpmax = UAIUtilsLibrary::GetVehicleHPMax(v);
                float hpRatio = (vhpmax > 0) ? (vhp / vhpmax) : 1.f;
                if (hpRatio < 0) hpRatio = 0;
                float barW = 40, barH = 5;
                DrawLine(hud, FVector2D(sp.X - barW / 2.f, sp.Y - 18.f), FVector2D(sp.X + barW / 2.f, sp.Y - 18.f), barH + 2, FLinearColor(0, 0, 0, 1));
                if (hpRatio > 0) DrawLine(hud, FVector2D(sp.X - barW / 2.f, sp.Y - 18.f), FVector2D(sp.X - barW / 2.f + barW * hpRatio, sp.Y - 18.f), barH, FLinearColor(0, 1, 0, 1));
                DrawText(hud, ToFString(std::to_wstring((int)(v->GetDistanceTo(lp) / 100.f)) + L"m"), FVector2D(sp.X, sp.Y - 11.f), FLinearColor(1, 1, 1, 1), true);
            }
        }
        if (itemEsp.metro_chests) {
            float msq = lootEsp.max_distance * 100.f;
            std::vector<APickUpListWrapperActor*> plw;
            GetAllActorsInGame(plw);
            for (auto a : plw) {
                if (!a || a->bHidden) continue;
                float dist = a->GetDistanceTo(lp);
                if (dist > msq) continue;
                FVector2D sp;
                if (!s->ProjectWorldToScreen(pc, a->K2_GetActorLocation(), false, &sp)) continue;
                float bh = 14, barW = 50, barH = 4;
                float ratio = fmaxf(0.f, 1.0f - (dist / msq));
                DrawLine(hud, FVector2D(sp.X - barW / 2.f, sp.Y + bh / 2.f + 6.f), FVector2D(sp.X + barW / 2.f, sp.Y + bh / 2.f + 6.f), barH + 2, FLinearColor(0, 0, 0, 1));
                if (ratio > 0) DrawLine(hud, FVector2D(sp.X - barW / 2.f, sp.Y + bh / 2.f + 6.f), FVector2D(sp.X - barW / 2.f + barW * ratio, sp.Y + bh / 2.f + 6.f), barH, FLinearColor(0, 0.7f, 1, 0.9f));
            }
        }
        if (lootEsp.enabled) {
            float msq = lootEsp.max_distance * 100.f;
            std::vector<APickUpWrapperActor*> ws;
            GetAllActorsInGame(ws);
            for (auto w : ws) {
                if (!w || w->bHidden) continue;
                float dist = w->GetDistanceTo(lp);
                if (dist > msq) continue;
                FVector2D sp;
                if (!s->ProjectWorldToScreen(pc, w->K2_GetActorLocation(), false, &sp)) continue;
                int id = w->DefineID.TypeSpecificID;
                if (id == 0 || (lootEsp.rare_only && id < 106001 && id < 203004)) continue;
                std::wstring nm = GetItemNameFromID(id);
                bool show = (lootEsp.weapons && id >= 101001 && id < 200000) ||
                            (lootEsp.attachments && id >= 201001 && id < 300000) ||
                            (lootEsp.ammo && id >= 301001 && id < 400000) ||
                            (lootEsp.health && id >= 601001 && id < 602000) ||
                            (lootEsp.backpacks && (id >= 501001 && id <= 501006)) ||
                            (lootEsp.helmets && id >= 502001 && id <= 502006)) ||
                            (lootEsp.vests && id >= 503001 && id <= 503006) ||
                            (lootEsp.metro_items && id >= 106001);
                if (show) {
                    tslFont->LegacyFontSize = 10;
                    DrawText(hud, ToFString(nm), sp, FLinearColor(1, 1, 1, 1), true);
                    if (vis.distance) DrawText(hud, ToFString(std::to_wstring((int)(dist / 100.f)) + L"m"), FVector2D(sp.X, sp.Y + 12.f), FLinearColor(1, 1, 1, 1), true);
                }
            }
        }
        tslFont->LegacyFontSize = 26;
        DrawText(hud, ToFString(std::to_wstring(enemyCount)), FVector2D(w / 2.f, 85.f), FLinearColor(1, 1, 1, 1), true);
        tslFont->LegacyFontSize = 13;
        if (aim.show_fov) DrawFOVCircle(hud, w / 2, h / 2, (int)aim.fov_size, FLinearColor(1, 1, 1, 0.3f));
        if (aim.silent_show_fov) DrawFOVCircle(hud, w / 2, h / 2, (int)aim.silent_fov, FLinearColor(1, 0, 0, 0.3f));
        if (aim.enabled && hasWeapon && g_LocalPlayer && g_PlayerController) {
            FRotator tr;
            ASTExtraPlayerCharacter* t = FindBestTarget(aim.fov_size, aim.max_distance, aim.target_bone, false, true, tr);
            if (t) {
                bool visb = g_PlayerController->LineOfSightTo(t, FVector(0, 0, 0), true);
                const char* bn = aim.target_bone == 0 ? "Head" : (aim.target_bone == 1 ? "neck_01" : (aim.target_bone == 2 ? "spine_03" : "pelvis"));
                FVector tp = t->GetBonePos(bn, FVector(0, 0, 0));
                FVector camPos = GetCameraLocation(g_PlayerController);
                if (aim.prediction) PredictTarget(tp, t, camPos);
                FRotator targetRot = UKismetMathLibrary::Conv_VectorToRotator(tp - camPos);
                NormalizeAngles(targetRot);
                FVector2D ts;
                if (visb && s->ProjectWorldToScreen(g_PlayerController, tp, false, &ts)) {
                    DrawLine(hud, FVector2D(w / 2.f, h / 2.f), ts, vis.line_width, FLinearColor(vis.snapline_color[0], vis.snapline_color[1], vis.snapline_color[2], vis.snapline_color[3]));
                }
                if (visb) {
                    FRotator camRot = g_PlayerController->PlayerCameraManager->CameraCache.POV.Rotation;
                    float pitchDiff = targetRot.Pitch - camRot.Pitch;
                    float yawDiff = targetRot.Yaw - camRot.Yaw;
                    while (yawDiff > 180) yawDiff -= 360;
                    while (yawDiff < -180) yawDiff += 360;
                    float sVal = fmaxf(aim.smooth, 1.0f);
                    g_LocalPlayer->AddControllerYawInput(yawDiff / sVal);
                    g_LocalPlayer->AddControllerPitchInput(pitchDiff / sVal);
                }
            }
        }
        if (aim.silent && g_LocalPlayer && g_PlayerController) {
            FRotator tr;
            ASTExtraPlayerCharacter* st = FindBestTarget(aim.silent_fov, aim.silent_distance, aim.silent_bone, aim.silent_vis_check, false, tr);
            if (st && g_PlayerController->LineOfSightTo(st, FVector(0, 0, 0), true)) {
                const char* bn = aim.silent_bone == 0 ? "Head" : (aim.silent_bone == 1 ? "neck_01" : (aim.silent_bone == 2 ? "spine_03" : "pelvis"));
                FVector tp = st->GetBonePos(bn, FVector(0, 0, 0));
                FVector2D ts;
                if (s->ProjectWorldToScreen(g_PlayerController, tp, false, &ts)) {
                    DrawLine(hud, FVector2D(w / 2.f, h / 2.f), ts, 1.f, FLinearColor(vis.silent_color[0], vis.silent_color[1], vis.silent_color[2], vis.silent_color[3]));
                }
            }
        }
    } @catch (...) {}
}

void HookedProcessEvent(UObject* o, UFunction* f, void* a) {
    @try {
        if (f && f->GetFullName().find(ENCRYPT("Function Engine.HUD.ReceiveDrawHUD")) != std::string::npos) {
            if (auto h = (AHUD*)o) {
                auto p = (AHUD_ReceiveDrawHUD_Params*)a;
                if (p) RenderESP(h, p->SizeX, p->SizeY);
            }
        }
        if (orig_process_event) orig_process_event(o, f, a);
    } @catch (...) {
        if (orig_process_event) orig_process_event(o, f, a);
    }
}

void InstallHooks() {
    @try {
        auto arr = (FUObjectArray*)GetGlobalObjectsOffset();
        auto objs = arr->ObjObjects;
        for (int i = 0; i < objs.Num(); i++) {
            @try {
                if (auto o = objs.GetByIndex(i); o && (o->IsA(AHUD::StaticClass()) || o->IsA(ASTExtraPlayerController::StaticClass()))) {
                    auto vt = *(void***)o;
                    if (vt && vt[76] != (void*)HookedProcessEvent) {
                        orig_process_event = (decltype(orig_process_event))vt[76];
                        vt[76] = (void*)HookedProcessEvent;
                    }
                }
            } @catch (...) {}
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(300 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            InstallHooks();
        });
    } @catch (...) {}
}

@implementation ImGuiDrawView

+ (void)load {
    LoadSettings();
    FName::GNames = GetGlobalNames();
    while (!FName::GNames) {
        FName::GNames = GetGlobalNames();
        usleep(100000);
    }
    UObject::GUObjectArray = (FUObjectArray*)GetGlobalObjectsOffset();
    while (!UObject::GUObjectArray) {
        UObject::GUObjectArray = (FUObjectArray*)GetGlobalObjectsOffset();
        usleep(100000);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        InstallHooks();
    });
}

+ (void)showChange:(BOOL)o { menu_open = o; }
+ (BOOL)isMenuShowing { return menu_open; }

- (instancetype)init {
    self = [super init];
    if (self) {
        _device = MTLCreateSystemDefaultDevice();
        _commandQueue = [_device newCommandQueue];
        IMGUI_CHECKVERSION();
        ImGui::CreateContext();
        ImGuiIO& io = ImGui::GetIO();
        if (sizeof(museo500_binary) > 1) io.Fonts->AddFontFromMemoryTTF(museo500_binary, sizeof(museo500_binary), 14);
        static const ImWchar icon_ranges[] = { ICON_MIN_FA, ICON_MAX_FA, 0 };
        ImFontConfig icons_config;
        icons_config.MergeMode = true;
        icons_config.PixelSnapH = true;
        if (sizeof(font_awesome_binary) > 1) io.Fonts->AddFontFromMemoryTTF(&font_awesome_binary, sizeof(font_awesome_binary), 13, &icons_config, icon_ranges);
        if (sizeof(museo900_binary) > 1) io.Fonts->AddFontFromMemoryTTF(museo900_binary, sizeof(museo900_binary), 28);
        ImGui::StyleColorsDark();
        ImGui::GetStyle().ScaleAllSizes(0.85f);
        ImGui_ImplMetal_Init(_device);
    }
    return self;
}

- (void)loadView {
    self.view = [[MTKView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mtkView = (MTKView*)self.view;
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor clearColor];
}

- (void)updateIOWithTouchEvent:(UIEvent*)e {
    UITouch* t = e.allTouches.anyObject;
    CGPoint p = [t locationInView:self.view];
    ImGuiIO& io = ImGui::GetIO();
    io.MousePos = ImVec2(p.x, p.y);
    BOOL act = NO;
    for (UITouch* touch in e.allTouches) {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            act = YES;
            break;
        }
    }
    io.MouseDown[0] = act;
}

- (void)touchesBegan:(NSSet<UITouch*>*)t withEvent:(UIEvent*)e { [self updateIOWithTouchEvent:e]; }
- (void)touchesMoved:(NSSet<UITouch*>*)t withEvent:(UIEvent*)e { [self updateIOWithTouchEvent:e]; }
- (void)touchesCancelled:(NSSet<UITouch*>*)t withEvent:(UIEvent*)e { [self updateIOWithTouchEvent:e]; }
- (void)touchesEnded:(NSSet<UITouch*>*)t withEvent:(UIEvent*)e { [self updateIOWithTouchEvent:e]; }

- (void)drawInMTKView:(MTKView*)view {
    @try {
        ImGuiIO& io = ImGui::GetIO();
        io.DisplaySize.x = view.bounds.size.width;
        io.DisplaySize.y = view.bounds.size.height;
        io.DisplayFramebufferScale = ImVec2(view.window.screen.nativeScale, view.window.screen.nativeScale);
        io.DeltaTime = 1.0f / 60.0f;
        [self.view setUserInteractionEnabled:menu_open];
        id<MTLCommandBuffer> cb = [self.commandQueue commandBuffer];
        MTLRenderPassDescriptor* rpd = view.currentRenderPassDescriptor;
        if (rpd) {
            id<MTLRenderCommandEncoder> re = [cb renderCommandEncoderWithDescriptor:rpd];
            [re pushDebugGroup:@"ImGui"];
            ImGui_ImplMetal_NewFrame(rpd);
            ImGui::NewFrame();
            if (menu_open) {
                PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(0, 0));
                ImGui::Begin(ENCRYPT("SILENTICUM"), NULL, ImGuiWindowFlags_NoDecoration | ImGuiWindowFlags_NoBackground);
                auto window = GetCurrentWindow();
                auto draw = window->DrawList;
                auto pos = window->Pos;
                auto size = window->Size;
                gui.m_anim = ImLerp(gui.m_anim, 1.f, 0.045f);
                SetWindowSize(ImVec2(690, 500));

                ImFont* titleFont = (io.Fonts->Fonts.Size > 1) ? io.Fonts->Fonts[1] : io.Fonts->Fonts[0];
                ImVec2 titlePos1 = pos + ImVec2(170 / 2.f - titleFont->CalcTextSizeA(titleFont->FontSize, FLT_MAX, 0, ENCRYPT("SILENTICUM")).x / 2.f + 1.f, 20.f);
                ImVec2 titlePos2 = pos + ImVec2(170 / 2.f - titleFont->CalcTextSizeA(titleFont->FontSize, FLT_MAX, 0, ENCRYPT("SILENTICUM")).x / 2.f, 20.f);
                draw->AddText(titleFont, titleFont->FontSize, titlePos1, gui.accent_color.to_im_color(), ENCRYPT("SILENTICUM"));
                draw->AddText(titleFont, titleFont->FontSize, titlePos2, GetColorU32(ImGuiCol_Text), ENCRYPT("SILENTICUM"));

                draw->AddLine(pos + ImVec2(0, size.y - 50), pos + ImVec2(170, size.y - 50), GetColorU32(ImGuiCol_WindowBg, 0.5f));
                draw->AddText(pos + ImVec2(50, size.y - 40), gui.text.to_im_color(), ENCRYPT("@shiedLess"));
                draw->AddText(pos + ImVec2(50, size.y - 25), gui.text_disabled.to_im_color(), ENCRYPT("Till:"));
                draw->AddText(pos + ImVec2(50 + CalcTextSize(ENCRYPT("Till: ")).x, size.y - 25), gui.accent_color.to_im_color(), ENCRYPT("mywings"));

                SetCursorPos(ImVec2(10, 70));
                BeginChild("##tabs", ImVec2(150, size.y - 120));
                gui.group_title(ENCRYPT("Aimbot"));
                if (gui.tab(ICON_FA_CROSSHAIRS, ENCRYPT("Aim Bot"), gui.m_tab == 0) && gui.m_tab != 0) gui.m_tab = 0;
                if (gui.tab(ICON_FA_GHOST, ENCRYPT("Advanced"), gui.m_tab == 1) && gui.m_tab != 1) gui.m_tab = 1;
                if (gui.tab(ICON_FA_MOUSE, ENCRYPT("Legit Bot"), gui.m_tab == 2) && gui.m_tab != 2) gui.m_tab = 2;
                Spacing(), Spacing(), Spacing();
                gui.group_title(ENCRYPT("Visuals"));
                if (gui.tab(ICON_FA_USER, ENCRYPT("Players"), gui.m_tab == 3) && gui.m_tab != 3) gui.m_tab = 3;
                if (gui.tab(ICON_FA_PALLET, ENCRYPT("World"), gui.m_tab == 4) && gui.m_tab != 4) gui.m_tab = 4;
                Spacing(), Spacing(), Spacing();
                gui.group_title(ENCRYPT("Miscellaneous"));
                if (gui.tab(ICON_FA_HAMMER, ENCRYPT("Main"), gui.m_tab == 5) && gui.m_tab != 5) gui.m_tab = 5;
                if (gui.tab(ICON_FA_CODE, ENCRYPT("Scripts"), gui.m_tab == 6) && gui.m_tab != 6) gui.m_tab = 6;
                EndChild();

                SetCursorPos(ImVec2(190, 20));
                Button(ICON_FA_SAVE " Save", ImVec2(95, 25));
                SetCursorPos(ImVec2(620, 20));
                PushStyleColor(ImGuiCol_Button, ImVec4(0, 0, 0, 0));
                PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0, 0, 0, 0));
                PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0, 0, 0, 0));
                Button(ICON_FA_SEARCH, ImVec2(25, 25));
                SameLine();
                SetCursorPos(ImVec2(650, 20));
                Button(ICON_FA_COG, ImVec2(25, 25));
                PopStyleColor(3);

                PushStyleVar(ImGuiStyleVar_ItemSpacing, ImVec2(8, 8));
                SetCursorPos(ImVec2(185, 81 - (5 * gui.m_anim)));
                float childHeight = size.y - 110;
                BeginChild("##childs", ImVec2(size.x - 200, childHeight), false, ImGuiWindowFlags_NoScrollbar);
                float groupWidth = GetWindowWidth() / 2.f - GetStyle().ItemSpacing.x / 2.f;
                float fullHeight = GetWindowHeight();
                float halfHeight = GetWindowHeight() / 2.f - 10.f;
                float smallHeight = GetWindowHeight() * 0.7f;

                switch (gui.m_tab) {
                    case 0:
                        gui.group_box(ENCRYPT("Aim Bot"), ImVec2(groupWidth, halfHeight)); {
                            ImGui::Checkbox(ENCRYPT("enable aimbot"), &aim.enabled);
                            ImGui::Checkbox(ENCRYPT("show fov"), &aim.show_fov);
                            ImGui::SliderFloat(ENCRYPT("fov size"), &aim.fov_size, 0, 500, "%.0f");
                            ImGui::SliderFloat(ENCRYPT("distance"), &aim.max_distance, 0, 400, "%.0f");
                        }
                        gui.end_group_box();
                        SameLine();
                        gui.group_box(ENCRYPT("Smooth"), ImVec2(groupWidth, halfHeight)); {
                            ImGui::SliderFloat(ENCRYPT("smooth"), &aim.smooth, 1, 10, "%.1f");
                            ImGui::Checkbox(ENCRYPT("prediction"), &aim.prediction);
                            const char* b[] = { ENCRYPT("head"), ENCRYPT("neck"), ENCRYPT("chest"), ENCRYPT("pelvis") };
                            ImGui::Combo(ENCRYPT("bone"), &aim.target_bone, b, 4);
                        }
                        gui.end_group_box();
                        gui.group_box(ENCRYPT("Trigger"), ImVec2(groupWidth, halfHeight)); {
                            const char* m[] = { ENCRYPT("always"), ENCRYPT("on fire"), ENCRYPT("on ads"), ENCRYPT("both") };
                            ImGui::Combo(ENCRYPT("trigger"), &aim.trigger_mode, m, 4);
                        }
                        gui.end_group_box();
                        SameLine();
                        gui.group_box(ENCRYPT("Silent"), ImVec2(groupWidth, halfHeight)); {
                            ImGui::Checkbox(ENCRYPT("enable silent"), &aim.silent);
                            ImGui::Checkbox(ENCRYPT("show silent fov"), &aim.silent_show_fov);
                            ImGui::SliderFloat(ENCRYPT("fov"), &aim.silent_fov, 0, 500, "%.0f");
                            ImGui::SliderFloat(ENCRYPT("distance"), &aim.silent_distance, 0, 400, "%.0f");
                            ImGui::Checkbox(ENCRYPT("visible check"), &aim.silent_vis_check);
                        }
                        gui.end_group_box();
                        break;
                    case 1:
                        gui.group_box(ENCRYPT("Protection"), ImVec2(groupWidth, smallHeight)); {
                            ImGui::Checkbox(ENCRYPT("grenade warning"), &aim.grenade_warning);
                            ImGui::Checkbox(ENCRYPT("vehicle aim"), &aim.vehicle_aim);
                            ImGui::Checkbox(ENCRYPT("closest priority"), &aim.closest_priority);
                        }
                        gui.end_group_box();
                        SameLine();
                        gui.group_box(ENCRYPT("Colors"), ImVec2(groupWidth, smallHeight)); {
                            ImGui::ColorEdit4(ENCRYPT("box"), vis.box_color, ALPHA);
                            ImGui::ColorEdit4(ENCRYPT("skel"), vis.skeleton_color, ALPHA);
                            ImGui::ColorEdit4(ENCRYPT("line"), vis.snapline_color, ALPHA);
                            ImGui::ColorEdit4(ENCRYPT("ind"), vis.indicator_color, ALPHA);
                            ImGui::ColorEdit4(ENCRYPT("silent"), vis.silent_color, ALPHA);
                        }
                        gui.end_group_box();
                        break;
                    case 2:
                        gui.group_box(ENCRYPT("Legit Bot"), ImVec2(groupWidth, halfHeight)); {
                            ImGui::SliderFloat(ENCRYPT("aim smooth"), &aim.smooth, 1, 10, "%.1f");
                            ImGui::SliderFloat(ENCRYPT("aim fov"), &aim.fov_size, 0, 500, "%.0f");
                        }
                        gui.end_group_box();
                        SameLine();
                        gui.group_box(ENCRYPT("Settings"), ImVec2(groupWidth, halfHeight)); {
                            const char* lb[] = { ENCRYPT("head"), ENCRYPT("neck"), ENCRYPT("chest"), ENCRYPT("pelvis") };
                            ImGui::Combo(ENCRYPT("aim bone"), &aim.target_bone, lb, 4);
                        }
                        gui.end_group_box();
                        break;
                    case 3:
                        gui.group_box(ENCRYPT("Player ESP"), ImVec2(groupWidth, halfHeight)); {
                            ImGui::Checkbox(ENCRYPT("box"), &vis.boxes);
                            ImGui::Checkbox(ENCRYPT("health"), &vis.health);
                            ImGui::Checkbox(ENCRYPT("skeleton"), &vis.skeleton);
                            ImGui::Checkbox(ENCRYPT("name"), &vis.names);
                            ImGui::Checkbox(ENCRYPT("distance"), &vis.distance);
                            ImGui::Checkbox(ENCRYPT("snapline"), &vis.snapline);
                        }
                        gui.end_group_box();
                        SameLine();
                        gui.group_box(ENCRYPT("Indicators"), ImVec2(groupWidth, halfHeight)); {
                            ImGui::Checkbox(ENCRYPT("indicators"), &vis.indicators);
                            if (vis.indicators) {
                                ImGui::Checkbox(ENCRYPT("fill"), &vis.indicator_fill);
                                ImGui::SliderFloat(ENCRYPT("size"), &vis.indicator_size, 5, 60, "%.0f");
                                ImGui::SliderFloat(ENCRYPT("width"), &vis.indicator_width, 10, 100, "%.0f");
                                ImGui::SliderFloat(ENCRYPT("dist"), &vis.indicator_distance, 50, 400, "%.0f");
                            }
                        }
                        gui.end_group_box();
                        gui.group_box(ENCRYPT("Other ESP"), ImVec2(groupWidth, halfHeight)); {
                            ImGui::Checkbox(ENCRYPT("self skeleton"), &vis.self_skeleton);
                            ImGui::Checkbox(ENCRYPT("draw bots"), &vis.draw_bots);
                        }
                        gui.end_group_box();
                        break;
                    case 4:
                        gui.group_box(ENCRYPT("Vehicles"), ImVec2(groupWidth, halfHeight)); {
                            ImGui::Checkbox(ENCRYPT("vehicles"), &itemEsp.vehicles);
                            ImGui::Checkbox(ENCRYPT("loot boxes"), &itemEsp.metro_chests);
                            ImGui::SliderFloat(ENCRYPT("max distance"), &itemEsp.max_distance, 50, 300, "%.0f");
                        }
                        gui.end_group_box();
                        SameLine();
                        gui.group_box(ENCRYPT("Loot"), ImVec2(groupWidth, halfHeight)); {
                            ImGui::Checkbox(ENCRYPT("enable loot"), &lootEsp.enabled);
                            ImGui::Checkbox(ENCRYPT("weapons"), &lootEsp.weapons);
                            ImGui::Checkbox(ENCRYPT("attachments"), &lootEsp.attachments);
                            ImGui::Checkbox(ENCRYPT("scopes"), &lootEsp.scopes);
                        }
                        gui.end_group_box();
                        gui.group_box(ENCRYPT("Items"), ImVec2(groupWidth, halfHeight)); {
                            ImGui::Checkbox(ENCRYPT("ammo"), &lootEsp.ammo);
                            ImGui::Checkbox(ENCRYPT("meds"), &lootEsp.health);
                            ImGui::Checkbox(ENCRYPT("backpacks"), &lootEsp.backpacks);
                            ImGui::Checkbox(ENCRYPT("helmets"), &lootEsp.helmets);
                            ImGui::Checkbox(ENCRYPT("vests"), &lootEsp.vests);
                        }
                        gui.end_group_box();
                        SameLine();
                        gui.group_box(ENCRYPT("Metro"), ImVec2(groupWidth, halfHeight)); {
                            ImGui::Checkbox(ENCRYPT("metro items"), &lootEsp.metro_items);
                            ImGui::Checkbox(ENCRYPT("rare only"), &lootEsp.rare_only);
                            ImGui::SliderFloat(ENCRYPT("loot distance"), &lootEsp.max_distance, 50, 200, "%.0f");
                        }
                        gui.end_group_box();
                        break;
                    case 5:
                        gui.group_box(ENCRYPT("Main"), ImVec2(groupWidth, fullHeight)); {}
                        gui.end_group_box();
                        SameLine();
                        gui.group_box(ENCRYPT("Info"), ImVec2(groupWidth, fullHeight)); {}
                        gui.end_group_box();
                        break;
                    case 6:
                        gui.group_box(ENCRYPT("Scripts"), ImVec2(groupWidth, fullHeight)); {
                            if (ImGui::Button(ENCRYPT("reset guest"), ImVec2(groupWidth - 30, 55))) {
                                ImGui::OpenPopup("Wait Message");
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    ImGui::CloseCurrentPopup();
                                });
                            }
                            if (ImGui::BeginPopupModal("Wait Message", NULL, ImGuiWindowFlags_AlwaysAutoResize)) {
                                ImGui::Text("Guest account 5 seconds");
                                ImGui::EndPopup();
                                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                                NSString *documentsDirectory = [paths objectAtIndex:0];
                                NSString *preferencesDirectory = [documentsDirectory stringByAppendingPathComponent:@"Preferences"];
                                NSFileManager *fileManager = [NSFileManager defaultManager];
                                NSError *error = nil;
                                if (![fileManager fileExistsAtPath:preferencesDirectory]) {
                                    [fileManager createDirectoryAtPath:preferencesDirectory withIntermediateDirectories:NO attributes:nil error:&error];
                                }
                                NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
                                NSUUID *uuid = [NSUUID UUID];
                                NSString *uuidString = [uuid UUIDString];
                                NSString *plistPath = [preferencesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", bundleIdentifier]];
                                NSString *loginResultPath = [preferencesDirectory stringByAppendingPathComponent:@"loginResult.plist"];
                                [fileManager removeItemAtPath:plistPath error:nil];
                                [fileManager removeItemAtPath:loginResultPath error:nil];
                                NSMutableDictionary *preferencesDict = [[NSMutableDictionary alloc] init];
                                [preferencesDict setObject:uuidString forKey:@"com.tencent.imsdk.gid.1320"];
                                NSString *UDIDss = [NSString stringWithFormat:@"{%@}", uuidString];
                                [preferencesDict setObject:UDIDss forKey:@"Engine/Privacy/AnonymousID"];
                                [preferencesDict setObject:uuidString forKey:@"kLinkSessionUUID"];
                                [preferencesDict setObject:uuidString forKey:@"kUniqueSessionUUID"];
                                NSString *filePath = [preferencesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", bundleIdentifier]];
                                [preferencesDict writeToFile:filePath atomically:YES];
                            }
                        }
                        gui.end_group_box();
                        SameLine();
                        gui.group_box(ENCRYPT("Config"), ImVec2(groupWidth, fullHeight)); {}
                        gui.end_group_box();
                        break;
                }
                EndChild();
                PopStyleVar(1);
                ImGui::End();
                PopStyleVar();
                SaveSettings();
            }
            ImGui::Render();
            ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), cb, re);
            [re popDebugGroup];
            [re endEncoding];
            [cb presentDrawable:view.currentDrawable];
        }
        [cb commit];
    } @catch (...) {}
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size {}

@end
