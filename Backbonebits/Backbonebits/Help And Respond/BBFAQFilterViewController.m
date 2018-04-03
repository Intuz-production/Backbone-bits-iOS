//
//  BBFAQFilterViewController.m
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

#import "BBFAQFilterViewController.h"

@implementation BBFAQFilterCell

@end

@interface BBFAQFilterViewController ()

@end

@implementation BBFAQFilterViewController

@synthesize arrQuestions;

+ (instancetype) sharedInstance {
    static BBFAQFilterViewController *faqFilterInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        faqFilterInstance = [kBBStoryboard instantiateViewControllerWithIdentifier:@"BBFAQFilterViewController"];
    });
    return faqFilterInstance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) loadFAQData:(BBLoadFAQBlock)complete {
    _bbLoadFAQ = complete;
    isPerformFilter = NO;
    [self setData];
}

- (void)setData {
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
        if ([[response valueForKeyPath:@"data.faq"] isKindOfClass:[NSArray class]]) {
            [arrQuestions addObjectsFromArray:[response valueForKeyPath:@"data.faq"]];
            [arrMainQuestions addObjectsFromArray:[response valueForKeyPath:@"data.faq"]];
        }
        
        isPerformFilter = YES;
        if (_bbLoadFAQ) {
            _bbLoadFAQ(isPerformFilter);
        }
    } failure:^(NSError *error) {
        isPerformFilter = NO;
        if (_bbLoadFAQ) {
            _bbLoadFAQ(isPerformFilter);
        }
    }];
}

#pragma mark - Filter FAQ

- (void) performFilterWithString:(NSString *)string withCompleteBlock:(BBCompleteFilterBlock)complete {
    _bbCompletionBlock = complete;
    
    if (arrMainQuestions.count > 0) {
        if (string.length > 0) {
            [arrQuestions removeAllObjects];
            NSPredicate *questionPredicate = [NSPredicate predicateWithFormat:@"question CONTAINS[cd] %@", string];
            NSPredicate *answerPredicate = [NSPredicate predicateWithFormat:@"answer CONTAINS[cd] %@", string];
            NSPredicate * finalPredecate = [NSCompoundPredicate orPredicateWithSubpredicates:@[questionPredicate, answerPredicate]];
            
            [arrQuestions addObjectsFromArray:[arrMainQuestions filteredArrayUsingPredicate:finalPredecate]];
            
            if (arrQuestions.count > 0) {
                [self showFAQFilterList:YES];
            } else {
                [self showFAQFilterList:NO];
            }
        } else {
            [self showFAQFilterList:NO];
        }
    } else {
        [self showFAQFilterList:NO];
    }
}

- (void) showFAQFilterList:(BOOL) isShow {
    [tblFAQFilter reloadData];
    if (_bbCompletionBlock) {
        _bbCompletionBlock(isShow, NO, arrQuestions.count);
    }
}

#pragma mark - Close Button

#pragma mark - Buttons

- (IBAction) btnCloseTapped:(id)sender {
    [self.view setHidden:YES];
}

#pragma mark - TableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [arrQuestions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBFAQFilterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BBFAQFilterCell" forIndexPath:indexPath];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell.contentView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.2]];
    
    NSMutableDictionary *dict = [arrQuestions objectAtIndex:indexPath.row];
    [cell.lblQuestion setText:[dict objectForKey:@"question"]];
    [cell.imgViewArrow setImage:[UIImage imageNamed:@"bb_right_arrow"]];
    [cell.lblQuestion setFont:[kBBUtility boldSystemFontWithSize:15 fixedSize:YES]];
    [cell.lblQuestion setTextColor:kBBRGBCOLOR(0.0, 172.0, 172.0)];
    
    [cell.lblSeparater setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:.3]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_bbCompletionBlock) {
        _bbCompletionBlock(NO, YES, arrQuestions.count);
    }
    NSMutableDictionary *dict = [arrQuestions objectAtIndex:indexPath.row];
    BBReadFAQViewController *viewReadFAQ = [kBBStoryboard instantiateViewControllerWithIdentifier:@"BBReadFAQViewController"];
    viewReadFAQ.selectedQuestionId = [[dict valueForKey:@"id"] integerValue];
    viewReadFAQ.arrMainQuestions = [[NSMutableArray alloc] initWithArray:arrMainQuestions];
    [kBBUtility pushViewController:viewReadFAQ animated:YES];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
