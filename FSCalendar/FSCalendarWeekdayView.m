//
//  FSCalendarWeekdayView.m
//  FSCalendar
//
//  Created by dingwenchao on 03/11/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendar.h"
#import "NSLocale+Category.h"
#import "NSString+Category.h"
#import "FSCalendarExtensions.h"
#import "FSCalendarWeekdayView.h"
#import "FSCalendarDynamicHeader.h"

@interface FSCalendarWeekdayView()

@property (strong, nonatomic) NSPointerArray *weekdayPointers;
@property (weak  , nonatomic) UIView *contentView;
@property (weak  , nonatomic) FSCalendar *calendar;

- (void)commonInit;

@end

@implementation FSCalendarWeekdayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:contentView];
    _contentView = contentView;
    
    _weekdayPointers = [NSPointerArray weakObjectsPointerArray];
    for (int i = 0; i < 7; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:weekdayLabel];
        [_weekdayPointers addPointer:(__bridge void * _Nullable)(weekdayLabel)];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.contentView.frame = self.bounds;

    NSInteger count = self.weekdayPointers.count;
    size_t size = sizeof(CGFloat) * count;
    CGFloat *widths = malloc(size);
    FSCalendarSliceCake(self.contentView.fs_width, count, widths);

    BOOL isRtl = [NSLocale characterDirectionForLanguage:_calendar.locale.languageCode] == NSLocaleLanguageDirectionRightToLeft;
    CGFloat x = isRtl ? self.contentView.fs_width : 0;

    for (NSInteger i = 0; i < count; i++) {
        UILabel *label = [self.weekdayPointers pointerAtIndex:i];
        CGFloat width = widths[i];

        if (isRtl) {
            x -= width;
            label.frame = CGRectMake(x, 0, width, self.contentView.fs_height);
        } else {
            label.frame = CGRectMake(x, 0, width, self.contentView.fs_height);
            x += width;
        }
    }

    free(widths);
}


- (void)setCalendar:(FSCalendar *)calendar
{
    _calendar = calendar;
    [self configureAppearance];
}

- (NSArray<UILabel *> *)weekdayLabels
{
    return self.weekdayPointers.allObjects;
}

- (void)configureAppearance
{
    BOOL useVeryShortWeekdaySymbols =
        (self.calendar.appearance.caseOptions & (15<<4)) == FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;

    NSArray *weekdaySyms = useVeryShortWeekdaySymbols
        ? self.calendar.gregorian.veryShortStandaloneWeekdaySymbols
        : self.calendar.gregorian.shortStandaloneWeekdaySymbols;

    // Get firstWeekday (1 = Sunday, 2 = Monday, etc.)
    NSInteger firstWeekday = self.calendar.firstWeekday;

    // Reorder symbols according to firstWeekday
    NSMutableArray *orderedSymbols = [NSMutableArray arrayWithCapacity:7];
    for (NSInteger i = 0; i < 7; i++) {
        NSInteger index = (i + firstWeekday - 1) % 7;
        [orderedSymbols addObject:weekdaySyms[index]];
    }

    for (NSInteger i = 0; i < self.weekdayPointers.count; i++) {
        UILabel *label = [self.weekdayPointers pointerAtIndex:i];
        label.font = self.calendar.appearance.weekdayFont;
        label.textColor = self.calendar.appearance.weekdayTextColor;
        label.text = [orderedSymbols[i] uppercaseString];

        label.transform = CGAffineTransformIdentity;
        label.textAlignment = NSTextAlignmentCenter;
        label.semanticContentAttribute = UISemanticContentAttributeForceLeftToRight;
    }
}



@end
