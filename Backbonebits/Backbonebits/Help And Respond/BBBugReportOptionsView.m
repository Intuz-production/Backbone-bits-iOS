/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBBugReportOptionsView.h"

#define kBugReportOptionViewTag 123456
#define kDefaultHeight 65

static NSString *const kWatchVideoImage = @"bb_watch_video_icon";
static NSString *const kReadFAQImage = @"bb_read_FAQ_icon";
static NSString *const kViewHelpScreensImage = @"bb_view_helpscreen_icon";
static NSString *const kSendTextRequestImage = @"bb_send_text_request_icon";
static NSString *const kSendScreenshotImage = @"bb_send_screenshot_icon";
static NSString *const kSendVideoImage = @"bb_send_video_icon";
static NSString *const kPastRequestsImage = @"bb_past_request_icon";

static NSString *const kBBTitle = @"Title";
static NSString *const kBBImageName = @"Image Name";


@implementation BBReportOptionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}

- (void)loadLayout {
    [_imgView setBackgroundColor:[UIColor clearColor]];
    
    [_lblTitle setTextColor:kBBRGBCOLOR(112.0, 112.0, 112.0)];
    [_lblTitle setBackgroundColor:[UIColor clearColor]];
    
    [_lblPostCount setTextColor:[UIColor whiteColor]];
    [_lblPostCount setBackgroundColor:kBBRGBCOLOR(218.0, 114.0, 114.0)];
    [_lblPostCount.layer setCornerRadius:_lblPostCount.frame.size.height/2];
    [_lblPostCount setClipsToBounds:YES];
    [_lblPostCount setTextAlignment:NSTextAlignmentCenter];
    
    [_viewLine setBackgroundColor:kBBRGBCOLOR(236.0, 236.0, 236.0)];
    [_viewSelectedBG setBackgroundColor:kBBRGBCOLOR(247.0, 247.0, 247.0)];
}

@end

@implementation BBBugReportOptionsView

+ (void) showBugReportOptionView {
    UINavigationController *navController = [kBBUtility getBBNavigationController];
    [navController popToRootViewControllerAnimated:YES];
    
    UIViewController * viewController = [kBBUtility getVisibleViewControllerFrom:[kBBUtility getWindowObject].rootViewController];
    if ([[navController.viewControllers firstObject] isKindOfClass:[BBBugReportOptionsView class]]) {
        [(BBBugReportOptionsView *)[navController.viewControllers firstObject] setData];
    }
    [viewController presentViewController:navController animated:YES completion:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadLayout];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [kBBUtility shouldRotateOriantation:YES];
    if (arrOptions.count <= 0 && !isCallForService) {
        [BBLoadingView show];
        [self setData];
    }
    [self refreshRequestCount];
}

#pragma mark - Other Methods

