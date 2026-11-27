#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <string>
#include <ctime>

extern bool IsLogin;
extern bool MenDeal;

extern "C" void showKeyMenu(void);
extern "C" void OpenNewMenu(void);
extern "C" void OpenMeenu(void);
extern "C" void DarkiosOpenNewMenu(void);
extern "C" void DarkiosOpenOldMenu(void);
extern "C" void DarkiosOpenBothMenus(void);

static NSString *const API_VERIFY_URL = @"https://darkios.onrender.com/api/verify";
static NSString *const kDarkiosSavedKey = @"SavedDarkIOSKey";
static NSString *const kDarkiosSavedExpire = @"SavedDarkIOSExpire";
static NSString *const kDarkiosSavedLifetime = @"SavedDarkIOSLifetime";
static NSString *const kESPKeyVerifiedDefaultsKey = @"ESP_Key_Verified_v1";

NSString *globalActiveKey = nil;
static int64_t g_ExpireEpoch = 0;
static bool g_IsLifetime = false;
static BOOL g_ShowingDurationAlert = NO;
static BOOL g_KeyMenuPresented = NO;
static BOOL g_CrashScheduled = NO;
static NSTimer *g_LiveStatusTimer = nil;

@interface DarkiosMenuIconView : UIView
@property (nonatomic, strong) UIButton *iconButton;
@end

static DarkiosMenuIconView *g_DarkiosMenuIcon = nil;

static BOOL isKeyAuthorized(void) {
    if (!IsLogin || !globalActiveKey.length) {
        return NO;
    }
    return [[NSUserDefaults standardUserDefaults] boolForKey:kESPKeyVerifiedDefaultsKey];
}

static NSString *getDeviceHWID(void) {
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return uuid ?: @"UNKNOWN_DEVICE_HWID";
}

static UIWindow *getKeyWindow(void) {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *winScene = (UIWindowScene *)scene;
                for (UIWindow *window in winScene.windows) {
                    if (window.isKeyWindow && !window.hidden) {
                        return window;
                    }
                }
                for (UIWindow *window in winScene.windows) {
                    if (!window.hidden && window.bounds.size.width > 0 && window.bounds.size.height > 0) {
                        return window;
                    }
                }
                if (winScene.windows.count > 0) {
                    return winScene.windows.firstObject;
                }
            }
        }
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [UIApplication sharedApplication].keyWindow ?: [UIApplication sharedApplication].windows.firstObject;
#pragma clang diagnostic pop
}

static UIViewController *getTopViewController(void) {
    UIWindow *window = getKeyWindow();
    UIViewController *topVC = window.rootViewController;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

static NSString *formatRemainingTime(int64_t expireEpoch, bool isLifetime) {
    if (isLifetime) {
        return @"Unlimited (Lifetime)";
    }
    int64_t nowSec = (int64_t)time(nullptr);
    int64_t diff = expireEpoch - nowSec;
    if (diff <= 0) {
        return @"0d 00h 00m 00s";
    }
    int64_t days = diff / 86400;
    int64_t hours = (diff % 86400) / 3600;
    int64_t mins = (diff % 3600) / 60;
    int64_t secs = diff % 60;
    return [NSString stringWithFormat:@"%lldd %02lldh %02lldm %02lds",
            days, hours, mins, secs];
}

static void hideMenuButton(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [g_DarkiosMenuIcon removeFromSuperview];
        g_DarkiosMenuIcon = nil;
    });
}

static void clearSavedKey(void) {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:kDarkiosSavedKey];
    [ud removeObjectForKey:kDarkiosSavedExpire];
    [ud removeObjectForKey:kDarkiosSavedLifetime];
    [ud setBool:NO forKey:kESPKeyVerifiedDefaultsKey];
    [ud synchronize];
    globalActiveKey = nil;
    g_ExpireEpoch = 0;
    g_IsLifetime = false;
    IsLogin = false;
    MenDeal = false;
    dispatch_async(dispatch_get_main_queue(), ^{
        [g_LiveStatusTimer invalidate];
        g_LiveStatusTimer = nil;
        [g_DarkiosMenuIcon removeFromSuperview];
        g_DarkiosMenuIcon = nil;
    });
}

