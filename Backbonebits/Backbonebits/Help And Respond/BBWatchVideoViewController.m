/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBWatchVideoViewController.h"


@implementation BBWatchVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadLayout];
    [BBLoadingView show];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

#pragma mark - Other Methods

- (void)btnBackTapped:(UIButton *)sender {
    [kBBUtility popViewControllerAnimated:YES];
}

- (void)loadLayout {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    UIColor *backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self.view addSubview:({
        viewTop = [BBTopView getBBTopView];
        [viewTop.lblTitle setText:kWatchVideo];
        [viewTop.btnLeft setTitle:@"Back" theme:BBTopBarButtonThemeBack target:self selector:@selector(btnBackTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addChildViewController:viewTop];
        viewTop.view;
    })];
    
    //View Bottom
    CGFloat height = 25;
    CGFloat spacing = 7;
    [self.view addSubview:({
        viewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
        [viewBottom setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        [viewBottom setBackgroundColor:backgroundColor];
        [viewBottom setHidden:YES];
        viewBottom;
    })];
    
    UIColor *sliderMaximumTintColor = kBBRGBCOLOR(51.0, 204.0, 204.0);
    
    CGFloat x = viewBottom.frame.size.width - (spacing) - height;
    [self.view addSubview:({
        _volumeView = [[MPVolumeView alloc] init];
        _volumeView.backgroundColor = [UIColor clearColor];
        _volumeView.showsVolumeSlider = YES;
        _volumeView.showsRouteButton = NO;
        CGFloat width = 90;
        [_volumeView setFrame:CGRectMake(x-30, self.view.frame.size.height - (viewBottom.frame.size.height*2)-15, width, 20)];
        [_volumeView setTintColor:sliderMaximumTintColor];
        CGAffineTransform trans = CGAffineTransformMakeRotation(-M_PI_2);
        _volumeView.transform = trans;
        
        _volumeView;
    })];
    [self btnSoundTapped:btnSound];
    
    [viewBottom addSubview:({
        btnSound = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnSound setFrame:CGRectMake(x, 10 , height, height)];
        [btnSound setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
        [btnSound setImage:[UIImage imageNamed:@"bb_volume_icon"] forState:UIControlStateNormal];
        [btnSound addTarget:self action:@selector(btnSoundTapped:) forControlEvents:UIControlEventTouchUpInside];
        btnSound;
    })];
    
    [viewBottom addSubview:({
        lblVideoTime = [[UILabel alloc] initWithFrame:CGRectMake(x - 35 - spacing, 0, 35, 44)];
        [lblVideoTime setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [lblVideoTime setTextAlignment:NSTextAlignmentCenter];
        [lblVideoTime setTextColor:[UIColor whiteColor]];
        [lblVideoTime setText:@"00:00"];
        [lblVideoTime setFont:[kBBUtility systemFontWithSize:11.0 fixedSize:YES]];
        lblVideoTime;
    })];
    
    [viewBottom addSubview:({
        btnPlayBottom = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnPlayBottom setFrame:CGRectMake(spacing, 10 , height, height)];
        [btnPlayBottom setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
        [btnPlayBottom setImage:[UIImage imageNamed:@"bb_play_icon"] forState:UIControlStateNormal];
        [btnPlayBottom setImage:[UIImage imageNamed:@"bb_pause_icon"] forState:UIControlStateSelected];

        [btnPlayBottom addTarget:self action:@selector(btnPlayTapped:) forControlEvents:UIControlEventTouchUpInside];
        btnPlayBottom;
    })];
    [viewBottom addSubview:({
        lblVideoCurrentTime = [[UILabel alloc] initWithFrame:CGRectMake(btnPlayBottom.frame.size.width + btnPlayBottom.frame.origin.x + spacing, 0, 35, 44)];
        [lblVideoCurrentTime setTextColor:[UIColor whiteColor]];
        [lblVideoCurrentTime setMinimumScaleFactor:0.5f];
        [lblVideoCurrentTime setTextAlignment:NSTextAlignmentCenter];
        [lblVideoCurrentTime setFont:[kBBUtility systemFontWithSize:11.0 fixedSize:YES]];
        [lblVideoCurrentTime setText:@"00:00"];
        lblVideoCurrentTime;
    })];
    [viewBottom addSubview:({
        CGFloat x = lblVideoCurrentTime.frame.size.width + lblVideoCurrentTime.frame.origin.x + spacing;
        sliderVideoSeek = [[UISlider alloc] initWithFrame:CGRectMake(x, 0, lblVideoTime.frame.origin.x - x - spacing, 44)];
        [sliderVideoSeek setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [sliderVideoSeek setMinimumTrackTintColor:[UIColor whiteColor]];
        [sliderVideoSeek setMaximumTrackTintColor:sliderMaximumTintColor];
        [sliderVideoSeek addTarget:self action:@selector(sliderVideoSeekValueChanged:) forControlEvents:UIControlEventValueChanged];
        [sliderVideoSeek addTarget:self action:@selector(sliderVideoSeekTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];

        sliderVideoSeek;
    })];
    
    [self setData];
}

- (void)setData {
    [kBBWebClient requestWithURLWithDefaultParameters:BB_URL_GET_HELP parameters:@{@"flag":@"video"} success:^(id response, NSData *responseData) {
        NSDictionary *dict = [response valueForKeyPath:@"data.video"];
        strVideoUrl = [dict objectForKey:@"tutorial_video"];
        strVideoUrlType = [dict objectForKey:@"video_type"];

        if([strVideoUrlType isEqualToString:@"youtube"]) {
            videoType = BBVideoTypeYoutube;
            [self setYoutubeVideo];
        }
        else if([strVideoUrlType isEqualToString:@"vimeo"]) {
            videoType = BBVideoTypeVimeo;
            [self setVimeoVideo];
        }
        else {
            videoType = BBVideoTypeNormal;
            [self setNormalVideo];
        }
        [BBLoadingView dismiss];
    } failure:^(NSError *error) {
        [BBLoadingView dismiss];
    }];
}

#pragma mark - Normal Video

- (void)setNormalVideo {
    [viewBottom setHidden:NO];
    _moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:strVideoUrl]];
    [_moviePlayerController setControlStyle:MPMovieControlStyleNone];
    [_moviePlayerController.view setFrame:self.view.bounds];
    _moviePlayerController.scalingMode = MPMovieScalingModeAspectFit;
    [self.view insertSubview:_moviePlayerController.view atIndex:0];
    [_moviePlayerController prepareToPlay];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishedPlaying:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoLoadStateChanged:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    
}

- (void)videoLoadStateChanged:(NSNotification *)notification {
    if(_moviePlayerController.loadState == MPMovieLoadStatePlaythroughOK){
        [_moviePlayerController pause];

        NSInteger minutes = (NSInteger)_moviePlayerController.duration / 60;
        NSInteger seconds = (NSInteger)_moviePlayerController.duration % 60;
        
        [lblVideoTime setText:[NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds]];
        [sliderVideoSeek setMaximumValue:_moviePlayerController.duration];
    }
}

- (void)videoDidFinishedPlaying:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [btnPlay setSelected:NO];
    [btnPlayBottom setSelected:NO];
    [self timerVideoInvalidate];
}

- (void)updatePlaybackTime {
    if(videoType == BBVideoTypeNormal) {
        NSInteger minutes = (NSInteger)_moviePlayerController.currentPlaybackTime / 60;
        NSInteger seconds = (NSInteger)_moviePlayerController.currentPlaybackTime % 60;

        [sliderVideoSeek setValue:_moviePlayerController.currentPlaybackTime];
        [lblVideoCurrentTime setText:[NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds]];
    }
}

- (void)startTimerVideo {
    timerVideo = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updatePlaybackTime) userInfo:nil repeats:YES];
}

