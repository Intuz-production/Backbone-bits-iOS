//
//  BBRequestDetailCell.m
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

#import "BBRequestDetailCell.h"
#import "BBContants.h"



@implementation BBRequestDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self loadLayout];
    }
    return self;
}

#pragma mark - Other Methods

- (void)loadLayout {
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    [self insertSubview:({
        _viewVerticalLine = [[UIView alloc] initWithFrame:CGRectMake(70, 0, 1, self.frame.size.height)];
        [_viewVerticalLine setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [_viewVerticalLine setBackgroundColor:kBBRGBCOLOR(232.0, 232.0, 232.0)];
        _viewVerticalLine;
    }) atIndex:0];
    
    [self addSubview:({
        _lblTime = [[UILabel alloc] initWithFrame:CGRectMake(5, 23, 50, 25)];
        [_lblTime setFont:[kBBUtility systemFontWithSize:12.0 fixedSize:YES]];
        [_lblTime setMinimumScaleFactor:.5];
        [_lblTime setNumberOfLines:0];
        [_lblTime setTextAlignment:NSTextAlignmentCenter];
        [_lblTime setTextColor:[UIColor grayColor]];
        _lblTime;
    })];
    
    [self addSubview:({
        _lblHours = [[UILabel alloc] initWithFrame:CGRectMake(5, 63, 50, 25)];
        [_lblHours setFont:[kBBUtility systemFontWithSize:10.0 fixedSize:YES]];
        [_lblHours setMinimumScaleFactor:.5];
        [_lblHours setNumberOfLines:1];
        [_lblHours setTextColor:[UIColor lightGrayColor]];
        _lblHours;
    })];
    
    [self addSubview:({
        _imgViewRequestFrom = [[UIImageView alloc] initWithFrame:CGRectMake(0, 23, 30, 30)];
        [_imgViewRequestFrom setCenter:CGPointMake(_viewVerticalLine.center.x, _imgViewRequestFrom.center.y)];
        _imgViewRequestFrom;
    })];
    
    CGFloat x = _imgViewRequestFrom.frame.origin.x + _imgViewRequestFrom.frame.size.width + 5;

    UIImageView *(^bubbleImageViewForView)(UIView *) = ^(UIView *view) {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:view.bounds];
        [imgView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin];
        return imgView;
    };
    
    [self addSubview:({
        if(!_lblName) {
            _lblName = [[UILabel alloc] initWithFrame:CGRectMake(x+7, 5, self.frame.size.width - x - 26, 20)];
            [_lblName setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [_lblName setFont:[kBBUtility systemFontWithSize:13.0]];
            [_lblName setBackgroundColor:[UIColor clearColor]];
            [_lblName setTextColor:[UIColor lightGrayColor]];
        }
        _lblName;
    })];
    
    [self addSubview:({
        _viewMessageBubble = [[UIView alloc] initWithFrame:CGRectMake(x, 25, self.frame.size.width - x - 20, 70)];
        [_viewMessageBubble setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        _imgViewMessageBubble = bubbleImageViewForView(_viewMessageBubble);
        [_viewMessageBubble addSubview:_imgViewMessageBubble];
        [_viewMessageBubble setBackgroundColor:[UIColor clearColor]];
        
        [_viewMessageBubble addSubview:({
            if(!_lblMessage) {
                _lblMessage = [[UITextView alloc] initWithFrame:CGRectMake(20, 8, _viewMessageBubble.frame.size.width - 30, 54)];
                [_lblMessage setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
                [_lblMessage setFont:[kBBUtility systemFontWithSize:15.0]];
                [_lblMessage setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
                [[_lblMessage textContainer] setLineFragmentPadding:0];
                [_lblMessage setBackgroundColor:[UIColor clearColor]];
                [_lblMessage setTextColor:kBBRGBCOLOR(92.0, 92.0, 92.0)];
                [_lblMessage setUserInteractionEnabled:YES];
                [_lblMessage setDelegate:self];
                [_lblMessage setBounces:NO];
                [_lblMessage setEditable:NO];
                [_lblMessage setSelectable:YES];
            }
            _lblMessage;
        })];
        
        
        _viewMessageBubble;
    })];
    
    [self addSubview:({
        _viewAttachment = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 70 - 10, self.frame.size.width, 50)];
        [_viewAttachment setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        
        [_viewAttachment addSubview:({
            _imgViewAttachmentIcon = [[UIImageView alloc] initWithFrame:CGRectMake(x+10, 0, 30, 30)];
            [_imgViewAttachmentIcon setImage:[UIImage imageNamed:@"bb_attach_icon"]];
            _imgViewAttachmentIcon;
        })];
        
        [_viewAttachment insertSubview:({
            _viewHorizontalLine = [[UIView alloc] initWithFrame:CGRectMake(_viewVerticalLine.frame.origin.x, 0, 45, 1)];
            [_viewHorizontalLine setCenter:CGPointMake(_viewHorizontalLine.center.x, _imgViewAttachmentIcon.center.y)];
            [_viewHorizontalLine setBackgroundColor:kBBRGBCOLOR(232.0, 232.0, 232.0)];
            _viewHorizontalLine;
        }) atIndex:0];
        
        [_viewAttachment addSubview:({
            CGFloat attachmentBubbleX = _imgViewAttachmentIcon.frame.origin.x + _imgViewAttachmentIcon.frame.size.width + 5;
            _viewAttachmentBubble = [[UIView alloc] initWithFrame:CGRectMake(attachmentBubbleX, 0, _viewAttachment.frame.size.width - attachmentBubbleX - 20, _viewAttachment.frame.size.height)];
            [_viewAttachmentBubble setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            [_viewAttachmentBubble setBackgroundColor:[UIColor clearColor]];
            
            [_viewAttachmentBubble addSubview:({
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
                [layout setMinimumInteritemSpacing:5.0];
                [layout setMinimumLineSpacing:5.0];
                [layout setItemSize:CGSizeMake(50, 50)];
                
                _collectionViewAttachments = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, _viewAttachmentBubble.frame.size.width, 50) collectionViewLayout:layout];
                [_collectionViewAttachments setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
                [_collectionViewAttachments setBackgroundColor:[UIColor whiteColor]];
                [_collectionViewAttachments registerClass:[BBAttachmentCell class] forCellWithReuseIdentifier:@"BBAttachmentCell"];
                [_collectionViewAttachments setDelegate:self];
                [_collectionViewAttachments setDataSource:self];
                [_collectionViewAttachments setBackgroundColor:[UIColor clearColor]];
                _collectionViewAttachments;
            })];
            _viewAttachmentBubble;
        })];
        
        _viewAttachment;
    })];
}

#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_arrAttachmentsThumb count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BBAttachmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BBAttachmentCell" forIndexPath:indexPath];
    [cell.btnDelete setHidden:YES];
    
    
    
    NSString *strImageURL = [_arrAttachmentsThumb objectAtIndex:indexPath.item];
    NSURL * imageURL = [NSURL URLWithString:[strImageURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    if([kBBUtility isVideoUrl:imageURL]) {
        
        [cell.imgViewAttachment setImage:nil];
        __block UIImageView *_imgView = cell.imgViewAttachment;
        [kBBUtility addActivityIndicatorInView:_imgView withStyle:UIActivityIndicatorViewStyleGray];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:imageURL options:nil];
        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        CMTime time = CMTimeMake(0, 30);
        
        dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSError *error = NULL;
            CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
            UIImage *frameImage = [[UIImage alloc] initWithCGImage:refImg];
            dispatch_async(dispatch_get_main_queue(), ^{
                [kBBUtility removeActivityIndicatorFromView:_imgView];
                if (frameImage) {
                    [self addBorderToImage:_imgView];
                    [_imgView setImage:frameImage];
                } else {
                    [self removeBorderToImage:_imgView];
                    [_imgView setImage:[UIImage imageNamed:@"bb_default_video_thumb"]];
                }
            });
        });
        
    }
    else {
        NSString *filePath = BB_TEMP_DIRECOTORY_ATTACHMENT_FILE([strImageURL lastPathComponent]);
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            UIImage *image = [UIImage imageNamed:filePath];
            [cell.imgViewAttachment setImage:image];
            [self addBorderToImage:cell.imgViewAttachment];
        }else {
            [kBBUtility addActivityIndicatorInView:cell.imgViewAttachment withStyle:UIActivityIndicatorViewStyleGray];
            [cell.imgViewAttachment setImage:nil];
            __block UIImageView *_imgView = cell.imgViewAttachment;
            [kBBUtility addActivityIndicatorInView:cell.imgViewAttachment withStyle:UIActivityIndicatorViewStyleGray];
            
            [kBBWebClient downloadImageWithURL:strImageURL success:^(id response, NSData *responseData) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager createFileAtPath:filePath contents:responseData attributes:nil];
                [_imgView setImage:response];
                [self addBorderToImage:_imgView];
                [kBBUtility removeActivityIndicatorFromView:_imgView];
            } failure:^(NSError *error) {
                [self removeBorderToImage:_imgView];
                [kBBUtility removeActivityIndicatorFromView:_imgView];
            }];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *fileUrl = [NSURL URLWithString:[_arrAttachmentsFull objectAtIndex:indexPath.row]];
    [BBPreviewView showViewWithFileUrl:fileUrl];
}

#pragma mark - Add/Remove Border

- (void) addBorderToImage:(UIImageView *) imageView {
    imageView.layer.cornerRadius = 3;
    [imageView.layer setBorderColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.4].CGColor];
    [imageView.layer setBorderWidth:1];
}

- (void) removeBorderToImage:(UIImageView *) imageView {
    imageView.layer.cornerRadius = 0;
    [imageView.layer setBorderColor:[UIColor clearColor].CGColor];
    [imageView.layer setBorderWidth:0];
}

#pragma mark - TextView Delegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if (kBB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9")) {
        // Fix for iOS 9 bug
        [[UIApplication sharedApplication] openURL:URL];
        return NO;
    }
    return YES;
}

@end
