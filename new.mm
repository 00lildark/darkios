#define IMGUI_DEFINE_MATH_OPERATORS

#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>

#include <cmath>
#include <vector>
#include <string>
#include <map>
#include <algorithm>

#include "imgui.h"
#include "imgui_internal.h"
#include "imgui_impl_metal.h"
#include "font_awesome_5.h"
#include "fa_solid_900.h"

#ifndef STR
#define STR(str) (str)
#endif

using namespace ImGui;

static bool menu_open = false;
static float g_menu_anim = 0.0f;

@interface ImGuiDrawView : UIViewController <MTKViewDelegate>
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) MTKView *mtkView;
+ (void)showChange:(BOOL)open;
+ (BOOL)isMenuShowing;
@end

static ImGuiDrawView *g_SilenticumDrawView = nil;

namespace SilenticumUI {

    struct AimSettings {
        bool enabled = false;
        bool show_fov = false;
        bool silent = false;
        bool silent_show_fov = false;
        bool prediction = false;
        bool vis_check = false;
        bool silent_vis_check = false;
        bool grenade_warning = false;
        bool vehicle_aim = false;
        bool closest_priority = false;

        float fov_size = 120.0f;
        float max_distance = 300.0f;
        float silent_distance = 300.0f;
        float smooth = 2.5f;
        float silent_smooth = 1.0f;
        float silent_fov = 90.0f;

        int target_bone = 0;
        int trigger_mode = 0;
        int silent_bone = 0;
    };

    struct VisualSettings {
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

        float indicator_size = 20.0f;
        float indicator_width = 50.0f;
        float indicator_distance = 180.0f;
        float line_width = 1.5f;

        float box_color[4] = {1, 1, 1, 1};
        float skeleton_color[4] = {1, 1, 1, 1};
        float snapline_color[4] = {1, 1, 1, 1};
        float indicator_color[4] = {1, 1, 1, 1};
        float silent_color[4] = {1, 0, 0, 1};
    };

    struct ItemSettings {
        bool vehicles = false;
        bool metro_chests = false;
        bool snow = false;
        float max_distance = 200.0f;
    };

    struct LootSettings {
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
        float max_distance = 150.0f;
    };

    static AimSettings aim;
    static VisualSettings vis;
    static ItemSettings itemEsp;
    static LootSettings lootEsp;

    static int selectedTab = 0;
    static bool showSearch = false;
    static bool showSettings = false;
    static bool showResetPopup = false;

    static void SaveSettings() {
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

        [d setBool:aim.enabled forKey:@"ui_ae"];
        [d setBool:aim.silent forKey:@"ui_as"];
        [d setBool:aim.show_fov forKey:@"ui_af"];
        [d setBool:aim.silent_show_fov forKey:@"ui_asf"];
        [d setBool:aim.prediction forKey:@"ui_ap"];

        [d setFloat:aim.fov_size forKey:@"ui_afs"];
        [d setFloat:aim.max_distance forKey:@"ui_am"];
        [d setFloat:aim.silent_distance forKey:@"ui_asd"];
        [d setFloat:aim.smooth forKey:@"ui_asm"];
        [d setFloat:aim.silent_fov forKey:@"ui_asfo"];

        [d setBool:vis.boxes forKey:@"ui_vb"];
        [d setBool:vis.health forKey:@"ui_vh"];
        [d setBool:vis.skeleton forKey:@"ui_vs"];
        [d setBool:vis.names forKey:@"ui_vn"];
        [d setBool:vis.distance forKey:@"ui_vd"];
        [d setBool:vis.snapline forKey:@"ui_vsp"];

        [d setBool:lootEsp.enabled forKey:@"ui_le"];
        [d setBool:lootEsp.weapons forKey:@"ui_lw"];
        [d setBool:lootEsp.attachments forKey:@"ui_la"];

        [d synchronize];
    }

