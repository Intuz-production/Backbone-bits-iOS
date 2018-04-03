/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBScreenshotEditingViewController.h"

@implementation BBTextEditView

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self setClipsToBounds:NO];

        [self addSubview:({
            _lblText = [[UILabel alloc] initWithFrame:self.bounds];
            [_lblText setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [_lblText setFont:[kBBUtility systemFontWithSize:20.0]];
            [_lblText setNumberOfLines:0];
            [_lblText setUserInteractionEnabled:YES];
            _lblText;
        })];
        
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.strokeColor = kBBRGBCOLOR(173.0, 185.0, 206.0).CGColor;
        _borderLayer.fillColor = nil;
        _borderLayer.lineDashPattern = @[@4, @2];
        [self.layer addSublayer:_borderLayer];
        
        [self addSubview:({
            _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat size = 22;
            [_btnDelete setFrame:CGRectMake(self.frame.size.width - (size/2), -(size/2), size, size)];
            [_btnDelete setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            [_btnDelete setImage:[UIImage imageNamed:@"bb_close"] forState:UIControlStateNormal];
            [_btnDelete addTarget:self action:@selector(btnDeleteTapped:) forControlEvents:UIControlEventTouchUpInside];
            _btnDelete;
        })];
    }
    return self;
}

- (void)layoutSubviews {
    _borderLayer.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    _borderLayer.frame = self.bounds;
}

- (void)btnDeleteTapped:(id)sender {
    [self removeFromSuperview];
}

@end

@implementation BBColorCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self loadLayout];
    }
    return self;
}

- (void)loadLayout {
    [self addSubview:({
        if(!_viewColor) {
            _viewColor = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            [_viewColor setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
            [_viewColor.layer setCornerRadius:_viewColor.frame.size.width/2];
            [_viewColor.layer setBorderWidth:1.0];
            [_viewColor setClipsToBounds:YES];
        }
        _viewColor;
    })];
}

@end

@implementation BBScreenshotEditingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [kBBUtility shouldRotateOriantation:NO];
    [self loadLayout];
    [self setData];

}

#pragma mark - Other Methods

