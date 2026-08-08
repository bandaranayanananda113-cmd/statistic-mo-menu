// Require standard library
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#include <iostream>
#include <UIKit/UIKit.h>
#include <vector>
#import "pthread.h"
#include <array>
#import <os/log.h>
#include <cmath>
#include <deque>
#include <fstream>
#include <algorithm>
#include <string>
#include <sstream>
#include <cstring>
#include <cstdlib>
#include <cstdio>
#include <cstdint>
#include <cinttypes>
#include <cerrno>
#include <cctype>

// Imgui library
#import "Esp/CaptainHook.h"
#import "Esp/ImGuiDrawView.h"
#import "IMGUI/imgui.h"
#import "IMGUI/imgui_internal.h"
#import "IMGUI/imgui_impl_metal.h"
#import "IMGUI/zzz.h"

ImFont* verdana_smol = nullptr;
ImFont* pixel_big = nullptr;
ImFont* pixel_smol = nullptr;

#include "oxorany/oxorany_include.h"
#import "Helper/Mem.h"
#import "Helper/Vector3.h"
#import "Helper/Vector2.h"
#import "Helper/Quaternion.h"
#import "Helper/Monostring.h"
#include "Helper/font.h"
#include "Helper/data.h"
#include "Helper/Obfuscate.h"

#import "Helper/Hooks.h"

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <unistd.h>
#include <string.h>
#include "Other/dobby_defines.h"
#import "Other/H5hook.h"
#include "Other/Paste.h"

#define Hook(x, y, z) \
{ \
    NSString* result_##y = StaticInlineHookPatch(("Frameworks/UnityFramework.framework/UnityFramework"), x, nullptr); \
    if (result_##y) { \
        void* result = StaticInlineHookFunction(("Frameworks/UnityFramework.framework/UnityFramework"), x, (void *) y); \
        *(void **) (&z) = (void*) result; \
    } \
}

static float fixLoginTimeout = 60.0f;
static bool MenDeal = false;

// KeyAuth Details
static NSString *const kAppName = @"STATISTIC PRO";
static NSString *const kOwnerID = @"wFY9t1Imun";
static NSString *const kAppSecret = @"b0ffff3c2299551401bdfcf35ea9be8283c0aab612cc0241c5d813e4f0f2a393";
static NSString *const kAppVersion = @"1.0";

// Theme State
static float menuAccentColor[4] = { 0.16f, 0.52f, 0.96f, 1.0f }; // Sapphire Accent
static float menuAlpha = 0.94f;

// Tab State & Animations
static int currentTab = 0; 
static float tabAnimAlpha = 1.0f;
static int lastTab = 0;

// Custom Colors
static float espLineColor[4] = { 0.95f, 0.25f, 0.25f, 1.0f };
static float espBoxColor[4]  = { 0.25f, 0.95f, 0.35f, 1.0f };
static float fovCircleColor[4] = { 0.25f, 0.75f, 1.0f, 0.85f };

// Auth & Status
static bool isLoggedIn = false;
static bool isAuthenticating = false;
static bool authFailed = false;
static char licenseKey[128] = "";
static std::string overlayStatusMsg = "";
static ImVec4 overlayStatusColor = ImVec4(0.15f, 0.85f, 1.0f, 1.0f);
static std::string keyExpiryDate = "Pending...";
static bool apiConnected = false;
static float statusMsgTimer = 0.0f;

#define kWidth  [UIScreen mainScreen].bounds.size.width
#define kHeight [UIScreen mainScreen].bounds.size.height
#define kScale [UIScreen mainScreen].scale

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
- (void)autoPasteAndAuthenticate;
- (void)authenticateKey:(NSString *)key;
- (void)handleAuthFailure:(NSString *)reason;
@end

