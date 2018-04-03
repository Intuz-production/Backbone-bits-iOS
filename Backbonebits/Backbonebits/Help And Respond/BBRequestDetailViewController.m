//
//  BBRequestDetailView.m
//  Backbonebits
//
//  Created by Backbonebits
//
//

/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBRequestDetailViewController.h"

#define kBBDate @"Date"
#define kBBDateData @"Date Data"
#define kBBWebViewHeight @"WebViewHeight"

@implementation BBRequestDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self loadLayout];
    [self setData];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Other Methods

- (void)btnBackTapped:(id)sender {
    [kBBUtility popViewControllerAnimated:YES];
}

- (void)loadLayout {
    arrFileUrls = [[NSMutableArray alloc] init];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    [self.view addSubview:({
        viewTop = [BBTopView getBBTopView];
        [viewTop.lblTitle setText:@"Request Detail"];
        [viewTop.btnLeft setTitle:@"Back" theme:BBTopBarButtonThemeBack target:self selector:@selector(btnBackTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addChildViewController:viewTop];
        viewTop.view;
    })];
    
    [self.view addSubview:({
        viewRequestType = [[UIView alloc] initWithFrame:CGRectMake(0, viewTop.view.frame.origin.y + viewTop.view.frame.size.height, kBBScreenWidth, 80)];
        [viewRequestType addSubview:({
            imgViewRequestType = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 55, 55)];
            imgViewRequestType;
        })];
        [viewRequestType addSubview:({
            lblRequestType = [[UILabel alloc] initWithFrame:CGRectMake(85, 10, viewRequestType.frame.size.width - 80 - 30, 20)];
            [lblRequestType setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [lblRequestType setTextColor:kBBRGBCOLOR(92, 92, 92)];
            lblRequestType;
        })];
        [viewRequestType addSubview:({
            lblRequestId = [[UILabel alloc] initWithFrame:CGRectMake(lblRequestType.frame.origin.x, lblRequestType.frame.origin.y + lblRequestType.frame.size.height + 10, lblRequestType.frame.size.width, 20)];
            [lblRequestId setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [lblRequestId setTextColor:kBBRGBCOLOR(92, 92, 92)];
            lblRequestId;
        })];
        viewRequestType;
    })];

    [self.view addSubview:({
        CGFloat y = viewRequestType.frame.origin.y + viewRequestType.frame.size.height;
        CGRect frame = CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height - y);
        tblViewRequests = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        [tblViewRequests setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [tblViewRequests registerClass:[BBRequestDetailCell class] forCellReuseIdentifier:@"BBRequestDetailCell"];
        [tblViewRequests setDelegate:self];
        [tblViewRequests setDataSource:self];
        [tblViewRequests setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [tblViewRequests setKeyboardDismissMode:UIScrollViewKeyboardDismissModeInteractive];
        [tblViewRequests setBackgroundColor:[UIColor clearColor]];
        tblViewRequests;
    })];
    
    messageInputView = [[BBMessageInputView alloc] init];
    messageInputView.delegate = self;
    messageInputView.tableView = tblViewRequests;
    [self.view addSubview:messageInputView];
    [messageInputView adjustPosition];
    
    [self.view addSubview:({
        CGFloat y = tblViewRequests.frame.origin.y + tblViewRequests.frame.size.height - 70;
        viewAttachment = [[UIView alloc] initWithFrame:CGRectMake(5, y - 40, 190, 70)];
        [viewAttachment setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [viewAttachment setBackgroundColor:kBBRGBCOLOR(11.0, 11.0, 11.0)];

        [viewAttachment addSubview:({
            UIImageView *imgViewArrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, viewAttachment.frame.size.height, 20, 10)];
            [imgViewArrow setCenter:CGPointMake(messageInputView.mediaButton.center.x, imgViewArrow.center.y)];
            [imgViewArrow setImage:[UIImage imageNamed:@"bb_popup_arrow"]];
            imgViewArrow;
        })];
        
        [viewAttachment addSubview:({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
            [layout setMinimumInteritemSpacing:10.0];
            [layout setMinimumLineSpacing:10.0];
            [layout setItemSize:CGSizeMake(50, 50)];
            
            collectionViewAttachment = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 10, viewAttachment.frame.size.width - 20, 50) collectionViewLayout:layout];
            [collectionViewAttachment setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [collectionViewAttachment setBackgroundColor:[UIColor whiteColor]];
            [collectionViewAttachment registerClass:[BBAttachmentCell class] forCellWithReuseIdentifier:@"BBAttachmentCell"];
            [collectionViewAttachment setDelegate:self];
            [collectionViewAttachment setDataSource:self];
            [collectionViewAttachment setBackgroundColor:[UIColor clearColor]];
            [collectionViewAttachment setClipsToBounds:NO];
            collectionViewAttachment;
        })];
        [viewAttachment setHidden:YES];
        viewAttachment;
    })];
    
    NSString *filePath = BB_ATTACHMENT_FILE(KBBImageFileName);
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

- (void)setData {
    [BBLoadingView show];
    arrRequests = [[NSMutableArray alloc] init];
    NSDictionary *dictParameters = @{@"request_id":_requestId,
                                     @"flag":@"listdetail"};
    [kBBWebClient requestWithURLWithDefaultParameters:BB_URL_GET_RESPOND_DETAIL parameters:dictParameters success:^(id response, NSData *responseData) {
        NSDictionary *dictTemp = [response objectForKey:@"data"];
        NSDictionary *dictRequests = [dictTemp objectForKey:@"request_data"];
    
        NSMutableArray *timestampArray = [[NSMutableArray alloc] init];
        [[dictRequests allKeys] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSDateFormatter *formator = [[NSDateFormatter alloc] init];
            [formator setDateFormat:@"yyyy-MM-dd"];
            NSDate *date1 = [formator dateFromString:obj];
            [timestampArray addObject:@([date1 timeIntervalSince1970])];
        }];
        
        NSArray *arrRequestDates = [timestampArray sortedArrayUsingComparator:^NSComparisonResult(NSNumber *a, NSNumber *b) {
            return [a compare:b] == NSOrderedAscending;
        }];
        
        [arrRequestDates enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[obj doubleValue]];
            NSDateFormatter *formator = [[NSDateFormatter alloc] init];
            [formator setDateFormat:@"yyyy-MM-dd"];
            NSString * strDate = [formator stringFromDate:date];
            
            NSArray *arrTemp = [dictRequests objectForKey:strDate];
            [arrRequests addObject:@{kBBDate:strDate,
                                     kBBDateData:arrTemp}];
        }];
        
        strRequestType = [dictTemp objectForKey:@"request_type"];
        strRequestByName = [dictTemp objectForKey:@"name"];
        strRequestByEmail = [dictTemp objectForKey:@"email"];
        NSString *strRequestTypeImageName = @"";
        if([strRequestType isEqualToString:@"query"]) {
            strRequestTypeImageName = @"bb_query_icon";
        }
        else if([strRequestType isEqualToString:@"bug"]) {
            strRequestTypeImageName = @"bb_bug_icon";
        }
        else if([strRequestType isEqualToString:@"feedback"]) {
            strRequestTypeImageName = @"bb_feedback_icon";
        }
        [imgViewRequestType setImage:[UIImage imageNamed:strRequestTypeImageName]];
        [lblRequestType setText:[strRequestType capitalizedString]];
        [lblRequestId setAttributedText:({
            NSString *strText = [NSString stringWithFormat:@"Request# %@",_requestId];
            NSDictionary *attibutes = @{NSForegroundColorAttributeName : [UIColor lightGrayColor]};
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:strText attributes:nil];
            [attributedString addAttributes:attibutes range:[attributedString.string rangeOfString:@"Request#" options:NSCaseInsensitiveSearch]];
            attributedString;
        })];
        
        [tblViewRequests reloadData];
        [BBLoadingView dismiss];
    } failure:^(NSError *error) {
        [BBLoadingView dismiss];
    }];
}

