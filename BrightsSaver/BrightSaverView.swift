//
//  BrightSaverView.swift
//  BrightsSaver
//
//  Created by Mac Bellingrath on 4/1/19.
//  Copyright © 2019 Mac Bellingrath. All rights reserved.
//

import Foundation
import ScreenSaver
import SceneKit

@objc(BrightsSaverView)
public class BrightsSaverView: ScreenSaverView {

    private var scnView: SCNView

    public override var frame: NSRect {
        didSet {
            scnView.frame = frame
        }
    }

    public override init?(frame: NSRect, isPreview: Bool) {
        scnView = SCNView(frame: frame)

        super.init(frame: frame, isPreview: isPreview)
        setUpScene()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpScene() {
        addSubview(scnView)
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "brights.scn", withExtension: nil, subdirectory: "art.scnassets") else {
            NSLog("no url for brights here")
            return
        }

        guard let scene = try? SCNScene(url: url, options: nil) else {
            NSLog("no scene found")
            return
        }

        scnView.scene = scene
    }

    public override func draw(_ rect: NSRect) {
        super.draw(rect)

        NSColor.cyan.set()
        NSBezierPath.fill(rect)
    }

//    public override func animateOneFrame() {
//        super.animateOneFrame()
//
//        scnView.pointOfView?.position.z -= 0.001
//    }
}


class Scene: SCNScene {
    
}
