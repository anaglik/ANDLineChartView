//
//  ANDLineChartView.h
//  Pods
//
//  Created by Andrzej Naglik on 08.09.2014.
//  Copyright (c) 2014 Andrzej Naglik. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ANDLineChartViewDataSource,ANDLineChartViewDelegate;

@interface ANDLineChartView : UIView

@property (nonatomic, strong) UIFont *gridIntervalFont;

@property (nonatomic, strong) UIColor *chartBackgroundColor; // default is [UIColor colorWithRed:0.39 green:0.38 blue:0.67 alpha:1.0]
@property (nonatomic, strong) UIColor *gridIntervalLinesColor; // default is [UIColor colorWithRed:0.325 green:0.314 blue:0.627 alpha:1.000]
@property (nonatomic, strong) UIColor *gridIntervalFontColor; // default is [UIColor colorWithRed:0.216 green:0.204 blue:0.478 alpha:1.000]

@property (nonatomic, strong) UIColor *elementFillColor; // default is [UIColor colorWithRed:0.39 green:0.38 blue:0.67 alpha:1.0]
@property (nonatomic, strong) UIColor *elementStrokeColor; // default is [UIColor colorWithRed:1 green:1 blue:1 alpha:1]
@property (nonatomic, strong) UIColor *lineColor; // default is [UIColor colorWithRed:1 green:1 blue:1 alpha:1]

@property (nonatomic, assign) CGFloat elementSpacing; //default is 30
@property (nonatomic, assign) NSTimeInterval animationDuration; //default is 0.36

@property (nonatomic, weak) id<ANDLineChartViewDataSource> dataSource;
@property (nonatomic, weak) id<ANDLineChartViewDelegate> delegate;

@property (nonatomic, assign) BOOL shouldLabelsFloat; //default YES

@property(nonatomic, readonly, strong) UIScrollView *scrollView;

- (void)reloadData;

- (NSUInteger)numberOfElements;
- (NSUInteger)numberOfIntervalLines;

- (CGFloat)valueForElementAtRow:(NSUInteger)row;
- (CGFloat)minValue;
- (CGFloat)maxValue;
- (NSString*)descriptionForValue:(CGFloat)value;

- (CGFloat)spacingForElementAtRow:(NSUInteger)row;
@end


@protocol ANDLineChartViewDataSource <NSObject>
@required
- (NSUInteger)numberOfElementsInChartView:(ANDLineChartView *)chartView;
- (NSUInteger)numberOfGridIntervalsInChartView:(ANDLineChartView *)chartView;
- (CGFloat)chartView:(ANDLineChartView *)chartView valueForElementAtRow:(NSUInteger)row;

// Values may be displayed differently eg. One might want to present 4200 seconds as 01h:10:00
- (NSString*)chartView:(ANDLineChartView *)chartView descriptionForGridIntervalValue:(CGFloat)interval;

- (CGFloat)maxValueForGridIntervalInChartView:(ANDLineChartView *)chartView;
- (CGFloat)minValueForGridIntervalInChartView:(ANDLineChartView *)chartView;
@end

@protocol ANDLineChartViewDelegate <NSObject>
@optional
// you can specify spacing from previous element to element at current row. If it is first element, spacing is computed
// from left border of view.
// if you want to have the same spacing between every element, use elementSpacing property from ANDGraphView
- (CGFloat)chartView:(ANDLineChartView *)chartView spacingForElementAtRow:(NSUInteger)row;

@end