- (NSMutableArray*)deepMutableCopyOfArray:(NSArray*)array error:(NSError**)outError
{
    NSError* error = nil;
    NSData* serializedData = [NSPropertyListSerialization dataWithPropertyList:array format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
    if( !serializedData ) {
        if( outError ) *outError = error;
        return nil;
    }
    
    NSMutableArray* mutableCopy = [NSPropertyListSerialization propertyListWithData:serializedData options:NSPropertyListMutableContainersAndLeaves format:NULL error:&error];
    if( !mutableCopy ) {
        if( outError ) *outError = error;
        return nil;
    }
    
    return mutableCopy;
}

#pragma mark - Buttons

- (void)btnDeleteAttachmentTapped:(id)sender {
    NSURL *fileUrl = [arrFileUrls objectAtIndex:[sender tag] - 1];
    if([[NSFileManager defaultManager] fileExistsAtPath:BB_ATTACHMENT_FILE(fileUrl.path)]) {
        [[NSFileManager defaultManager] removeItemAtPath:BB_ATTACHMENT_FILE(fileUrl.path) error:nil];
    }
    [arrFileUrls removeObject:fileUrl];
    [collectionViewAttachment reloadData];
    if(![arrFileUrls count]) {
        [messageInputView.mediaButton setSelected:NO];
        [viewAttachment setHidden:YES];
    }
}

- (void) resetAttachmentView {
    [arrFileUrls removeAllObjects];
    
    if(![arrFileUrls count]) {
        [messageInputView.mediaButton setSelected:NO];
        [viewAttachment setHidden:YES];
    }
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"HeaderView"];
    
    UIView *viewVerticalLine;
    if(!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"HeaderView"];
        [headerView setClipsToBounds:YES];
        [headerView.contentView addSubview:({
            viewVerticalLine = [[UIView alloc] initWithFrame:CGRectMake(70, 0, 1, 30)];
            [viewVerticalLine setBackgroundColor:kBBRGBCOLOR(232.0, 232.0, 232.0)];
            [viewVerticalLine setTag:210];
            viewVerticalLine;
        })];
    }
    
    UILabel *lblDate = (UILabel *)[headerView viewWithTag:1234];
    [headerView.contentView addSubview:({
        if(!lblDate) {
            lblDate = [[UILabel alloc] initWithFrame:CGRectMake(30, 5, 50, 20)];
            [lblDate setTag:1234];
            [lblDate setBackgroundColor:[UIColor whiteColor]];
            [lblDate setFont:[kBBUtility systemFontWithSize:10.0 fixedSize:YES]];
            [lblDate setTextAlignment:NSTextAlignmentCenter];
            [lblDate.layer setCornerRadius:5.0];
            [lblDate setClipsToBounds:YES];
            [lblDate.layer setBorderWidth:1.0];
            [lblDate.layer setBorderColor:kBBRGBCOLOR(232.0, 232.0, 232.0).CGColor];
        }
        lblDate;
    })];
    
    NSString *strDate = [[arrRequests objectAtIndex:section] objectForKey:kBBDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormatter dateFromString:strDate];
    [dateFormatter setDateFormat:@"dd MMM yyyy"];
    [lblDate setText:[dateFormatter stringFromDate:date]];
    
    CGSize lblTimeSize = [kBBUtility labelSizeForString:lblDate.text height:lblDate.frame.size.height font:lblDate.font];
    CGRect lblTimeRect = lblDate.frame;
    lblTimeRect.size.width = lblTimeSize.width+6;
    [lblDate setFrame:lblTimeRect];
    UIView *separaterView = [headerView.contentView viewWithTag:210];
    [lblDate setCenter:CGPointMake(separaterView.center.x, lblDate.center.y)];
    
    return headerView;
}

