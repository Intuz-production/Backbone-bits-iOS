/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBPastReportsViewController.h"


@implementation BBPastReportsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self loadLayout];
    }
    return self;
}

- (void)loadLayout {
    [_lblTime setFont:[kBBUtility systemFontWithSize:12.0 fixedSize:YES]];
    [_lblTime setTextColor:[UIColor grayColor]];
    [_lblTime setMinimumScaleFactor:0.4];
    [_lblTime setNumberOfLines:0];
    
    [_lblDate setFont:[kBBUtility systemFontWithSize:10.0 fixedSize:YES]];
    [_lblDate setTextColor:[UIColor lightGrayColor]];
    [_lblDate setMinimumScaleFactor:0.5];
    [_lblDate setNumberOfLines:1];
    
    [_lblHours setFont:[kBBUtility systemFontWithSize:10.0 fixedSize:YES]];
    [_lblHours setTextColor:[UIColor lightGrayColor]];
    [_lblHours setMinimumScaleFactor:0.5];
    [_lblHours setNumberOfLines:1];

    [_lblMessage setFont:[kBBUtility systemFontWithSize:15.0]];
    [_lblMessage setMinimumScaleFactor:.5];
    [_lblMessage setBackgroundColor:[UIColor clearColor]];
    [_lblMessage setTextColor:kBBRGBCOLOR(92.0, 92.0, 92.0)];
    [_lblMessage setNumberOfLines:2];
    
    [_lblMessageCount setFont:[kBBUtility systemFontWithSize:12.0 fixedSize:YES]];
    [_lblMessageCount setClipsToBounds:YES];
    [_lblReplyCount setFont:[kBBUtility systemFontWithSize:12.0 fixedSize:YES]];
    [_lblReplyCount setClipsToBounds:YES];
    
    [self addSubview:({
        if(!_viewLine) {
            _viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
        }
        
        [_viewLine setBackgroundColor:kBBRGBCOLOR(232.0, 232.0, 232.0)];
        [_viewLine setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        _viewLine;
    })];
}

@end

@implementation BBPastReportsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    isCameFromDetail = NO;
    [self loadLayout];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [tblViewPastReports reloadData];
    if (isCameFromDetail) {
        isCameFromDetail = NO;
        [BBLoadingView show];
        [self setData];
    }
}

#pragma mark - Other Methods

- (void)btnBackTapped:(id)sender {
    [kBBUtility popViewControllerAnimated:YES];
}