static void triggerCrashAfter3Seconds(NSString *title, NSString *message) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (g_CrashScheduled) return;
        g_CrashScheduled = YES;
        clearSavedKey();

        UIViewController *topVC = getTopViewController();
        if (topVC) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                           message:message
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            alert.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
            [topVC presentViewController:alert animated:YES completion:nil];
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            __builtin_trap();
        });
    });
}

static void openOldMenuFromFile(void) {
    if (!isKeyAuthorized()) {
        showKeyMenu();
        return;
    }
    void *symOpenMeenu = dlsym(RTLD_DEFAULT, "OpenMeenu");
    if (symOpenMeenu) {
        void (*fn)(void) = (void (*)(void))symOpenMeenu;
        fn();
    }
    MenDeal = !MenDeal;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"MeenuOpenRequested" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DarkiosOpenOldMenu" object:nil];
}

extern "C" void DarkiosOpenOldMenu(void) {
    if (!isKeyAuthorized()) {
        showKeyMenu();
        return;
    }
    openOldMenuFromFile();
}

extern "C" void DarkiosOpenNewMenu(void) {
    if (!isKeyAuthorized()) {
        showKeyMenu();
        return;
    }
    OpenNewMenu();
}

extern "C" void DarkiosOpenBothMenus(void) {
    if (!isKeyAuthorized()) {
        showKeyMenu();
        return;
    }
    openOldMenuFromFile();
    OpenNewMenu();
}

@implementation DarkiosMenuIconView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = frame.size.width * 0.5;
        self.layer.borderWidth = 1.2;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.65;
        self.layer.shadowRadius = 8.0;
        self.layer.shadowOffset = CGSizeMake(0, 3);
        self.backgroundColor = [UIColor colorWithWhite:0.04 alpha:0.96];
        self.layer.borderColor = [UIColor colorWithWhite:0.25 alpha:0.9].CGColor;

        _iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _iconButton.frame = self.bounds;
        _iconButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _iconButton.backgroundColor = [UIColor clearColor];

        if (@available(iOS 13.0, *)) {
            UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightBold];
            UIImage *img = [UIImage systemImageNamed:@"square.grid.2x2.fill" withConfiguration:cfg];
            [_iconButton setImage:img forState:UIControlStateNormal];
            _iconButton.tintColor = [UIColor whiteColor];
        } else {
            [_iconButton setTitle:@"M" forState:UIControlStateNormal];
            [_iconButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _iconButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        }

        [_iconButton addTarget:self action:@selector(handleIconTap) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_iconButton];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)handleIconTap {
    if (!isKeyAuthorized()) {
        hideMenuButton();
        showKeyMenu();
        return;
    }
    DarkiosOpenNewMenu();
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    UIView *superV = self.superview;
    if (!superV) return;
    CGPoint pt = [gesture locationInView:superV];
    CGFloat halfW = self.bounds.size.width * 0.5;
    CGFloat halfH = self.bounds.size.height * 0.5;
    CGFloat minX = halfW + 8.0;
    CGFloat maxX = superV.bounds.size.width - halfW - 8.0;
    CGFloat minY = halfH + 24.0;
    CGFloat maxY = superV.bounds.size.height - halfH - 24.0;

    CGFloat clampedX = MIN(MAX(pt.x, minX), MAX(minX, maxX));
    CGFloat clampedY = MIN(MAX(pt.y, minY), MAX(minY, maxY));
    self.center = CGPointMake(clampedX, clampedY);
}

@end

static void showMenuIcons(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!isKeyAuthorized()) {
            hideMenuButton();
            return;
        }
        UIWindow *win = getKeyWindow();
        if (!win) return;

        CGFloat size = 46.0;
        if (!g_DarkiosMenuIcon) {
            g_DarkiosMenuIcon = [[DarkiosMenuIconView alloc] initWithFrame:CGRectMake(20.0, 120.0, size, size)];
        }
        if (g_DarkiosMenuIcon.superview != win) {
            [g_DarkiosMenuIcon removeFromSuperview];
            [win addSubview:g_DarkiosMenuIcon];
        }
        [win bringSubviewToFront:g_DarkiosMenuIcon];
    });
}

