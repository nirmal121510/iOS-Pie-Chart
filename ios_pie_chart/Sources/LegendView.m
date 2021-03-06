//
//  LegendView.m
//  ios_pie_chart
//
//  Created by Maxim Bilan on 11/3/13.
//  Copyright (c) 2013 Maxim. All rights reserved.
//

#import "LegendView.h"
#import "LegendCellView.h"
#import "ChartData.h"
#import "NSString+Chart.h"

#import <CoreText/CoreText.h>

static			NSString * const	LegendViewTitleFontFamily		= @"HelveticaNeue-Light";
static const	CGFloat				LegendViewTitleFontSize			= 16.0;
static const    CGFloat             LegendViewTitleWidth            = 75;
static const    CGFloat             LegendViewTitleHeight           = 30;
static const    CGFloat             LegendViewItemWidth             = 75;
static const    CGFloat             LegendViewItemHeight            = 15;
static const    CGFloat             LegendViewItemYStartOffset      = 5.0;
static const    CGFloat             LegendViewItemYOffset           = 1.0;
static const    NSInteger			LegendViewItemAmount            = 5;

@interface LegendView ()
{
    NSMutableDictionary *data;
    NSMutableArray *legends;
    
    NSString *currentKey;
}

- (void)createCells;

@end

@implementation LegendView

@synthesize isTitleEnabled = _isTitleEnabled;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        data = [[NSMutableDictionary alloc] init];
        legends = [[NSMutableArray alloc] init];
        currentKey = @"";
        self.isTitleEnabled = YES;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
	CGContextFillRect(context, rect);
    
    if (self.isTitleEnabled && [currentKey length] > 0) {
        NSArray* d = data[currentKey];
        if ([d count] > 0) {
            NSDictionary *attributesTitle = [NSString generateAttributes:LegendViewTitleFontFamily
                                                            withFontSize:LegendViewTitleFontSize
                                                               withColor:[UIColor colorWithRed:0.298039 green:0.337255 blue:0.423529 alpha:1.000]
                                                           withAlignment:NSTextAlignmentFromCTTextAlignment(kCTTextAlignmentCenter)];
        
            [currentKey drawInRect:CGRectMake(0, 0, LegendViewTitleWidth, LegendViewTitleHeight) withAttributes:attributesTitle];
        }
    }
}

- (void)setData:(NSArray *)array withKey:(NSString *)key
{
    [data removeObjectForKey:key];
    
    NSMutableArray *temp = [[NSMutableArray alloc] init];
    for( ChartItemDerived *item in array ) {
        [temp addObject:item];
    }
    
    data[key] = temp;
    currentKey = key;
    
    [self createCells];
    [self setNeedsDisplay];
}

- (void)createCells
{
    for( LegendCellView *legendCellView in legends )
    {
        [legendCellView removeFromSuperview];
    }
    [legends removeAllObjects];
    
    if ([currentKey length] > 0) {
        NSArray* finaData = data[currentKey];
        if ([finaData count] > 0) {
            CGFloat x = 0.0;
            CGFloat y = LegendViewItemYStartOffset;
    
            NSArray *colors = [ChartData colors];
    
            int index = 0;
            for (ChartItemDerived *item in finaData) {
                y += (LegendViewItemHeight + LegendViewItemYOffset);
        
                LegendCellView *cellView = [[LegendCellView alloc] initWithFrame:CGRectMake(x, y, LegendViewItemWidth, LegendViewItemHeight)];
                [self addSubview:cellView];
                [cellView setColor:colors[index]];
                [cellView setText:[item name]];
                [cellView setPercent:item.percent];
                [legends addObject:cellView];
        
                ++index;
        
                if (index == LegendViewItemAmount) {
                    break;
                }
            }
        }
    }
}

- (void)changeKey:(NSString *)key
{
    currentKey = key;
    [self createCells];
}

@end
