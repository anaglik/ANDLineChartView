# ANDLineChartView for iOS

ANDLineChartView is easy to use view-based class for displaying animated line chart.

![](https://raw.github.com/anaglik/ANDLineChartView/master/example.gif)

## Usage

API is simple. Just implement following data source methods:

``` objective-c
- (NSUInteger)numberOfElementsInChartView:(ANDLineChartView *)chartView;
- (CGFloat)chartView:(ANDLineChartView *)chartView valueForElementAtRow:(NSUInteger)row;

- (NSUInteger)numberOfGridIntervalsInChartView:(ANDLineChartView *)chartView;
- (NSString*)chartView:(ANDLineChartView *)chartView descriptionForGridIntervalValue:(CGFloat)interval;

- (CGFloat)maxValueForGridIntervalInChartView:(ANDLineChartView *)chartView;
- (CGFloat)minValueForGridIntervalInChartView:(ANDLineChartView *)chartView;
```

You can also specify spacing between elements in chart by implementing optional delegate method :
``` objective-c
- (CGFloat)chartView:(ANDLineChartView *)chartView spacingForElementAtRow:(NSUInteger)row
```
Font and colors are customizable through class properties.

To run the example project, just clone repo and open ANDLineChartView.xcworkspace .

## Screenshot

![Alt text](https://raw.github.com/anaglik/ANDLineChartView/master/screen1.png)

## Requirements

iOS7 or later

## Installation

ANDLineChartView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

pod "ANDLineChartView"

## Author

Andrzej Naglik, dev.an@icloud.com

## License

ANDLineChartView is available under the MIT license. See the LICENSE file for more info.
