//
//  ViewController.swift
//  HowDoesALightHouseLookHere
//
//  Created by Aaron Eisses on 10/17/18.
//  Copyright © 2018 Aaron Eisses. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL")
        } catch {
            fatalError("Error getting world map URL from document directory.")
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        addBox()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration();
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func addBox() {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(0, 0, -0.2)
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(boxNode)
        sceneView.scene = scene
    }
    
    func archive(worldMap: ARWorldMap) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: self.worldMapURL, options: [.atomic])
    }
    
//    @IBAction func saveBarButtonItemDidTouch(_ sender: UIBarButtonItem) {
//        
//        sceneView.session.getCurrentWorldMap { (worldMap, error) in
//            guard let worldMap = worldMap else {
//                return self.setLabel(text: "Error getting current world map.")
//            }
//
//            do {
//                try self.archive(worldMap: worldMap)
//                DispatchQueue.main.async {
//                    self.setLabel(text: "World map is saved.")
//                }
//            } catch {
//                fatalError("Error saving world map: \(error.localizedDescription)")
//            }
//        }
//    }
}