@implementation ImGuiDrawView
ImFont *_espFont;
ImFont* verdanab;
ImFont* icons;
ImFont* interb;
ImFont* Urbanist;

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];

    if (!self.device) abort();

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    // === PROFESSIONAL ENGINE STYLE SETUP ===
    ImGuiStyle& style = ImGui::GetStyle();
    style.Alpha = 1.0f;
    style.WindowRounding = 10.0f;     
    style.FrameRounding = 5.0f;
    style.ChildRounding = 8.0f;
    style.PopupRounding = 8.0f;
    style.ScrollbarRounding = 6.0f;
    style.GrabRounding = 4.0f;
    style.TabRounding = 5.0f;
    style.WindowBorderSize = 1.0f;
    style.FrameBorderSize = 0.0f;    
    style.WindowPadding = ImVec2(16.0f, 16.0f);
    style.ItemSpacing = ImVec2(12.0f, 10.0f);
    style.ItemInnerSpacing = ImVec2(8.0f, 6.0f);
    style.AntiAliasedLines = true;
    style.AntiAliasedFill = true;
    
    // One-time Static Style Colors Initialization
    ImVec4* colors = style.Colors;
    colors[ImGuiCol_Text]                   = ImVec4(0.92f, 0.94f, 0.96f, 1.00f);
    colors[ImGuiCol_TextDisabled]           = ImVec4(0.48f, 0.52f, 0.58f, 1.00f);
    colors[ImGuiCol_WindowBg]               = ImVec4(0.08f, 0.09f, 0.11f, menuAlpha);
    colors[ImGuiCol_ChildBg]                = ImVec4(0.11f, 0.12f, 0.15f, 0.80f);
    colors[ImGuiCol_PopupBg]                = ImVec4(0.09f, 0.10f, 0.12f, 0.98f);
    colors[ImGuiCol_FrameBg]                = ImVec4(0.14f, 0.16f, 0.20f, 1.00f);
    colors[ImGuiCol_FrameBgHovered]         = ImVec4(0.18f, 0.22f, 0.28f, 1.00f);
    colors[ImGuiCol_FrameBgActive]          = ImVec4(0.22f, 0.26f, 0.34f, 1.00f);
    colors[ImGuiCol_TitleBg]                = ImVec4(0.06f, 0.07f, 0.09f, 1.00f);
    colors[ImGuiCol_TitleBgActive]          = ImVec4(0.08f, 0.09f, 0.12f, 1.00f);
    colors[ImGuiCol_ScrollbarBg]            = ImVec4(0.04f, 0.04f, 0.05f, 0.20f);
    colors[ImGuiCol_ScrollbarGrab]          = ImVec4(0.22f, 0.25f, 0.32f, 1.00f);
    colors[ImGuiCol_Separator]              = ImVec4(0.16f, 0.18f, 0.22f, 1.00f);

    ImFontConfig font_cfg;
    font_cfg.SizePixels = 15.0f;
    font_cfg.OversampleH = 3;
    font_cfg.OversampleV = 3;
    font_cfg.PixelSnapH = true;

    ImFont* font = io.Fonts->AddFontFromMemoryTTF(sansbold, sizeof(sansbold), 15.0f, &font_cfg, io.Fonts->GetGlyphRangesCyrillic());
    verdana_smol = io.Fonts->AddFontFromMemoryTTF(verdana, sizeof(verdana), 30, NULL, io.Fonts->GetGlyphRangesCyrillic());
    pixel_big = io.Fonts->AddFontFromMemoryTTF((void*)smallestpixel, sizeof(smallestpixel), 64, NULL, io.Fonts->GetGlyphRangesCyrillic());
    pixel_smol = io.Fonts->AddFontFromMemoryTTF((void*)smallestpixel, sizeof(smallestpixel), 16, NULL, io.Fonts->GetGlyphRangesCyrillic());
    
    ImGui_ImplMetal_Init(_device);

    return self;
}

+ (void)showChange:(BOOL)open
{
    MenDeal = open;
}

- (MTKView *)mtkView
{
    return (MTKView *)self.view;
}

- (void)loadView
{
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.view = [[MTKView alloc] initWithFrame:bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.mtkView.clipsToBounds = YES;
    self.mtkView.contentScaleFactor = [UIScreen mainScreen].nativeScale;
    
    self.view.userInteractionEnabled = YES;
    self.view.hidden = NO;

    Hook(0x58B3258 , BLAGCMCGEJG1, old_BLAGCMCGEJG1);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self autoPasteAndAuthenticate];
    });
}

