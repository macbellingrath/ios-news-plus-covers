//: A SpriteKit based Playground

import PlaygroundSupport
import SceneKit

struct BrightImage: Codable {
    let image: URL
    let title: String
    let url: URL
}

struct Brights: Codable {
    let brights: [BrightImage]
}


class BrightService {
    let brightsURL = URL(string: "https://api.washingtonpost.com/rainbow-tv/brights/?width=200")!

    func getBrights(completion: @escaping (Brights) -> Void) {
        URLSession.shared.dataTask(with: brightsURL) { (data, resp, error) in

            if let data = data,
                let brights = try? JSONDecoder().decode(
                    Brights.self, from: data) {
                print(brights)
                completion(brights)
            }
        }.resume()
    }
}

class Scene: SCNScene {

    var service = BrightService()
    override init() {
        super.init()

        let boxes = SCNNode()
        let boxGeometry = SCNBox(
            width: 1,
            height: 0.1,
            length: 1,
            chamferRadius: 0.1
        )
        boxGeometry.firstMaterial?.diffuse.contents = NSColor.gray
        boxGeometry.firstMaterial?.isDoubleSided = false
        let boxNode = SCNNode(geometry: boxGeometry)
        boxNode.castsShadow = true
        boxes.addChildNode(boxNode)
        rootNode.addChildNode(boxes)

        let cameraNode = SCNNode()
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, 10)
        rootNode.addChildNode(cameraNode)

        let light = SCNLight()
        let lightNode = SCNNode()
        light.type = .omni
        light.shadowRadius = 100
        light.castsShadow = true
        lightNode.position = SCNVector3(x: 0, y: 100, z: 0)
        lightNode.light = light
        boxes.addChildNode(lightNode)

        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.diffuse.contents = NSColor.white
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(x: 0, y: -0.5, z: 0)
        boxes.addChildNode(floorNode)

        service.getBrights { (brights) in
            // todo
            DispatchQueue.main.async {
                boxGeometry.firstMaterial?.diffuse.contents = NSImage(contentsOf: brights.brights[0].image)
            }
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class View: SCNView {

}

// Load the SKScene from 'GameScene.sks'
let sceneView = View(frame: CGRect(x:0 , y:0, width: 640, height: 480))
sceneView.allowsCameraControl = true

let scene = Scene()
sceneView.scene = scene

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView
print(sceneView.pointOfView?.position)
