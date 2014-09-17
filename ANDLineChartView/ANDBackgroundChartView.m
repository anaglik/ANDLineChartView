//
//  ANDBackgroundChartView.m
//  Pods
//
//  Created by Andrzej Naglik on 14.09.2014.
//
//

#import "ANDBackgroundChartView.h"
#import "ANDLineChartView.h"

#define INTERVAL_TEXT_LEFT_MARGIN 10.0
#define INTERVAL_TEXT_MAX_WIDTH 100.0

@interface ANDBackgroundChartView()
@property (nonatomic, weak) ANDLineChartView *chartContainer;
@end

@implementation ANDBackgroundChartView

- (instancetype)initWithFrame:(CGRect)frame chartContainer:(ANDLineChartView*)chartContainer{
  self = [super initWithFrame:frame];
  if(self){
    [self setContentMode:UIViewContentModeRedraw];
    [self setChartContainer:chartContainer];
  }
  return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
  NSAssert(NO, @"Use initWithFrame:chartContainer:");
  return [self initWithFrame:frame chartContainer:nil];
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  UIBezierPath *boundsPath = [UIBezierPath bezierPathWithRect:self.bounds];
  CGContextSetFillColorWithColor(context, [[self.chartContainer chartBackgroundColor] CGColor]);
  [boundsPath fill];
  
  CGFloat maxHeight = [self viewHeight];
  
  [[UIColor colorWithRed:0.329 green:0.322 blue:0.620 alpha:1.000] setStroke];
  UIBezierPath *gridLinePath = [UIBezierPath bezierPath];
  CGPoint startPoint = CGPointMake(0.0,CGRectGetHeight([self frame]));
  CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetHeight([self frame]));
  [gridLinePath moveToPoint:startPoint];
  [gridLinePath addLineToPoint:endPoint];
  [gridLinePath setLineWidth:1.0];
  
  CGContextSaveGState(context);
  
  NSUInteger numberOfIntervalLines =  [self.chartContainer numberOfIntervalLines];
  CGFloat intervalSpacing = (maxHeight/(numberOfIntervalLines-1));

  CGFloat maxIntervalValue = [self.chartContainer maxValue];
  CGFloat minIntervalValue = [self.chartContainer minValue];
  CGFloat maxIntervalDiff = (maxIntervalValue - minIntervalValue)/(numberOfIntervalLines-1);
  
  for(NSUInteger i = 0;i<numberOfIntervalLines;i++){
    [[self.chartContainer gridIntervalLinesColor] setStroke];
    [gridLinePath stroke];
    NSString *stringToDraw = [self.chartContainer descriptionForValue:minIntervalValue + i*maxIntervalDiff];
    UIColor *stringColor = [self.chartContainer gridIntervalFontColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [stringToDraw drawInRect:CGRectMake(INTERVAL_TEXT_LEFT_MARGIN,
                                        (CGRectGetHeight([self frame]) - [[self.chartContainer gridIntervalFont] lineHeight]),
                                        INTERVAL_TEXT_MAX_WIDTH, [[self.chartContainer gridIntervalFont] lineHeight])
              withAttributes:@{NSFontAttributeName: [self.chartContainer gridIntervalFont],
                               NSForegroundColorAttributeName: stringColor,
                               NSParagraphStyleAttributeName: paragraphStyle
                               }];
    
    
    CGContextTranslateCTM(context, 0.0, - intervalSpacing);
  }
  
  CGContextRestoreGState(context);
}

- (CGFloat)viewHeight{
  UIFont *font = [self.chartContainer gridIntervalFont];
  CGFloat maxHeight = round(CGRectGetHeight([self frame]) - [font lineHeight]);
  return maxHeight;
}


@end