- (void)autoPasteAndAuthenticate {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSString *clipboardStr = pasteboard.string;
    
    if (clipboardStr && clipboardStr.length > 0) {
        NSString *cleanedKey = [clipboardStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        strncpy(licenseKey, cleanedKey.UTF8String, sizeof(licenseKey) - 1);
        [self authenticateKey:cleanedKey];
    } else {
        [self handleAuthFailure:@"INVALID KEY / CLIPBOARD EMPTY"];
    }
}

- (void)handleAuthFailure:(NSString *)reason {
    overlayStatusMsg = std::string(reason.UTF8String);
    overlayStatusColor = ImVec4(1.0f, 0.25f, 0.25f, 1.0f);
    statusMsgTimer = 5.0f;
    isAuthenticating = false;
    authFailed = true;
    MenDeal = false; 
}

- (void)authenticateKey:(NSString *)key {
    isAuthenticating = true;
    authFailed = false;
    
    NSString *initUrlStr = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=init&ver=%@&name=%@&ownerid=%@&secret=%@", kAppVersion, [kAppName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], kOwnerID, kAppSecret];
    
    NSMutableURLRequest *initReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:initUrlStr]];
    initReq.HTTPMethod = @"GET";
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:initReq completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
        if (err || !data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleAuthFailure:@"NETWORK CONNECTION FAILED"];
            });
            return;
        }
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if ([json[@"success"] boolValue]) {
            NSString *sessionId = json[@"sessionid"];
            NSString *hwid = [[[UIDevice currentDevice] identifierForVendor] UUIDString]; 
            
            NSString *licUrlStr = [NSString stringWithFormat:@"https://keyauth.win/api/1.2/?type=license&key=%@&hwid=%@&sessionid=%@&name=%@&ownerid=%@&secret=%@", key, hwid, sessionId, [kAppName stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]], kOwnerID, kAppSecret];
            
            NSMutableURLRequest *licReq = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:licUrlStr]];
            licReq.HTTPMethod = @"GET";
            
            [[[NSURLSession sharedSession] dataTaskWithRequest:licReq completionHandler:^(NSData *licData, NSURLResponse *licRes, NSError *licErr) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    isAuthenticating = false;
                    if (licErr || !licData) {
                        [self handleAuthFailure:@"AUTHENTICATION API ERROR"];
                        return;
                    }
                    
                    NSDictionary *licJson = [NSJSONSerialization JSONObjectWithData:licData options:0 error:nil];
                    if ([licJson[@"success"] boolValue]) {
                        isLoggedIn = true;
                        apiConnected = true;
                        
                        overlayStatusMsg = "API CONNECTED & VERIFIED";
                        overlayStatusColor = ImVec4(0.2f, 0.90f, 0.4f, 1.0f);
                        statusMsgTimer = 3.5f;
                        
                        MenDeal = true; 
                        
                        NSDictionary *info = licJson[@"info"];
                        if (info && info[@"subscriptions"]) {
                            NSArray *subs = info[@"subscriptions"];
                            if (subs.count > 0) {
                                NSString *expiryTimestamp = subs[0][@"expiry"];
                                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[expiryTimestamp doubleValue]];
                                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                keyExpiryDate = std::string([[formatter stringFromDate:date] UTF8String]);
                            }
                        }
                    } else {
                        NSString *msg = licJson[@"message"];
                        if ([msg containsString:@"hwid"]) {
                            [self handleAuthFailure:@"HWID MISMATCH - RESET YOUR KEY"];
                        } else {
                            [self handleAuthFailure:@"INVALID LICENSE KEY"];
                        }
                    }
                });
            }] resume];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self handleAuthFailure:@"KEYAUTH INIT FAILED"];
            });
        }
    }] resume];
}

#pragma mark - Touch Interactions

- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    if (isLoggedIn && event.allTouches.count == 3) {
        UITouch *firstTouch = event.allTouches.anyObject;
        if (firstTouch.phase == UITouchPhaseBegan) {
            MenDeal = !MenDeal;
        }
    }

    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { [self updateIOWithTouchEvent:event]; }

#pragma mark - MTKViewDelegate & Rendering

