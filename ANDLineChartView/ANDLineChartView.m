//
//  ANDExampleViewController.h
//  SimpleAnimatedGraph v.0.1.0
//
//  Created by Andrzej Naglik on 19.01.2014.
//  Copyright (c) 2014 Andrzej Naglik. All rights reserved.
//

#import "ANDLineChartView.h"
#import "tgmath.h"

#define DEFAULT_ELEMENT_SPACING 30.0
#define DEFAULT_FONT_SIZE 12.0

#define INTERVAL_TEXT_LEFT_MARGIN 10.0
#define INTERVAL_TEXT_MAX_WIDTH 100.0

#define CIRCLE_SIZE 14.0

#define TRANSITION_DURATION 0.36

@implementation ANDLineChartView{
  CAShapeLayer *_graphLayer;
  CAShapeLayer *_maskLayer;
  CAGradientLayer *_gradientLayer;
  UIImage *_circleImage;
  NSUInteger _numberOfPreviousElements;

  CGFloat _maxValue;
  CGFloat _minValue;
}

- (instancetype)initWithFrame:(CGRect)frame{
  self = [super initWithFrame:frame];
  if(self){
    //set default colors,fonts etc.
    [self setChartBackgroundColor:[UIColor colorWithRed:0.39 green:0.38 blue:0.67 alpha:1.0]];
    [self setBackgroundColor:[self chartBackgroundColor]];
    [self setLineColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [self setElementColor:[self chartBackgroundColor]];
    [self setElementStrokeColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    [self setGridIntervalLinesColor:[UIColor colorWithRed:0.325 green:0.314 blue:0.627 alpha:1.000]];
    [self setGridIntervalFontColor:[UIColor colorWithRed:0.216 green:0.204 blue:0.478 alpha:1.000]];
    
    [self setGridIntervalFont:[UIFont fontWithName:@"HelveticaNeue" size:DEFAULT_FONT_SIZE]];
    [self setElementSpacing:DEFAULT_ELEMENT_SPACING];
    
    [self setContentMode:UIViewContentModeRedraw];
    
    [self setupGradientLayer];
    [self setupMaskLayer];
    [self setupGraphLayer];
  }
  return self;
}

- (void)setupGraphLayer{
  _graphLayer = [CAShapeLayer layer];
  [_graphLayer setFrame:[self bounds]];
  [_graphLayer setGeometryFlipped:YES];
  [_graphLayer setStrokeColor:[[self lineColor] CGColor]];
  [_graphLayer setFillColor:nil];
  [_graphLayer setLineWidth:2.0f];
  [_graphLayer setLineJoin:kCALineJoinBevel];
  [[self layer] addSublayer:_graphLayer];
}

- (void)setupGradientLayer{
  _gradientLayer = [CAGradientLayer layer];
  CGColorRef color1 = [UIColor colorWithWhite:1.000 alpha:0.7].CGColor;
  CGColorRef color2 = [UIColor colorWithWhite:1.000 alpha:0.0].CGColor;
  [_gradientLayer setColors:@[(__bridge id)color1,(__bridge id)color2]];
  [_gradientLayer setLocations:@[@0.0,@0.9]];
  [_gradientLayer setFrame:[self bounds]];
  [[self layer] addSublayer:_gradientLayer];
}

- (void)setupMaskLayer{
  _maskLayer = [CAShapeLayer layer];
  [_maskLayer setFrame:[self bounds]];
  [_maskLayer setGeometryFlipped:YES];
  [_maskLayer setStrokeColor:[[UIColor clearColor] CGColor]];
  [_maskLayer setFillColor:[[UIColor blackColor] CGColor]];
  [_maskLayer setLineWidth:2.0f];
  [_maskLayer setLineJoin:kCALineJoinBevel];
  [_maskLayer setMasksToBounds:YES];
}

- (void)drawRect:(CGRect)rect{
  CGContextRef context = UIGraphicsGetCurrentContext();
  UIBezierPath *boundsPath = [UIBezierPath bezierPathWithRect:self.bounds];
  CGContextSetFillColorWithColor(context, [_chartBackgroundColor CGColor]);
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
  
  NSUInteger numberOfIntervalLines = [[self dataSource] numberOfGridIntervalsInChartView:self];
  CGFloat intervalSpacing = floor(maxHeight/(numberOfIntervalLines-1));
  
  CGFloat maxIntervalValue = [[self dataSource] maxValueForGridIntervalInChartView:self];
  CGFloat minIntervalValue = [[self dataSource] minValueForGridIntervalInChartView:self];
  CGFloat maxIntervalDiff = (maxIntervalValue - minIntervalValue)/(numberOfIntervalLines-1);
  
  for(NSUInteger i = 0;i<numberOfIntervalLines;i++){
    [_gridIntervalLinesColor setStroke];
    [gridLinePath stroke];
    NSString *stringToDraw = [[self dataSource] chartView:self descriptionForGridIntervalValue:minIntervalValue + i*maxIntervalDiff];
    UIColor *stringColor = [self gridIntervalFontColor];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    
    [stringToDraw drawInRect:CGRectMake(INTERVAL_TEXT_LEFT_MARGIN, (CGRectGetHeight([self frame]) - [[self gridIntervalFont] lineHeight]),
                                   INTERVAL_TEXT_MAX_WIDTH, [[self gridIntervalFont] lineHeight])
              withAttributes:@{NSFontAttributeName: [self gridIntervalFont],
                    NSForegroundColorAttributeName: stringColor,
                     NSParagraphStyleAttributeName: paragraphStyle
                              }];
    
    
    CGContextTranslateCTM(context, 0.0, - intervalSpacing);
  }
  
  CGContextRestoreGState(context);
}

- (void)reloadData{
  NSUInteger numberOfPoints = [[self dataSource] numberOfElementsInChartView:self];
  if(numberOfPoints != _numberOfPreviousElements)
    [self invalidateIntrinsicContentSize];
  [self setNeedsDisplay];
  [self setNeedsLayout];
}

- (void)layoutSubviews{
  [super layoutSubviews];
  
  [_graphLayer setFrame:[self bounds]];
  [_maskLayer setFrame:[self bounds]];
  [_gradientLayer setFrame:[self bounds]];
  
  [self refreshGraphLayer];
}

- (void)refreshGraphLayer{
  if([[self dataSource] numberOfElementsInChartView:self] == 0)
    return;
  
  UIBezierPath *path = [UIBezierPath bezierPath];
  [path moveToPoint:CGPointMake(0.0, 0.0)];
  NSUInteger numberOfPoints = [[self dataSource] numberOfElementsInChartView:self];
  _numberOfPreviousElements = numberOfPoints;
  CGFloat xPosition = 0.0;
  CGFloat yMargin = 0.0;
  CGFloat yPosition = 0.0;
  CGFloat maxHeight = 0.0;
  BOOL animationNeeded = ([_graphLayer path] != NULL);
  
  [_graphLayer setStrokeColor:[[self lineColor] CGColor]];

  CGPoint lastPoint;
  [CATransaction begin];
  for(NSUInteger i = 0; i<numberOfPoints;i++){
    CGFloat value = [[self dataSource] chartView:self valueForElementAtRow:i];
    CGFloat minGridValue = [[self dataSource] minValueForGridIntervalInChartView:self];
    
    xPosition += [self spacingForElementAtRow:i] ;
    yPosition = yMargin + floor((value-minGridValue)*[self pixelToRecordPoint]);
    
    if(yPosition > maxHeight) maxHeight = yPosition;
    CGPoint newPosition = CGPointMake(xPosition, yPosition);
    [path addLineToPoint:newPosition];
    
    CALayer *circle = [self circleLayerForPointAtRow:i];
    CGPoint oldPosition = [circle position];
    [circle setPosition: newPosition];
    lastPoint = newPosition;
    
    //animate position change
    if(animationNeeded){
      CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
      positionAnimation.duration = TRANSITION_DURATION;
      positionAnimation.fromValue = [NSValue valueWithCGPoint:oldPosition];
      positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
      //[positionAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
      [positionAnimation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.5 :1.4 :1 :1]];
      [circle addAnimation:positionAnimation forKey:@"position"];
    }
  }
  
  // hide other circles if needed
  if([[_graphLayer sublayers] count] > numberOfPoints){
    for(NSUInteger i = numberOfPoints; i < [[_graphLayer sublayers] count];i++){
      CALayer *circle = [self circleLayerForPointAtRow:i];
      CGPoint oldPosition = [circle position];
      CGPoint newPosition = CGPointMake(oldPosition.x, -200.0);
      [circle setPosition:newPosition];
      
      
      // animate position change
      if(animationNeeded){
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.duration = TRANSITION_DURATION;
        positionAnimation.fromValue = [NSValue valueWithCGPoint:oldPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:newPosition];
        [positionAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [circle addAnimation:positionAnimation forKey:@"position"];
      }
    }
  }
  
  CGPathRef oldPath = [_graphLayer path];
  CGPathRef newPath = path.CGPath;
  
  [_graphLayer setPath:path.CGPath];
  if(animationNeeded){
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = TRANSITION_DURATION;
    pathAnimation.fromValue = (__bridge id)oldPath;
    pathAnimation.toValue = (__bridge id)newPath;
    //[pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.5 :1.4 :1 :1]];
    [_graphLayer addAnimation:pathAnimation forKey:@"path"];
  }
  
  UIBezierPath *copyPath = [UIBezierPath bezierPathWithCGPath:path.CGPath];
  [copyPath addLineToPoint:CGPointMake(lastPoint.x+80, -100)];
  [copyPath addLineToPoint:CGPointMake(0.0, 0.0)];
  CGPathRef maskOldPath = _maskLayer.path;
  CGPathRef maskNewPath = copyPath.CGPath;
  [_maskLayer setPath:copyPath.CGPath];
  [_gradientLayer setMask:_maskLayer];

  if(animationNeeded){
    CABasicAnimation *pathAnimation2 = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation2.duration = TRANSITION_DURATION;
    pathAnimation2.fromValue = (__bridge id)maskOldPath;
    pathAnimation2.toValue = (__bridge id)maskNewPath;
    //[pathAnimation2 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [pathAnimation2 setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.5 :1.4 :1 :1]];
    [_maskLayer addAnimation:pathAnimation2 forKey:@"path"];
  }

  
  [CATransaction commit];

}

#pragma mark - 
#pragma mark - Helpers

- (CGFloat)spacingForElementAtRow:(NSUInteger)row{
  CGFloat spacing = [self elementSpacing];
  if(_delegate && [_delegate respondsToSelector:@selector(chartView:spacingForElementAtRow:)]){
    CGFloat newSpacing = [_delegate chartView:self spacingForElementAtRow:row];
    NSAssert(newSpacing > 0, @"Spacing cannot be smaller than 0.0");
    CGSize imageSize = [self.circleImage size];
    newSpacing += (row == 0)
                  ? imageSize.width/2.0
                  : imageSize.width;
    if(newSpacing > 0) spacing = newSpacing;
  }
  
  return spacing;
}

- (CGFloat)viewHeight{
  UIFont *font = [self gridIntervalFont];
  CGFloat maxHeight = round(CGRectGetHeight([self frame]) - [font lineHeight]);
  return maxHeight;
}

- (CGFloat)pixelToRecordPoint{
  CGFloat maxHeight = [self viewHeight];
  
  CGFloat maxIntervalValue = [[self dataSource] maxValueForGridIntervalInChartView:self];
  CGFloat minIntervalValue = [[self dataSource] minValueForGridIntervalInChartView:self];
  
  return round(maxHeight/(maxIntervalValue - minIntervalValue));
}

- (CALayer*)circleLayerForPointAtRow:(NSUInteger)row{
  NSUInteger totalNumberOfCircles = [[_graphLayer sublayers] count];
  if(row >=  totalNumberOfCircles){
    CALayer *circleLayer = [self newCircleLayer];
    [_graphLayer addSublayer:circleLayer];
  }

  return [_graphLayer sublayers][row];
}

- (CALayer*)newCircleLayer{
  CALayer *newCircleLayer = [CALayer layer];
  UIImage *img = [self circleImage];
  [newCircleLayer setContents:(id)img.CGImage];
  [newCircleLayer setFrame:CGRectMake(0, 0, img.size.width, img.size.height)];
  [newCircleLayer setGeometryFlipped:YES];
  return newCircleLayer;
}

- (UIImage*)circleImage{
  if(!_circleImage){
    CGSize imageSize = CGSizeMake(CIRCLE_SIZE, CIRCLE_SIZE);
    CGFloat strokeWidth = 2;
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);//[UIImage imageNamed:@"circle"];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor clearColor] setFill];
    CGContextFillRect(context, (CGRect){CGPointZero, imageSize});
    
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithOvalInRect: (CGRect){CGPointMake(strokeWidth/2.0, strokeWidth/2.0),
                                                                    CGSizeMake(CIRCLE_SIZE-strokeWidth, CIRCLE_SIZE-strokeWidth)}];
    CGContextSaveGState(context);
    [[self elementColor] setFill];
    [ovalPath fill];
    CGContextRestoreGState(context);
    
    [[self elementStrokeColor] setStroke];
    [ovalPath setLineWidth:strokeWidth];
    [ovalPath stroke];
    
    _circleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
  }
  return _circleImage;
}

#pragma mark - 
#pragma mark - Autolayout code

- (CGSize)intrinsicContentSize{
  CGFloat width = 0.0;
  NSUInteger totalElements = [[self dataSource] numberOfElementsInChartView:self];
  for(int i = 0;i < totalElements;i++){
    width += [self spacingForElementAtRow:i];
  }
  
  width += [[self circleImage] size].width;
  if(width < [self preferredMinLayoutWidth]) width = [self preferredMinLayoutWidth];
  return CGSizeMake(width, UIViewNoIntrinsicMetric);
}

- (void)setPreferredMinLayoutWidth:(CGFloat)preferredMinLayoutWidth{
  if(_preferredMinLayoutWidth != preferredMinLayoutWidth){
    _preferredMinLayoutWidth = preferredMinLayoutWidth;
    if(CGRectGetWidth([self frame]) < preferredMinLayoutWidth){
      [self invalidateIntrinsicContentSize];
    }
  }
}

@end
