//
//  ANDLineChartView.m
//  Pods
//
//  Created by Andrzej Naglik on 08.09.2014.
//  Copyright (c) 2014 Andrzej Naglik. All rights reserved.
//

#import "ANDLineChartView.h"
#import "ANDInternalLineChartView.h"
#import "ANDBackgroundChartView.h"

#define DEFAULT_ELEMENT_SPACING 30.0
#define DEFAULT_FONT_SIZE 12.0

#define TRANSITION_DURATION 0.36


@interface ANDLineChartView()<UIScrollViewDelegate>{
  UIScrollView *_scrollView;
  ANDInternalLineChartView *_internalChartView;
  ANDBackgroundChartView *_backgroundChartView;
  NSLayoutConstraint *_floatingConstraint;
  NSLayoutConstraint *_backgroundWidthEqualToScrollViewConstraints;
  NSLayoutConstraint *_backgroundWidthEqualToChartViewConstraints;
}
@end

@implementation ANDLineChartView

- (instancetype)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if(self){
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _internalChartView = [[ANDInternalLineChartView alloc] initWithFrame:CGRectZero chartContainer:self];
    _backgroundChartView = [[ANDBackgroundChartView alloc] initWithFrame:CGRectZero chartContainer:self];
    
    [_scrollView addSubview:_backgroundChartView];
    [_scrollView addSubview:_internalChartView];
    [self addSubview:_scrollView];
    [self setupDefaultAppearence];
    [self setupInitialConstraints];
  }
  return self;
}

