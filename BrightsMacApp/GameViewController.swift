//
//  GameViewController.swift
//  BrightsMacApp
//
//  Created by Mac Bellingrath on 4/14/19.
//  Copyright © 2019 Mac Bellingrath. All rights reserved.
//

import SceneKit
import QuartzCore

class GameViewController: NSViewController {

    var scnView = View()

    override func loadView() {
        view = scnView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scnView.loadScene()
        scnView.allowsCameraControl = true
    }

}
