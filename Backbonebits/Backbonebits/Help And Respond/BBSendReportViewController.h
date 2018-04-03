/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "BBContants.h"
#import "BBUtility.h"

@interface BBSendReportViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIView *viewMainContainer;
    IBOutlet UIView *viewContainer;
    
    IBOutlet UIView *viewNameContainer;
    IBOutlet BBMaterialTextfield *txtFieldName;
    IBOutlet UILabel * lblNameInfo;
    IBOutlet UILabel * lblNameTitle;
    
    IBOutlet UIView *viewEmailContainer;
    IBOutlet BBMaterialTextfield *txtFieldEmail;
    IBOutlet UILabel * lblEmailInfo;
    IBOutlet UILabel * lblEmailTitle;
    
    IBOutlet UIView * viewDescription;
    IBOutlet BBPlaceHolderTextView *txtViewDescription;
    
    IBOutlet UIButton *btnDelete;
    IBOutlet UIView * viewImageContainer;
    IBOutlet UIButton *btnThumbImage;
    IBOutlet UIView * viewAddOptionContainer;
    IBOutlet UIButton *btnGellary;
    IBOutlet UIButton *btnTakeScreenshot;
    IBOutlet UIButton *btnVideo;
    
    IBOutlet UIButton *btnQuery;
    IBOutlet UIButton *btnBug;
    IBOutlet UIButton *btnFeedback;
    
    BBTopView *viewTop;
    CGFloat previousYPosition;
    CGSize keyboardUpdatedSize;
    NSInteger searchCount;
}

@property (nonatomic, retain) NSURL *fileUrl;
@property (nonatomic, assign) NSNumber *attachmentType;

+ (void)showViewWithFileUrl:(NSURL *)fileUrl attachmentType:(NSNumber *)attachmentType;

- (IBAction)btnGalleryTapped:(id)sender;
- (IBAction)btnTakeScreenshotTapped:(id)sender;
- (IBAction)btnVideoTapped:(id)sender;

@end