- (void)setupDefaultAppearence{
  //set default colors,fonts etc.
  [self setChartBackgroundColor:[UIColor colorWithRed:0.39 green:0.38 blue:0.67 alpha:1.0]];
  [self setBackgroundColor:[self chartBackgroundColor]];
  [self setLineColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
  [self setElementFillColor:[self chartBackgroundColor]];
  [self setElementStrokeColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
  [self setGridIntervalLinesColor:[UIColor colorWithRed:0.325 green:0.314 blue:0.627 alpha:1.000]];
  [self setGridIntervalFontColor:[UIColor colorWithRed:0.216 green:0.204 blue:0.478 alpha:1.000]];
  
  [self setGridIntervalFont:[UIFont fontWithName:@"HelveticaNeue" size:DEFAULT_FONT_SIZE]];
  [self setElementSpacing:DEFAULT_ELEMENT_SPACING];
  [self setAnimationDuration:TRANSITION_DURATION];
  _shouldLabelsFloat = YES;
}

- (void)setupInitialConstraints{
  [_scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
  [_internalChartView setTranslatesAutoresizingMaskIntoConstraints:NO];
  [_backgroundChartView setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_scrollView,_internalChartView,_backgroundChartView);//
  
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_scrollView]|" options:0 metrics:nil views:viewsDict]];
  [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_scrollView]|" options:0 metrics:nil views:viewsDict]];
  
  [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_internalChartView]|" options:0 metrics:nil views:viewsDict]];
  
  [_scrollView addConstraint:[NSLayoutConstraint constraintWithItem:_internalChartView attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual toItem:_scrollView
                                                          attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
  
  [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_internalChartView]|" options:0 metrics:nil views:viewsDict]];

  [_scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_backgroundChartView]|" options:0 metrics:nil views:viewsDict]];
  
  
  _floatingConstraint = [NSLayoutConstraint constraintWithItem:_backgroundChartView attribute:NSLayoutAttributeLeft
                                                     relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft
                                                    multiplier:1.0 constant:0.0];
  
  _backgroundWidthEqualToScrollViewConstraints = [NSLayoutConstraint constraintWithItem:_backgroundChartView attribute:NSLayoutAttributeWidth
                                                                              relatedBy:NSLayoutRelationEqual toItem:_scrollView
                                                                              attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
  
  _backgroundWidthEqualToChartViewConstraints = [NSLayoutConstraint constraintWithItem:_backgroundChartView attribute:NSLayoutAttributeWidth
                                                                             relatedBy:NSLayoutRelationEqual toItem:_internalChartView
                                                                             attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0];
  
  if([self shouldLabelsFloat]){
    [self addConstraint:_floatingConstraint];
    [_scrollView addConstraint:_backgroundWidthEqualToScrollViewConstraints];
  }else{
    [_scrollView addConstraint:_backgroundWidthEqualToChartViewConstraints];
  }
}

- (void)layoutSubviews{
  [super layoutSubviews];
  [_internalChartView setPreferredMinLayoutWidth:CGRectGetWidth([self frame])];
}

- (void)reloadData{
  [_backgroundChartView setNeedsDisplay];
  [_internalChartView reloadData];
}

- (void)setShouldLabelsFloat:(BOOL)shouldLabelsFloat{
  if(_shouldLabelsFloat == shouldLabelsFloat)
    return;
  
  if(_shouldLabelsFloat){
    [self removeConstraint:_floatingConstraint];
    [_scrollView removeConstraint:_backgroundWidthEqualToScrollViewConstraints];
  }else{
    [_scrollView removeConstraint:_backgroundWidthEqualToChartViewConstraints];
  }
  
  if(shouldLabelsFloat){
    [self addConstraint:_floatingConstraint];
    [_scrollView addConstraint:_backgroundWidthEqualToScrollViewConstraints];
  }else{
    [_scrollView addConstraint:_backgroundWidthEqualToChartViewConstraints];
  }
  
  _shouldLabelsFloat = shouldLabelsFloat;
  [self setNeedsUpdateConstraints];
}

#pragma mark - 
#pragma mark - ANDInternalLineChartViewDataSource methods

- (CGFloat)spacingForElementAtRow:(NSUInteger)row{
  CGFloat spacing = [self elementSpacing];
  if(_delegate && [_delegate respondsToSelector:@selector(chartView:spacingForElementAtRow:)]){
    CGFloat newSpacing = [_delegate chartView:self spacingForElementAtRow:row];
    NSAssert(newSpacing > 0, @"Spacing cannot be smaller than 0.0");
    CGSize imageSize = [_internalChartView.circleImage size];
    newSpacing += (row == 0)
    ? imageSize.width/2.0
    : imageSize.width;
    if(newSpacing > 0) spacing = newSpacing;
  }
  
  return spacing;
}

- (NSUInteger)numberOfElements{
  if(_dataSource && [_dataSource respondsToSelector:@selector(numberOfElementsInChartView:)]){
    return [_dataSource numberOfElementsInChartView:self];
  }else{
    NSAssert(_dataSource, @"Data source is not set.");
    NSAssert([_dataSource respondsToSelector:@selector(numberOfElementsInChartView:)], @"numberOfElementsInChartView: not implemented.");
    return 0;
  }
}

- (NSUInteger)numberOfIntervalLines{
  if(_dataSource && [_dataSource respondsToSelector:@selector(numberOfGridIntervalsInChartView:)]){
    return [_dataSource numberOfGridIntervalsInChartView:self];
  }else{
    NSAssert(_dataSource, @"Data source is not set.");
    NSAssert([_dataSource respondsToSelector:@selector(numberOfGridIntervalsInChartView:)], @"numberOfGridIntervalsInChartView: not implemented.");
    return 0;
  }
}

- (CGFloat)valueForElementAtRow:(NSUInteger)row{
  if(_dataSource && [_dataSource respondsToSelector:@selector(chartView:valueForElementAtRow:)]){
    CGFloat value = [_dataSource chartView:self valueForElementAtRow:row];
    NSAssert(value >= [self minValue] && value <= [self maxValue], @"Value for element %lu (%f) is not in min/max range",(unsigned long)row,value);
    return value;
  }else{
    NSAssert(_dataSource, @"Data source is not set.");
    NSAssert([_dataSource respondsToSelector:@selector(chartView:valueForElementAtRow:)], @"chartView:valueForElementAtRow: not implemented.");
    return 0.0;
  }
}

- (CGFloat)minValue{
  if(_dataSource && [_dataSource respondsToSelector:@selector(minValueForGridIntervalInChartView:)]){
    CGFloat minValue = [_dataSource minValueForGridIntervalInChartView:self];
    NSAssert(minValue < [self maxValue], @"minimal value cannot be bigger than max value");
    return minValue;
  }else{
    NSAssert(_dataSource, @"Data source is not set.");
    NSAssert([_dataSource respondsToSelector:@selector(minValueForGridIntervalInChartView:)], @"minValueForGridIntervalInChartView: not implemented.");
    return 0.0;
  }
}

- (CGFloat)maxValue{
  if(_dataSource && [_dataSource respondsToSelector:@selector(maxValueForGridIntervalInChartView:)]){
    return [_dataSource maxValueForGridIntervalInChartView:self];
  }else{
    NSAssert(_dataSource, @"Data source is not set.");
    NSAssert([_dataSource respondsToSelector:@selector(maxValueForGridIntervalInChartView:)], @"maxValueForGridIntervalInChartView: not implemented.");
    return 0.0;
  }
}

- (NSString*)descriptionForValue:(CGFloat)value{
  if(_dataSource && [_dataSource respondsToSelector:@selector(chartView:descriptionForGridIntervalValue:)]){
    return [_dataSource chartView:self descriptionForGridIntervalValue:value];
  }else{
    NSAssert(_dataSource, @"Data source is not set.");
    NSAssert([_dataSource respondsToSelector:@selector(chartView:descriptionForGridIntervalValue:)], @"chartView:descriptionForGridIntervalValue: not implemented.");
    return @"";
  }
}

@end