- (NSMutableAttributedString *) getAttributedMessage:(NSString *) message {
    NSString * htmlString = [NSString stringWithFormat:@"<html><body style=\"font-family:Helvetica; font-size:%fpx; color:rgb(92, 92, 92); margin:0px\">%@</body></html>", [kBBUtility sizeForDevice:15], message];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    return attributedString;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *arrTemp = [[arrRequests objectAtIndex:indexPath.section] objectForKey:kBBDateData];
    NSDictionary *dict = [arrTemp objectAtIndex:indexPath.row];
    
    CGFloat textWidth = self.view.frame.size.width - 80 - 60;
    NSMutableAttributedString *attrMessage = [self getAttributedMessage:[dict valueForKey:@"message"]];
    CGFloat messageHeight = [kBBUtility labelSizeForAttributedString:attrMessage width:textWidth].height;
    NSArray *arrAttachments = [dict objectForKey:@"attachment_thumb"];
    CGFloat height;
    if (messageHeight == 0) {
        height = 70;
    } else {
        height = messageHeight + 65;
    }
    height += [arrAttachments count] ? 70 : 0;
    return height;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [arrRequests count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[arrRequests objectAtIndex:section] objectForKey:kBBDateData] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBRequestDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BBRequestDetailCell" forIndexPath:indexPath];
    
    NSArray *arrTemp = [[arrRequests objectAtIndex:indexPath.section] objectForKey:kBBDateData];
    NSDictionary *dict = [arrTemp objectAtIndex:indexPath.row];
    
    NSArray *arrAttachmentsThumb = [dict objectForKey:@"attachment_thumb"];
    if([arrAttachmentsThumb count]) {
        [cell.viewAttachment setHidden:NO];
    }
    else {
        [cell.viewAttachment setHidden:YES];
    }
    cell.arrAttachmentsThumb = arrAttachmentsThumb;
    cell.arrAttachmentsFull = [dict objectForKey:@"attachment_full"];
    [cell.collectionViewAttachments reloadData];
    NSString *strRequestName = [dict objectForKey:@"name"];

    UIEdgeInsets imageCapInset = UIEdgeInsetsMake(25, 8, 25, 8);
    if([strRequestName isEqualToString:strRequestByName]) {
        [cell.imgViewRequestFrom setImage:[UIImage imageNamed:@"bb_message_icon"]];
        UIImage *image = [UIImage imageNamed:@"bb_bubble_white"];
        [cell.imgViewMessageBubble setImage:[image resizableImageWithCapInsets:imageCapInset]];
        [cell.imgViewAttachmentBubble setImage:[image resizableImageWithCapInsets:imageCapInset]];
    }
    else {
        [cell.imgViewRequestFrom setImage:[UIImage imageNamed:@"bb_reply_icon"]];
        UIImage *image = [UIImage imageNamed:@"bb_bubble_grey"];
        [cell.imgViewMessageBubble setImage:[image resizableImageWithCapInsets:imageCapInset]];
        [cell.imgViewAttachmentBubble setImage:[image resizableImageWithCapInsets:imageCapInset]];
    }

    [cell.lblTime setText:[dict objectForKey:@"date"]];
    [cell.lblTime sizeToFit];
    [cell.lblTime setCenter:CGPointMake(27, cell.imgViewRequestFrom.center.y)];

    [cell.lblHours setText:[dict objectForKey:@"timestamp"]];
    [cell.lblHours sizeToFit];
    CGRect hoursRect = cell.lblHours.frame;
    hoursRect.origin.y = cell.lblTime.frame.origin.y + cell.lblTime.frame.size.height;
    [cell.lblHours setFrame:hoursRect];
    [cell.lblHours setCenter:CGPointMake(cell.lblTime.center.x, cell.lblHours.center.y)];
    
    [cell.lblName setText:[dict objectForKey:@"name"]];
    
    NSMutableAttributedString *attrMessage = [self getAttributedMessage:[dict valueForKey:@"message"]];
    CGFloat messageHeight = [kBBUtility labelSizeForAttributedString:attrMessage width:cell.lblMessage.frame.size.width].height;
    [cell.lblMessage setAttributedText:attrMessage];
    
    CGRect viewMessageRect = cell.viewMessageBubble.frame;
    viewMessageRect.size.height = messageHeight + 16 + 4;
    cell.viewMessageBubble.frame = viewMessageRect;
    
    return cell;
}

