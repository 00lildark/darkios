#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <atomic>
#include "imgui.h"

extern bool MenDeal;
extern bool IsLogin;
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
extern float AimF;
extern bool Blacksky;
extern bool CL;
extern bool CarFly;
extern bool Config;
extern float DanceValue;
extern float DancerValue;
extern bool FixShoot;
extern float Gun_Size;
extern bool IsHitXPL;
extern bool IsLaunch;
extern bool Radar;
extern float RadarX;
extern float RadarY;
extern bool ReCo;
extern bool ResetGuest;
extern bool ShowFov;
extern bool VisCheck;
extern void* g_LocalController;
extern float g_disstance;
extern bool initialized;
extern int screenWidth;
extern int screenHeight;
extern float carx, cary, carz;
extern bool tudongnhay;
extern bool 下雨;
extern bool 下雪特效;
extern bool 人物变大;
extern bool 人物自杀;
extern bool 坐标追;
extern bool 巨人;
extern bool 打击圈;
extern bool 据点;
extern bool 枪械变大;
extern bool 瞄准线;
extern bool 重置游客;
extern ImU32 COLOR_Distance;
extern ImColor bgColor;
extern ImFont* mainFont;
extern ImFont* cyberMenuFont;

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

void RenderMenu();
void ApplyImGuiStyle();
void InitializeMenuFonts(ImGuiIO& io);
void DrawMenuHudBadge(ImDrawList* draw_list, ImVec2 center, float radius);
int GetMenuLanguage();
void SetMenuLanguage(int lang);
const char* TranslateMenuText(const char* text);
void* GetMenuBadgeImage();

extern "C" void OpenMeenu(void);
extern "C" void OpenNewMenu(void);
extern "C" void RenderNewMenuOverlay(void);
