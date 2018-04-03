/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "BBContants.h"

@interface BBPastReportsCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIImageView *imgViewRequestType;
@property (nonatomic, retain) IBOutlet UILabel *lblTime;
@property (nonatomic, retain) IBOutlet UILabel *lblDate;
@property (nonatomic, retain) IBOutlet UILabel *lblHours;
@property (nonatomic, retain) IBOutlet UILabel *lblRequestId;
@property (nonatomic, retain) IBOutlet UILabel *lblMessage;
@property (nonatomic, retain) IBOutlet UIImageView *imgViewDetailDisclousure;

@property (nonatomic, retain) IBOutlet UIView *viewCount;
@property (nonatomic, retain) IBOutlet UILabel *lblMessageCount;
@property (nonatomic, retain) IBOutlet UILabel *lblReplyCount;
@property (nonatomic, retain) IBOutlet UIImageView *imgMessageType;

@property (nonatomic, retain) UIView *viewLine;

@end

@interface BBPastReportsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    BBTopView *viewTop;
    IBOutlet UITableView *tblViewPastReports;
    UILabel *lblNoDataFound;
    
    BOOL isCameFromDetail;
}

@property (nonatomic, strong) NSMutableArray *arrReports;

@end
