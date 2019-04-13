import PlaygroundSupport
import SceneKit

PlaygroundPage.current.needsIndefiniteExecution = true

#if TARGET_OS_IPHONE
import UIKit
#else
import AppKit
#endif
import Foundation

#if TARGET_OS_IPHONE
typealias Image = UIImage
#else
typealias Image = NSImage
#endif

class ImageService: NSObject {
    func getImage(url: URL, completion: @escaping (Result<Image, Error>) -> Void) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, resp, error) in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let image = Image(data: data) {
                completion(.success(image))
            }
        }).resume()
    }
}


struct BrightImage: Codable {
    let image: URL
    let title: String
    let url: URL
}

struct Brights: Codable {
    let brights: [BrightImage]
}

class BrightService {
    let brightsURL = URL(string: "https://api.washingtonpost.com/rainbow-tv/brights")!

    func getBrights(completion: @escaping (Brights) -> Void) {
        URLSession.shared.dataTask(with: brightsURL) { (data, resp, error) in
            if let data = data,
                let brights = try? JSONDecoder().decode(
                    Brights.self, from: data) {
                completion(brights)
            }
        }.resume()
    }
}

class Scene: SCNScene {
    var imageService = ImageService()
    var service = BrightService()
    var cameraNode: SCNNode?

    func render(completion: @escaping () -> Void) {
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position.y = 5
        cameraNode.position.x = -5
        cameraNode.eulerAngles = SCNVector3(x: -(CGFloat.pi/2) + 0.35,
                                            y: 0.1,
                                            z: 0)

        rootNode.addChildNode(cameraNode)
        self.cameraNode = cameraNode

        let light = SCNLight()
        light.type = .directional
        light.castsShadow = true
        // A larger shadow map image produces more detailed shadows at a higher cost to rendering performance; a smaller shadow map renders more quickly but results in pixelation at the edges of shadows.
        light.shadowMapSize = .zero // CGSize(width: 10, height: 10)
        // bigger is softer
        light.orthographicScale = 10
        // Lower numbers result in shadows with sharply defined, pixelated edges; higher numbers result in blurry shadows.
        light.shadowRadius = 10
        // Higher numbers result in smoother edges; lower numbers increase rendering performance.
        // default is 1 on iOS and 16 on macOS
        light.shadowSampleCount = 25
        light.shadowBias = 5
        light.zNear = 1
        light.zFar = 1

        let lightNode = SCNNode()
        lightNode.position = SCNVector3(x: 0, y: 10, z: 0)

        lightNode.eulerAngles = SCNVector3(x: 0, y: (.pi/2) - 0.02, z: 0)
        lightNode.light = light
        rootNode.addChildNode(lightNode)


        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.diffuse.contents = NSColor.white
        floor.firstMaterial?.isDoubleSided = false
        let floorNode = SCNNode(geometry: floor)
        rootNode.addChildNode(floorNode)

        lightNode.constraints = [SCNLookAtConstraint(target: floorNode)]

        service.getBrights { resp in
            // 6 rows of <= 5
            var matrix: [[BrightImage]] = []
            var i = 0
            var j = 0
            let num = resp.brights.count
            while i < num {
                if i % 5 == 0 {
                    let subseq = Array(resp.brights[j..<i])
                    matrix.append(subseq)
                    j = i
                }

                i += 1
            }

            if j < num {
                matrix.append(Array(resp.brights[j..<num]))
            }

            var position = self.rootNode.position
            // slightly above floor for shadow
            position.y = 0.2
            let margin = CGFloat(1)
            let width = CGFloat(1)
            let height = CGFloat(0.15)
            let length = CGFloat(1)
            let chamferRadius = CGFloat(0.3)

            let group = DispatchGroup()

            for row in matrix {
                for column in row {
                    let newBoxGeometry = SCNBox(
                        width: width,
                        height: height,
                        length: length,
                        chamferRadius: chamferRadius
                    )

                    let newBoxNode = SCNNode(geometry: newBoxGeometry)
                    newBoxNode.castsShadow = true
                    newBoxNode.position = position
                    position.x += newBoxGeometry.width + margin
                    group.enter()
                    self.imageService.getImage(url: column.image, completion: { result in
                        newBoxGeometry.firstMaterial?.diffuse.contents = try? result.get()
                        self.rootNode.addChildNode(newBoxNode)
                        group.leave()
                    })
                }


                position.x = 0
                position.z += length + margin
            }
            group.notify(queue: .main, execute: completion)
        }
    }

}

class View: SCNView, SCNSceneRendererDelegate {

    func loadScene() {
        let scene = Scene()
        self.scene = scene

        // loops actions
        loops = true

        scene.render {
            let duration: TimeInterval = 10
            var actions: [SCNAction] = []

            for node in scene.rootNode.childNodes {
                if let box = node.geometry as? SCNBox {
                    var nodePos = node.position
                    nodePos.y = 3
                    nodePos.z += box.length / 2
                    nodePos.x += box.width / 2

                    let action = SCNAction.move(to:nodePos, duration: duration)
                    actions.append(action)
                }
            }
            actions.shuffle()
            let sequenceAction = SCNAction.sequence(actions)
            let repeatedSequence = SCNAction.repeatForever(sequenceAction)
            scene.cameraNode?.runAction(repeatedSequence)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    }
}

let sceneView = View(frame: CGRect(x:0 , y:0, width: 1000, height: 1000))
sceneView.loadScene()
sceneView.allowsCameraControl = true
sceneView.delegate = sceneView

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

