//
//  ANDBackgroundChartView.h
//  Pods
//
//  Created by Andrzej Naglik on 14.09.2014.
//
//

#import <UIKit/UIKit.h>
@class ANDLineChartView;

@interface ANDBackgroundChartView : UIView
- (instancetype)initWithFrame:(CGRect)frame chartContainer:(ANDLineChartView*)chartContainer;
@end
