/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBReadFAQViewController.h"

@implementation BBReadFAQCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self loadLayout];
    }
    return self;
}

- (void)loadLayout {
    [self setClipsToBounds:YES];
    [self addSubview:({
        if(!_lblQuestion) {
            _lblQuestion = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.frame.size.width - 20, 50)];
        }
        [_lblQuestion setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        _lblQuestion;
    })];
    
    [self addSubview:({
        if(!_imgViewArrow) {
            _imgViewArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 26 - 15, 12, 26, 26)];
        }
        [_imgViewArrow setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        _imgViewArrow;
    })];
    
    [self addSubview:({
        if(!_viewLine) {
            _viewLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
        }
        
        [_viewLine setBackgroundColor:kBBRGBCOLOR(232.0, 232.0, 232.0)];
        [_viewLine setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        _viewLine;
    })];
    
    [self addSubview:({
        if(!_viewWebViewContainer) {
            _viewWebViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 50, self.frame.size.width, 50)];
        }
        [_viewWebViewContainer setBackgroundColor:kBBRGBCOLOR(232.0, 232.0, 232.0)];
        [_viewWebViewContainer setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

        [_viewWebViewContainer addSubview:({
            if(!_webViewAnswer) {
                _webViewAnswer = [[UIWebView alloc] initWithFrame:CGRectMake(20, 0, self.frame.size.width - 20, 50)];
            }
            [_webViewAnswer setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [_webViewAnswer setBackgroundColor:[UIColor clearColor]];
            [_webViewAnswer setOpaque:NO];
            [_webViewAnswer.scrollView setBounces:NO];
            [_webViewAnswer setClipsToBounds:YES];
            [_webViewAnswer setScalesPageToFit:NO];
            [_webViewAnswer setUserInteractionEnabled:NO];
            _webViewAnswer;
        })];

        _viewWebViewContainer;
    })];
}

@end

@implementation BBReadFAQViewController

@synthesize arrMainQuestions;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadLayout];
    [BBLoadingView show];

}

#pragma mark - Other Methods

- (void)btnBackTapped:(id)sender {
    [self.view endEditing:YES];
    [kBBUtility popViewControllerAnimated:YES];
}

- (void)loadLayout {
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.view addSubview:({
        viewTop = [BBTopView getBBTopView];
        [viewTop.lblTitle setText:kReadFAQ];
        [viewTop.btnLeft setTitle:@"Back" theme:BBTopBarButtonThemeBack target:self selector:@selector(btnBackTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self addChildViewController:viewTop];
        viewTop.view;
    })];
    
    // Set Table Layout.
    [tblViewFAQ setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tblViewFAQ setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [tblViewFAQ registerClass:[BBReadFAQCell class] forCellReuseIdentifier:@"BBReadFAQCell"];
    [tblViewFAQ setBackgroundColor:[UIColor clearColor]];
    
    [self setData];
}

- (void)setData {
    
    if (arrMainQuestions != nil) {
        
        if(!arrQuestions) {
            arrQuestions = [[NSMutableArray alloc] init];
        }
        
        [arrQuestions removeAllObjects];
        __block NSInteger selectedIndex = -1;
        [arrMainQuestions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *dict = [obj mutableCopy];
            if (_selectedQuestionId == [[obj valueForKey:@"id"] integerValue]) {
                selectedIndex = idx;
            }
            [dict setObject:@(NO) forKey:@"isExpanded"];
            [arrQuestions addObject:dict];
        }];
        
        [tblViewFAQ reloadData];
        [BBLoadingView dismiss];
        if (selectedIndex != -1) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSIndexPath * indexPath = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
                [self reloadRowAtIndexPath:indexPath];
            });
        }
        return;
    }
    
    NSDictionary *params = @{@"flag":@"faq",
                             @"ver_id":kBB_APP_VERSION_NUMBER_STRING};
    [kBBWebClient requestWithURLWithDefaultParameters:BB_URL_GET_HELP parameters:params success:^(id response, NSData *responseData) {
        if(!arrQuestions) {
            arrQuestions = [[NSMutableArray alloc] init];
        }
        if(!arrMainQuestions) {
            arrMainQuestions = [[NSMutableArray alloc] init];
        }
        
        [arrQuestions removeAllObjects];
        [arrMainQuestions removeAllObjects];
        [[response valueForKeyPath:@"data.faq"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *dict = [obj mutableCopy];
            [dict setObject:@(NO) forKey:@"isExpanded"];
            [arrQuestions addObject:dict];
        }];
        // Make copy of main data for search.
        [arrMainQuestions addObjectsFromArray:arrQuestions];
        
        [tblViewFAQ reloadData];
        
        [BBLoadingView dismiss];
    } failure:^(NSError *error) {
        [BBLoadingView dismiss];
    }];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *dict = [arrQuestions objectAtIndex:indexPath.row];
    if([[dict objectForKey:@"isExpanded"] boolValue]) {
        return 50 + [[dict objectForKey:@"answerContentHeight"] floatValue];
    }
    else {
        return 50;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrQuestions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBReadFAQCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BBReadFAQCell" forIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    NSMutableDictionary *dict = [arrQuestions objectAtIndex:indexPath.row];
    [cell.lblQuestion setText:[dict objectForKey:@"question"]];
    [cell.webViewAnswer setDelegate:self];
    [cell.webViewAnswer setTag:indexPath.row + 1];
    if([[dict objectForKey:@"isExpanded"] boolValue]) {
        [cell.imgViewArrow setImage:[UIImage imageNamed:@"bb_down_arrow"]];
        [cell.lblQuestion setFont:[kBBUtility boldSystemFontWithSize:cell.lblQuestion.font.pointSize fixedSize:YES]];
        [cell.lblQuestion setTextColor:kBBRGBCOLOR(0.0, 172.0, 172.0)];
    }
    else {
        [cell.imgViewArrow setImage:[UIImage imageNamed:@"bb_right_arrow"]];
        [cell.lblQuestion setFont:[kBBUtility systemFontWithSize:cell.lblQuestion.font.pointSize fixedSize:YES]];
        [cell.lblQuestion setTextColor:kBBRGBCOLOR(71.0, 71.0, 71.0)];
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString * htmlString = [NSString stringWithFormat:@"<html><body style=\"font-family:Roboto,sans-serif; font-size:16px;\">%@</body></html>",[dict objectForKey:@"answer"]];
            [cell.webViewAnswer loadHTMLString:htmlString baseURL:nil];
        });
    });
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self reloadRowAtIndexPath:indexPath];
}

