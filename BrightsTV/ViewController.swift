//
//  ViewController.swift
//  BrightsTV
//
//  Created by Mac Bellingrath on 4/13/19.
//  Copyright © 2019 Mac Bellingrath. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var scnView = View(frame: .zero)

    override func loadView() {
        view = scnView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scnView.loadScene()
        #if DEBUG
        scnView.allowsCameraControl = true
        #endif
    }


}

