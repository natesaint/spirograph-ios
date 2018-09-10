//
//  ViewController.swift
//  Spirograph simulator
//
//  Created by Nathen St. Germain on 2018-02-13.
//

import UIKit
import SceneKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Read input
        let params = readParams("input")
        
        // Setup scene
        let sceneView = SCNView(frame : self.view.frame)
        self.view.addSubview(sceneView)
        let scene = SCNScene()
        sceneView.scene = scene
        
        // Camera object
        let cam = SCNCamera()
        let camNode = SCNNode()
        camNode.camera = cam
        camNode.position = SCNVector3(x: -3.0, y: 4, z: 2.0)
        
        // Ambient light object
        let ambientLight = SCNLight()
        ambientLight.type = SCNLight.LightType.ambient
        ambientLight.color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        camNode.light = ambientLight
        
        // Light object
        let light = SCNLight()
        light.type = SCNLight.LightType.spot
        light.spotInnerAngle = 100.0
        light.spotOuterAngle = 180.0
        light.castsShadow = true
        light.shadowColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.3)
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 1.5, y: 3, z: 1.5)
        
        // Cube to focus camera on
        let cubeGeometry = SCNBox(width: 0.001, height: 0.001, length: 0.001, chamferRadius: 0.001)
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        // Plane
        let planeGeometry = SCNPlane(width: 70.0, height: 70.0)
        let planeNode = SCNNode(geometry: planeGeometry)
        planeNode.eulerAngles = SCNVector3(x: GLKMathDegreesToRadians(-90), y: 0, z: 0)
        planeNode.position = SCNVector3(x: 0, y: -1.5, z: 0)
        
        // Plane colour
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.white
        planeGeometry.materials = [mat]
        
        // Make camera and light look at cube
        let constraint = SCNLookAtConstraint(target: cubeNode)
        constraint.isGimbalLockEnabled = true
        camNode.constraints = [constraint]
        lightNode.constraints = [constraint]
        
        // Generate nodes used for spirograph
        let cubeNodes = genSpirograph(k: params.k, l: params.l, R: params.R, n: 10000, increment: 0.06282)
        
        // Add elements to the scene
        scene.rootNode.addChildNode(lightNode)
        scene.rootNode.addChildNode(camNode)
        scene.rootNode.addChildNode(cubeNode)
        scene.rootNode.addChildNode(planeNode)
        
        // Add elements of spirograph to scene
        for n in cubeNodes {
            scene.rootNode.addChildNode(n)
        }
    }
    
    // Create and return array of SCNNode objects that are cubes to draw the spirograph
    func genSpirograph (k : Double, l : Double, R : Double, n : Int, increment : Double) -> [SCNNode] {
        let cubeGeometry = SCNBox(width : 0.05, height : 0.05, length : 0.05, chamferRadius : 0.0)
        var cubes = [SCNNode]()
        
        // Colour of cubes
        let mat = SCNMaterial()
        mat.diffuse.contents = UIColor.red
        cubeGeometry.materials = [mat]
        
        // Create all cubes, incrementing t value based on i and calculating x and z values
        for i in 1...n {
            let cubeNode = SCNNode(geometry : cubeGeometry)
            let t = Double(i) * increment
            let x = R * ((1.0-k) * cos(t) + l * k * cos(((1.0-k)/k)*t))
            let z = R * ((1.0-k) * sin(t) + l * k * sin(((1.0-k)/k)*t))
            cubeNode.position = SCNVector3(x : Float(x), y : 0.0, z: Float(z))
            cubes.append(cubeNode)
        }
        
        return cubes
    }
    
    // Read parameters text file
    func readParams (_ filename : String) -> (k : Double, l : Double, R : Double) {
        var str = ""
        if let file = Bundle.main.path(forResource: filename, ofType: "txt") {
            do {
                str = try String(contentsOfFile: file, encoding: String.Encoding.utf8)
            } catch let err as NSError {
                print("Failed to read file...")
                print(err)
            }
        } else {
            print ("Cannot find file: 'input.txt'")
        }
        return parseParams(str)
    }
    
    // Parse parameters into a tuple
    func parseParams (_ str : String) -> (k : Double, l : Double, R : Double) {
        var set = CharacterSet.whitespacesAndNewlines
        set.insert(charactersIn : ",")
        var params = str.components(separatedBy: set)
        params = params.filter{$0 != ""}
        return (k : Double(params[0])!, l : Double(params[1])!, R : Double(params[2])!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

