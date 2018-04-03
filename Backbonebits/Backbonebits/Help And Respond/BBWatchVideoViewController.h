/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "BBContants.h"

typedef enum : NSUInteger {
    BBVideoTypeNormal,
    BBVideoTypeYoutube,
    BBVideoTypeVimeo,
} BBVideoType;

@interface BBWatchVideoViewController : UIViewController <YTPlayerViewDelegate>
{
    BBTopView *viewTop;
    IBOutlet UIView *viewBottom;
    IBOutlet UIButton *btnPlay;
    IBOutlet UIButton *btnPlayBottom;
    IBOutlet UISlider *sliderVideoSeek;
    IBOutlet UILabel *lblVideoCurrentTime;
    IBOutlet UILabel *lblVideoTime;
    IBOutlet UIButton *btnSound;
    
    NSString *strVideoUrl;
    NSString *strVideoUrlType;
    NSTimer *timerVideo;
    
    BBVideoType videoType;
}

@property (nonatomic, retain) MPVolumeView *volumeView;
@property (nonatomic, retain) MPMoviePlayerController *moviePlayerController;
@property (nonatomic, retain) BBYoutubePlayerView *youTubePlayerView;
@property (nonatomic, retain) UIWebView *webviewVimeoVideo;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;


@end