- (void)drawInMTKView:(MTKView*)view
{
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;

    CGFloat framebufferScale = view.window.screen.nativeScale ?: UIScreen.mainScreen.nativeScale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1.0f / float(view.preferredFramesPerSecond ?: 60);

    self.view.userInteractionEnabled = MenDeal;

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    
    if (renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui Main View"];

        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();
        
        // Scope Palette Colors
        ImVec4 accent = ImVec4(menuAccentColor[0], menuAccentColor[1], menuAccentColor[2], 1.0f);
        ImVec4 accent_hover = ImVec4(menuAccentColor[0] * 1.15f, menuAccentColor[1] * 1.15f, menuAccentColor[2] * 1.15f, 1.0f);
        ImVec4 accent_subtle = ImVec4(menuAccentColor[0], menuAccentColor[1], menuAccentColor[2], 0.20f);

        // Frame Push Styles
        ImGui::PushStyleColor(ImGuiCol_Border, accent_subtle);
        ImGui::PushStyleColor(ImGuiCol_CheckMark, accent);
        ImGui::PushStyleColor(ImGuiCol_SliderGrab, accent);
        ImGui::PushStyleColor(ImGuiCol_SliderGrabActive, accent_hover);

        // --- Status Overlay Box ---
        if (overlayStatusMsg.length() > 0 && statusMsgTimer > 0.0f) {
            statusMsgTimer -= io.DeltaTime;
            
            ImGui::SetNextWindowPos(ImVec2(io.DisplaySize.x / 2.0f, 25.0f), ImGuiCond_Always, ImVec2(0.5f, 0.0f));
            ImGui::PushStyleVar(ImGuiStyleVar_WindowRounding, 20.0f);
            ImGui::PushStyleVar(ImGuiStyleVar_WindowPadding, ImVec2(16.0f, 8.0f));
            ImGui::Begin("StatusOverlay", NULL, ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoMove | ImGuiWindowFlags_AlwaysAutoResize | ImGuiWindowFlags_NoInputs);
            
            ImGui::TextColored(overlayStatusColor, "STATUS  |  %s", overlayStatusMsg.c_str());
            
            ImGui::End();
            ImGui::PopStyleVar(2);
        }

        // =========================================================
        //  🎮 MAIN MOD MENU
        // =========================================================
        if (isLoggedIn && MenDeal)
        {                
            ImGui::SetNextWindowSize(ImVec2(600, 370), ImGuiCond_FirstUseEver);
            ImGui::SetNextWindowPos(ImVec2((io.DisplaySize.x - 600) / 2, (io.DisplaySize.y - 370) / 2), ImGuiCond_FirstUseEver);
            
            ImGui::Begin("STATISTIC PRO", &MenDeal, ImGuiWindowFlags_NoCollapse);

            ImDrawList* windowDrawList = ImGui::GetWindowDrawList();
            ImVec2 winPos = ImGui::GetWindowPos();
            ImVec2 winSize = ImGui::GetWindowSize();
            
            // Outer Drop Shadow Depth Layers
            for (int i = 1; i <= 4; i++) {
                windowDrawList->AddRect(
                    ImVec2(winPos.x - i, winPos.y - i),
                    ImVec2(winPos.x + winSize.x + i, winPos.y + winSize.y + i),
                    ImColor(0.0f, 0.0f, 0.0f, 0.08f - (i * 0.015f)),
                    10.0f + i
                );
            }

            // Top Header Accent Strip
            windowDrawList->AddRectFilled(
                ImVec2(winPos.x, winPos.y), 
                ImVec2(winPos.x + winSize.x, winPos.y + 3.0f), 
                ImColor(accent), 
                10.0f, 
                ImDrawFlags_RoundCornersTop
            );

            // --- Left Navigation Sidebar ---
            ImGui::BeginChild("Sidebar", ImVec2(155, 0), true);
            
            ImGui::SetCursorPosY(12);
            ImGui::TextColored(accent, " STATISTIC PRO");
            ImGui::Spacing();
            ImGui::Separator();
            ImGui::Spacing();
            
            auto DrawSidebarButton = [&](const char* label, int tabIndex) {
                bool isActive = (currentTab == tabIndex);
                ImVec2 cursorPos = ImGui::GetCursorScreenPos();
                
                if (isActive) {
                    ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(accent.x, accent.y, accent.z, 0.25f));
                    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(accent.x, accent.y, accent.z, 0.30f));
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(1.0f, 1.0f, 1.0f, 1.0f));
                } else {
                    ImGui::PushStyleColor(ImGuiCol_Button, ImVec4(0.13f, 0.15f, 0.19f, 0.5f));
                    ImGui::PushStyleColor(ImGuiCol_ButtonHovered, ImVec4(0.18f, 0.21f, 0.27f, 0.8f));
                    ImGui::PushStyleColor(ImGuiCol_Text, ImVec4(0.70f, 0.74f, 0.80f, 1.0f));
                }

                if (ImGui::Button(label, ImVec2(138, 38))) {
                    if (currentTab != tabIndex) {
                        lastTab = currentTab;
                        currentTab = tabIndex;
                        tabAnimAlpha = 0.0f;
                    }
                }
                
                if (isActive) {
                    ImDrawList* drawList = ImGui::GetWindowDrawList();
                    drawList->AddRectFilled(
                        ImVec2(cursorPos.x, cursorPos.y + 4.0f),
                        ImVec2(cursorPos.x + 3.5f, cursorPos.y + 34.0f),
                        ImColor(accent),
                        2.0f
                    );
                }

                ImGui::PopStyleColor(3);
                ImGui::Spacing();
            };

            DrawSidebarButton("  ESP Visuals", 0);
            DrawSidebarButton("  Aimbot Engine", 1);
            DrawSidebarButton("  Settings & Keys", 2);
            
            ImGui::EndChild();
            
            ImGui::SameLine();
            
            if (tabAnimAlpha < 1.0f) {
                tabAnimAlpha += io.DeltaTime * 4.0f;
                if (tabAnimAlpha > 1.0f) tabAnimAlpha = 1.0f;
            }

            // --- Right Content Container ---
            ImGui::PushStyleVar(ImGuiStyleVar_Alpha, tabAnimAlpha);
            ImGui::BeginChild("ContentArea", ImVec2(0, 0), true);
            
            // --- TAB 0: ESP ---
            if (currentTab == 0) {
                ImGui::TextColored(accent, "VISUALS & ESP");
                ImGui::Separator();
                ImGui::Spacing();

                ImGui::Checkbox("Enable ESP Master", &Vars.Enable);
                ImGui::Spacing();
                ImGui::Separator();
                ImGui::Spacing();

                if (ImGui::BeginTable("ESP_Grid_Table", 2, ImGuiTableFlags_SizingStretchSame)) {
                    ImGui::TableNextRow();
                    
                    ImGui::TableSetColumnIndex(0);
                    ImGui::Checkbox("Show Lines", &Vars.lines);
                    ImGui::SameLine();
                    ImGui::ColorEdit4("##LineColor", espLineColor, ImGuiColorEditFlags_NoInputs | ImGuiColorEditFlags_AlphaBar);

                    ImGui::Checkbox("Show Boxes", &Vars.Box);
                    ImGui::SameLine();
                    ImGui::ColorEdit4("##BoxColor", espBoxColor, ImGuiColorEditFlags_NoInputs | ImGuiColorEditFlags_AlphaBar);

                    ImGui::Checkbox("Show Health", &Vars.Health);
                    ImGui::Checkbox("Show Names", &Vars.Name);

                    ImGui::TableSetColumnIndex(1);
                    ImGui::Checkbox("Show Skeleton", &Vars.skeleton);
                    ImGui::Checkbox("Show Distance", &Vars.Distance);
                    ImGui::Checkbox("3D Pos Circle", &Vars.circlepos);
                    ImGui::Checkbox("Enemy Outline", &Vars.Outline);

                    ImGui::EndTable();
                }
                
                ImGui::Spacing();
                ImGui::Separator();
                ImGui::Spacing();

                ImGui::Checkbox("Out of Screen Warning", &Vars.OOF); 
                ImGui::Checkbox("Total Enemy Count", &Vars.enemycount);
            }
            
            // --- TAB 1: AIMBOT ENGINE ---
            else if (currentTab == 1) {
                ImGui::TextColored(accent, "AIMBOT CONFIGURATION");
                ImGui::Separator();
                ImGui::Spacing();

                ImGui::Checkbox("Enable Master Aimbot", &Vars.Aimbot);
                ImGui::Spacing();
                ImGui::Separator();
                ImGui::Spacing();

                if (ImGui::BeginTable("Aimbot_Grid_Table", 2, ImGuiTableFlags_SizingStretchSame)) {
                    ImGui::TableNextRow();
                    
                    ImGui::TableSetColumnIndex(0);
                    ImGui::Checkbox("Silent Aim", &SilentAim);
                    ImGui::Checkbox("Visible Only Check", &Vars.VisibleCheck);

                    ImGui::TableSetColumnIndex(1);
                    ImGui::Checkbox("Check Wall Penetration", &CheckWall1);
                    ImGui::Checkbox("Ignore Knocked Players", &Vars.IgnoreKnocked);

                    ImGui::EndTable();
                }

                ImGui::Spacing();
                ImGui::Separator();
                ImGui::Spacing();

                ImGui::Checkbox("Show FOV Circle Overlay", &Vars.isAimFov);
                ImGui::SameLine();
                ImGui::ColorEdit4("##FovColor", fovCircleColor, ImGuiColorEditFlags_NoInputs | ImGuiColorEditFlags_AlphaBar);

                ImGui::SetNextItemWidth(230);
                ImGui::Combo("Trigger Condition", &Vars.AimWhen, Vars.dir, 4);

                ImGui::SetNextItemWidth(230);
                ImGui::Combo("Target Hitbox", &Vars.AimHitbox, Vars.aimHitboxes, 3);

                ImGui::SetNextItemWidth(230);
                ImGui::Combo("Aimbot Mode", &Vars.AimMode, Vars.aimModes, 3);

                ImGui::SetNextItemWidth(280);
                ImGui::SliderFloat("FOV Size", &Vars.AimFov, 0.0f, 360.0f, "%.0f Deg");
            }
            
            // --- TAB 2: SETTINGS & LICENSE ---
            else if (currentTab == 2) {
                ImGui::TextColored(accent, "SYSTEM & LICENSE DETAILS");
                ImGui::Separator();
                ImGui::Spacing();

                ImGui::Text("API Connection:");
                ImGui::SameLine(150);
                ImGui::TextColored(apiConnected ? ImVec4(0.2f, 0.90f, 0.4f, 1.0f) : ImVec4(1.0f, 0.25f, 0.25f, 1.0f), apiConnected ? "ONLINE (VERIFIED)" : "DISCONNECTED");

                ImGui::Text("Active License:");
                ImGui::SameLine(150);
                std::string keyStr = std::string(licenseKey);
                std::string maskedKey = keyStr;
                if (keyStr.length() > 8) {
                    maskedKey = keyStr.substr(0, 4) + "********" + keyStr.substr(keyStr.length() - 4);
                }
                ImGui::TextColored(accent, "%s", maskedKey.c_str());

                ImGui::Text("Subscription Expiry:");
                ImGui::SameLine(150);
                ImGui::TextColored(accent, "%s", keyExpiryDate.c_str());

                ImGui::Spacing();
                ImGui::Separator();
                ImGui::Spacing();

                ImGui::SetNextItemWidth(220);
                ImGui::ColorEdit3("Menu Accent Color", menuAccentColor, ImGuiColorEditFlags_NoInputs);

                ImGui::SetNextItemWidth(220);
                ImGui::SliderFloat("Menu Transparency", &menuAlpha, 0.30f, 1.00f, "%.2f");

                ImGui::Spacing();
                ImGui::Separator();
                ImGui::Spacing();

                if (ImGui::Button("Execute Fix Login", ImVec2(160, 32))) {
                    self.view.hidden = YES; 
                    MenDeal = false; 
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(fixLoginTimeout * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.view.hidden = NO; 
                        MenDeal = true; 
                    });
                }
                ImGui::SameLine();
                ImGui::SetNextItemWidth(140);
                ImGui::SliderFloat("##fixlogin", &fixLoginTimeout, 40.0f, 80.0f, "Timeout: %.0f s");
            }
            
            ImGui::EndChild();
            ImGui::PopStyleVar();
            
            ImGui::End();
        }
        
        ImGui::PopStyleColor(4);

        // --- Game Drawing & Logic Calls ---
        ImDrawList* draw_list = ImGui::GetBackgroundDrawList();
        get_players();
        draw_watermark();
        aimbot();
        
        if (game_sdk) {
            game_sdk->init();
        }

        Vars.isAimFov = (Vars.AimFov > 0);

        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
      
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];

        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size
{
    
}

@end
