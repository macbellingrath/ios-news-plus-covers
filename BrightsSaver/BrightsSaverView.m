//
//  BrightsSaverView.m
//  BrightsSaver
//
//  Created by Mac Bellingrath on 3/31/19.
//  Copyright © 2019 Mac Bellingrath. All rights reserved.
//

#import "BrightsSaverView.h"
@import SceneKit;

@implementation BrightsSaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    self.scnView = [[SCNView alloc] initWithFrame:frame options:nil];
    if (self) {
        [self setAnimationTimeInterval:1/30.0];
        [self setUpSceneWithFrame:frame];
    }
    return self;
}

- (void)setFrame:(NSRect)frame {
    [super setFrame:frame];

    [[self scnView] setFrame:frame];
}

- (void)setUpSceneWithFrame:(NSRect)frame
{
    [self addSubview: [self scnView]];
    

    SCNScene *scene = [SCNScene sceneNamed: @"art.scnassets/brights.scn"];
    scnView.scene = scene;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];

    [[NSColor redColor] set];
    [NSBezierPath fillRect:rect];
}

- (void)animateOneFrame
{
    return;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