    static void LoadSettings() {
        NSUserDefaults *d = [NSUserDefaults standardUserDefaults];

        aim.enabled = [d boolForKey:@"ui_ae"];
        aim.silent = [d boolForKey:@"ui_as"];
        aim.show_fov = [d boolForKey:@"ui_af"];
        aim.silent_show_fov = [d boolForKey:@"ui_asf"];
        aim.prediction = [d boolForKey:@"ui_ap"];

        aim.fov_size = [d floatForKey:@"ui_afs"];
        aim.max_distance = [d floatForKey:@"ui_am"];
        aim.silent_distance = [d floatForKey:@"ui_asd"];
        aim.smooth = [d floatForKey:@"ui_asm"];
        aim.silent_fov = [d floatForKey:@"ui_asfo"];

        vis.boxes = [d boolForKey:@"ui_vb"];
        vis.health = [d boolForKey:@"ui_vh"];
        vis.skeleton = [d boolForKey:@"ui_vs"];
        vis.names = [d boolForKey:@"ui_vn"];
        vis.distance = [d boolForKey:@"ui_vd"];
        vis.snapline = [d boolForKey:@"ui_vsp"];

        lootEsp.enabled = [d boolForKey:@"ui_le"];
        lootEsp.weapons = [d boolForKey:@"ui_lw"];
        lootEsp.attachments = [d boolForKey:@"ui_la"];
    }

    static bool TabButton(const char *icon, const char *label, bool active) {
        char buf[128];
        snprintf(buf, sizeof(buf), "%s  %s", icon, label);
        ImVec4 col = active
            ? ImVec4(0.47f, 0.47f, 1.0f, 0.35f)
            : ImVec4(0.12f, 0.12f, 0.16f, 0.40f);
        ImGui::PushStyleColor(ImGuiCol_Button, col);
        ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.47f, 0.47f, 1.0f, 0.25f));
        ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0.47f, 0.47f, 1.0f, 0.45f));
        bool pressed = ImGui::Button(buf, ImVec2(-1, 28));
        ImGui::PopStyleColor(3);
        return pressed;
    }

    static void BeginGroupBox(const char *name, ImVec2 size) {
        ImGui::PushStyleColor(ImGuiCol_ChildBg, ImVec4(0.08f, 0.08f, 0.11f, 0.85f));
        ImGui::BeginChild(name, size, true);
        ImGui::TextColored(ImVec4(0.75f, 0.78f, 0.90f, 1.0f), "%s", name);
        ImGui::Separator();
    }

    static void EndGroupBox() {
        ImGui::EndChild();
        ImGui::PopStyleColor();
    }

    static UIWindow *KeyWindow() {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                for (UIWindow *win in scene.windows) {
                    if (win.isKeyWindow) return win;
                }
                return scene.windows.firstObject;
            }
        }
        return [UIApplication sharedApplication].windows.firstObject;
    }

    static void AttachOverlayView() {
        if (!g_SilenticumDrawView) {
            g_SilenticumDrawView = [[ImGuiDrawView alloc] init];
        }
        UIWindow *win = KeyWindow();
        if (!win) return;
        UIView *targetView = g_SilenticumDrawView.view;
        if (targetView.superview != win) {
            [targetView removeFromSuperview];
            targetView.frame = win.bounds;
            targetView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [win addSubview:targetView];
        }
        [win bringSubviewToFront:targetView];
        [targetView setUserInteractionEnabled:menu_open];
    }
}

@implementation ImGuiDrawView

+ (void)load {
    SilenticumUI::LoadSettings();
}

+ (void)showChange:(BOOL)open {
    menu_open = open;
    if (open) {
        SilenticumUI::AttachOverlayView();
    } else if (g_SilenticumDrawView) {
        [g_SilenticumDrawView.view setUserInteractionEnabled:NO];
    }
}

+ (BOOL)isMenuShowing {
    return menu_open;
}

- (instancetype)init {
    self = [super init];

    if (self) {
        _device = MTLCreateSystemDefaultDevice();
        _commandQueue = [_device newCommandQueue];

        IMGUI_CHECKVERSION();
        ImGui::CreateContext();

        ImGuiIO &io = ImGui::GetIO();

        NSString *fontPath = @"/System/Library/Fonts/Core/AvenirNext.ttc";
        io.Fonts->AddFontFromFileTTF(fontPath.UTF8String, 14.0f);

        static const ImWchar icon_ranges[] = {
            ICON_MIN_FA,
            ICON_MAX_FA,
            0
        };

        ImFontConfig icons_config;
        icons_config.MergeMode = true;
        icons_config.PixelSnapH = true;

        io.Fonts->AddFontFromMemoryTTF(
            (void *)fa_solid_900,
            sizeof(fa_solid_900),
            13.0f,
            &icons_config,
            icon_ranges
        );

        ImGui::StyleColorsDark();
        ImGui::GetStyle().ScaleAllSizes(0.85f);

        ImGui_ImplMetal_Init(_device);
    }

    return self;
}

