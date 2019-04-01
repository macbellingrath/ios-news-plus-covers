//
//  BrightsSaverView.h
//  BrightsSaver
//
//  Created by Mac Bellingrath on 3/31/19.
//  Copyright © 2019 Mac Bellingrath. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <SceneKit/SceneKit.h>

@interface BrightsSaverView : ScreenSaverView
@property (nullable, retain) SCNView *scnView;
@end