- (void)loadLayout {
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:({
        txtFieldTemp = [[UITextField alloc] initWithFrame:CGRectZero];
        [txtFieldTemp setAutocorrectionType:UITextAutocorrectionTypeNo];
        [txtFieldTemp setDelegate:self];
        txtFieldTemp;
    })];
    

    [self.view addSubview:({
        viewDrawableContainer = [[UIView alloc] initWithFrame:self.view.bounds];
        [viewDrawableContainer setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [viewDrawableContainer setBackgroundColor:[UIColor clearColor]];
        viewDrawableContainer;
    })];
    
    [viewDrawableContainer addSubview:({
        imgViewScreenshot = [[UIImageView alloc] initWithFrame:viewDrawableContainer.bounds];
        [imgViewScreenshot setContentMode:UIViewContentModeScaleAspectFit];
        [imgViewScreenshot setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        imgViewScreenshot;
    })];
    
    [viewDrawableContainer addSubview:({
        viewDrawable = [[BBDrawableView alloc] initWithFrame:viewDrawableContainer.bounds];
        [viewDrawable setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        __weak typeof(self) weakSelf = self;
        [viewDrawable setDrawingStarted:^{
            [weakSelf hideTopAndBottomViewAnimated:YES];
        }];
        [viewDrawable setDrawingEnded:^(NSDictionary *dict){
            [weakSelf showTopAndBottomViewAnimated:YES];
            if(dict) {
                [weakSelf.arrOperations addObject:dict];
            }
        }];
        [viewDrawable setIsDrawingEnabled:TRUE];
        viewDrawable;
    })];
    
    [self.view addSubview:({
        viewTop = [BBTopView getBBTopView];
        [viewTop.lblTitle setText:kSendScreenshot];
        [viewTop.btnLeft setTitle:@"Back" theme:BBTopBarButtonThemeBack target:self selector:@selector(btnBackTapped:) forControlEvents:UIControlEventTouchUpInside];
        [viewTop.btnRight setTitle:@"Send" theme:BBTopBarButtonThemeActive target:self selector:@selector(btnSendTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addChildViewController:viewTop];
        viewTop.view;
    })];
    
    CGFloat height = 50;
    CGFloat btnSize = 30;
    CGFloat spacing = (self.view.frame.size.width - (btnSize*3))/3;
    [self.view addSubview:({
        viewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, height)];
        [viewBottom setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.6]];
        [viewBottom setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        
        CGFloat x = (self.view.frame.size.width - ((btnSize*3)+(spacing*2)))/2;
        CGFloat y = 5, lblY = 7;
        
        btnDraw = [self customButtonWithFrame:CGRectMake(x, y, btnSize, btnSize)
                                                 action:@selector(btnDrawTapped:)];
        [btnDraw addTarget:self action:@selector(bottomTouchDownEvent:) forControlEvents:UIControlEventTouchDown];
        [btnDraw addTarget:self action:@selector(bottomTouchUpEvent:) forControlEvents:UIControlEventTouchUpInside];
        [btnDraw setImage:[UIImage imageNamed:@"bb_colorpicker_icon"] forState:UIControlStateNormal];
        [btnDraw setImage:[UIImage imageNamed:@"bb_colorpicker_icon_selected"] forState:UIControlStateHighlighted];
        [btnDraw setImage:[UIImage imageNamed:@"bb_colorpicker_icon_selected"] forState:UIControlStateSelected];
        [btnDraw setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin];
        [viewBottom addSubview:btnDraw];
        
        lblDraw = [[UILabel alloc] initWithFrame:CGRectMake(x, btnSize+lblY, btnSize, 10)];
        [lblDraw setTextColor:[UIColor whiteColor]];
        [lblDraw setTextAlignment:NSTextAlignmentCenter];
        [lblDraw setText:@"Color"];
        [lblDraw setFont:[kBBUtility systemFontWithSize:10 fixedSize:YES]];
        [lblDraw setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleLeftMargin];
        [kBBUtility bbTapped:^{
            [self btnDrawTapped:btnDraw];
        } onView:lblDraw];
        [viewBottom addSubview:lblDraw];
        
        x = btnDraw.frame.origin.x + btnSize + spacing;
        btnText = [self customButtonWithFrame:CGRectMake(x, y, btnSize, btnSize)
                                                 action:@selector(btnTextTapped:)];
        [btnText addTarget:self action:@selector(bottomTouchDownEvent:) forControlEvents:UIControlEventTouchDown];
        [btnText addTarget:self action:@selector(bottomTouchUpEvent:) forControlEvents:UIControlEventTouchUpInside];
        [btnText setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [btnText setImage:[UIImage imageNamed:@"bb_text_icon"] forState:UIControlStateNormal];
        [btnText setImage:[UIImage imageNamed:@"bb_text_icon_selected"] forState:UIControlStateHighlighted];
        [btnText setImage:[UIImage imageNamed:@"bb_text_icon_selected"] forState:UIControlStateSelected];
        [viewBottom addSubview:btnText];
        
        lblText = [[UILabel alloc] initWithFrame:CGRectMake(x, btnSize+lblY, btnSize, 10)];
        [lblText setTextColor:[UIColor whiteColor]];
        [lblText setTextAlignment:NSTextAlignmentCenter];
        [lblText setText:@"Text"];
        [lblText setFont:[kBBUtility systemFontWithSize:10 fixedSize:YES]];
        [lblText setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [kBBUtility bbTapped:^{
            [self btnTextTapped:btnText];
        } onView:lblText];
        [viewBottom addSubview:lblText];
        
        x = btnText.frame.origin.x + btnSize + spacing;
        btnUndo = [self customButtonWithFrame:CGRectMake(x, y, btnSize, btnSize)
                                                 action:@selector(btnUndoTapped:)];
        [btnUndo addTarget:self action:@selector(bottomTouchDownEvent:) forControlEvents:UIControlEventTouchDown];
        [btnUndo addTarget:self action:@selector(bottomTouchUpEvent:) forControlEvents:UIControlEventTouchUpInside];
        [btnUndo setImage:[UIImage imageNamed:@"bb_undo_icon"] forState:UIControlStateNormal];
        [btnUndo setImage:[UIImage imageNamed:@"bb_undo_icon_selected"] forState:UIControlStateHighlighted];
        [btnUndo setImage:[UIImage imageNamed:@"bb_undo_icon_selected"] forState:UIControlStateSelected];
        [btnUndo setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [viewBottom addSubview:btnUndo];
        
        lblUndo = [[UILabel alloc] initWithFrame:CGRectMake(x, btnSize+lblY, btnSize, 10)];
        [lblUndo setTextColor:[UIColor whiteColor]];
        [lblUndo setTextAlignment:NSTextAlignmentCenter];
        [lblUndo setText:@"Undo"];
        [lblUndo setFont:[kBBUtility systemFontWithSize:10 fixedSize:YES]];
        [lblUndo setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [kBBUtility bbTapped:^{
            [self btnUndoTapped:btnUndo];
        } onView:lblUndo];
        [viewBottom addSubview:lblUndo];
        
        viewBottom;
    })];
    
    [self addColorPicker];
    [self showTopAndBottomViewAnimated:YES];
}

- (void)addColorPicker {
    if(!arrColors) {
        arrColors = [[NSMutableArray alloc] init];
    }
    [arrColors addObjectsFromArray:@[kBBRGBCOLOR(229.0, 80.0, 35.0),
                                     kBBRGBCOLOR(7.0, 0.0, 122.0),
                                     kBBRGBCOLOR(211.0, 0.0, 45.0),
                                     kBBRGBCOLOR(100.0, 149.0, 237.0),
                                     kBBRGBCOLOR(142.0, 64.0, 32.0),
                                     kBBRGBCOLOR(208.0, 152.0, 10.0),
                                     kBBRGBCOLOR(162.0, 18.0, 24.0),
                                     kBBRGBCOLOR(86.0, 86.0, 86.0),
                                     kBBRGBCOLOR(95.0, 0.0, 134.0),
                                     kBBRGBCOLOR(36.0, 62.0, 62.0),
                                     kBBRGBCOLOR(88.0, 58.0, 196.0),
                                     kBBRGBCOLOR(9.0, 121.0, 120.0),
                                     kBBRGBCOLOR(170.0, 35.0, 92.0),
                                     kBBRGBCOLOR(166.0, 96.0, 55.0),
                                     kBBRGBCOLOR(22.0, 199.0, 46.0)]];
    
    selectedColor = [arrColors objectAtIndex:0];
    [viewDrawable setStrokeColor:selectedColor];
    [self.view addSubview:({
        viewColorPicker = [[UIView alloc] initWithFrame:CGRectMake(0, viewBottom.frame.origin.y - 50, viewBottom.frame.size.width, 50)];
        [viewColorPicker setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        [viewColorPicker setBackgroundColor:kBBRGBCOLOR(11.0, 11.0, 11.0)];
        [viewColorPicker setClipsToBounds:NO];
        [viewColorPicker setHidden:YES];
        viewColorPicker;
    })];
    
    [viewColorPicker addSubview:({
        UIImageView *imgViewArrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, viewColorPicker.frame.size.height, 20, 10)];
        [imgViewArrow setCenter:CGPointMake(btnDraw.center.x, imgViewArrow.center.y)];
        [imgViewArrow setImage:[UIImage imageNamed:@"bb_popup_arrow"]];
        imgViewArrow;
    })];
    
    [viewColorPicker addSubview:({
        CGFloat spacing = 7.0;
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        [collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [collectionViewLayout setMinimumInteritemSpacing:spacing];
        [collectionViewLayout setMinimumLineSpacing:spacing];
        [collectionViewLayout setItemSize:CGSizeMake(30, 30)];
        [collectionViewLayout setSectionInset:UIEdgeInsetsMake(0, spacing, 0, spacing)];
        
        collectionViewColorPicker = [[UICollectionView alloc] initWithFrame:viewColorPicker.bounds collectionViewLayout:collectionViewLayout];
        [collectionViewColorPicker setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [collectionViewColorPicker setShowsHorizontalScrollIndicator:NO];
        [collectionViewColorPicker setShowsVerticalScrollIndicator:NO];
        [collectionViewColorPicker setBackgroundColor:[UIColor clearColor]];
        [collectionViewColorPicker setDelegate:self];
        [collectionViewColorPicker setDataSource:self];
        [collectionViewColorPicker registerClass:[BBColorCell class] forCellWithReuseIdentifier:@"BBColorCell"];
        collectionViewColorPicker;
    })];
}

- (void)setData {
    _arrOperations = [[NSMutableArray alloc] init];
    [imgViewScreenshot setImage:_imgScreenshot];
}

#pragma mark - Orientation Methods

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [arrColors count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *strCellIdentifier = @"BBColorCell";
    BBColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:strCellIdentifier forIndexPath:indexPath];
    UIColor *color = [arrColors objectAtIndex:indexPath.item];
    if(color == selectedColor) {
        [cell.viewColor.layer setBorderColor:[UIColor whiteColor].CGColor];
    }
    else {
        [cell.viewColor.layer setBorderColor:[UIColor clearColor].CGColor];
    }
    [cell.viewColor setBackgroundColor:color];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    selectedColor = [arrColors objectAtIndex:indexPath.item];
    [viewDrawable setStrokeColor:selectedColor];
    [collectionView reloadData];
}

#pragma mark - Custom Button

- (UIButton *)customButtonWithFrame:(CGRect)frame action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:frame];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

#pragma - mark Buttons

- (void)btnBackTapped:(id)sender {
    [[BBUtility sharedInstance] showAlertController:@"" message:@"All the changes will be discarded and image will not be saved. Are you sure?" actionTitles:@[@"No",@"Yes"] completionBlock:^(id alertController, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kBBDefaulAlertWaitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [kBBUtility popViewControllerAnimated:YES];
            });
        }
    }];
}

- (void)bottomTouchDownEvent:(id)sender {
    if ([sender isEqual:btnDraw]) {
        [lblDraw setTextColor:kBBRGBCOLOR(47,209,209)];
    } else if ([sender isEqual:btnText]) {
        [lblText setTextColor:kBBRGBCOLOR(47,209,209)];
    } else if ([sender isEqual:btnUndo]) {
        [lblUndo setTextColor:kBBRGBCOLOR(47,209,209)];
    } else if ([sender isEqual:btnCancel]) {
        [lblCancel setTextColor:kBBRGBCOLOR(47,209,209)];
    }
}

- (void)bottomTouchUpEvent:(id)sender {
    if ([sender isEqual:btnDraw]) {
    } else if ([sender isEqual:btnText]) {
    } else if ([sender isEqual:btnUndo]) {
        [lblUndo setTextColor:[UIColor whiteColor]];
    } else if ([sender isEqual:btnCancel]) {
        [lblCancel setTextColor:[UIColor whiteColor]];
    }
}

- (void)btnSendTapped:(id)sender {
    [self resignTextField];
    [kBBUtility saveImageToDocumentDirectory:[kBBUtility screenshotOfView:viewDrawableContainer] withName:KBBImageFileName];
    [BBSendReportViewController showViewWithFileUrl:[NSURL fileURLWithPath:BB_ATTACHMENT_FILE(KBBImageFileName)] attachmentType:@(BBAttachmentTypeScreenshot)];
}

- (void)btnDrawTapped:(id)sender {
    [sender setSelected:![sender isSelected]];
    [lblDraw setTextColor:([sender isSelected])?kBBRGBCOLOR(47,209,209):[UIColor whiteColor]];
    [viewColorPicker setHidden:![sender isSelected]];
}

- (void)btnTextTapped:(id)sender {
    [txtFieldTemp becomeFirstResponder];
    [sender setSelected:YES];
    [lblText setTextColor:([sender isSelected])?kBBRGBCOLOR(47,209,209):[UIColor whiteColor]];
    [viewDrawableContainer addSubview:({
        currentEditableView = [[BBTextEditView alloc] initWithFrame:CGRectMake(20, 100, 50, 30)];
        [currentEditableView.lblText setTextColor:selectedColor];
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanOnLabel:)];
        [panGesture setDelaysTouchesBegan:NO];
        [currentEditableView addGestureRecognizer:panGesture];
        currentEditableView;
    })];
    viewDrawable.isDrawingEnabled = NO;
    
    [_arrOperations addObject:currentEditableView];
}

