/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBSendReportViewController.h"

#define kBBFAQFilterTag 12762

@implementation BBSendReportViewController

+ (void)showViewWithFileUrl:(NSURL *)fileUrl attachmentType:(NSNumber *)attachmentType {
    BBSendReportViewController *viewSendReport = [kBBStoryboard instantiateViewControllerWithIdentifier:@"BBSendReportViewController"];
    viewSendReport.attachmentType = attachmentType;
    viewSendReport.fileUrl = fileUrl;
    [kBBUtility pushViewController:viewSendReport animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setModalPresentationStyle:UIModalPresentationCustom];
    
    [kBBUtility shouldRotateOriantation:NO];
    [self loadLayout];
    [self setData];
    [self getFAQData];
    
    if (kBB_IS_GRATER_THEN_IPHONE_5 &&
        (kBB_INTERFACE_ORIENTATION == UIInterfaceOrientationPortrait ||
         kBB_INTERFACE_ORIENTATION == UIInterfaceOrientationPortraitUpsideDown))
    {
        CGRect rect = viewMainContainer.frame;
        rect.size.height = scrollView.frame.size.height;
        [viewMainContainer setFrame:rect];
    }
    [scrollView setContentSize:CGSizeMake(0, viewMainContainer.frame.size.height)];
    
    [kBBUtility bbKeyboardWillShowWithCompletion:^(CGSize size) {
        keyboardUpdatedSize = size;
        [self updateViewContainerFrameFromKeyboard:size];
    }];
    
    [kBBUtility bbKeyboardWillHideWithCompletion:^(CGSize size) {
        if (kBB_IS_IPAD) {
            [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        } else {
            [scrollView setContentOffset:CGPointMake(0, scrollView.contentSize.height-scrollView.frame.size.height) animated:YES];
        }
    }];
}

- (void) getFAQData {
    [[BBFAQFilterViewController sharedInstance] loadFAQData:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Orientation Methods

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [self.view endEditing:YES];
    [self showFaqFilterView:NO withCount:0];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.view endEditing:YES];
    [self showFaqFilterView:NO withCount:0];
}

- (void)updateViewContainerFrameFromKeyboard:(CGSize)keyboardSize  {
    if (kBB_IS_IPAD) {
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat yDisplacement = 0;
            switch (kBB_INTERFACE_ORIENTATION) {
                case UIInterfaceOrientationPortrait:
                case UIInterfaceOrientationPortraitUpsideDown: {
                    yDisplacement = 0;
                    break;
                }
                case UIInterfaceOrientationLandscapeLeft:
                case UIInterfaceOrientationLandscapeRight: {
                    if(txtViewDescription.isFirstResponder) {
                        yDisplacement = 380;
                    }
                    else if(txtFieldName.isFirstResponder) {
                        yDisplacement = 150;
                    }
                    else if(txtFieldEmail.isFirstResponder) {
                        yDisplacement = 230;
                    }
                    break;
                }
                default:
                    break;
            }
            [scrollView setContentOffset:CGPointMake(0, yDisplacement) animated:YES];
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat yDisplacement = 0;
            switch (kBB_INTERFACE_ORIENTATION) {
                case UIInterfaceOrientationPortrait:
                case UIInterfaceOrientationPortraitUpsideDown: {
                    if(txtViewDescription.isFirstResponder) {
                        CGFloat yIndex = scrollView.contentSize.height - (scrollView.frame.size.height-keyboardSize.height);
                        yDisplacement = yIndex;
                    }
                    else if(txtFieldName.isFirstResponder) {
                        yDisplacement = 150;
                    }
                    else if(txtFieldEmail.isFirstResponder) {
                        yDisplacement = 230;
                    }
                    break;
                }
                case UIInterfaceOrientationLandscapeLeft:
                case UIInterfaceOrientationLandscapeRight: {
                    if(txtViewDescription.isFirstResponder) {
                        yDisplacement = 380;
                    }
                    else if(txtFieldName.isFirstResponder) {
                        yDisplacement = 150;
                    }
                    else if(txtFieldEmail.isFirstResponder) {
                        yDisplacement = 230;
                    }
                    break;
                }
                default:
                    break;
            }
            [scrollView setContentOffset:CGPointMake(0, yDisplacement) animated:YES];
        }];
    }
}

#pragma mark - Other Methods

