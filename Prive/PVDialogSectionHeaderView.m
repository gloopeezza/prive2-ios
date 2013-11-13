//
//  PVDialogSectionHeaderView.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/13/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVDialogSectionHeaderView.h"

@interface PVDialogSectionHeaderView ()

@property (nonatomic, weak, readonly) UIView *lineView;

@end

@implementation PVDialogSectionHeaderView {
    UILabel *_textLabel;
    __weak UIView *_lineView;
}

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    
    if (self) {
        //[self.contentView addSubview:self.textLabel];
        [self.contentView addSubview:self.lineView];
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    return self;
}

- (void)setTitle:(NSString *)title {
    NSParameterAssert(title);
    _title = [title copy];
    
    self.textLabel.text = title;
    [self setNeedsLayout];
}

- (UIView *)lineView {
    if (_lineView) return _lineView;
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    _lineView = view;
    return view;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [super textLabel];
        _textLabel.font = [UIFont systemFontOfSize:10.0f];
        _textLabel.textColor = [UIColor colorWithWhite:1.0f alpha:0.8f];
    }
    return _textLabel;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.textLabel sizeToFit];
    CGRect rect = self.textLabel.frame;
    rect.origin.x = 8;
    self.textLabel.frame = rect;
    
    CGFloat width = CGRectGetWidth(self.contentView.bounds) - 8.0f*3 - CGRectGetWidth(rect);
    CGFloat xoffset = CGRectGetWidth(rect) + 8.0f * 2;
    CGFloat yoffset = rect.origin.y + CGRectGetHeight(rect)/2.0f;
    
    CGFloat lineWidth = 1.0f/[[UIScreen mainScreen] scale];
    
    rect = CGRectIntegral(CGRectMake(xoffset , yoffset, width, lineWidth));
    self.lineView.frame = rect;
}


@end
