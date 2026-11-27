#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

extern bool MenDeal;
extern "C" void OpenNewMenu(void);

static NSString *const kESPKeyVerifiedDefaultsKey = @"ESP_Key_Verified_v1";

static BOOL IsESPKeyVerified(void) {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kESPKeyVerifiedDefaultsKey];
}

@interface MeenuOverlayController : NSObject
@property (nonatomic, strong) UIButton *blackCircleButton;
- (void)handleBlackCircleTap;
- (void)syncWithKeyAuth;
@end

static MeenuOverlayController *gMeenuOverlay = nil;

@implementation MeenuOverlayController

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(syncWithKeyAuth)
                                                     name:@"KeyAuthSuccessNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleBlackCircleTap)
                                                     name:@"MeenuOpenRequested"
                                                   object:nil];
    }
    return self;
}

- (UIWindow *)activeWindow {
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            for (UIWindow *w in scene.windows) {
                if (w.isKeyWindow) return w;
            }
            if (scene.windows.firstObject) return scene.windows.firstObject;
        }
    }
    return [UIApplication sharedApplication].windows.firstObject;
}

- (void)syncWithKeyAuth {
    if (!IsESPKeyVerified()) {
        MenDeal = false;
        self.blackCircleButton.hidden = YES;
        return;
    }
    [self attachCircle];
    self.blackCircleButton.hidden = NO;
}

- (void)handleBlackCircleTap {
    if (!IsESPKeyVerified()) {
        MenDeal = false;
        self.blackCircleButton.hidden = YES;
        return;
    }
    OpenNewMenu();
}

- (void)attachCircle {
    if (!IsESPKeyVerified()) {
        self.blackCircleButton.hidden = YES;
        return;
    }

    UIWindow *win = [self activeWindow];
    if (!win) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self attachCircle];
        });
        return;
    }

    if (!self.blackCircleButton) {
        CGFloat size = 48.0;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(24.0, 56.0, size, size);
        btn.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.70];
        btn.layer.cornerRadius = size * 0.5;
        btn.layer.borderWidth = 0.0;
        btn.clipsToBounds = YES;
        [btn addTarget:self action:@selector(handleBlackCircleTap) forControlEvents:UIControlEventTouchUpInside];
        self.blackCircleButton = btn;
    }

    self.blackCircleButton.hidden = NO;
    if (!self.blackCircleButton.superview) {
        [win addSubview:self.blackCircleButton];
    }
    [win bringSubviewToFront:self.blackCircleButton];
}

@end

extern "C" void MeenuOverlayOpen(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!gMeenuOverlay) {
            gMeenuOverlay = [[MeenuOverlayController alloc] init];
        }
        [gMeenuOverlay syncWithKeyAuth];
    });
}

__attribute__((constructor))
static void initMeenuOverlay(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!gMeenuOverlay) {
            gMeenuOverlay = [[MeenuOverlayController alloc] init];
        }
        [gMeenuOverlay syncWithKeyAuth];
    });
}