- (void) btnBackBtnTapped:(id)sender {
    BOOL isVideoSelected = [kBBUtility isVideoUrl:_fileUrl];
    if (isVideoSelected) {
        [[BBUtility sharedInstance] showAlertController:@"" message:@"Recorded video will be discarded and video will not be saved. Are you sure?" actionTitles:@[@"No",@"Yes"] completionBlock:^(id alertController, NSInteger buttonIndex) {
            
            if (buttonIndex == 1) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kBBDefaulAlertWaitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [kBBUtility popViewControllerAnimated:YES];
                });
            }
        }];
    } else {
        [self.view endEditing:YES];
        [kBBUtility popViewControllerAnimated:YES];
    }
}

- (void)loadLayout {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:({
        viewTop = [BBTopView getBBTopView];
        [viewTop.lblTitle setText:@"New Request"];
        [viewTop.btnLeft setTitle:@"Back" theme:BBTopBarButtonThemeBack target:self selector:@selector(btnBackBtnTapped:) forControlEvents:UIControlEventTouchUpInside];        
        [viewTop.btnRight setTitle:@"Send" theme:BBTopBarButtonThemeActive target:self selector:@selector(btnSubmitTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addChildViewController:viewTop];
        viewTop.view;
    })];
    
    UIFont *font = [kBBUtility systemFontWithSize:15.0 fixedSize:YES];

    [btnThumbImage.imageView setContentMode:UIViewContentModeScaleAspectFill];
    [btnThumbImage setBackgroundColor:[UIColor clearColor]];
    [btnThumbImage.layer setBorderColor:kBBRGBCOLOR(183,183,183).CGColor];
    [btnThumbImage.layer setBorderWidth:1];
    [btnThumbImage.layer setCornerRadius:3];
    [btnThumbImage setClipsToBounds:YES];
    
    [viewAddOptionContainer.layer setCornerRadius:3];
    
    // Name Field
    NSString * nameText = @"Your Name";
    NSString * requiredText = @"(Required)";
    [lblNameTitle setText:nameText];
    [txtFieldName setText:[kBBUtility getDefaultUserName]];
    [txtFieldName setFont:font];
    [txtFieldName setTextColor:[UIColor blackColor]];
    
    // Email Field
    NSString * emailText = @"Your Email (Required)";
    NSMutableAttributedString * attrEmailTitle = [[NSMutableAttributedString alloc] initWithString:emailText attributes:@{NSFontAttributeName : lblNameTitle.font}];
    [attrEmailTitle addAttributes:@{ NSFontAttributeName: [UIFont fontWithName:lblNameTitle.font.fontName size:lblNameTitle.font.capHeight-3]} range:NSMakeRange([emailText rangeOfString:requiredText].location, requiredText.length)];
    [lblEmailTitle setAttributedText:attrEmailTitle];
    [txtFieldEmail setFont:font];
    [txtFieldEmail setTextColor:[UIColor blackColor]];
    
    // Description
    [txtViewDescription setDelegate:self];
    [txtViewDescription setFont:font];
    [txtViewDescription setTextColor:[UIColor blackColor]];
    [txtViewDescription setPlaceholder:@"Enter your message here"];
    [txtViewDescription setTextContainerInset:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    // Set Btn Layout.
    CGPoint bugPoint = btnBug.center;
    bugPoint.x = viewEmailContainer.center.x;
    btnBug.center = bugPoint;
    [self btnReportTypeTapped:btnFeedback];
    
}

- (void)setData {
    
    // Set previously add email.
    NSUserDefaults *userDefaults = [kBBUtility userDefaults];
    if ([userDefaults valueForKey:kBBSavedEmail]) {
        txtFieldEmail.text = [userDefaults valueForKey:kBBSavedEmail];
    }
    
    // Set Image and Video Thumb.
    if (_fileUrl != nil) {
        BOOL isVideoSelected = [kBBUtility isVideoUrl:_fileUrl];
        if(isVideoSelected) {
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:_fileUrl options:nil];
            AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
            NSError *error = NULL;
            CMTime time = CMTimeMake(0, 30);
            CMTime timeActual;
            CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:&timeActual error:&error];
            UIImage *frameImage= [[UIImage alloc] initWithCGImage:refImg];
            [btnThumbImage setImage:frameImage forState:UIControlStateNormal];
        }
        else {
            [btnThumbImage setImage:[kBBUtility imageFromDocumentDirectoryWithName:KBBImageFileName] forState:UIControlStateNormal];
        }
        [self resetThumbBtnView:NO];
    } else {
        [self resetThumbBtnView:YES];
    }
}

