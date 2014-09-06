//
//  ANDExampleViewController.h
//  SimpleAnimatedGraph v.0.1.0
//
//  Created by Andrzej Naglik on 19.01.2014.
//  Copyright (c) 2014 Andrzej Naglik. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ANDLineChartViewDataSource,ANDLineChartViewDelegate;

@interface ANDLineChartView : UIView

@property (nonatomic, weak) id<ANDLineChartViewDataSource> dataSource;
@property (nonatomic, weak) id<ANDLineChartViewDelegate> delegate;

@property (nonatomic, strong) UIFont *gridIntervalFont;

@property (nonatomic, strong) UIColor *chartBackgroundColor;
@property (nonatomic, strong) UIColor *gridIntervalLinesColor;
@property (nonatomic, strong) UIColor *gridIntervalFontColor;

@property (nonatomic, strong) UIColor *elementColor;
@property (nonatomic, strong) UIColor *elementStrokeColor;
@property (nonatomic, strong) UIColor *lineColor;

@property (nonatomic, assign) CGFloat elementSpacing; //default is 30

@property (nonatomic, assign) NSTimeInterval animationDuration; //default is 0.36

// Support for constraint-based layout (auto layout)
// If nonzero, this is used when determining -intrinsicContentSize
@property(nonatomic, assign) CGFloat preferredMinLayoutWidth;

- (void)reloadData;
@end

@protocol ANDLineChartViewDataSource <NSObject>

@required
- (NSUInteger)numberOfElementsInChartView:(ANDLineChartView *)chartView;

- (CGFloat)chartView:(ANDLineChartView *)chartView valueForElementAtRow:(NSUInteger)row;

- (NSUInteger)numberOfGridIntervalsInChartView:(ANDLineChartView *)chartView;

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