/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "BBContants.h"


@interface BBReportOptionCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *imgView;
@property (nonatomic, retain) IBOutlet UILabel *lblTitle;
@property (nonatomic, retain) IBOutlet UIView *viewSelectedBG;
@property (nonatomic, retain) IBOutlet UILabel *lblPostCount;
@property (nonatomic, retain) IBOutlet UIView *viewLine;

@end


@interface BBBugReportOptionsView : UIViewController <UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
    BBTopView *viewTop;
    NSMutableArray *arrOptions, *arrQuestions;
    IBOutlet UITableView *tblViewOptions;
    UIWindow *window;
    NSInteger pastRequestCount;
    
    BOOL isCallForService;
}

+ (void) showBugReportOptionView;

@end