- (void) resetThumbBtnView:(BOOL) isDeleted {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.1 animations:^{
            [btnDelete setHidden:isDeleted];
            [btnThumbImage setHidden:isDeleted];
            [viewAddOptionContainer setHidden:!isDeleted];
            
            if (isDeleted) {
                _fileUrl = nil;
                _attachmentType = @(BBAttachmentTypeUndefined);
            }
        }];
    });
}

#pragma mark - Pick Image

- (void) addImageFromGellary {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [imagePicker.navigationBar setBarTintColor:[UIColor whiteColor]];
    [imagePicker.navigationBar setTranslucent:FALSE];
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if(CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        UIImage *pickedImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        [kBBUtility saveImageToDocumentDirectory:pickedImage withName:KBBImageFileName];
        _fileUrl = [NSURL fileURLWithPath:BB_ATTACHMENT_FILE(KBBImageFileName)];
        _attachmentType = @(BBAttachmentTypeImage);
        [self setData];
    }
    else
    {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        NSString *moviePath = BB_ATTACHMENT_FILE(kBBVideoFileName);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:moviePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:moviePath error:nil];
        }
        NSError *error = nil;
        [[NSFileManager defaultManager] copyItemAtPath:[videoUrl path] toPath:moviePath error:&error];
        if (error == nil) {
            _fileUrl = [NSURL fileURLWithPath:moviePath];
            _attachmentType = @(BBAttachmentTypeVideo);
            [self setData];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Buttons

- (IBAction)btnThumbImageTapped:(id)sender {
    if (_fileUrl != nil) {
        [BBPreviewView showViewWithFileUrl:_fileUrl];
    }
}

- (IBAction)btnGalleryTapped:(id)sender {
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
    [self addImageFromGellary];
}

- (IBAction)btnTakeScreenshotTapped:(id)sender {
    [kBBUtility takeConfirmationAlert:BBAssistiveControlTypeImage withComplete:^(BOOL isPerform) {
        if (isPerform) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController dismissViewControllerAnimated:YES completion:^
                {
                    [kBBUtility assistiveControlWithType:BBAssistiveControlTypeImage];
                }];
            });
        }
    }];
}

- (IBAction)btnVideoTapped:(id)sender {
    [kBBUtility takeConfirmationAlert:BBAssistiveControlTypeVideo withComplete:^(BOOL isPerform) {
        if (isPerform) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController dismissViewControllerAnimated:YES completion:^
                {
                    [kBBUtility assistiveControlWithType:BBAssistiveControlTypeVideo];
                }];
            });
        }
    }];
}

- (IBAction)btnReportTypeTapped:(id)sender {
    [btnQuery setSelected:NO];
    [btnBug setSelected:NO];
    [btnFeedback setSelected:NO];
    [sender setSelected:YES];
}

- (NSString *) getTrimValue:(NSString *) text {
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *) getDescriptionValue {
    NSString *description = [self getTrimValue:txtViewDescription.text];
    if ([description length] == 0) {
        switch ([_attachmentType integerValue]) {
            case BBAttachmentTypeScreenshot:
                description = @"Screenshot Attached";
                break;
            case BBAttachmentTypeImage:
                description = @"Image Attached";
                break;
            case BBAttachmentTypeVideo:
                description = @"Video Attached";
                break;
            default:
                break;
        }
    }
    else {
        description = txtViewDescription.text;
    }
    return description;
}