static void showAlertMessage(NSString *title, NSString *message, BOOL retry) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *topVC = getTopViewController();
        if (!topVC) return;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        alert.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;

        if (retry) {
            [alert addAction:[UIAlertAction actionWithTitle:@"Try Again"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(__unused UIAlertAction *action) {
                g_KeyMenuPresented = NO;
                showKeyMenu();
            }]];
        } else {
            [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(__unused UIAlertAction *action) {
                g_KeyMenuPresented = NO;
            }]];
        }

        [topVC presentViewController:alert animated:YES completion:nil];
    });
}

static void showVerifiedDuration5Sec(int64_t expireEpoch, bool isLifetime) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!isKeyAuthorized()) return;
        if (g_ShowingDurationAlert) return;
        UIViewController *topVC = getTopViewController();
        if (!topVC) return;

        g_ShowingDurationAlert = YES;

        NSString *msg = [NSString stringWithFormat:@"Remaining time: %@",
                         formatRemainingTime(expireEpoch, isLifetime)];

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Key Verified"
                                                                       message:msg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        alert.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;

        __block BOOL dismissed = NO;
        __weak UIAlertController *weakAlert = alert;

        void (^finishAndDismiss)(void) = ^{
            if (dismissed) return;
            dismissed = YES;
            g_ShowingDurationAlert = NO;
            showMenuIcons();
            UIAlertController *strongAlert = weakAlert;
            if (strongAlert && strongAlert.presentingViewController) {
                [strongAlert dismissViewControllerAnimated:YES completion:nil];
            }
        };

        [alert addAction:[UIAlertAction actionWithTitle:@"Close"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(__unused UIAlertAction *action) {
            finishAndDismiss();
        }]];

        [topVC presentViewController:alert animated:YES completion:^{
            UIView *backdrop = alert.view.superview;
            if (backdrop) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:nil action:NULL];
                tap.cancelsTouchesInView = NO;
                [backdrop addGestureRecognizer:tap];
            }
        }];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            finishAndDismiss();
        });
    });
}

static NSDictionary *parseServerJSON(NSData *data) {
    if (!data || data.length == 0) return nil;
    NSString *raw = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!raw) return nil;
    NSString *trimmed = [raw stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange brace = [trimmed rangeOfString:@"{"];
    if (brace.location == NSNotFound) return nil;
    NSData *slice = [[trimmed substringFromIndex:brace.location] dataUsingEncoding:NSUTF8StringEncoding];
    if (!slice) return nil;
    id parsed = [NSJSONSerialization JSONObjectWithData:slice options:0 error:nil];
    return [parsed isKindOfClass:[NSDictionary class]] ? (NSDictionary *)parsed : nil;
}

