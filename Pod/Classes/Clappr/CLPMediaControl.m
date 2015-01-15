//
//  CLPMediaControl.m
//  Clappr
//
//  Created by Gustavo Barbosa on 12/18/14.
//  Copyright (c) 2014 globo.com. All rights reserved.
//

#import "CLPMediaControl.h"
#import "CLPContainer.h"
#import "CLPPlayback.h"

NSString *const CLPMediaControlEventPlaying = @"clappr:media_control:playing";
NSString *const CLPMediaControlEventNotPlaying = @"clappr:media_control:not_playing";

static CGFloat const kMediaControlAnimationDuration = 0.3;

NSTimeInterval CLPAnimationDuration(BOOL animated) {
    return animated ? kMediaControlAnimationDuration : 0.0;
}


@implementation CLPMediaControl

#pragma mark - Ctors

- (instancetype)initWithContainer:(CLPContainer *)container
{
    self = [super init];
    if (self) {
        _container = container;

        [self addControlViews];
        [self bindEventListeners];
        [self addTapGestureToShowOrHideControls];
    }
    return self;
}

- (void)addControlViews
{
    _playPauseButton = [UIButton new];
    [_playPauseButton addTarget:self
                         action:@selector(togglePlay)
               forControlEvents:UIControlEventTouchUpInside];
    [_container.view addSubview:_playPauseButton];

    _stopButton = [UIButton new];
    [_stopButton addTarget:self
                    action:@selector(stop)
          forControlEvents:UIControlEventTouchUpInside];
    [_container.view addSubview:_stopButton];

    _volumeSlider = [UISlider new];
    _volumeSlider.continuous = YES;
    [_volumeSlider addTarget:self
                      action:@selector(volumeSliderValueDidChange)
            forControlEvents:UIControlEventValueChanged];
    [_container.view addSubview:_volumeSlider];
}

- (void)bindEventListeners
{
    __weak typeof(self) weakSelf = self;
    [self listenTo:_container eventName:CLPContainerEventPlay callback:^(NSDictionary *userInfo) {
        [weakSelf containerDidPlay];
    }];

    [self listenTo:_container eventName:CLPContainerEventPause callback:^(NSDictionary *userInfo) {
        [weakSelf containerDidPause];
    }];
}

- (void)addTapGestureToShowOrHideControls
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] init];
    [self.view addGestureRecognizer:tapGesture];
}

#pragma mark - Methods

- (void)play
{
    [_container play];
    [self trigger:CLPMediaControlEventPlaying];
}

- (void)pause
{
    [_container pause];
    [self trigger:CLPMediaControlEventNotPlaying];
}

- (void)togglePlay
{
    if ([_container isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

- (void)stop
{
    if (!_container.playing)
        return;

    [_container stop];
    [self trigger:CLPMediaControlEventNotPlaying];
}

- (void)volumeSliderValueDidChange
{
    _container.playback.volume = _volumeSlider.value;
}

- (void)show
{
    [self showAnimated:NO];
}

- (void)showAnimated:(BOOL)animated
{
    self.view.alpha = 0.0;
    self.view.hidden = NO;

    [UIView animateWithDuration:CLPAnimationDuration(animated) animations:^{
        self.view.alpha = 1.0;
    }];
}

- (void)hide
{
    [self hideAnimated:NO];
}

- (void)hideAnimated:(BOOL)animated
{
    __weak typeof(self) weakSelf = self;

    [UIView animateWithDuration:CLPAnimationDuration(animated) animations:^{
        self.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        weakSelf.view.hidden = finished;
    }];
}

#pragma mark - Notification handling

- (void)containerDidPlay
{
    [self trigger:CLPMediaControlEventPlaying];
}

- (void)containerDidPause
{
    [self trigger:CLPMediaControlEventNotPlaying];
}

@end