- (void) reloadRowAtIndexPath:(NSIndexPath *) indexPath {
    NSMutableDictionary *dict = [arrQuestions objectAtIndex:indexPath.row];
    if(![[dict objectForKey:@"isExpanded"] boolValue]) {
        [arrQuestions setValue:@(NO) forKey:@"isExpanded"];
    }
    [dict setObject:@(![[dict objectForKey:@"isExpanded"] boolValue]) forKey:@"isExpanded"];
    [tblViewFAQ reloadData];
    [tblViewFAQ scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
}

#pragma mark - WebView

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    CGRect webViewContainerFrame = [webView.superview frame];
    webViewContainerFrame.size.height = fittingSize.height;
    [webView.superview setFrame:webViewContainerFrame];
    
    NSMutableDictionary *dict = [arrQuestions objectAtIndex:webView.tag - 1];
    if(![dict objectForKey:@"answerContentHeight"]) {
        [dict setObject:@(fittingSize.height) forKey:@"answerContentHeight"];
    }
}

#pragma mark - Search Bar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    UITextField *searchBarTextField = nil;
    for (UIView *mainview in topSearchBar.subviews)
    {
        for (UIView *subview in mainview.subviews) {
            if ([subview isKindOfClass:[UITextField class]])
            {
                searchBarTextField = (UITextField *)subview;
                break;
            }
        }
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
}

- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSString *filterText = [searchBar.text stringByReplacingCharactersInRange:range withString:text];
    [self filterFAQWithString:filterText];
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self filterFAQWithString:searchBar.text];
}

- (void) filterFAQWithString:(NSString *)string
{
    if (arrMainQuestions.count > 0) {
        if (string.length > 0) {
            [arrQuestions removeAllObjects];
            NSPredicate *questionPredicate = [NSPredicate predicateWithFormat:@"question CONTAINS[cd] %@", string];
            NSPredicate *answerPredicate = [NSPredicate predicateWithFormat:@"answer CONTAINS[cd] %@", string];
            NSPredicate * finalPredecate = [NSCompoundPredicate orPredicateWithSubpredicates:@[questionPredicate, answerPredicate]];
            
            [arrQuestions addObjectsFromArray:[arrMainQuestions filteredArrayUsingPredicate:finalPredecate]];
            [arrQuestions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj setObject:@(NO) forKey:@"isExpanded"];
            }];
            [tblViewFAQ reloadData];
        } else {
            [self loadAllData];
        }
    }
}

- (void) loadAllData {
    if (arrMainQuestions.count > 0) {
        [arrQuestions removeAllObjects];
        [arrQuestions addObjectsFromArray:arrMainQuestions];
        [arrQuestions enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj setObject:@(NO) forKey:@"isExpanded"];
        }];
        [tblViewFAQ reloadData];
    }
}

@end