- (void)loadView {
    self.view = [[MTKView alloc] initWithFrame:
        CGRectMake(
            0,
            0,
            [UIScreen mainScreen].bounds.size.width,
            [UIScreen mainScreen].bounds.size.height
        )
    ];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mtkView = (MTKView *)self.view;
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;

    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor clearColor];
}

- (void)updateIOWithTouchEvent:(UIEvent *)event {
    UITouch *touch = event.allTouches.anyObject;

    if (!touch) return;

    CGPoint point = [touch locationInView:self.view];

    ImGuiIO &io = ImGui::GetIO();

    io.MousePos = ImVec2(point.x, point.y);

    BOOL active = NO;

    for (UITouch *t in event.allTouches) {
        if (t.phase != UITouchPhaseEnded &&
            t.phase != UITouchPhaseCancelled) {
            active = YES;
            break;
        }
    }

    io.MouseDown[0] = active;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches
              withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

static void DrawGroupTitle(const char *title) {
    ImGui::PushStyleColor(
        ImGuiCol_Text,
        ImVec4(0.55f, 0.57f, 0.62f, 1.0f)
    );

    ImGui::TextUnformatted(title);

    ImGui::PopStyleColor();
}

- (void)drawInMTKView:(MTKView *)view {
    @try {
        ImGuiIO &io = ImGui::GetIO();

        io.DisplaySize = ImVec2(
            view.bounds.size.width,
            view.bounds.size.height
        );

        io.DisplayFramebufferScale = ImVec2(
            view.window.screen.nativeScale,
            view.window.screen.nativeScale
        );

        io.DeltaTime = 1.0f / 60.0f;

        [self.view setUserInteractionEnabled:menu_open];

        id<MTLCommandBuffer> commandBuffer =
            [self.commandQueue commandBuffer];

        MTLRenderPassDescriptor *renderPass =
            view.currentRenderPassDescriptor;

        if (renderPass) {
            id<MTLRenderCommandEncoder> encoder =
                [commandBuffer renderCommandEncoderWithDescriptor:renderPass];

            [encoder pushDebugGroup:@"SILENTICUM"];

            ImGui_ImplMetal_NewFrame(renderPass);
            ImGui::NewFrame();

            if (menu_open) {
                using namespace SilenticumUI;

                ImGui::PushStyleVar(
                    ImGuiStyleVar_WindowPadding,
                    ImVec2(0, 0)
                );

                ImGui::SetNextWindowSize(
                    ImVec2(690, 500),
                    ImGuiCond_Always
                );

                ImGui::Begin(
                    "SILENTICUM",
                    nullptr,
                    ImGuiWindowFlags_NoDecoration |
                    ImGuiWindowFlags_NoBackground
                );

                ImGuiWindow *window = ImGui::GetCurrentWindow();
                ImDrawList *draw = window->DrawList;

                ImVec2 pos = window->Pos;
                ImVec2 size = ImVec2(690, 500);

                g_menu_anim = ImLerp(
                    g_menu_anim,
                    1.0f,
                    0.045f
                );

                const char *title = "SILENTICUM";

                ImVec2 titleSize =
                    ImGui::CalcTextSize(title);

                ImFont *titleFont = (io.Fonts->Fonts.Size > 2 && io.Fonts->Fonts[2])
                    ? io.Fonts->Fonts[2]
                    : ImGui::GetFont();

                draw->AddText(
                    titleFont,
                    28,
                    ImVec2(pos.x + 85 - titleSize.x / 2 + 1, pos.y + 20),
                    IM_COL32(120, 120, 255, 255),
                    title
                );

                draw->AddText(
                    titleFont,
                    28,
                    ImVec2(pos.x + 85 - titleSize.x / 2, pos.y + 20),
                    IM_COL32(255, 255, 255, 255),
                    title
                );

                draw->AddLine(
                    ImVec2(pos.x, pos.y + size.y - 50),
                    ImVec2(pos.x + 170, pos.y + size.y - 50),
                    IM_COL32(255, 255, 255, 80)
                );

                draw->AddText(
                    ImVec2(pos.x + 50, pos.y + size.y - 40),
                    IM_COL32(255, 255, 255, 255),
                    "@shiedLess"
                );

                draw->AddText(
                    ImVec2(pos.x + 50, pos.y + size.y - 25),
                    IM_COL32(150, 150, 150, 255),
                    "Till:"
                );

                draw->AddText(
                    ImVec2(pos.x + 50 + ImGui::CalcTextSize("Till: ").x, pos.y + size.y - 25),
                    IM_COL32(120, 120, 255, 255),
                    "mywings"
                );

                ImGui::SetCursorPos(ImVec2(10, 70));

                ImGui::BeginChild(
                    "##tabs",
                    ImVec2(150, size.y - 120),
                    false
                );

                DrawGroupTitle("Aimbot");

                if (TabButton(ICON_FA_CROSSHAIRS, "Aim Bot", selectedTab == 0)) selectedTab = 0;
                if (TabButton(ICON_FA_GHOST, "Advanced", selectedTab == 1)) selectedTab = 1;
                if (TabButton(ICON_FA_MOUSE_POINTER, "Legit Bot", selectedTab == 2)) selectedTab = 2;

                ImGui::Spacing();
                ImGui::Spacing();
                ImGui::Spacing();

                DrawGroupTitle("Visuals");

                if (TabButton(ICON_FA_USER, "Players", selectedTab == 3)) selectedTab = 3;
                if (TabButton(ICON_FA_PALLET, "World", selectedTab == 4)) selectedTab = 4;

                ImGui::Spacing();
                ImGui::Spacing();
                ImGui::Spacing();

                DrawGroupTitle("Miscellaneous");

                if (TabButton(ICON_FA_HAMMER, "Main", selectedTab == 5)) selectedTab = 5;
                if (TabButton(ICON_FA_CODE, "Scripts", selectedTab == 6)) selectedTab = 6;

                ImGui::EndChild();

                ImGui::SetCursorPos(ImVec2(190, 20));

                if (ImGui::Button(
                    ICON_FA_SAVE " Save",
                    ImVec2(95, 25)
                )) {
                    SaveSettings();
                }

                ImGui::SetCursorPos(ImVec2(620, 20));

                ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0, 0, 0, 0));
                ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0, 0, 0, 0));
                ImGui::PushStyleColor(ImGuiCol_ButtonActive, ImVec4(0, 0, 0, 0));

                if (ImGui::Button(ICON_FA_SEARCH, ImVec2(25, 25))) {
                    showSearch = !showSearch;
                }

                ImGui::SameLine();

                ImGui::SetCursorPos(ImVec2(650, 20));

                if (ImGui::Button(ICON_FA_COG, ImVec2(25, 25))) {
                    showSettings = !showSettings;
                }

                ImGui::PopStyleColor(3);

                ImGui::PushStyleVar(
                    ImGuiStyleVar_ItemSpacing,
                    ImVec2(8, 8)
                );

                ImGui::SetCursorPos(
                    ImVec2(185, 81 - (5 * g_menu_anim))
                );

                float childHeight = size.y - 110;

                ImGui::BeginChild(
                    "##childs",
                    ImVec2(size.x - 200, childHeight),
                    false,
                    ImGuiWindowFlags_NoScrollbar
                );

                float groupWidth =
                    ImGui::GetWindowWidth() / 2 -
                    ImGui::GetStyle().ItemSpacing.x / 2;

                float fullHeight = ImGui::GetWindowHeight();
                float halfHeight = fullHeight / 2 - 10;
                float smallHeight = fullHeight * 0.7f;

                switch (selectedTab) {

                    case 0:
                        BeginGroupBox("Aim Bot", ImVec2(groupWidth, halfHeight));
                        ImGui::Checkbox("enable aimbot", &aim.enabled);
                        ImGui::Checkbox("show fov", &aim.show_fov);
                        ImGui::SliderFloat("fov size", &aim.fov_size, 0, 500, "%.0f");
                        ImGui::SliderFloat("distance", &aim.max_distance, 0, 400, "%.0f");
                        EndGroupBox();

                        ImGui::SameLine();

                        BeginGroupBox("Smooth", ImVec2(groupWidth, halfHeight));
                        ImGui::SliderFloat("smooth", &aim.smooth, 1, 10, "%.1f");
                        ImGui::Checkbox("prediction", &aim.prediction);

                        {
                            const char *bones[] = {
                                "head", "neck", "chest", "pelvis"
                            };

                            ImGui::Combo("bone", &aim.target_bone, bones, 4);
                        }

                        EndGroupBox();

                        BeginGroupBox("Trigger", ImVec2(groupWidth, halfHeight));

                        {
                            const char *modes[] = {
                                "always", "on fire", "on ads", "both"
                            };

                            ImGui::Combo(
                                "trigger",
                                &aim.trigger_mode,
                                modes,
                                4
                            );
                        }

                        EndGroupBox();

                        ImGui::SameLine();

                        BeginGroupBox("Silent", ImVec2(groupWidth, halfHeight));
                        ImGui::Checkbox("enable silent", &aim.silent);
                        ImGui::Checkbox("show silent fov", &aim.silent_show_fov);
                        ImGui::SliderFloat("fov", &aim.silent_fov, 0, 500, "%.0f");
                        ImGui::SliderFloat("distance", &aim.silent_distance, 0, 400, "%.0f");
                        ImGui::Checkbox("visible check", &aim.silent_vis_check);
                        EndGroupBox();
                        break;

                    case 1:
                        BeginGroupBox("Protection", ImVec2(groupWidth, smallHeight));
                        ImGui::Checkbox("grenade warning", &aim.grenade_warning);
                        ImGui::Checkbox("vehicle aim", &aim.vehicle_aim);
                        ImGui::Checkbox("closest priority", &aim.closest_priority);
                        EndGroupBox();

                        ImGui::SameLine();

                        BeginGroupBox("Colors", ImVec2(groupWidth, smallHeight));
                        ImGui::ColorEdit4("box", vis.box_color);
                        ImGui::ColorEdit4("skel", vis.skeleton_color);
                        ImGui::ColorEdit4("line", vis.snapline_color);
                        ImGui::ColorEdit4("ind", vis.indicator_color);
                        ImGui::ColorEdit4("silent", vis.silent_color);
                        EndGroupBox();
                        break;

                    case 2:
                        BeginGroupBox("Legit Bot", ImVec2(groupWidth, halfHeight));
                        ImGui::SliderFloat("aim smooth", &aim.smooth, 1, 10, "%.1f");
                        ImGui::SliderFloat("aim fov", &aim.fov_size, 0, 500, "%.0f");
                        EndGroupBox();

                        ImGui::SameLine();

                        BeginGroupBox("Settings", ImVec2(groupWidth, halfHeight));

                        {
                            const char *bones[] = {
                                "head", "neck", "chest", "pelvis"
                            };

                            ImGui::Combo("aim bone", &aim.target_bone, bones, 4);
                        }

                        EndGroupBox();
                        break;

                    case 3:
                        BeginGroupBox("Player ESP", ImVec2(groupWidth, halfHeight));
                        ImGui::Checkbox("box", &vis.boxes);
                        ImGui::Checkbox("health", &vis.health);
                        ImGui::Checkbox("skeleton", &vis.skeleton);
                        ImGui::Checkbox("name", &vis.names);
                        ImGui::Checkbox("distance", &vis.distance);
                        ImGui::Checkbox("snapline", &vis.snapline);
                        EndGroupBox();

                        ImGui::SameLine();

                        BeginGroupBox("Indicators", ImVec2(groupWidth, halfHeight));
                        ImGui::Checkbox("indicators", &vis.indicators);

                        if (vis.indicators) {
                            ImGui::Checkbox("fill", &vis.indicator_fill);
                            ImGui::SliderFloat("size", &vis.indicator_size, 5, 60, "%.0f");
                            ImGui::SliderFloat("width", &vis.indicator_width, 10, 100, "%.0f");
                            ImGui::SliderFloat("dist", &vis.indicator_distance, 50, 400, "%.0f");
                        }

                        EndGroupBox();

                        BeginGroupBox("Other ESP", ImVec2(groupWidth, halfHeight));
                        ImGui::Checkbox("self skeleton", &vis.self_skeleton);
                        ImGui::Checkbox("draw bots", &vis.draw_bots);
                        EndGroupBox();
                        break;

                    case 4:
                        BeginGroupBox("Vehicles", ImVec2(groupWidth, halfHeight));
                        ImGui::Checkbox("vehicles", &itemEsp.vehicles);
                        ImGui::Checkbox("loot boxes", &itemEsp.metro_chests);
                        ImGui::SliderFloat("max distance", &itemEsp.max_distance, 50, 300, "%.0f");
                        EndGroupBox();

                        ImGui::SameLine();

                        BeginGroupBox("Loot", ImVec2(groupWidth, halfHeight));
                        ImGui::Checkbox("enable loot", &lootEsp.enabled);
                        ImGui::Checkbox("weapons", &lootEsp.weapons);
                        ImGui::Checkbox("attachments", &lootEsp.attachments);
                        ImGui::Checkbox("scopes", &lootEsp.scopes);
                        EndGroupBox();

                        BeginGroupBox("Items", ImVec2(groupWidth, halfHeight));
                        ImGui::Checkbox("ammo", &lootEsp.ammo);
                        ImGui::Checkbox("meds", &lootEsp.health);
                        ImGui::Checkbox("backpacks", &lootEsp.backpacks);
                        ImGui::Checkbox("helmets", &lootEsp.helmets);
                        ImGui::Checkbox("vests", &lootEsp.vests);
                        EndGroupBox();

                        ImGui::SameLine();

                        BeginGroupBox("Metro", ImVec2(groupWidth, halfHeight));
                        ImGui::Checkbox("metro items", &lootEsp.metro_items);
                        ImGui::Checkbox("rare only", &lootEsp.rare_only);
                        ImGui::SliderFloat("loot distance", &lootEsp.max_distance, 50, 200, "%.0f");
                        EndGroupBox();
                        break;

                    case 5:
                        BeginGroupBox("Main", ImVec2(groupWidth, fullHeight));
                        EndGroupBox();

                        ImGui::SameLine();

                        BeginGroupBox("Info", ImVec2(groupWidth, fullHeight));
                        EndGroupBox();
                        break;

                    case 6:
                        BeginGroupBox("Scripts", ImVec2(groupWidth, fullHeight));

                        if (ImGui::Button(
                            "reset guest",
                            ImVec2(groupWidth - 30, 55)
                        )) {
                            showResetPopup = true;
                        }

                        if (showResetPopup) {
                            ImGui::OpenPopup("Wait Message");
                        }

                        if (ImGui::BeginPopupModal(
                            "Wait Message",
                            nullptr,
                            ImGuiWindowFlags_AlwaysAutoResize
                        )) {
                            ImGui::Text("Guest account 5 seconds");

                            if (ImGui::Button("Close")) {
                                showResetPopup = false;
                                ImGui::CloseCurrentPopup();
                            }

                            ImGui::EndPopup();
                        }

                        EndGroupBox();

                        ImGui::SameLine();

                        BeginGroupBox("Config", ImVec2(groupWidth, fullHeight));
                        EndGroupBox();
                        break;
                }

                ImGui::EndChild();

                ImGui::PopStyleVar();

                ImGui::End();

                ImGui::PopStyleVar();

                SaveSettings();
            }

            ImGui::Render();

            ImGui_ImplMetal_RenderDrawData(
                ImGui::GetDrawData(),
                commandBuffer,
                encoder
            );

            [encoder popDebugGroup];
            [encoder endEncoding];

            [commandBuffer presentDrawable:view.currentDrawable];
        }

        [commandBuffer commit];
    }
    @catch (...) {
    }
}

- (void)mtkView:(MTKView *)view
drawableSizeWillChange:(CGSize)size {
}

@end

extern "C" void OpenNewMenu(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [ImGuiDrawView showChange:![ImGuiDrawView isMenuShowing]];
    });
}

extern "C" void RenderNewMenuOverlay(void) {
    if (![ImGuiDrawView isMenuShowing]) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        SilenticumUI::AttachOverlayView();
    });
}