- (void)loadLayout {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    [self.view addSubview:({
        viewTop = [BBTopView getBBTopView];
        [viewTop.lblTitle setText:kPastRequests];
        [viewTop.btnLeft setTitle:@"Back" theme:BBTopBarButtonThemeBack target:self selector:@selector(btnBackTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addChildViewController:viewTop];
        viewTop.view;
    })];
    
    // Table Configuration
    [tblViewPastReports setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tblViewPastReports setSeparatorColor:[UIColor clearColor]];
    [tblViewPastReports setBackgroundColor:[UIColor clearColor]];
}

- (void)setData {
    
    if (!_arrReports)
        _arrReports = [[NSMutableArray alloc] init];
    
    NSDictionary *dictParameters = @{@"flag":@"list",
                                     @"device_id":[BBUtility deviceUUID]};
    [kBBWebClient requestWithURLWithDefaultParameters:BB_URL_GET_RESPOND parameters:dictParameters success:^(id response, NSData *responseData) {
        tblViewPastReports.hidden = NO;
        if ([[response objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
            if ([[response objectForKey:@"data"] count] > 0) {
                _arrReports = [response objectForKey:@"data"];
            }
        }
        [tblViewPastReports reloadData];
        [BBLoadingView dismiss];
    
    } failure:^(NSError *error) {
        
        [_arrReports removeAllObjects];
        [tblViewPastReports reloadData];
        [BBLoadingView dismiss];
    }];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_arrReports count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBPastReportsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BBPastReportsCell" forIndexPath:indexPath];
    
    [cell loadLayout];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary *dict = [_arrReports objectAtIndex:indexPath.row];
    
    [cell.lblTime setText:[dict objectForKey:@"date"]];
    [cell.lblDate setText:[dict objectForKey:@"timestamp_date"]];
    [cell.lblHours setText:[dict objectForKey:@"timestamp"]];
    
    NSString *strText = [NSString stringWithFormat:@"%@",[dict objectForKey:@"message_id"]];
    [cell.lblRequestId setTextColor:[UIColor lightGrayColor]];
    [cell.lblRequestId setText:strText];
    
    NSString *strMessage = [kBBUtility bbStringByStrippingHTML:[dict objectForKey:@"message"]];
    strMessage = [strMessage stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    strMessage = [strMessage stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    [cell.lblMessage setText:strMessage];
    CGRect frame = [cell.lblMessage frame];
    frame.size = [kBBUtility labelSizeForString:strMessage width:cell.lblMessage.frame.size.width font:cell.lblMessage.font];
    if (frame.size.height > 45) {
        frame.size.height = 45;
    }
    frame.size.width = tableView.frame.size.width - 135;
    [cell.lblMessage setFrame:frame];
    
    NSString * messageCount = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"message_count"] description]];
    [cell.lblMessageCount setText:messageCount];
    [cell.lblMessageCount sizeToFit];
    CGRect messageRect = cell.lblMessageCount.frame;
    if (messageRect.size.width < 24)
        messageRect.size.width = 24;
    else
        messageRect.size.width = messageRect.size.width + 10;
    messageRect.size.height = 24;
    messageRect.origin.x = 0;
    [cell.lblMessageCount setFrame:messageRect];
    [cell.lblMessageCount.layer setCornerRadius:cell.lblMessageCount.frame.size.height/2];
    
    CGRect rect = cell.imgMessageType.frame;
    rect.origin.x = cell.lblMessageCount.frame.origin.x + cell.lblMessageCount.frame.size.width + 5;
    [cell.imgMessageType setFrame:rect];
    
    NSString *name = [dict objectForKey:@"name"];
    NSString *ownerName = [dict objectForKey:@"owner_name"];
    if ([[name lowercaseString] isEqualToString:[ownerName lowercaseString]]) {
        [cell.imgMessageType setImage:[UIImage imageNamed:@"bb_message_icon"]];
    } else {
        [cell.imgMessageType setImage:[UIImage imageNamed:@"bb_reply_icon"]];
    }
    
    NSString * replyCount = [NSString stringWithFormat:@"%@",[[dict objectForKey:@"unread_count"] description]];
    if ([replyCount integerValue] > 0) {
        [cell.lblReplyCount setText:replyCount];
        [cell.lblReplyCount sizeToFit];
        CGRect replyRect = cell.lblReplyCount.frame;
        if (replyRect.size.width < 24)
            replyRect.size.width = 24;
        else
            replyRect.size.width = replyRect.size.width + 10;
        replyRect.size.height = 24;
        replyRect.origin.x = cell.viewCount.frame.size.width-replyRect.size.width;
        [cell.lblReplyCount setFrame:replyRect];
        [cell.lblReplyCount.layer setCornerRadius:cell.lblReplyCount.frame.size.height/2];
        [cell.lblReplyCount setHidden:NO];
    } else {
        [cell.lblReplyCount setHidden:YES];
    }
    
    if ([replyCount integerValue] > 0) {
        [cell.containerView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.2]];
    } else {
        [cell.containerView setBackgroundColor:[UIColor whiteColor]];
    }
    
    NSString *strRequestType = [dict objectForKey:@"request_type"];
    NSString *strRequestTypeImageName = @"";
    if([strRequestType isEqualToString:@"query"]) {
        strRequestTypeImageName = ([replyCount integerValue]>0)?@"bb_query_icon_selected":@"bb_query_icon";
    }
    else if([strRequestType isEqualToString:@"bug"]) {
        strRequestTypeImageName = ([replyCount integerValue]>0)?@"bb_bug_icon_selected":@"bb_bug_icon";
    }
    else if([strRequestType isEqualToString:@"feedback"]) {
        strRequestTypeImageName = ([replyCount integerValue]>0)?@"bb_feedback_icon_selected":@"bb_feedback_icon";
    }
    [cell.imgViewRequestType setImage:[UIImage imageNamed:strRequestTypeImageName]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    isCameFromDetail = YES;
    BBRequestDetailViewController *viewRequestDetail = [[BBRequestDetailViewController alloc] init];
    viewRequestDetail.requestId = [[_arrReports objectAtIndex:indexPath.row] objectForKey:@"message_id"];
    [kBBUtility pushViewController:viewRequestDetail animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -

@end