- (void)btnUndoTapped:(id)sender {
    id obj = [_arrOperations lastObject];
    if([obj isKindOfClass:[NSDictionary class]]) {
        if([viewDrawable.arrPaths containsObject:obj]) {
            [viewDrawable.arrPaths removeObject:obj];
            [viewDrawable setNeedsDisplay];
        }
    }
    else if([obj isKindOfClass:[BBTextEditView class]]) {
        [obj removeFromSuperview];
    }
    [_arrOperations removeLastObject];
}

#pragma mark - Gesture

- (void)handlePanOnLabel:(UIPanGestureRecognizer *)sender {
    if(currentEditableView.lblText.text.length > 0) {
        [self resignTextField];
        CGPoint location = [sender locationInView:self.view];
        currentEditableView = (BBTextEditView *)sender.view;
        [currentEditableView setCenter:location];
    }
}

#pragma - mark Show/Hide Top And Bottom View

- (void)showTopAndBottomViewAnimated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.3 : 0.0 animations:^{
        CGRect viewTopFrame = viewTop.view.frame;
        viewTopFrame.origin.y = 0;
        [viewTop.view setFrame:viewTopFrame];
        
        CGRect viewBottomFrame = viewBottom.frame;
        viewBottomFrame.origin.y = self.view.frame.size.height - viewBottom.frame.size.height;
        [viewBottom setFrame:viewBottomFrame];
        
        CGRect viewColorPickerFrame = viewColorPicker.frame;
        viewColorPickerFrame.origin.y = viewBottom.frame.origin.y - 50;
        [viewColorPicker setFrame:viewColorPickerFrame];
    }];
}

