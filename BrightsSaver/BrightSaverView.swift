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

    private var scnView: View

    public override var frame: NSRect {
        didSet {
            scnView.frame = frame
        }
    }

    public override init?(frame: NSRect, isPreview: Bool) {
        scnView = View(frame: frame)

        super.init(frame: frame, isPreview: isPreview)
        setUpScene()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpScene() {
        addSubview(scnView)
        scnView.loadScene()
    }

}