- (void)btnSubmitTapped:(id)sender {
    [self.view endEditing:YES];
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString *strCountry = [usLocale displayNameForKey: NSLocaleCountryCode value:countryCode];
    
    NSString *strQueryType = @"";
    if([btnQuery isSelected]) strQueryType = @"query";
    else if([btnBug isSelected]) strQueryType = @"bug";
    else if([btnFeedback isSelected]) strQueryType = @"feedback";
    
    NSString *strMessage = @"";
    if([txtFieldName.text length] == 0) {
        txtFieldName.text = [kBBUtility getDefaultUserName];
    }
    else if([[self getTrimValue:txtFieldEmail.text] length] == 0) {
        strMessage = @"Please enter your email.";
    }
    else if([[kBBUtility getValidStringObject:txtFieldEmail.text] length] != 0 &&
            ![kBBUtility bbValidateEmail:txtFieldEmail.text]) {
        strMessage = @"Please enter vaild email.";
    }
    else if(_attachmentType == BBAttachmentTypeUndefined &&
            [[self getTrimValue:txtViewDescription.text] length] == 0) {
        strMessage = @"Please enter description.";
    }
    else if([strQueryType length] == 0) {
        strMessage = @"Please select request type";
    }
    if([strMessage length] > 0) {
        [[BBUtility sharedInstance] showAlertController:@"" message:strMessage actionTitles:@[@"Ok"] completionBlock:nil];
        return;
    }
    
    // Save Email for future use.
    NSUserDefaults *userDefaults = [kBBUtility userDefaults];
    [userDefaults setObject:txtFieldEmail.text forKey:kBBSavedEmail];
    [userDefaults synchronize];
    
    NSDictionary *dictParameters = @{@"request_id":@(0),
                                     @"request_type":strQueryType,
                                     @"name":txtFieldName.text,
                                     @"email":txtFieldEmail.text,
                                     @"message":[self getDescriptionValue],
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
    NSArray *arrFiles = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:_fileUrl.path]) {
        arrFiles = @[_fileUrl];
    }

    // Fail Alert.
    void(^requestFailed)(void) = ^() {
        [[BBUtility sharedInstance] showAlertController:@"" message:@"Failed to submit your request. Please try again." actionTitles:@[@"Ok"] completionBlock:nil];
    };
    
    [kBBWebClient requestWithURLWithDefaultParameters:BB_URL_SAVE_RESPOND parameters:dictParameters fileUrls:arrFiles success:^(id response, NSData *responseData) {
        [BBLoadingView dismiss];
        if ([[response valueForKey:@"status"] integerValue] == 1) {
            [kBBUtility popToRootViewControllerAnimated:NO];
            [BBLoadingView show];
            [[Backbonebits sharedInstance] openPastReports:^(BOOL success) {
                [BBLoadingView dismiss];
            }];
        } else {
            requestFailed();
        }
    } failure:^(NSError *error) {
        [BBLoadingView dismiss];
        requestFailed();
    }];
     
}

- (void)btnDoneKeyboardTapped:(id)sender {
    [self showFaqFilterView:NO withCount:0];
    [txtViewDescription resignFirstResponder];
}

- (IBAction)btnDeleteTapped:(id)sender {
    [[BBUtility sharedInstance] showAlertController:@"" message:@"Are you sure you want to delete video?" actionTitles:@[@"No",@"Yes"] completionBlock:^(id alertController, NSInteger buttonIndex) {
        
        if (buttonIndex == 1) {
            NSString *filePath = BB_ATTACHMENT_FILE(kBBVideoFileName);
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            }
            [self resetThumbBtnView:YES];
        }
    }];
}

#pragma mark - Custom Button

- (UIButton *)customButtonWithFrame:(CGRect)frame title:(NSString *)title action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:frame];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

#pragma mark - TextField

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([textField isEqual:txtFieldName]) {
        NSString *name = [textField.text stringByReplacingCharactersInRange:range withString:string];
        if (name.length > 0) {
            if ([name isEqualToString:[kBBUtility getDefaultUserName]]) {
                [lblNameInfo setHidden:NO];
            } else {
                [lblNameInfo setHidden:YES];
            }
        } else {
            [lblNameInfo setHidden:NO];
        }
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if(textView.inputAccessoryView == nil && !kBB_IS_IPAD) {
        [textView setInputAccessoryView:({
            UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
            UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(btnDoneKeyboardTapped:)];
            [toolBar setItems:@[flexibleItem,doneButton] animated:YES];
            toolBar;
        })];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([textView isEqual:txtViewDescription]) {
        NSString *searchString = [textView.text stringByReplacingCharactersInRange:range withString:text];
        BBFAQFilterViewController *filterView = [self addFaqFilterViewWithFrame:[self getFAQViewFrame:0]];
        [filterView performFilterWithString:searchString withCompleteBlock:^(BOOL isShow, BOOL isCompleted, NSInteger count) {
            if (isCompleted) {
                [self showFaqFilterView:isShow withCount:count];
                [txtViewDescription resignFirstResponder];
            } else {
                [self showFaqFilterView:isShow withCount:count];
            }
        }];
    }
    return YES;
}

#pragma mark - FAQ Filter List