- (void) btnCloseTapped:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)loadLayout {
    [self.view setBackgroundColor:kBBRGBCOLOR(247.0, 247.0, 247.0)];
    
    [self.view addSubview:({
        viewTop = [BBTopView getBBTopView];
        [viewTop.lblTitle setText:kGetHelp];
        [viewTop.btnRight setTitle:@"Close" theme:BBTopBarButtonThemeActive target:self selector:@selector(btnCloseTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addChildViewController:viewTop];
        viewTop.view;
    })];
    
    [tblViewOptions setBounces:NO];
    [tblViewOptions setBackgroundColor:[UIColor clearColor]];
    [tblViewOptions setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)setData {
    [BBLoadingView show];
    tblViewOptions.hidden = YES;
    isCallForService = YES;
    
    pastRequestCount = 0;
    if(!arrOptions) {
        arrOptions = [[NSMutableArray alloc] init];
    }
    else {
        [arrOptions removeAllObjects];
    }
    
    NSDictionary * params = @{@"device_id":[BBUtility deviceUUID]};
    
    [kBBWebClient requestWithURLWithDefaultParameters:BB_URL_GET_STATUS_MENU parameters:params success:^(id response, NSData *responseData) {
        isCallForService = NO;
        
        [arrOptions addObject:@{kBBTitle : kSendTextRequest, kBBImageName : kSendTextRequestImage}];
        [arrOptions addObject:@{kBBTitle : kSendScreenshot, kBBImageName : kSendScreenshotImage}];
        [arrOptions addObject:@{kBBTitle : kSendVideo, kBBImageName : kSendVideoImage}];
        [arrOptions addObject:@{kBBTitle : kPastRequests, kBBImageName : kPastRequestsImage}];
        
        NSInteger indexToUse = 0;
        if([[response valueForKeyPath:@"video.status"] boolValue]) {
            [arrOptions insertObject:@{kBBTitle : kWatchVideo, kBBImageName : kWatchVideoImage} atIndex:indexToUse];
            indexToUse += 1;
        }
        if([[response valueForKeyPath:@"faq.status"] boolValue]) {
            [arrOptions insertObject:@{kBBTitle : kReadFAQ, kBBImageName : kReadFAQImage} atIndex:indexToUse];
            indexToUse += 1;
        }
        if([[response valueForKeyPath:@"image.status"] boolValue]) {
            [arrOptions insertObject:@{kBBTitle : kViewHelpScreens, kBBImageName : kViewHelpScreensImage} atIndex:indexToUse];
        }
        tblViewOptions.hidden = NO;
        [tblViewOptions reloadData];
        [BBLoadingView dismiss];
        
    } failure:^(NSError *error) {
        isCallForService = NO;
        
        NSLog(@"%@",[error localizedDescription]);
        [BBLoadingView dismiss];
        tblViewOptions.hidden = NO;
    }];
}

- (void) refreshRequestCount {
    [[Backbonebits sharedInstance] getUnreadPastRequestCount:^(NSInteger unreadCount, NSError *error) {
        if (!error) {
            pastRequestCount = unreadCount;
            [tblViewOptions reloadData];
        }
    }];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kDefaultHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrOptions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBReportOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BBReportOptionCell" forIndexPath:indexPath];
    [cell loadLayout];
    
    if (indexPath.row%2 == 0) {
        [cell.viewSelectedBG setBackgroundColor:[UIColor whiteColor]];
    } else {
        [cell.viewSelectedBG setBackgroundColor:kBBRGBCOLOR(247.0, 247.0, 247.0)];
    }
    
    NSDictionary *dict = [arrOptions objectAtIndex:indexPath.row];
    NSString *strText = [dict objectForKey:kBBTitle];
    [cell.lblTitle setText:strText];
    [cell.imgView setImage:[UIImage imageNamed:[dict objectForKey:kBBImageName]]];
    if ([strText isEqualToString:kPastRequests] && pastRequestCount > 0) {
        [cell.lblPostCount setHidden:NO];
        [cell.lblPostCount setText:[NSString stringWithFormat:@"%ld",(long)pastRequestCount]];
        [cell.lblPostCount sizeToFit];
        CGRect rect = cell.lblPostCount.frame;
        if (rect.size.width < 27)
            rect.size.width = 27;
        else
            rect.size.width = rect.size.width + 10;
        rect.size.height = 27;
        rect.origin.x = tableView.frame.size.width-(rect.size.width + 10);
        [cell.lblPostCount setFrame:rect];
    } else {
        [cell.lblPostCount setHidden:YES];
    }
    
    [cell.viewLine setHidden:NO];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= arrOptions.count)
        return;
    
    NSString *strText = [[arrOptions objectAtIndex:indexPath.row] objectForKey:kBBTitle];
    if([strText isEqualToString:kWatchVideo]) {
        BBWatchVideoViewController *viewWatchVideo = [[BBWatchVideoViewController alloc] init];
        [kBBUtility pushViewController:viewWatchVideo animated:YES];
    }
    else if([strText isEqualToString:kReadFAQ]) {
        [BBLoadingView show];
        [self loadFAQData];
    }
    else if([strText isEqualToString:kViewHelpScreens]) {
        BBHelpScreensViewController *viewHelpScreen = [[BBHelpScreensViewController alloc] init];
        [kBBUtility pushViewController:viewHelpScreen animated:YES];
    }
    else if([strText isEqualToString:kSendScreenshot]) {
        [kBBUtility sendConfirmationAlert:BBAssistiveControlTypeImage withComplete:^(BOOL isPerform) {
            if (isPerform) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kBBDefaulAlertWaitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        [self showImageCapture];
                    }];
                });
            }
        }];
    }
    else if ([strText isEqualToString:kSendTextRequest]) {
        [BBSendReportViewController showViewWithFileUrl:nil attachmentType:@(BBAttachmentTypeUndefined)];
    }
    else if([strText isEqualToString:kSendVideo]) {
        [kBBUtility sendConfirmationAlert:BBAssistiveControlTypeVideo withComplete:^(BOOL isPerform) {
            if (isPerform) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kBBDefaulAlertWaitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        [self startScreenRecording];
                    }];
                });
            }
        }];
        return;
    }
    else if([strText isEqualToString:kPastRequests]) {
        [BBLoadingView show];
        [[Backbonebits sharedInstance] openPastReports:^(BOOL success) {
            [BBLoadingView dismiss];
        }];
    }
}

#pragma mark - FAQ.

- (void) loadFAQData {
    NSDictionary *params = @{@"flag":@"faq",
                             @"ver_id":kBB_APP_VERSION_NUMBER_STRING};
    [kBBWebClient requestWithURLWithDefaultParameters:BB_URL_GET_HELP parameters:params success:^(id response, NSData *responseData) {
        if(!arrQuestions) {
            arrQuestions = [[NSMutableArray alloc] init];
        }
        
        [arrQuestions removeAllObjects];
        [[response valueForKeyPath:@"data.faq"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *dict = [obj mutableCopy];
            [dict setObject:@(NO) forKey:@"isExpanded"];
            [arrQuestions addObject:dict];
        }];
        
        if (arrQuestions.count > 0) {
            BBReadFAQViewController *viewReadFAQ = [kBBStoryboard instantiateViewControllerWithIdentifier:@"BBReadFAQViewController"];
            viewReadFAQ.selectedQuestionId = -1;
            viewReadFAQ.arrMainQuestions = [[NSMutableArray alloc] initWithArray:arrQuestions];
            [kBBUtility pushViewController:viewReadFAQ animated:YES];
        } else {
            [[BBUtility sharedInstance] showAlertController:@"" message:@"No FAQ found" actionTitles:@[@"Ok"] completionBlock:nil];
        }
        [BBLoadingView dismiss];
    } failure:^(NSError *error) {
        [[BBUtility sharedInstance] showAlertController:@"" message:[error localizedDescription] actionTitles:@[@"Ok"] completionBlock:nil];
        [BBLoadingView dismiss];
    }];
}

#pragma mark - Image Capture

- (void)showImageCapture {
    [kBBUtility assistiveControlWithType:BBAssistiveControlTypeImage];
}

#pragma mark - Video Recording
- (void)startScreenRecording {
    [kBBUtility assistiveControlWithType:BBAssistiveControlTypeVideo];
}

@end
