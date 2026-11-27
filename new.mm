#define IMGUI_DEFINE_MATH_OPERATORS
#define LocalPlayer g_LocalPlayer

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <objc/message.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <unistd.h>

#include <algorithm>
#include <cmath>
#include <cfloat>
#include <vector>
#include <string>
#include <map>

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

#ifndef STR
#define STR(str) (str)
#endif

using namespace ImGui;
using namespace SDK;

#define ALPHA (ImGuiColorEditFlags_NoTooltip|ImGuiColorEditFlags_NoInputs|ImGuiColorEditFlags_NoLabel|ImGuiColorEditFlags_AlphaBar|ImGuiColorEditFlags_InputRGB|ImGuiColorEditFlags_Float|ImGuiColorEditFlags_NoDragDrop|ImGuiColorEditFlags_PickerHueBar|ImGuiColorEditFlags_NoBorder)
#define NO_ALPHA (ImGuiColorEditFlags_NoTooltip|ImGuiColorEditFlags_NoInputs|ImGuiColorEditFlags_NoLabel|ImGuiColorEditFlags_NoAlpha|ImGuiColorEditFlags_InputRGB|ImGuiColorEditFlags_Float|ImGuiColorEditFlags_NoDragDrop|ImGuiColorEditFlags_PickerHueBar|ImGuiColorEditFlags_NoBorder)

extern bool IsLogin;
extern bool MenDeal;

