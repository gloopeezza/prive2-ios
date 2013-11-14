//
//  PVDialogSectionHeaderView.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/13/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVDialogSectionHeaderView.h"

@interface PVDialogSectionHeaderView ()

@property (nonatomic, readonly) UIView *lineView;
@property (nonatomic, readonly) UILabel *dateLabel;

@end

@implementation PVDialogSectionHeaderView {
    UILabel *_dateLabel;
    UIView *_lineView;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self.contentView addSubview:self.dateLabel];
        [self.contentView addSubview:self.lineView];
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    NSParameterAssert(title);
    _title = [title copy];
    
    self.dateLabel.text = title;
    [self layoutIfNeeded];
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }

    return _lineView;
}

- (UILabel *)dateLabel {
    
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateLabel.font = [UIFont systemFontOfSize:10.0f];
        _dateLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
        _dateLabel.backgroundColor = [UIColor clearColor];
    }
   
    return _dateLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [_dateLabel sizeToFit];
    
    CGRect rect = _dateLabel.frame;
    rect.origin.x = 8;
    rect.origin.y = 4;
    _dateLabel.frame = rect;
    
    CGFloat width = CGRectGetWidth(self.contentView.bounds) - 8.0f*3 - CGRectGetWidth(rect);
    CGFloat xoffset = CGRectGetWidth(rect) + 8.0f * 2;
    CGFloat yoffset = rect.origin.y + CGRectGetHeight(rect)/2.0f;
    
    CGFloat lineWidth = 1.0f/[[UIScreen mainScreen] scale];
    
    rect = CGRectIntegral(CGRectMake(xoffset , yoffset, width, lineWidth));
    _lineView.frame = rect;
}


@end
