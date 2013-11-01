//
//  SayNoToMagicNumber
//
//  Created by Dmitriy  on 30/10/2013.
//    Copyright (c) 2013 Dmitriy . All rights reserved.
//

#define kPopoverHeight 120.f
#define kPopoverWidth 300.0f

#import "SayNoToMagicNumber.h"
#import "DialogBox.h"
//#import "PopoverViewController.h"


static SayNoToMagicNumber *sharedPlugin;

@interface SayNoToMagicNumber()

@property (nonatomic, strong) NSBundle *bundle;
@end

@implementation SayNoToMagicNumber

//The only way to debug
//    NSAlert *alert = [NSAlert alertWithMessageText:@"Hello, World" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@""];
//    [alert runModal];

- (void) popoverCreation
{
    NSArray* selectedRanges = [_textView selectedRanges];
    if (selectedRanges.count >= 1)
    {
        //make global
        NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
        NSString *text = _textView.textStorage.string;
//        NSRange lineRange = [text lineRangeForRange:selectedRange];
//        NSString *line = [text substringWithRange:lineRange];
        NSString *selectedText = [text substringWithRange:selectedRange];
        
//        NSRange colorRange = [line rangeOfString:@"autoresizingmask" options:NSCaseInsensitiveSearch];
        if (YES)
        {
            NSRect selectionRectOnScreen = [_textView firstRectForCharacterRange:selectedRange];
            NSRect selectionRectInWindow = [_textView.window convertRectFromScreen:selectionRectOnScreen];
            NSRect selectionRectInView = [_textView convertRect:selectionRectInWindow fromView:nil];

            if (!_dialogPopover)
            {
                _dialogPopover = [[NSPopover alloc] init];
            }
            [_dialogPopover setDelegate:self];
            [_dialogPopover setContentSize:NSMakeSize(kPopoverWidth, kPopoverHeight)];
            
            PopoverViewController *vc = [[PopoverViewController alloc] init];
            vc.popover = _dialogPopover;
            vc.constantBody = selectedText;
            [_dialogPopover setContentViewController:vc];
            [_dialogPopover setAnimates:YES];
            [_dialogPopover setBehavior:NSPopoverBehaviorTransient];
            [_dialogPopover showRelativeToRect: NSMakeRect(CGRectGetMaxX(selectionRectInView),
                                                            CGRectGetMinY(selectionRectInView),
                                                            1.f,
                                                            1.f)
                            ofView:_textView
                            preferredEdge:NSMaxXEdge];
        }
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    if ([firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")]
         && [firstResponder isKindOfClass:[NSTextView class]])
    {
        self.textView = (NSTextView *)firstResponder;
        [self popoverCreation];
    }
    else
    {
        self.textView = nil;
        return;
    }
}

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"])
    {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource acccess
        self.bundle = plugin;
        
        // Create menu items, initialize UI, etc.

        // Sample Menu Item:
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
        if (menuItem)
        {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Add define" action:@selector(doMenuAction) keyEquivalent:@"w"];
            [actionMenuItem setTarget:self];
            [actionMenuItem setKeyEquivalentModifierMask:NSCommandKeyMask | NSShiftKeyMask];
            [[menuItem submenu] addItem:actionMenuItem];
        }
    }
    return self;
}


#pragma mark -
#pragma mark NSPopoverDelegate

- (void)popoverDidClose:(NSNotification *)notification
{
    NSResponder *responder = [notification object];
    NSPopover *popover = (NSPopover*)responder;
    PopoverViewController *pvc = (PopoverViewController*)popover.contentViewController;
    if ([pvc userApproveConstantCreation]) {
        NSString *name = pvc.constNameTxtFld.stringValue;
        NSString *body = pvc.constantBodyTxtFld.stringValue;
        NSString *combine = [NSString stringWithFormat:@"#define %@ %@\n",name,body];
        
        [self.textView.undoManager beginUndoGrouping];
        [self.textView insertText:combine replacementRange:NSMakeRange(0, 0)];

        NSArray* selectedRanges = [_textView selectedRanges];
        if (selectedRanges.count >= 1)
        {
            //make global
            NSRange selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];

            [self.textView insertText:name replacementRange:selectedRange];
            [self.textView.undoManager endUndoGrouping];
        }
    
    }
    _dialogPopover = nil;
}

