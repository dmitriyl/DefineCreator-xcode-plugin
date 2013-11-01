//
//  SayNoToMagicNumber.h
//  SayNoToMagicNumber
//
//  Created by Dmitriy  on 30/10/2013.
//  Copyright (c) 2013 Dmitriy . All rights reserved.
//
//#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
@class DialogBox;


@interface SayNoToMagicNumber : NSObject <NSPopoverDelegate>
@property (nonatomic, strong) NSTextView *textView;
//@property (nonatomic, weak) DialogBox *dialogView;
@property (nonatomic, strong) NSPopover *dialogPopover;
@end

@interface PopoverViewController : NSViewController <NSTextFieldDelegate>
//@property (nonatomic, strong) id <PopoverControllerDelegate> delegate;
@property (nonatomic, weak) NSString *constantBody;
@property (nonatomic, strong) NSTextField *constantBodyTxtFld;
@property (nonatomic, strong) NSTextField *constNameTxtFld;
@property (nonatomic, weak) NSButton *okButton;
@property (nonatomic, weak) NSPopover *popover;
//@property (nonatomic, strong) NSTextView *textView;
@property (nonatomic, assign) BOOL userApproveConstantCreation;
@end