static void startLiveStatusMonitor(NSString *activeKey) {
    if (!activeKey.length) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (g_LiveStatusTimer) return;
        g_LiveStatusTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:YES block:^(__unused NSTimer *timer) {
            if (!isKeyAuthorized() || !globalActiveKey.length || g_CrashScheduled) return;
            NSString *hwid = getDeviceHWID();
            NSURL *url = [NSURL URLWithString:API_VERIFY_URL];
            if (!url) return;

            NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
            req.HTTPMethod = @"POST";
            req.timeoutInterval = 8.0;
            [req setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

            NSCharacterSet *allowed = [NSCharacterSet URLQueryAllowedCharacterSet];
            NSString *body = [NSString stringWithFormat:@"key=%@&hwid=%@",
                              [globalActiveKey stringByAddingPercentEncodingWithAllowedCharacters:allowed] ?: @"",
                              [hwid stringByAddingPercentEncodingWithAllowedCharacters:allowed] ?: @""];
            req.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];

            [[[NSURLSession sharedSession] dataTaskWithRequest:req
                                             completionHandler:^(NSData *data, __unused NSURLResponse *resp, NSError *err) {
                if (err || !data) return;
                NSDictionary *json = parseServerJSON(data);
                if (!json) return;

                NSString *status = [[json[@"status"] description] lowercaseString];

                if ([json[@"banned"] boolValue] || [status isEqualToString:@"banned"] || [status isEqualToString:@"ban"]) {
                    triggerCrashAfter3Seconds(@"Banned", @"You have been banned by admin");
                    return;
                }

                if ([json[@"paused"] boolValue] || [status isEqualToString:@"paused"] || [status isEqualToString:@"stopped"] || [status isEqualToString:@"disabled"]) {
                    triggerCrashAfter3Seconds(@"Key Paused", @"Your key has been paused by admin");
                    return;
                }

                if ([json[@"updating"] boolValue] || [status isEqualToString:@"updating"] || [status isEqualToString:@"update"]) {
                    triggerCrashAfter3Seconds(@"Updating", @"Cheat is currently updating");
                    return;
                }
            }] resume];
        }];
    });
}

static void handleServerStatusResponse(NSString *inputKey, NSDictionary *json, BOOL wasAlreadyLoggedIn) {
    NSString *status = [[json[@"status"] description] lowercaseString];
    NSString *rawMessage = [json[@"message"] isKindOfClass:[NSString class]] ? json[@"message"] : nil;

    if ([json[@"banned"] boolValue] || [status isEqualToString:@"banned"] || [status isEqualToString:@"ban"]) {
        if (wasAlreadyLoggedIn || isKeyAuthorized()) {
            triggerCrashAfter3Seconds(@"Banned", @"You have been banned by admin");
            return;
        }
        clearSavedKey();
        showAlertMessage(@"Banned", @"You have been banned by admin", YES);
        return;
    }

    if ([json[@"paused"] boolValue] || [status isEqualToString:@"paused"] || [status isEqualToString:@"stopped"] || [status isEqualToString:@"disabled"]) {
        if (wasAlreadyLoggedIn || isKeyAuthorized()) {
            triggerCrashAfter3Seconds(@"Key Paused", @"Your key has been paused by admin");
            return;
        }
        clearSavedKey();
        showAlertMessage(@"Key Paused", @"Your key has been paused by admin", YES);
        return;
    }

    if ([json[@"updating"] boolValue] || [status isEqualToString:@"updating"] || [status isEqualToString:@"update"]) {
        if (wasAlreadyLoggedIn || isKeyAuthorized()) {
            triggerCrashAfter3Seconds(@"Updating", @"Cheat is currently updating");
            return;
        }
        clearSavedKey();
        showAlertMessage(@"Updating",
                         rawMessage.length > 0 ? rawMessage : @"Cheat is currently updating. Please try again later.",
                         NO);
        return;
    }

    if ([json[@"valid"] boolValue] || [status isEqualToString:@"success"] || [status isEqualToString:@"valid"] || [status isEqualToString:@"ok"]) {
        bool lifetime = [json[@"lifetime"] boolValue];
        int64_t expireEpoch = 0;
        if ([json[@"expire_epoch"] respondsToSelector:@selector(longLongValue)]) {
            expireEpoch = [json[@"expire_epoch"] longLongValue];
        } else if ([json[@"expires_at"] respondsToSelector:@selector(longLongValue)]) {
            expireEpoch = [json[@"expires_at"] longLongValue];
        }

        if (!lifetime && expireEpoch > 0 && expireEpoch <= (int64_t)time(nullptr)) {
            clearSavedKey();
            showAlertMessage(@"Expired", @"Your key has expired.", YES);
            return;
        }

        globalActiveKey = inputKey;
        g_ExpireEpoch = expireEpoch;
        g_IsLifetime = lifetime;
        IsLogin = true;
        g_KeyMenuPresented = NO;

        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:inputKey forKey:kDarkiosSavedKey];
        [ud setObject:@(expireEpoch) forKey:kDarkiosSavedExpire];
        [ud setBool:lifetime forKey:kDarkiosSavedLifetime];
        [ud setBool:YES forKey:kESPKeyVerifiedDefaultsKey];
        [ud synchronize];

        showMenuIcons();
        startLiveStatusMonitor(inputKey);

        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"StartHack" object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"KeyAuthSuccessNotification" object:nil];
        });

        showVerifiedDuration5Sec(expireEpoch, lifetime);
        return;
    }

    clearSavedKey();
    showAlertMessage(@"Login Failed",
                     rawMessage.length > 0 ? rawMessage : @"Invalid or inactive key.",
                     YES);
}

