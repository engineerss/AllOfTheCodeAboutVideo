//
//  ZSBrightnessView.m
//  VideoTest2
//
//  Created by zs mac on 16/9/12.
//  Copyright © 2016年 zs mac. All rights reserved.
//
#import "ZSPlayer.h"
#import "ZSBrightnessView.h"

@interface ZSBrightnessView()

@property (nonatomic,strong) UIImageView                    *backImage;
@property (nonatomic,strong) UILabel                        *title;
@property (nonatomic,strong) UIView                         *longView;
@property (nonatomic,strong) NSMutableArray                 *tipArray;
@property (nonatomic,assign) BOOL                           orientationDidChange;

@property (nonatomic,strong) NSTimer                        *timer;


@end

@implementation ZSBrightnessView

+(instancetype)shareBrightnessView
{
    static ZSBrightnessView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ZSBrightnessView alloc]init];
        [[UIApplication sharedApplication].keyWindow addSubview:instance];
        
    });
    return instance;
    
}


-(instancetype)init
{
    if (self = [super init]) {
        self.frame = CGRectMake(ScreenWidth * 0.5, ScreenWidth * 0.5, 155, 155);
        
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        
        UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:self.bounds];
        toolbar.alpha = 0.97;
        [self addSubview:toolbar];
        
        
        self.backImage = ({
        
            UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 79, 76)];
            imgView.image = ZSPlayerImage(@"ZFPlayer_brightness");
            [self addSubview:imgView];
            imgView;
        });
        
        
        self.title = ({
            UILabel *title      = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 30)];
            title.font          = [UIFont boldSystemFontOfSize:16];
            title.textColor     = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
            title.textAlignment = NSTextAlignmentCenter;
            title.text          = @"亮-度";
            [self addSubview:title];
            title;
        });
        
        
        self.longView = ({
            UIView *longView         = [[UIView alloc]initWithFrame:CGRectMake(13, 132, self.bounds.size.width - 26, 7)];
            longView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
            [self addSubview:longView];
            longView;
        });

        [self createTips];
        [self addNotification];
        [self addObserver];
        
        self.alpha = 0.0;
        
    }
    
  
    
    return self;
    
    
}
#pragma makr - 通知 KVO
- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateLayer:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)addObserver {
    
    [[UIScreen mainScreen] addObserver:self
                            forKeyPath:@"brightness"
                               options:NSKeyValueObservingOptionNew context:NULL];
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    CGFloat sound = [change[@"new"] floatValue];
    [self appearSoundView];
    
    
    [self updateLongView:sound];
    
    
    
    
    
}
- (void)appearSoundView {
    
    
    
    if (self.alpha == 0.0) {
        
        NSLog(@"亮度显示");
        self.alpha = 1.0;
        [self updateTimer];
    }
}
- (void)disAppearSoundView {
    
    if (self.alpha == 1.0) {
        [UIView animateWithDuration:0.8 animations:^{
            self.alpha = 0.0;
        } completion:^(BOOL finished) {
            
        }];
    }
}


- (void)updateLayer:(NSNotification *)notify {
    self.orientationDidChange = YES;
    [self setNeedsLayout];
}

- (void)addtimer {
    
    if (self.timer) {
        return;
    }
    
    self.timer = [NSTimer timerWithTimeInterval:3
                                         target:self
                                       selector:@selector(disAppearSoundView)
                                       userInfo:nil
                                        repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)removeTimer {
    
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
- (void)updateTimer {
    [self removeTimer];
    [self addtimer];
}




//创建tips

-(void)createTips
{
    
    self.tipArray = [NSMutableArray arrayWithCapacity:16];
    
    CGFloat tipW = (self.longView.bounds.size.width - 17) / 16;
    CGFloat tipH = 5;
    CGFloat tipY = 1;
    
    for (int i = 0; i < 16; i++) {
        CGFloat tipX          = i * (tipW + 1) + 1;
        UIImageView *image    = [[UIImageView alloc] init];
        image.backgroundColor = [UIColor whiteColor];
        image.frame           = CGRectMake(tipX, tipY, tipW, tipH);
        [self.longView addSubview:image];
        [self.tipArray addObject:image];
    }
    [self updateLongView:[UIScreen mainScreen].brightness];

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}

#pragma mark - Update View
- (void)updateLongView:(CGFloat)sound {
    CGFloat stage = 1 / 15.0;
    NSInteger level = sound / stage;
    
    for (int i = 0; i < self.tipArray.count; i++) {
        UIImageView *img = self.tipArray[i];
        
        if (i <= level) {
            img.hidden = NO;
        } else {
            img.hidden = YES;
        }
    }
}
- (void)didMoveToSuperview {}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self setNeedsLayout];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (self.orientationDidChange) {
        [UIView animateWithDuration:0.25 animations:^{
            if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait
                || [UIDevice currentDevice].orientation == UIDeviceOrientationFaceUp) {
                self.center = CGPointMake(ScreenWidth * 0.5, (ScreenHeight - 10) * 0.5);
            } else {
                self.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.5);
            }
        } completion:^(BOOL finished) {
            self.orientationDidChange = NO;
        }];
    } else {
        if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
            self.center = CGPointMake(ScreenWidth * 0.5, (ScreenHeight - 10) * 0.5);
        } else {
            self.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.5);
        }
    }
    
    self.backImage.center = CGPointMake(155 * 0.5, 155 * 0.5);

}

- (void)dealloc {
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
