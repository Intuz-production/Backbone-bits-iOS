/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBHelpScreensViewController.h"
#import "BBContants.h"

@implementation BBHelpScreensCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
    }
    return self;
}

@end

@implementation BBHelpScreensViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadLayout];
    [BBLoadingView show];
}

#pragma mark - Other Methods

- (void) btnBackTapped:(id)sender {
    [kBBUtility popViewControllerAnimated:YES];
}

- (void)loadLayout {
    [self.view setBackgroundColor:[UIColor whiteColor]];

    [self.view addSubview:({
        viewTop = [BBTopView getBBTopView];
        [viewTop.lblTitle setText:@"Help Screens"];
        [viewTop.btnLeft setTitle:@"Back" theme:BBTopBarButtonThemeBack target:self selector:@selector(btnBackTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addChildViewController:viewTop];
        viewTop.view;
    })];
    
    [self.view addSubview:({
        CGRect frame = CGRectMake(0, viewTop.view.frame.origin.y + viewTop.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
        UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        [collectionViewLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [collectionViewLayout setMinimumInteritemSpacing:0.0];
        [collectionViewLayout setMinimumLineSpacing:0.0];
        
        collectionViewImages = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:collectionViewLayout];
        [collectionViewImages setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [collectionViewImages setShowsHorizontalScrollIndicator:NO];
        [collectionViewImages setShowsVerticalScrollIndicator:NO];
        [collectionViewImages setBackgroundColor:[UIColor clearColor]];
        [collectionViewImages setDelegate:self];
        [collectionViewImages setDataSource:self];
        [collectionViewImages registerClass:[BBHelpScreensCell class] forCellWithReuseIdentifier:@"BBHelpScreensCell"];
        [collectionViewImages setPagingEnabled:YES];
        collectionViewImages;
    })];
    
    [self.view addSubview:({
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 30, self.view.frame.size.width, 30)];
        [pageControl setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        [pageControl setPageIndicatorTintColor:kBBRGBCOLOR(119.0, 119.0, 119.0)];
        [pageControl setCurrentPageIndicatorTintColor:kBBRGBCOLOR(229.0, 229.0, 229.0)];
        [pageControl addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        pageControl;
    })];
    [self setData];
}

- (void)setData {
    [kBBWebClient requestWithURLWithDefaultParameters:BB_URL_GET_HELP parameters:@{@"flag":@"image"} success:^(id response, NSData *responseData) {
        if(!arrImages) {
            arrImages = [[NSMutableArray alloc] init];
        }
        [arrImages removeAllObjects];
        [arrImages addObjectsFromArray:[response valueForKeyPath:@"data.images"]];
        [pageControl setNumberOfPages:[arrImages count]];
        [collectionViewImages reloadData];
        [BBLoadingView dismiss];
    } failure:^(NSError *error) {
        [BBLoadingView dismiss];
    }];
}

#pragma mark - Orientation Methods

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator {
    [collectionViewImages reloadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [collectionViewImages reloadData];
}


#pragma mark - Buttons

- (void)btnCloseTapped:(id)sender {
    [kBBUtility dismissViewController:self animated:YES completion:^{
    }];
}

- (IBAction)pageControlValueChanged:(UIPageControl *)sender {
    [collectionViewImages setContentOffset:CGPointMake(collectionViewImages.frame.size.width * sender.currentPage,0) animated:YES];
}

#pragma mark - CollectionView

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [arrImages count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *strCellIdentifier = @"BBHelpScreensCell";
    BBHelpScreensCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:strCellIdentifier forIndexPath:indexPath];

    NSDictionary *dict = [arrImages objectAtIndex:indexPath.item];
    NSString *strUrl = [dict objectForKey:@"img"];

    [cell addSubview:({
        if(!cell.scrollViewImage) {
            cell.scrollViewImage = [[UIScrollView alloc] initWithFrame:cell.bounds];
            [cell.scrollViewImage setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [cell.scrollViewImage setDelegate:self];
            [cell.scrollViewImage setClipsToBounds:YES];
        }
        cell.scrollViewImage;
    })];
    
    [cell.scrollViewImage addSubview:({
        [[cell.scrollViewImage subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
        cell.imgView = [[UIImageView alloc] initWithFrame:cell.scrollViewImage.bounds];
        cell.imgView;
    })];

    NSLog(@"%@",cell.imgView.subviews);
    [kBBUtility addActivityIndicatorInView:cell.imgView withStyle:UIActivityIndicatorViewStyleWhite];
    NSLog(@"%@",cell.imgView.subviews);
    void(^setImageInScrollView)(UIImage *) = ^(UIImage *image) {
        [kBBUtility removeActivityIndicatorFromView:cell.imgView];
        [cell.imgView setImage:image];
        [cell.imgView setFrame:(CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size}];
        [cell.scrollViewImage setContentSize:image.size];
        
        CGRect scrollViewFrame = cell.scrollViewImage.frame;
        CGFloat scaleWidth = scrollViewFrame.size.width / cell.scrollViewImage.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / cell.scrollViewImage.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        
        cell.scrollViewImage.minimumZoomScale = minScale;
        cell.scrollViewImage.maximumZoomScale = 2.0;
        cell.scrollViewImage.zoomScale = minScale;
        [self centeredFrameForScrollView:cell.scrollViewImage andUIView:cell.imgView];
    };
    NSString *filePath = BB_TEMP_DIRECOTORY_ATTACHMENT_FILE([strUrl lastPathComponent]);
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        UIImage *image = [UIImage imageWithContentsOfFile:filePath];
        setImageInScrollView(image);
    }
    else
    {
        NSURLSessionDownloadTask *task = objc_getAssociatedObject(cell, @"Task");
        [task cancel];
        task = [kBBWebClient downloadImageWithURL:strUrl success:^(id response, NSData *responseData) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createFileAtPath:filePath contents:responseData attributes:nil];
            UIImage *image = (UIImage *)response;
            setImageInScrollView(image);
        } failure:^(NSError *error) {
            if(![[error localizedDescription] isEqualToString:@"cancelled"]) {
                [kBBUtility removeActivityIndicatorFromView:cell.imgView];
            }
        }];
        objc_setAssociatedObject(cell, @"Task", task, OBJC_ASSOCIATION_RETAIN);
    }
    return cell;
}

#pragma mark - ScrollView

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger currentPage = collectionViewImages.contentOffset.x / collectionViewImages.frame.size.width;
    [pageControl setCurrentPage:currentPage];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self getImageViewFromScrollView:scrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIImageView *imgView = [self getImageViewFromScrollView:scrollView];
    [self centeredFrameForScrollView:scrollView andUIView:imgView];
}

#pragma mark - Image

- (UIImageView *)getImageViewFromScrollView:(UIScrollView *)scrollView {
    __block UIImageView *imgView;
    [scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[UIImageView class]]) {
            imgView = obj;
            *stop = YES;
        }
    }];
    return imgView;
}

- (void)centeredFrameForScrollView:(UIScrollView *)scrollView andUIView:(UIImageView *)imgView {
    CGSize boundsSize = scrollView.bounds.size;
    CGRect contentsFrame = imgView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    [imgView setFrame:contentsFrame];
}


@end
