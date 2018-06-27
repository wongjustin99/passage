//
//  PAppDelegate.m
//  Passage
//
//  Created by Choong Ng on 6/2/13.
//  Copyright (c) 2013 Choong Ng. All rights reserved.
//

#import "PAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@implementation PAppDelegate

- (id)init
{
    self = [super init];
    return self;
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Hide dock icon
    [self hideDockIcon];
        
    // Place movie window over desktop, under icons, and in all spaces
    {
        NSWindow *w = self.window;
        w.level = kCGDesktopWindowLevel;
        w.styleMask = 0;
        w.canHide = NO;
        w.collectionBehavior = NSWindowCollectionBehaviorCanJoinAllSpaces;
    }

    // Set up movie area
    [self resizePlaybackArea];
    
    // Schedule periodic callback so we can advance the movie
    self.frameAdvanceTimer = [NSTimer
                              scheduledTimerWithTimeInterval:10
                              target:self
                              selector:@selector(advanceFrame)
                              userInfo:nil
                              repeats:YES];
    
    // Add status item
    {
        NSImage *statusImage = [PAppDelegate imageForResourceName:@"status-icon"];
        NSImage *statusImageHighlight = [PAppDelegate imageForResourceName:@"status-icon-highlight"];
        NSStatusItem *si = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
        si.image = statusImage;
        si.alternateImage = statusImageHighlight;
        si.highlightMode = YES;
        si.menu = self.statusMenu;
        self.statusItem = si;
    }
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification
{
    [self resizePlaybackArea];
}

#pragma mark - NSWindowDelegate

- (void)windowDidResize:(NSNotification *)notification
{
    [self resizePlaybackArea];
}

#pragma mark - window management

- (void)resizePlaybackArea
{
    // set window to screen size
    NSRect frame = self.window.screen.frame;
    [self.window setFrame:frame display:YES];
  
  //Johntest: change the color of the background

  //self.movieView.layer.backgroundColor = [NSColor redColor].CGColor;
    
    /*
    if (self.movieView.movie != nil) {
    */
        // get underlying movie size
        //NSSize movieSize;
        //[[self.movieView.movie attributeForKey:QTMovieNaturalSizeAttribute] getValue:&movieSize];
        NSSize movieSize = NSMakeSize(1024, 768);
  
        // get screen size
        NSRect screenFrame = self.window.screen.frame;
        
        // find smallest dimension of movie wrt screen
        float heightRatio = 1.0f * movieSize.height / screenFrame.size.height;
        float widthRatio = 1.0f * movieSize.width / screenFrame.size.width;
        
        // calculate scaled movie size
        int scaledWidth, scaledHeight, scaledOffsetX, scaledOffsetY;
        if (heightRatio > widthRatio) {
            scaledWidth = screenFrame.size.width;
            scaledHeight = 1.0f * scaledWidth / movieSize.width * movieSize.height;
        } else {
            scaledHeight = screenFrame.size.height;
            scaledWidth = 1.0f * scaledHeight / movieSize.height * movieSize.width;
        }
        
        scaledOffsetX = (scaledWidth - screenFrame.size.width) / 2;
        scaledOffsetY = (scaledHeight - screenFrame.size.height) / 2;
        
        // place view within window to crop horiz or vert
        NSRect movieFrame2 = {
            -scaledOffsetX,
            -scaledOffsetY,
            scaledWidth,
            scaledHeight
        };
  NSRect movieFrame = {
    400,
    400,
    500,
    500
  };
  NSLog(@"x:%f, y:%f, %f, %f", movieFrame.origin.x, movieFrame.origin.y, movieFrame.size.width, movieFrame.size.height);
        self.movieView.frame = movieFrame;
    /*
    } else {
        self.movieView.frame = frame;
    }
     */
}

- (void)hideDockIcon
{
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToBackgroundApplication);
}