@end

@interface PopoverViewController ()

@end

@implementation PopoverViewController

- (id)init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

-(void)loadView
{
    DialogBox *db = [[DialogBox alloc] initWithFrame:NSZeroRect];
    db.frame = CGRectMake(0, 0, kPopoverWidth, kPopoverHeight);
    self.view = db;
    
    //name lbl
    NSTextField *nameLbl;
    nameLbl = [[NSTextField alloc] initWithFrame:NSMakeRect(25, 90, 60, 15)];
    [nameLbl setFont:[NSFont boldSystemFontOfSize:10.f]];
    [nameLbl setTextColor:[NSColor colorWithWhite:0.310 alpha:1.000]];
    [nameLbl setStringValue:@"Name:"];
    [nameLbl setBezeled:NO];
    [nameLbl setDrawsBackground:NO];
    [nameLbl setEditable:NO];
    [nameLbl setSelectable:NO];
    [self.view addSubview:nameLbl];

    //name
    NSTextField *tfname = [[NSTextField alloc] initWithFrame:CGRectMake(100, 80, (self.view.frame.size.width-130.f), 22)];
    _constNameTxtFld = tfname;
    [_constNameTxtFld setDelegate:self];
    [self.view addSubview:_constNameTxtFld];
    
    //body lbl
    NSTextField *bodyLbl;
    bodyLbl = [[NSTextField alloc] initWithFrame:NSMakeRect(25, 65, 60, 15)];
    [bodyLbl setFont:[NSFont boldSystemFontOfSize:10.f]];
    [bodyLbl setTextColor:[NSColor colorWithWhite:0.310 alpha:1.000]];
    [bodyLbl setStringValue:@"Body:"];
    [bodyLbl setBezeled:NO];
    [bodyLbl setDrawsBackground:NO];
    [bodyLbl setEditable:NO];
    [bodyLbl setSelectable:NO];
    [self.view addSubview:bodyLbl];
    
    
    //body
    NSTextField *tfbody = [[NSTextField alloc] initWithFrame:CGRectMake(100, 30, (self.view.frame.size.width-130.f), 44)];
    _constantBodyTxtFld = tfbody;
    [_constantBodyTxtFld setDelegate:self];
    [_constantBodyTxtFld setStringValue:_constantBody];
    [self.view addSubview:_constantBodyTxtFld];
    
    
    //Button
    NSButton *btn = [[NSButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width/2)-50.f, 0.f, 100, 30)];
    _okButton = btn;
    [_okButton setButtonType:NSMomentaryChangeButton];
    [_okButton setBezelStyle:NSRoundRectBezelStyle];
    [_okButton setTitle:@"Done"];
    [_okButton setTarget:self];
    [_okButton setAction:@selector(okAction:)];
    [self.view addSubview:_okButton];
    [super loadView];
}

- (void)controlTextDidEndEditing:(NSNotification *)notification
{
    NSTextField *tf = (NSTextField*)[notification object];
    // See if it was due to a return
    if ( [[[notification userInfo] objectForKey:@"NSTextMovement"] intValue] == NSReturnTextMovement )
    {
        if ([_constNameTxtFld.stringValue length] && [_constantBodyTxtFld.stringValue length])
        {
            _userApproveConstantCreation = YES;
            [self.popover close];
        }
        else
        {
            if (tf == _constNameTxtFld && [_constNameTxtFld.stringValue length]
                && ![_constantBodyTxtFld.stringValue length])
            {
                [[self.view window]
                 performSelector:@selector(makeFirstResponder:)
                 withObject:_constantBodyTxtFld
                 afterDelay:0];
            }
        }
    }

}

- (IBAction)okAction:(id)sender
{
    [self.popover close];
}

@end