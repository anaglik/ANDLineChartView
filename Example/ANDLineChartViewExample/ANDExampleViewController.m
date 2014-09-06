//
//  ANDExampleViewController.m
//  SimpleAnimatedGraph
//
//  Created by Andrzej Naglik on 20.06.2014.
//  Copyright (c) 2014 Andrzej Naglik. All rights reserved.
//

#import "ANDExampleViewController.h"
#import <ANDLineChartView/ANDLineChartView.h>

#define NUMBERS_COUNT 20

#define MAX_NUMBER 20

@interface ANDExampleViewController()<ANDLineChartViewDataSource,ANDLineChartViewDelegate>{
  NSArray *_elements;
  ANDLineChartView *_chartView;
  UIScrollView *_chartContainer;
}

@end

@implementation ANDExampleViewController

- (void)loadView{
  UIView *mainView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self setView:mainView];
  
  _chartContainer = [[UIScrollView alloc] init];
  [_chartContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
  [[self view] addSubview:_chartContainer];
  
  _chartView = [[ANDLineChartView alloc] initWithFrame:CGRectZero];
  [_chartView setTranslatesAutoresizingMaskIntoConstraints:NO];
  [_chartView setDataSource:self];
  [_chartView setDelegate:self];
  [_chartContainer addSubview:_chartView];
  _elements = [self arrayWithNumberOfRandomNumbers:NUMBERS_COUNT];
  
  [_chartContainer setBackgroundColor:[_chartView chartBackgroundColor]];
  
  [self configureInitialConstraints];
}

- (void)viewDidLoad{
  [super viewDidLoad];
  [self setTitle:@"Example graph"];
}

- (void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
  [self randomizeElements];
}

- (void)viewDidLayoutSubviews{
  [super viewDidLayoutSubviews];
  [_chartView setPreferredMinLayoutWidth:CGRectGetWidth([_chartContainer frame])];
}

- (void)randomizeElements{
  __weak ANDExampleViewController *weakSelf = self;
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    _elements = [self arrayWithNumberOfRandomNumbers:NUMBERS_COUNT];
    [_chartView reloadData];
    [weakSelf randomizeElements];
  });
}

- (NSArray*)arrayWithNumberOfRandomNumbers:(NSUInteger)count{
  NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
  for(NSUInteger i = 0;i<count;i++){
    NSUInteger r = arc4random_uniform(MAX_NUMBER + 1);
    [array addObject:@(r)];
  }
  return array;
}


- (void)configureInitialConstraints{
  id topLayoutGuide = [self topLayoutGuide];
  NSDictionary *viewsDict = NSDictionaryOfVariableBindings(topLayoutGuide,_chartContainer,_chartView);//
  
  [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topLayoutGuide][_chartContainer]|"
                                                                      options:0 metrics:nil views:viewsDict]];
  [[self view] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_chartContainer]|" options:0 metrics:nil views:viewsDict]];
  
  [_chartContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_chartView]|" options:0 metrics:0 views:viewsDict]];
  
  [_chartContainer addConstraint:[NSLayoutConstraint constraintWithItem:_chartView attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual toItem:_chartContainer attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
  
  [_chartContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_chartView]|" options:0 metrics:0 views:viewsDict]];
}


- (BOOL)automaticallyAdjustsScrollViewInsets{
  return NO;
}

#pragma mark
#pragma mark - ANDLineChartViewDataSource methods

- (NSUInteger)numberOfElementsInChartView:(ANDLineChartView *)graphView{
  return NUMBERS_COUNT;
}

- (CGFloat)chartView:(ANDLineChartView *)graphView valueForElementAtRow:(NSUInteger)row{
  return [(NSNumber*)_elements[row] floatValue];
}

- (CGFloat)maxValueForGridIntervalInChartView:(ANDLineChartView *)graphView{
  return 20.0;
}

- (CGFloat)minValueForGridIntervalInChartView:(ANDLineChartView *)graphView{
  return -2.0;
}

- (NSUInteger)numberOfGridIntervalsInChartView:(ANDLineChartView *)graphView{
  return 12.0;
}

- (NSString*)chartView:(ANDLineChartView *)graphView descriptionForGridIntervalValue:(CGFloat)interval{
  return [NSString stringWithFormat:@"%.1f",interval];
}

#pragma mark
#pragma mark - ANDLineChartViewDelegate method

- (CGFloat)chartView:(ANDLineChartView *)graphView spacingForElementAtRow:(NSUInteger)row{
  return (row == 0) ? 60.0 : 30.0;
}

@end