- (void)timerVideoInvalidate {
    if([timerVideo isValid]) {
        [timerVideo invalidate];
        timerVideo = nil;
    }
}

#pragma mark - Youtube 

- (void)setYoutubeVideo {
    [viewBottom setHidden:NO];
    _youTubePlayerView = [[BBYoutubePlayerView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64-44)];
    [_youTubePlayerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view insertSubview:_youTubePlayerView atIndex:0];
    
    
    //@"M7lc1UVf-VE";
    NSString *videoId = [[BBUtility sharedInstance] getYoutubeVideoIdFromUrlString:strVideoUrl];
    
    // For a full list of player parameters, see the documentation for the HTML5 player
    // at: https://developers.google.com/youtube/player_parameters?playerVersion=HTML5
    NSDictionary *playerVars = @{
                                 @"controls" : @0,
                                 @"playsinline" : @1,
                                 @"autohide" : @1,
                                 @"showinfo" : @0,
                                 @"modestbranding" : @1,
                                 };
    _youTubePlayerView.delegate = self;
    
    [_youTubePlayerView loadWithVideoId:videoId playerVars:playerVars];
}

- (void)playerViewDidBecomeReady:(BBYoutubePlayerView *)playerView {
    NSInteger minutes = (NSInteger)_youTubePlayerView.duration / 60;
    NSInteger seconds = (NSInteger)_youTubePlayerView.duration % 60;
    [lblVideoTime setText:[NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds]];
    [sliderVideoSeek setMaximumValue:_youTubePlayerView.duration];
}

- (void)playerView:(BBYoutubePlayerView *)ytPlayerView didChangeToState:(YTPlayerState)state {

    [btnPlayBottom setSelected:state == kBBYoutubePlayerStatePlaying];

}

