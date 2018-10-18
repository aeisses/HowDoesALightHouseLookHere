//
//  ViewController.swift
//  HowDoesALightHouseLookHere
//
//  Created by Aaron Eisses on 10/17/18.
//  Copyright © 2018 Aaron Eisses. All rights reserved.
//

import UIKit
import ARKit
import AFNetworking
import CoreLocation

class ViewController: UIViewController, ARSKViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var sceneView: ARSKView!
    var locationManager: CLLocationManager!
    
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

        // Set the view's delegate
        sceneView.delegate = self

        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true

        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        
        initLocationManager()
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
    
//    func addBox() {
//        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//
//        let boxNode = SCNNode()
//        boxNode.geometry = box
//        boxNode.position = SCNVector3(0, 0, -0.2)
//
//        let scene = SCNScene()
//        scene.rootNode.addChildNode(boxNode)
//        sceneView.scene = scene
//    }

    func archive(worldMap: ARWorldMap) throws {
        let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
        try data.write(to: self.worldMapURL, options: [.atomic])
    }

    // MARK: - ARSKViewDelegate

    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        let labelNode = SKLabelNode(text: "👾")
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        return labelNode;
    }

    func session(_ session: ARSession, didFailWithError error: Error) {}
    func sessionWasInterrupted(_ session: ARSession) {}
    func sessionInterruptionEnded(_ session: ARSession) {}
    
    @IBAction func saveWorldMapButton(_ sender: Any) {
        sceneView.session.getCurrentWorldMap { (worldMap, error) in
            // FIXME handle nil values
            let latitude: CLLocationDegrees = self.getCurrentCoord()?.latitude ?? 0
            let longitude: CLLocationDegrees = self.getCurrentCoord()?.longitude ?? 0
            var worldMapString: String?
            
            do {
                // FIXME lots of unsafe nils here
                let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap, requiringSecureCoding: true)
                worldMapString = data.base64EncodedString()
                let lighthouseToSave = SavedLighthouse(longitude: longitude as Double, latitude: latitude as Double, worldMap: worldMapString!)
            } catch {
                // FIXME handle this
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func getCurrentCoord() -> CLLocationCoordinate2D? {
        return locationManager.location?.coordinate
    }
    
    func initLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Represents a saved LightHouse either being saved or fetched
    class SavedLighthouse {
        var longitude: Double
        var latitude: Double
        var worldMap: String
        
        init(longitude: Double, latitude: Double, worldMap: String) {
            self.longitude = longitude
            self.latitude = latitude
            self.worldMap = worldMap
        }
        
        // Converts a lighthouse into a JSON object for the server
        func toJson() -> [String: Any] {
            let jsonObject: [String: Any] = [
                "latitude" : self.latitude,
                "longitude" : self.longitude,
                "worldMap" : worldMap
            ]
            
            let valid = JSONSerialization.isValidJSONObject(jsonObject)
            
            if (valid) {
                return jsonObject
            } else {
                // FIXME handle this
                return ["": ""]
            }
        }
        
        // Converts fetched JSON from the server into a SavedLightHouse instance
//        static func fromJson() -> SavedLighthouse {
//            // TODO
//        }
    }
}