struct AimConfig {
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

struct VisConfig {
    bool boxes = false;
    bool health = false;
    bool skeleton = false;
    bool names = false;
    bool distance = false;
    bool snapline = false;
    bool indicators = false;
    bool indicator_fill = false;
    float indicator_size = 20.f;
    float indicator_width = 50.f;
    float indicator_distance = 180.f;
    bool self_skeleton = false;
    bool draw_bots = false;
    float line_width = 1.5f;
    float box_color[4] = {1.f, 1.f, 1.f, 1.f};
    float skeleton_color[4] = {1.f, 1.f, 1.f, 1.f};
    float snapline_color[4] = {1.f, 1.f, 1.f, 1.f};
    float indicator_color[4] = {1.f, 1.f, 1.f, 1.f};
    float silent_color[4] = {1.f, 0.f, 0.f, 1.f};
};

struct ItemEspConfig {
    bool vehicles = false;
    bool metro_chests = false;
    bool snow = false;
    float max_distance = 200.f;
};

struct LootEspConfig {
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

static AimConfig aim;
static VisConfig vis;
static ItemEspConfig itemEsp;
static LootEspConfig lootEsp;

static ASTExtraPlayerCharacter* g_LocalPlayer = nullptr;
static ASTExtraPlayerController* g_PlayerController = nullptr;
static UFont* tslFont = nullptr;
static int enemyCount = 0;
static bool menu_open = false;

static void (*orig_shoot_event)(USTExtraShootWeaponComponent*, FVector, FRotator, ASTExtraShootWeapon*, int) = nullptr;
static void (*orig_throw_grenade)(ASTExtraWeapon*, FVector, FRotator) = nullptr;
static void (*orig_shoot_underbarrel)(ASTExtraWeapon*, FVector, FRotator) = nullptr;
static void (*orig_process_event)(UObject*, UFunction*, void*) = nullptr;

static inline bool IsValidPtr(const void* p) {
    uintptr_t addr = (uintptr_t)p;
    return addr >= 0x100000000ULL && addr < 0x2000000000ULL;
}

static inline FString MakeFString(const wchar_t* ws) {
    return FString(ws ? ws : L"");
}

static inline FString MakeFString(const std::wstring& ws) {
    return FString(ws.c_str());
}

static std::wstring FStringToWStringSafe(const FString& fs) {
    @try {
        int32_t n = fs.Num();
        const wchar_t* ptr = fs.GetData();
        if (n > 0 && n < 128 && IsValidPtr(ptr)) {
            return std::wstring(ptr, (size_t)n - (ptr[n - 1] == L'\0' ? 1 : 0));
        }
    } @catch (...) {}
    return L"player";
}

static uint64_t getBaseAddress(const char* n) {
    for (int i = 0; i < (int)_dyld_image_count(); i++) {
        const char* name = _dyld_get_image_name(i);
        if (name && strstr(name, n)) {
            return (uint64_t)_dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

static uint64_t getRealOffset(uint64_t o) {
    uint64_t slide = getBaseAddress(ENCRYPT("ShadowTrackerExtra"));
    return slide ? (slide + o) : 0;
}

static FUObjectArray* ResolveGUObjectArray(void) {
    @try {
        uint64_t symAddr = getRealOffset(0x10A7F93E0);
        if (!IsValidPtr((const void*)symAddr)) return nullptr;
        FUObjectArray* direct = (FUObjectArray*)symAddr;
        if (IsValidPtr(direct) && direct->ObjObjects.Num() > 0 && direct->ObjObjects.Num() < 5000000) {
            return direct;
        }
        FUObjectArray* deref = *(FUObjectArray**)symAddr;
        if (IsValidPtr(deref) && deref->ObjObjects.Num() > 0 && deref->ObjObjects.Num() < 5000000) {
            return deref;
        }
    } @catch (...) {}
    return nullptr;
}

static TNameEntryArray* GetGlobalNames(void) {
    @try {
        uint64_t fnAddr = getRealOffset(0x105014128);
        if (!IsValidPtr((const void*)fnAddr)) return nullptr;
        return ((TNameEntryArray*(*)())fnAddr)();
    } @catch (...) {
        return nullptr;
    }
}

static UWorld* GEWorld = nullptr;
static int GWorldNum = 0;

static UWorld* GetFullWorld(void) {
    @try {
        if (!IsValidPtr(UObject::GUObjectArray)) return nullptr;
        auto& objs = UObject::GUObjectArray->ObjObjects;
        int total = objs.Num();
        if (total <= 0 || total > 5000000) return nullptr;

        if (GWorldNum > 0 && GWorldNum < total) {
            @try {
                auto e = (UEngine*)objs.GetByIndex(GWorldNum);
                if (IsValidPtr(e)) {
                    if (!tslFont && IsValidPtr(e->MediumFont)) tslFont = e->MediumFont;
                    auto v = e->GameViewport;
                    if (IsValidPtr(v) && IsValidPtr(v->World)) {
                        GEWorld = v->World;
                        return v->World;
                    }
                }
            } @catch (...) {
                GWorldNum = 0;
            }
        }

        for (int i = 0; i < total; i++) {
            @try {
                auto o = objs.GetByIndex(i);
                if (IsValidPtr(o) && o->IsA(UEngine::StaticClass())) {
                    auto e = (UEngine*)o;
                    if (IsValidPtr(e->GameViewport)) {
                        if (IsValidPtr(e->MediumFont)) tslFont = e->MediumFont;
                        auto v = e->GameViewport;
                        if (IsValidPtr(v->World)) {
                            GEWorld = v->World;
                            GWorldNum = i;
                            return v->World;
                        }
                    }
                }
            } @catch (...) {}
        }
    } @catch (...) {}
    return nullptr;
}

template<class T>
static void GetAllActorsInGame(std::vector<T*>& a) {
    @try {
        auto w = GetFullWorld();
        if (!IsValidPtr(w)) return;
        auto s = (UGameplayStatics*)UGameplayStatics::StaticClass();
        if (!IsValidPtr(s)) return;
        TArray<AActor*> arr;
        s->GetAllActorsOfClass((UObject*)w, T::StaticClass(), &arr);
        int n = arr.Num();
        if (n <= 0 || n > 20000) return;
        for (int i = 0; i < n; i++) {
            @try {
                if (IsValidPtr(arr[i])) a.push_back((T*)arr[i]);
            } @catch (...) {}
        }
    } @catch (...) {}
}

static float FVectorSize(const FVector& v) {
    return sqrtf(v.X * v.X + v.Y * v.Y + v.Z * v.Z);
}

static void NormalizeAngles(FRotator& a) {
    while (a.Pitch > 180) a.Pitch -= 360;
    while (a.Pitch < -180) a.Pitch += 360;
    if (a.Pitch > 89) a.Pitch = 89;
    if (a.Pitch < -89) a.Pitch = -89;
    while (a.Yaw > 180) a.Yaw -= 360;
    while (a.Yaw < -180) a.Yaw += 360;
    a.Roll = 0;
}

static FVector GetCameraLocation(ASTExtraPlayerController* pc) {
    @try {
        if (IsValidPtr(pc) && IsValidPtr(pc->PlayerCameraManager)) {
            return pc->PlayerCameraManager->CameraCache.POV.Location;
        }
    } @catch (...) {}
    return FVector();
}

static FRotator GetCameraRotation(ASTExtraPlayerController* pc) {
    @try {
        if (IsValidPtr(pc) && IsValidPtr(pc->PlayerCameraManager)) {
            return pc->PlayerCameraManager->CameraCache.POV.Rotation;
        }
    } @catch (...) {}
    return FRotator();
}

static void DrawLine(AHUD* h, FVector2D a, FVector2D b, float t, FLinearColor c) {
    @try {
        if (IsValidPtr(h) && IsValidPtr(h->Canvas)) h->Canvas->K2_DrawLine(a, b, t, c);
    } @catch (...) {}
}

static void DrawTriangleIndicatorCanvas(AHUD* h, float cx, float cy, float hgt, float wd, float angle, FLinearColor col, bool fill) {
    @try {
        if (!IsValidPtr(h) || !IsValidPtr(h->Canvas)) return;
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

static void DrawFOVCircle(AHUD* h, int x, int y, int r, FLinearColor c) {
    if (!IsValidPtr(h) || !IsValidPtr(h->Canvas)) return;
    float s = (float)(M_PI * 2.0 / 32.0);
    for (float a = 0; a < (float)(M_PI * 2.0); a += s) {
        h->Canvas->K2_DrawLine(
            FVector2D(r * cosf(a) + x, r * sinf(a) + y),
            FVector2D(r * cosf(a + s) + x, r * sinf(a + s) + y),
            1.f, c);
    }
}

static void DrawText(AHUD* h, FString t, FVector2D p, FLinearColor c, bool cx) {
    @try {
        if (IsValidPtr(h) && IsValidPtr(h->Canvas) && IsValidPtr(tslFont)) {
            h->Canvas->K2_DrawText(tslFont, t, p, c, 1.f, FLinearColor(0, 0, 0, 0), FVector2D(0, 0), cx, false, false, FLinearColor(0, 0, 0, 0));
        }
    } @catch (...) {}
}

static void DrawSkeleton(AHUD* h, ASTExtraPlayerCharacter* pl, ASTExtraPlayerController* pc, UGameplayStatics* s, FLinearColor c) {
    @try {
        if (!IsValidPtr(pl) || !IsValidPtr(pl->Mesh) || !IsValidPtr(s) || !IsValidPtr(pc)) return;
        const char* n[] = {"Head", "neck_01", "spine_03", "spine_02", "spine_01", "pelvis", "upperarm_r", "lowerarm_r", "hand_r", "upperarm_l", "lowerarm_l", "hand_l", "thigh_r", "calf_r", "foot_r", "thigh_l", "calf_l", "foot_l"};
        FVector2D p[18];
        bool ok[18] = {};
        for (int i = 0; i < 18; i++) {
            FVector w = pl->GetBonePos(n[i], FVector(0, 0, 0));
            if (s->ProjectWorldToScreen(pc, w, false, &p[i])) ok[i] = true;
        }
        int conn[17][2] = {{0, 1}, {1, 2}, {2, 3}, {3, 4}, {4, 5}, {1, 6}, {6, 7}, {7, 8}, {1, 9}, {9, 10}, {10, 11}, {5, 12}, {12, 13}, {13, 14}, {5, 15}, {15, 16}, {16, 17}};
        for (auto& pr : conn) {
            if (ok[pr[0]] && ok[pr[1]]) DrawLine(h, p[pr[0]], p[pr[1]], vis.line_width, c);
        }
    } @catch (...) {}
}

static ASTExtraPlayerCharacter* FindBestTarget(float fov, float maxD, int bone, bool checkVis, bool closestFirst, FRotator& outRot) {
    @try {
        if (!IsValidPtr(g_LocalPlayer) || !IsValidPtr(g_PlayerController) || !IsValidPtr(g_PlayerController->PlayerCameraManager)) return nullptr;
        std::vector<ASTExtraPlayerCharacter*> p;
        GetAllActorsInGame(p);
        ASTExtraPlayerCharacter* best = nullptr;
        float bestVal = FLT_MAX;
        FVector camLoc = GetCameraLocation(g_PlayerController);
        FRotator camRot = GetCameraRotation(g_PlayerController);
        for (auto e : p) {
            if (!IsValidPtr(e) || !IsValidPtr(e->RootComponent) || e->GetCurrentVehicle() || e->PlayerKey == g_LocalPlayer->PlayerKey || e->TeamID == g_LocalPlayer->TeamID || e->bDead || e->bHidden) continue;
            if (!vis.draw_bots && e->bEnsure) continue;
            float dist = e->GetDistanceTo(g_LocalPlayer) / 100.f;
            if (dist > maxD) continue;
            const char* bn = bone == 0 ? "Head" : (bone == 1 ? "neck_01" : (bone == 2 ? "spine_03" : "pelvis"));
            FVector bp = e->GetBonePos(bn, FVector(0, 0, 0));
            if (checkVis && !g_PlayerController->LineOfSightTo(e, bp, true)) continue;
            FVector dir = bp - camLoc;
            FRotator tr = UKismetMathLibrary::Conv_VectorToRotator(dir);
            NormalizeAngles(tr);
            float da = sqrtf(powf(tr.Pitch - camRot.Pitch, 2) + powf(tr.Yaw - camRot.Yaw, 2));
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

static float GetBulletSpeed(void) {
    @try {
        if (!IsValidPtr(g_LocalPlayer)) return 800;
        float bs = 800;
        auto wm = g_LocalPlayer->WeaponManagerComponent;
        if (IsValidPtr(wm)) {
            auto cw = (ASTExtraShootWeapon*)wm->CurrentWeaponReplicated;
            if (IsValidPtr(cw) && IsValidPtr(cw->ShootWeaponEntityComp)) {
                bs = cw->ShootWeaponEntityComp->BulletFireSpeed;
            }
        }
        return bs > 1.f ? bs : 800;
    } @catch (...) {
        return 800;
    }
}

static void PredictTarget(FVector& tp, ASTExtraPlayerCharacter* t, FVector origin) {
    @try {
        if (!IsValidPtr(t)) return;
        FVector vel = t->GetVelocity();
        ASTExtraVehicleBase* v = t->GetCurrentVehicle();
        if (IsValidPtr(v)) {
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

static bool HasWeaponEquipped(void) {
    @try {
        if (!IsValidPtr(g_LocalPlayer)) return false;
        auto wm = g_LocalPlayer->WeaponManagerComponent;
        if (!IsValidPtr(wm)) return false;
        int slotVal = (int)wm->GetCurrentUsingPropSlot().GetValue();
        return (slotVal >= 1 && slotVal <= 3);
    } @catch (...) {
        return false;
    }
}

static void HookedShootEvent(USTExtraShootWeaponComponent* c, FVector s, FRotator r, ASTExtraShootWeapon* w, int u) {
    @try {
        FRotator tr;
        ASTExtraPlayerCharacter* t = FindBestTarget(aim.silent_fov, aim.silent_distance, aim.silent_bone, aim.silent_vis_check, false, tr);
        if (!t || !aim.silent || !IsValidPtr(g_PlayerController)) {
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

static void HookedThrowGrenade(ASTExtraWeapon* w, FVector s, FRotator r) {
    @try {
        FRotator tr;
        ASTExtraPlayerCharacter* t = FindBestTarget(aim.silent_fov, aim.silent_distance, aim.silent_bone, aim.silent_vis_check, false, tr);
        if (!t || !aim.silent || !IsValidPtr(g_PlayerController)) {
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

static void HookedShootUnderbarrel(ASTExtraWeapon* w, FVector s, FRotator r) {
    @try {
        FRotator tr;
        ASTExtraPlayerCharacter* t = FindBestTarget(aim.silent_fov, aim.silent_distance, aim.silent_bone, aim.silent_vis_check, false, tr);
        if (!t || !aim.silent || !IsValidPtr(g_PlayerController)) {
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

static void RenderESP(AHUD* hud, int w, int h) {
    @try {
        if (!IsValidPtr(hud) || !IsValidPtr(hud->Canvas)) return;
        auto s = (UGameplayStatics*)UGameplayStatics::StaticClass();
        auto world = GetFullWorld();
        if (!IsValidPtr(s) || !IsValidPtr(world)) return;

        ASTExtraPlayerController* pc = nullptr;
        if (IsValidPtr(world->NetDriver) && IsValidPtr(world->NetDriver->ServerConnection)) {
            pc = (ASTExtraPlayerController*)world->NetDriver->ServerConnection->PlayerController;
        }
        if (!IsValidPtr(pc) || !IsValidPtr(pc->PlayerCameraManager)) return;

        std::vector<ASTExtraPlayerCharacter*> pl;
        GetAllActorsInGame(pl);
        ASTExtraPlayerCharacter* lp = nullptr;
        for (auto p : pl) {
            if (IsValidPtr(p) && p->PlayerKey == pc->PlayerKey) {
                lp = p;
                break;
            }
        }
        if (!IsValidPtr(lp) || !IsValidPtr(lp->RootComponent)) return;
        g_LocalPlayer = lp;
        g_PlayerController = pc;
        bool hasWeapon = HasWeaponEquipped();

        if (vis.self_skeleton) DrawSkeleton(hud, lp, pc, s, FLinearColor(1, 1, 1, 0.5f));

        if (aim.grenade_warning) {
            std::vector<ASTExtraGrenadeBase*> gs;
            GetAllActorsInGame(gs);
            for (auto g : gs) {
                if (!IsValidPtr(g) || !IsValidPtr(g->RootComponent) || g->bHidden || g->GetDistanceTo(lp) / 100.f > 15) continue;
                if (!g->HasBeenThrowedOut()) continue;
                FVector2D sp;
                if (s->ProjectWorldToScreen(pc, g->K2_GetActorLocation(), false, &sp)) {
                    int id = g->ItemDefineID.TypeSpecificID;
                    std::wstring nm = (id == 602002) ? L"smoke" : (id == 602003) ? L"fire" : (id == 602004 || id == 602005) ? L"nade" : L"grenade";
                    if (g->GetDistanceTo(lp) / 100.f < 10 && IsValidPtr(tslFont)) {
                        tslFont->LegacyFontSize = 22;
                        DrawText(hud, MakeFString(nm + L" near"), FVector2D(w / 2.f, h - 40.f), FLinearColor(1, 0, 0, 1), true);
                    }
                    if (IsValidPtr(tslFont)) {
                        tslFont->LegacyFontSize = 11;
                        DrawText(hud, MakeFString(nm), FVector2D(sp.X, sp.Y - 18), FLinearColor(1, 1, 1, 1), true);
                    }
                    DrawFOVCircle(hud, (int)sp.X, (int)sp.Y, 12, FLinearColor(1, 0, 0, 0.6f));
                }
            }
        }

        enemyCount = 0;
        for (auto e : pl) {
            if (!IsValidPtr(e) || (!vis.draw_bots && e->bEnsure) || e->PlayerKey == lp->PlayerKey || e->TeamID == lp->TeamID || e->bDead || e->bHidden) continue;
            enemyCount++;
            float dist = e->GetDistanceTo(lp) / 100.f;
            if (dist > 400 || !IsValidPtr(e->Mesh) || !IsValidPtr(e->RootComponent)) continue;
            bool visb = pc->LineOfSightTo(e, FVector(0, 0, 0), true);
            float hp = e->HealthMax > 0 ? (e->Health / e->HealthMax) : 0.f;
            FLinearColor hpCol = visb ? (hp > 0.6f ? FLinearColor(0, 1, 0, 1) : (hp > 0.3f ? FLinearColor(1, 1, 0, 1) : FLinearColor(1, 0, 0, 1))) : FLinearColor(1, 1, 1, 1);
            FVector head = e->GetBonePos("Head", FVector(0, 0, 0));
            FVector foot = e->GetBonePos("foot_l", FVector(0, 0, 0));
            head.Z += 10;
            FVector2D hs, fs;
            if (s->ProjectWorldToScreen(pc, head, false, &hs) && s->ProjectWorldToScreen(pc, foot, false, &fs)) {
                float bh = fabsf(hs.Y - fs.Y);
                if (bh < 1) continue;
                float bw = bh * 0.52f;
                float bx = hs.X - bw / 2;
                float by = hs.Y;
                FLinearColor skelCol = FLinearColor(vis.skeleton_color[0], vis.skeleton_color[1], vis.skeleton_color[2], vis.skeleton_color[3]);
                if (!visb) skelCol = FLinearColor(0.3f, 0.3f, 0.3f, 1);
                if (vis.skeleton) DrawSkeleton(hud, e, pc, s, skelCol);
                if (vis.health) {
                    float barW = 40, barH = 5;
                    DrawLine(hud, FVector2D(hs.X - barW / 2 - 1, by - 12), FVector2D(hs.X + barW / 2 + 1, by - 12), barH + 2, FLinearColor(0, 0, 0, 1));
                    if (hp > 0) DrawLine(hud, FVector2D(hs.X - barW / 2, by - 12), FVector2D(hs.X - barW / 2 + barW * hp, by - 12), barH, hpCol);
                }
                if (vis.snapline) {
                    DrawLine(hud, FVector2D(w / 2.f, 135), FVector2D(hs.X, by - 20), vis.line_width, FLinearColor(vis.snapline_color[0], vis.snapline_color[1], vis.snapline_color[2], vis.snapline_color[3]));
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
                }
                if (IsValidPtr(tslFont)) {
                    if (vis.names) {
                        tslFont->LegacyFontSize = 13;
                        std::wstring nm = e->bEnsure ? L"bot" : FStringToWStringSafe(e->PlayerName);
                        DrawText(hud, MakeFString(nm), FVector2D(hs.X, by + bh + 4), FLinearColor(1, 1, 1, 1), true);
                    }
                    if (vis.distance) {
                        tslFont->LegacyFontSize = 11;
                        DrawText(hud, MakeFString(std::to_wstring((int)dist) + L"m"), FVector2D(hs.X, by + bh + 18), FLinearColor(1, 1, 1, 1), true);
                    }
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
                if (IsValidPtr(tslFont)) {
                    tslFont->LegacyFontSize = 12;
                    DrawText(hud, MakeFString(std::to_wstring((int)dist) + L"m"), FVector2D(x, y + isz + 4), FLinearColor(1, 1, 1, 1), true);
                }
            }
        }
        if (IsValidPtr(tslFont)) {
            tslFont->LegacyFontSize = 26;
            DrawText(hud, MakeFString(std::to_wstring(enemyCount)), FVector2D(w / 2.f, 85), FLinearColor(1, 1, 1, 1), true);
            tslFont->LegacyFontSize = 13;
        }
        if (aim.show_fov) DrawFOVCircle(hud, w / 2, h / 2, (int)aim.fov_size, FLinearColor(1, 1, 1, 0.3f));
        if (aim.silent_show_fov) DrawFOVCircle(hud, w / 2, h / 2, (int)aim.silent_fov, FLinearColor(1, 0, 0, 0.3f));
        if (aim.enabled && hasWeapon && IsValidPtr(g_LocalPlayer) && IsValidPtr(g_PlayerController)) {
            FRotator tr;
            ASTExtraPlayerCharacter* t = FindBestTarget(aim.fov_size, aim.max_distance, aim.target_bone, false, true, tr);
            if (IsValidPtr(t)) {
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
    } @catch (...) {}
}

static void HookedProcessEvent(UObject* o, UFunction* f, void* a) {
    @try {
        if (IsValidPtr(o) && IsValidPtr(f) && IsValidPtr(a)) {
            std::string fn = f->GetFullName();
            if (fn.find(ENCRYPT("Function Engine.HUD.ReceiveDrawHUD")) != std::string::npos) {
                if (o->IsA(AHUD::StaticClass())) {
                    auto h = (AHUD*)o;
                    auto p = (AHUD_ReceiveDrawHUD_Params*)a;
                    if (p->SizeX > 0 && p->SizeY > 0) {
                        RenderESP(h, p->SizeX, p->SizeY);
                    }
                }
            }
        }
        if (orig_process_event) orig_process_event(o, f, a);
    } @catch (...) {
        if (orig_process_event) orig_process_event(o, f, a);
    }
}

static void EnsureDarkIOSKeyVerified(void) {
    NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
    NSString* savedKey = [defs stringForKey:@"DARKIOS_Saved_Key_v1"];
    if (![savedKey isKindOfClass:[NSString class]] || savedKey.length < 10 || ![savedKey hasPrefix:@"DARKIOS-"]) {
        [defs setObject:@"DARKIOS-1D-ADMIN01" forKey:@"DARKIOS_Saved_Key_v1"];
    }
    [defs setBool:YES forKey:@"ESP_Key_Verified_v1"];
    [defs setBool:YES forKey:@"DARKIOS_Key_Verified_v1"];
    [defs synchronize];
}

static void ToggleMenuViaImGuiLoad(BOOL forceOpen, BOOL toggle) {
    EnsureDarkIOSKeyVerified();
    IsLogin = true;
    BOOL nextState = toggle ? !MenDeal : forceOpen;
    menu_open = (bool)nextState;

    dispatch_block_t applyBlock = ^{
        [[ImGuiLoad share] initTapGes];
        [[ImGuiLoad share] setMenuVisible:nextState];
        if (nextState) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MeenuOpenRequested" object:nil];
        }
    };

    if ([NSThread isMainThread]) {
        applyBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), applyBlock);
    }
}

extern "C" void OpenNewMenu(void) {
    ToggleMenuViaImGuiLoad(YES, YES);
}

@interface ThreeFingerTripleTapHandler : NSObject
- (void)onThreeFingerTripleTap:(UITapGestureRecognizer *)gr;
@end

static ThreeFingerTripleTapHandler *g_TripleTapHandler = nil;

@implementation ThreeFingerTripleTapHandler
- (void)onThreeFingerTripleTap:(UITapGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateEnded) {
        OpenNewMenu();
    }
}
@end

static void AttachThreeFingerTripleTap(UIWindow *win) {
    if (!win) return;
    if (!g_TripleTapHandler) {
        g_TripleTapHandler = [[ThreeFingerTripleTapHandler alloc] init];
    }
    for (UIGestureRecognizer *existing in win.gestureRecognizers) {
        if ([existing isKindOfClass:[UITapGestureRecognizer class]]) {
            UITapGestureRecognizer *tgr = (UITapGestureRecognizer *)existing;
            if (tgr.numberOfTouchesRequired == 3 && tgr.numberOfTapsRequired == 3) {
                return;
            }
        }
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:g_TripleTapHandler action:@selector(onThreeFingerTripleTap:)];
    tap.numberOfTouchesRequired = 3;
    tap.numberOfTapsRequired = 3;
    tap.cancelsTouchesInView = NO;
    tap.delaysTouchesBegan = NO;
    tap.delaysTouchesEnded = NO;
    [win addGestureRecognizer:tap];
}

static void RegisterThreeFingerTripleTapLoop(void) {
    for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if ([scene isKindOfClass:[UIWindowScene class]]) {
            for (UIWindow *w in ((UIWindowScene *)scene).windows) {
                AttachThreeFingerTripleTap(w);
            }
        }
    }
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        AttachThreeFingerTripleTap(w);
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        RegisterThreeFingerTripleTapLoop();
    });
}

__attribute__((constructor))
static void InitNewMenuGestureAndHooks(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        EnsureDarkIOSKeyVerified();
        IsLogin = true;
        [[ImGuiLoad share] initTapGes];
        RegisterThreeFingerTripleTapLoop();
    });
}