#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if([arrFileUrls count] == 3) {
        return [arrFileUrls count];
    }
    else {
        return [arrFileUrls count] + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *strCellIdentifier = @"BBAttachmentCell";
    BBAttachmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:strCellIdentifier forIndexPath:indexPath];
    [cell.btnDelete addTarget:self action:@selector(btnDeleteAttachmentTapped:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnDelete setTag:indexPath.item + 1];
    if(indexPath.row < [arrFileUrls count]) {
        NSURL *url = [arrFileUrls objectAtIndex:indexPath.item];
        [cell.imgViewAttachment setImage:[kBBUtility imageFromDocumentDirectoryWithName:url.lastPathComponent]];
        [cell.btnDelete setHidden:NO];
    }
    else {
        [cell.btnDelete setHidden:YES];
        [cell.imgViewAttachment setImage:[UIImage imageNamed:@"bb_attach_icon_add"]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row >= [arrFileUrls count]) {
        [self openImagePicker];
    }
    else {
        [BBPreviewView showViewWithFileUrl:[arrFileUrls objectAtIndex:indexPath.row]];
    }
}

#pragma mark - Message InputView Delegate

- (void)messageInputView:(BBMessageInputView *)inputView didSendMessage:(NSString *)message {
    [self.view endEditing:YES];
    
    if([message length] == 0) {
        [[BBUtility sharedInstance] showAlertController:@"" message:@"Please enter message" actionTitles:@[@"Ok"] completionBlock:nil];
        return;
    }
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString *strCountry = [usLocale displayNameForKey: NSLocaleCountryCode value:countryCode];
    
    NSDictionary *dictParameters = @{@"request_id":_requestId,
                                     @"request_type":strRequestType,
                                     @"name":strRequestByName,
                                     @"email":strRequestByEmail,
                                     @"message":message,
                                     @"region":strCountry,
                                     @"version":kBB_SYSTEM_VERSION,
                                     @"app_version":kBB_APP_VERSION_NUMBER_STRING,
                                     @"device":kBB_DEVICE_MODEL,
                                     @"os_type":KBB_OS_TYPE,
                                     @"subject":@"",
                                     @"phone":@"",
                                     @"device_id":[BBUtility deviceUUID],
                                     @"device_token":[[kBBUtility userDefaults] objectForKey:kBBDeviceTokenKey]};
    [BBLoadingView show];
    [kBBWebClient requestWithURLWithDefaultParameters:BB_URL_SAVE_RESPOND parameters:dictParameters fileUrls:arrFileUrls success:^(id response, NSData *responseData)
    {
        [self resetAttachmentView];
        [self setData];
        [BBLoadingView dismiss];
    } failure:^(NSError *error) {
        [BBLoadingView dismiss];
    }];
}

- (void)messageInputViewDidSelectMediaButton:(BBMessageInputView *)inputView {
    [self.view endEditing:YES];
    if(![arrFileUrls count]) {
        [self openImagePicker];
    }
    else {
        [viewAttachment setHidden:!viewAttachment.isHidden];
    }
}

#pragma mark - ImagePicker

- (void)openImagePicker {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status != ALAuthorizationStatusAuthorized &&
        status != ALAuthorizationStatusNotDetermined) {
        
        NSArray *actions;
        if (kBB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
            actions = @[@"Cancel", @"Settings"];
        } else {
            actions = @[@"Ok"];
        }
        [[BBUtility sharedInstance] showAlertController:@"This app does not have access to your photos or videos." message:@"You can enable access in Privacy Settings." actionTitles:actions completionBlock:^(id alertController, NSInteger buttonIndex) {
            
            if (buttonIndex == 1) {
                if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }];
        return;
    }
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    [_imagePickerController setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    [_imagePickerController setDelegate:self];
    [_imagePickerController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [_imagePickerController.navigationBar setTranslucent:FALSE];
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(id)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];

    NSString *strImageName = [[kBBUtility randomString] stringByAppendingString:@".jpg"];
    [kBBUtility saveImageToDocumentDirectory:image withName:strImageName];
    [arrFileUrls addObject:[NSURL fileURLWithPath:BB_ATTACHMENT_FILE(strImageName)]];
    [collectionViewAttachment reloadData];
    
    [messageInputView.mediaButton setSelected:YES];
    
    [kBBUtility dismissViewController:self animated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [kBBUtility dismissViewController:self animated:YES completion:nil];
}

#pragma mark - Orientation Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    if([arrRequests count]) {
        [tblViewRequests reloadData];
        [tblViewRequests scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    if([arrRequests count]) {
        [tblViewRequests reloadData];
        [tblViewRequests scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}

@end