- (void)playerView:(BBYoutubePlayerView *)playerView didPlayTime:(float)playTime {
    
    CGFloat progress = playTime/_youTubePlayerView.duration;
    [sliderVideoSeek setValue:progress];
    
    NSInteger minutes = (NSInteger)playTime / 60;
    NSInteger seconds = (NSInteger)playTime % 60;
    
    [sliderVideoSeek setValue:playTime];
    [lblVideoCurrentTime setText:[NSString stringWithFormat:@"%02ld:%02ld",(long)minutes,(long)seconds]];
}


#pragma mark - Vimeo

- (void)setVimeoVideo {
    [viewBottom setHidden:YES];
    CGFloat width = self.view.frame.size.width - 10;
    CGFloat height = self.view.frame.size.height - 64 - 10;
    
    _webviewVimeoVideo = [[UIWebView alloc] initWithFrame:CGRectMake(0, 64, width, height)];
    [_webviewVimeoVideo setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_webviewVimeoVideo setAllowsInlineMediaPlayback:YES];
    [_webviewVimeoVideo.scrollView setScrollEnabled:NO];
    [_webviewVimeoVideo.scrollView setBounces:NO];
    [_webviewVimeoVideo setBackgroundColor:[UIColor clearColor]];
    [_webviewVimeoVideo setOpaque:NO];
    [self.view addSubview:_webviewVimeoVideo];
    [_webviewVimeoVideo loadHTMLString:[self vimeoHTMLString:self.view.frame.size] baseURL:[NSURL URLWithString:@"vimeo.com"]];
}

- (NSString *)vimeoHTMLString:(CGSize)size {
    CGFloat width = size.width - 10;
    CGFloat height = size.height - 64 - 10;
    
    NSString *htmlString = [NSString stringWithFormat:@"<html><head><script type=\"text/javascript\"></script></head><body><iframe src=\"http://player.vimeo.com/video/%@?title=0&byline=0&portrait=0\"width=\"%f\" height=\"%f\" frameborder=\"0\" autoplay=\"1\"=></iframe></body></html>",[strVideoUrl lastPathComponent],width,height];

    return htmlString;
}

#pragma mark - Orientation Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    if(videoType == BBVideoTypeVimeo) {
        [_webviewVimeoVideo loadHTMLString:[self vimeoHTMLString:size] baseURL:[NSURL URLWithString:@"vimeo.com"]];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if(videoType == BBVideoTypeVimeo) {
        [_webviewVimeoVideo loadHTMLString:[self vimeoHTMLString:self.view.frame.size] baseURL:[NSURL URLWithString:@"vimeo.com"]];
    }
}

#pragma mark - Buttons

- (void)btnPlayTapped:(UIButton *)sender {
    [sender setSelected:![sender isSelected]];
    if([sender isSelected]) {
        if(videoType == BBVideoTypeNormal) {
            [_moviePlayerController play];
            [self startTimerVideo];
        }
        else if(videoType == BBVideoTypeYoutube) {
            [_youTubePlayerView playVideo];
        }
    }
    else {
        if(videoType == BBVideoTypeNormal) {
            [_moviePlayerController pause];
            [self timerVideoInvalidate];
        }
        else if(videoType == BBVideoTypeYoutube) {
            [_youTubePlayerView pauseVideo];
        }
    }
}

- (void) btnSoundTapped:(id) sender {
    CGFloat animationDuration = .3;
    NSInteger animationDelay = 0;
    CGFloat volumeHeight = 90;
    
    [sender setUserInteractionEnabled:NO];
    if (_volumeView.hidden) {
        _volumeView.hidden = NO;
        [UIView animateWithDuration:animationDuration
                              delay:animationDelay
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGRect rect = _volumeView.frame;
                             rect.origin.y -= volumeHeight;
                             rect.size.height += volumeHeight;
                             _volumeView.frame = rect;
                         }
                         completion:^(BOOL finished) {
                             _volumeView.hidden = NO;
                             [sender setUserInteractionEnabled:YES];
                         }];
    } else {
        _volumeView.hidden = NO;
        [UIView animateWithDuration:animationDuration
                              delay:animationDelay
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             CGRect rect = _volumeView.frame;
                             rect.origin.y += volumeHeight;
                             rect.size.height -= volumeHeight;
                             _volumeView.frame = rect;
                         }
                         completion:^(BOOL finished) {
                             _volumeView.hidden = YES;
                             [sender setUserInteractionEnabled:YES];
                         }];
    }
}

#pragma mark - Slider

- (void)sliderVideoSeekTouchUpInside:(UISlider *)sender {
    if(videoType == BBVideoTypeNormal) {
        [self startTimerVideo];
    }
}

- (void)sliderVideoSeekValueChanged:(UISlider *)sender {
    if(videoType == BBVideoTypeNormal) {
        _moviePlayerController.currentPlaybackTime = sender.value;
        [self updatePlaybackTime];
        [self timerVideoInvalidate];
    }
    else if(videoType == BBVideoTypeYoutube) {
        float seekToTime = sliderVideoSeek.value;
        
        [self.youTubePlayerView seekToSeconds:seekToTime allowSeekAhead:YES];
    }
}

@end
