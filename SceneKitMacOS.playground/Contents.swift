import PlaygroundSupport
import SceneKit

PlaygroundPage.current.needsIndefiniteExecution = true

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
                completion(brights)
            }
        }.resume()
    }
}

class Scene: SCNScene {

    var service = BrightService()
    var cameraNode: SCNNode?

    func render(completion: @escaping () -> Void) {
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 6.2,
                                         y: 7.856,
                                         z: 9.964)
        cameraNode.eulerAngles = SCNVector3(x: -1.2,
                                            y: 0.8,
                                            z: -0.072)
        rootNode.addChildNode(cameraNode)
        self.cameraNode = cameraNode

        let light = SCNLight()
        light.type = .directional
        light.castsShadow = true
        // A larger shadow map image produces more detailed shadows at a higher cost to rendering performance; a smaller shadow map renders more quickly but results in pixelation at the edges of shadows.
        light.shadowMapSize = .zero // CGSize(width: 2000, height: 2000)
        // bigger is softer
        light.orthographicScale = 100
        // Lower numbers result in shadows with sharply defined, pixelated edges; higher numbers result in blurry shadows.
        light.shadowRadius = 10
        // Higher numbers result in smoother edges; lower numbers increase rendering performance.
        light.shadowSampleCount = 10


        let lightNode = SCNNode()
        lightNode.position = SCNVector3(x: 0, y: 100, z: 0)
        lightNode.eulerAngles = SCNVector3(x: 0, y: CGFloat.pi/2, z: 0)
        lightNode.light = light
        rootNode.addChildNode(lightNode)

        let floor = SCNFloor()
        floor.reflectivity = 0
        floor.firstMaterial?.diffuse.contents = NSColor.white
        floor.firstMaterial?.isDoubleSided = false
        let floorNode = SCNNode(geometry: floor)
        floorNode.position = SCNVector3(x: 0, y: -0.2, z: 0)
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
            let margin = CGFloat(1)
            let width = CGFloat(1)
            let height = CGFloat(0.15)
            let length = CGFloat(1)
            let chamferRadiuss = CGFloat(0.3)

            for row in matrix {
                for column in row {
                    let newBoxGeometry = SCNBox(
                        width: width,
                        height: height,
                        length: length,
                        chamferRadius: chamferRadiuss
                    )
                    newBoxGeometry.firstMaterial?.diffuse.contents = NSImage(contentsOf: column.image)
                    let newBoxNode = SCNNode(geometry: newBoxGeometry)
                    newBoxNode.castsShadow = true
                    newBoxNode.position = position
                    position.x += newBoxGeometry.width + margin
                    self.rootNode.addChildNode(newBoxNode)
                }
                position.x = 0
                position.z += length + margin
            }

            completion()
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
            let duration: TimeInterval = 2
            let moveDownAction = SCNAction.move(by: SCNVector3(x: 0, y: -5, z: -5), duration: duration)
            let rotateAction = SCNAction.rotateBy(x: -0.3, y: -0.2, z: 0, duration: duration)
            let pan = SCNAction.move(by:  SCNVector3(x: 0, y: 0, z: 5), duration: duration)
            let sequenceAction = SCNAction.sequence([moveDownAction, rotateAction, pan])
            scene.cameraNode?.runAction(sequenceAction)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        print("euler - \(pointOfView?.eulerAngles) position: \(pointOfView?.position)")
    }
}

let sceneView = View(frame: CGRect(x:0 , y:0, width: 800, height: 450))
sceneView.loadScene()
sceneView.allowsCameraControl = true
sceneView.delegate = sceneView

PlaygroundSupport.PlaygroundPage.current.liveView = sceneView