- (BBFAQFilterViewController *) addFaqFilterViewWithFrame:(CGRect)frame {
    BBFAQFilterViewController *viewController = [BBFAQFilterViewController sharedInstance];
    if (![self.view viewWithTag:kBBFAQFilterTag]) {
        [viewController.view setFrame:frame];
        [viewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [viewController.view setBackgroundColor:[UIColor whiteColor]];
        [viewController.view setTag:kBBFAQFilterTag];
        [self.view addSubview:viewController.view];
        [viewController.view setHidden:YES];
    }
    return viewController;
}

- (void) updateFAQViewFrame:(CGRect) frame {
    if ([self.view viewWithTag:kBBFAQFilterTag]) {
        [[self.view viewWithTag:kBBFAQFilterTag] setFrame:frame];
    }
}

- (CGRect) getFAQViewFrame:(NSInteger) count {
    CGRect faqFrame = CGRectZero;
    switch (kBB_INTERFACE_ORIENTATION) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown: {
            CGFloat portraitHeight = [self getYDisplacement:count];
            CGFloat yPosition = self.view.frame.size.height-(keyboardUpdatedSize.height+[self getYDisplacement:count]);
            CGFloat portraitWidth = self.view.frame.size.width;
            faqFrame.origin = CGPointMake(0, yPosition);
            faqFrame.size = CGSizeMake(portraitWidth, portraitHeight);
            break;
        }
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight: {
            CGFloat xPossition = [self getWidthForLanscapMode];
            CGFloat portraitHeight = 150;
            CGFloat portraitWidth = self.view.frame.size.width-[self getWidthForLanscapMode];
            faqFrame.origin = CGPointMake(xPossition, 64);
            faqFrame.size = CGSizeMake(portraitWidth, portraitHeight);
            break;
        }
        default:
            break;
    }
    return faqFrame;
}

- (void) showFaqFilterView:(BOOL)isShow withCount:(NSInteger) count {
    if ([self.view viewWithTag:kBBFAQFilterTag]) {
        [UIView animateWithDuration:0.3 animations:^{
            [[self.view viewWithTag:kBBFAQFilterTag] setHidden:!isShow];
            [self updateFAQViewFrame:[self getFAQViewFrame:count]];
            if (kBB_INTERFACE_ORIENTATION == UIInterfaceOrientationLandscapeLeft ||
                kBB_INTERFACE_ORIENTATION == UIInterfaceOrientationLandscapeRight) {
                if (isShow) {
                    CGRect rect = [viewMainContainer frame];
                    rect.size.width = [self getWidthForLanscapMode];
                    viewMainContainer.frame = rect;
                } else {
                    CGRect rect = [viewMainContainer frame];
                    rect.size.width = self.view.frame.size.width;
                    viewMainContainer.frame = rect;
                }
            } else {
                CGFloat padding = 45;
                if (isShow) {
                    if (previousYPosition == 0) {
                        previousYPosition = [scrollView contentOffset].y;
                        CGPoint point = [scrollView contentOffset];
                        point.y = (point.y+[self getYDisplacement:count])-padding;
                        scrollView.contentOffset = point;
                    } else {
                        CGPoint point = [scrollView contentOffset];
                        point.y = (previousYPosition+[self getYDisplacement:count])-padding;
                        scrollView.contentOffset = point;
                    }
                } else {
                    if (previousYPosition != 0) {
                        CGPoint point = [scrollView contentOffset];
                        point.y = previousYPosition;
                        scrollView.contentOffset = point;
                        previousYPosition = 0;
                    }
                }
            }
        }];
    }
}

- (CGFloat) getYDisplacement:(NSInteger) count {
    NSInteger numberToShow = 3;
    if (kBB_IS_IPHONE_4_OR_LESS) {
        numberToShow = 2;
    }
    if (count <= numberToShow) {
        return count * 40;
    }
    if (kBB_IS_IPHONE_4_OR_LESS) {
        return 80;
    } else {
        return 100;
    }
}

- (CGFloat) getWidthForLanscapMode {
    CGFloat width = 250;
    if (kBB_IS_IPHONE_4_OR_LESS) {
        width = 250;
    } else if (kBB_IS_IPHONE_5) {
        width = self.view.frame.size.width/2;
    } else if (kBB_IS_IPHONE_6) {
        width = self.view.frame.size.width/2;
    } else if (kBB_IS_IPHONE_6P) {
        width = self.view.frame.size.width/2;
    } else if (kBB_IS_IPAD) {
        width = self.view.frame.size.width/2;
    }
    return width;
}

- (void) removeFaqFilterView {
    if ([self.view viewWithTag:kBBFAQFilterTag]) {
        [[self.view viewWithTag:kBBFAQFilterTag] removeFromSuperview];
    }
}

@end