- (void)hideTopAndBottomViewAnimated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.3 : 0.0 animations:^{
        CGRect viewTopFrame = viewTop.view.frame;
        viewTopFrame.origin.y = -viewTopFrame.size.height;
        [viewTop.view setFrame:viewTopFrame];
        
        CGRect viewBottomFrame = viewBottom.frame;
        viewBottomFrame.origin.y = self.view.frame.size.height;
        [viewBottom setFrame:viewBottomFrame];
        
        CGRect viewColorPickerFrame = viewColorPicker.frame;
        viewColorPickerFrame.origin.y = self.view.frame.size.height;
        [viewColorPicker setFrame:viewColorPickerFrame];
    
    }];
}

#pragma mark - TextField 

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *strText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [currentEditableView.lblText setText:strText];
    CGSize size = [currentEditableView.lblText sizeThatFits:CGSizeMake(self.view.frame.size.width - 40, 100)];
    CGRect frame = [currentEditableView frame];
    frame.size = size;
    [currentEditableView setFrame:frame];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self resignTextField];
    return YES;
}

- (void)resignTextField {
    if(currentEditableView.lblText.text.length == 0) {
        [currentEditableView removeFromSuperview];
    }
    [currentEditableView.btnDelete removeFromSuperview];
    for (CALayer *layer in currentEditableView.layer.sublayers) {
        if(layer == currentEditableView.borderLayer) {
            [layer removeFromSuperlayer];
        }
    }
    
    viewDrawable.isDrawingEnabled = YES;
    [btnText setSelected:NO];
    [lblText setTextColor:[UIColor whiteColor]];
    [txtFieldTemp setText:@""];
    [txtFieldTemp resignFirstResponder];
}

@end