static void verifyKeyWithServer(NSString *inputKey) {
    BOOL wasAlreadyLoggedIn = isKeyAuthorized();
    NSString *hwid = getDeviceHWID();
    NSURL *url = [NSURL URLWithString:API_VERIFY_URL];
    if (!url) {
        showAlertMessage(@"Error", @"Invalid server URL.", YES);
        return;
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = 20.0;
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];

    NSCharacterSet *allowed = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *postString = [NSString stringWithFormat:@"key=%@&hwid=%@",
                            [inputKey stringByAddingPercentEncodingWithAllowedCharacters:allowed] ?: @"",
                            [hwid stringByAddingPercentEncodingWithAllowedCharacters:allowed] ?: @""];
    request.HTTPBody = [postString dataUsingEncoding:NSUTF8StringEncoding];

    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || !data) {
            NSString *errMsg = error.localizedDescription.length > 0
                ? error.localizedDescription
                : @"Unable to connect to server. Check your internet.";
            showAlertMessage(@"Connection Error", errMsg, YES);
            return;
        }

        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        NSString *rawStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] ?: @"";
        NSString *trimmed = [rawStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

        if (trimmed.length == 0) {
            showAlertMessage(@"Response Error",
                             [NSString stringWithFormat:@"Empty response from server (HTTP %ld).", (long)statusCode],
                             YES);
            return;
        }

        NSDictionary *parsed = parseServerJSON(data);
        if (!parsed) {
            NSString *preview = trimmed.length > 90 ? [[trimmed substringToIndex:90] stringByAppendingString:@"..."] : trimmed;
            showAlertMessage(@"Response Error",
                             [NSString stringWithFormat:@"HTTP %ld: %@", (long)statusCode, preview],
                             YES);
            return;
        }

        handleServerStatusResponse(inputKey, parsed, wasAlreadyLoggedIn);
    }];
    [task resume];
}

extern "C" void showKeyMenu(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!isKeyAuthorized()) {
            hideMenuButton();
        }

        UIViewController *topVC = getTopViewController();
        if (!topVC) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                showKeyMenu();
            });
            return;
        }

        NSString *savedKey = [[NSUserDefaults standardUserDefaults] stringForKey:kDarkiosSavedKey];
        if (savedKey.length > 0) {
            verifyKeyWithServer(savedKey);
            return;
        }

        if (g_KeyMenuPresented && [topVC isKindOfClass:[UIAlertController class]]) {
            return;
        }
        g_KeyMenuPresented = YES;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"DARKIOS - Key Login"
                                                                       message:@"Please enter the key from admin panel:"
                                                                preferredStyle:UIAlertControllerStyleAlert];

        alert.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;

        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"DARKIOS-1D-XXXXX";
            textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
            textField.autocorrectionType = UITextAutocorrectionTypeNo;
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        }];

        UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"Login"
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(__unused UIAlertAction *action) {
            g_KeyMenuPresented = NO;
            UITextField *keyField = alert.textFields.firstObject;
            NSString *enteredKey = [keyField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            if (enteredKey.length == 0) {
                showKeyMenu();
            } else {
                verifyKeyWithServer(enteredKey);
            }
        }];

        [alert addAction:loginAction];
        [topVC presentViewController:alert animated:YES completion:nil];
    });
}

__attribute__((constructor))
static void DarkiosAuthEntry(void) {
    hideMenuButton();
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showKeyMenu();
    });
}