- (IBAction)showAboutDialog:(id)sender
{
    //show about window
    NSArray *aboutWindowObjects = NULL;
    [[NSBundle mainBundle] loadNibNamed:@"AboutWindow"
                                  owner:self
                        topLevelObjects:&aboutWindowObjects];
    self.aboutWindowObjects = aboutWindowObjects;

    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);

    for (int i=0; i<self.aboutWindowObjects.count; i++) {
        NSWindow *wind = (NSWindow *)(self.aboutWindowObjects[i]);
        if ([wind.title isEqualToString:@"About Passage"])
        [wind setLevel:kCGPopUpMenuWindowLevel];
        [wind makeKeyAndOrderFront:self];
    }

    [NSApp activateIgnoringOtherApps:YES];
}

#pragma mark - movie management

- (void)loadMovie:(NSURL *)movieURL
{
    /*
    self.movieView.movie = [QTMovie movieWithURL:movieURL error:NULL];
    self.movieView.preservesAspectRatio = YES;
    self.movieView.movie.muted = YES;
    [self.movieView.movie setCurrentTime:[self getCurrentPlaybackTime]];
    */
  
  AVPlayer *player = [AVPlayer playerWithURL:movieURL];
  
  // create a player view controller
  NSRect newPlayerLayerFrame = {
    self.movieView.frame.origin.x,
    self.movieView.frame.origin.x,
    self.movieView.frame.size.width,
    self.movieView.frame.size.height
  };
  //[newPlayerLayer setBackgroundColor: [NSColor redColor].CGColor];
  //[self.movieView.layer setBackgroundColor: [NSColor yellowColor].CGColor];

  //newPlayerLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
  //newPlayerLayer.hidden = YES;
  
  [self.movieView setWantsLayer:YES];
  AVPlayerLayer * newPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
  //[newPlayerLayer setFrame: newPlayerLayerFrame];
  // THIS BELOW LINE FIXES NOT SHOWING ON DESKTOP !!!!
  [newPlayerLayer setFrame:self.movieView.bounds];
 [self.movieView.layer addSublayer:newPlayerLayer];
  [self.movieView.layer setBackgroundColor: [NSColor yellowColor].CGColor];
  NSLog(@"6666666666666PLAYER x:%@", CGRectCreateDictionaryRepresentation(newPlayerLayer.frame));
 //self.playerLayer = newPlayerLayer;

  [player play];
   NSLog(@"77777777PLAYER x:%@", CGRectCreateDictionaryRepresentation(newPlayerLayer.frame));
  NSLog(@"x:%f, y:%f, %f, %f", self.movieView.frame.origin.x, self.movieView.frame.origin.y, self.movieView.frame.size.width, self.movieView.frame.size.height);

  //[self resizePlaybackArea];
}

- (IBAction)selectMovieFile:(id)sender {
    ProcessSerialNumber psn = { 0, kCurrentProcess };
    TransformProcessType(&psn, kProcessTransformToForegroundApplication);

    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.delegate = self;
    [openPanel beginWithCompletionHandler:^(NSInteger result) {
        if (openPanel.URL != nil) {
            NSLog(@"%@", openPanel.URL);
            [self loadMovie:openPanel.URL];
        }
        TransformProcessType(&psn, kProcessTransformToBackgroundApplication);
    }];
    [openPanel setLevel:kCGPopUpMenuWindowLevel];
    [openPanel makeKeyAndOrderFront:self];
    [NSApp activateIgnoringOtherApps:YES];
}

/*
- (QTTime)getCurrentPlaybackTime
{
    // Get progress through the day
    NSDate *now = [NSDate date];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar]
                                        components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                        fromDate:now];
    NSDate *beginningOfDay = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    NSTimeInterval dayElapsedInterval = [now timeIntervalSinceDate:beginningOfDay];
    float dayElapsed = dayElapsedInterval / (24 * 60 * 60);
    
    // Set progress through the movie
    QTTime startTime = self.movieView.movie.duration;
    startTime.timeValue = startTime.timeValue * dayElapsed;
    return startTime;
}
 */

- (void)advanceFrame
{
    // The implementation inside QT seems to be efficient when seeking to the
    // same frame repeatedly.
  
    //self.movieView.movie.currentTime = [self getCurrentPlaybackTime];
}

#pragma mark - helpers

+ (NSImage *)imageForResourceName:(NSString *)resourceName
{
    NSBundle *bundle = [NSBundle mainBundle];
    return [[NSImage alloc] initWithContentsOfFile:[bundle pathForImageResource:resourceName]];
}

@end
