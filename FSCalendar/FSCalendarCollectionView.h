//
//  FSCalendarCollectionView.h
//  FSCalendar
//
//  Created by Wenchao Ding on 10/25/15.
//  Copyright (c) 2015 Wenchao Ding. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSCalendar;

@interface FSCalendarCollectionView : UICollectionView

@property (weak, nonatomic) FSCalendar *calendar;

@end

@interface FSCalendarSeparator : UICollectionReusableView
@end
