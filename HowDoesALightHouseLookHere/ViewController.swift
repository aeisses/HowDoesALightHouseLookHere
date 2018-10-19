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
import Network

class ViewController: UIViewController, ARSKViewDelegate, CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var sceneView: ARSKView!
    @IBOutlet weak var lightHouseSwitchButton: UIButton!
    
    @IBOutlet weak var lightHousePicker: UIPickerView!
    
    var pickerData: [String] = [String]()
    var pickerValue: String = "PeggysCove"
    
    var locationManager: CLLocationManager!
    let networkObject = Network()

    var worldMapURL: URL = {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("worldMapURL")
        } catch {
            fatalError("Error getting world map URL from document directory.")
        }
    }()
    
    @IBAction func sliderValueChanged( _sender: UISlider) {
        if let scene = sceneView.scene as? Scene {
            scene.offSet = Float(_sender.value)
        }
    }
    
    @IBAction func changeLightHouse( _sender: UIButton) {
        
    }
    
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
        self.lightHousePicker.delegate = self;
        self.lightHousePicker.dataSource = self;
        
        pickerData = ["PeggysCove", "capedor", "CapeGeorge", "fortpoint", "Louisbourg", "portbickerton"]
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
        let lighthouse = SKSpriteNode(imageNamed: pickerValue)
        
        let scaledHeight = lighthouse.size.height * 0.20
        let scaledWidth = lighthouse.size.width * 0.20
        
        lighthouse.size.height = scaledHeight
        lighthouse.size.width = scaledWidth
    
        return lighthouse
    }

    func session(_ session: ARSession, didFailWithError error: Error) {}
    func sessionWasInterrupted(_ session: ARSession) {}
    func sessionInterruptionEnded(_ session: ARSession) {}
    
    @IBAction func loadWorldMap(_ sender: Any) {
        networkObject.getDataFromServer { (Array, Error) in
            let info = Array?.first as! Lighthouse
            let data = Data(base64Encoded: info.worldMap, options: .ignoreUnknownCharacters)
            let worldMap = self.unarchive(worldMapData: data!)
            self.resetTrackingConfiguration(with: worldMap)
        }
    }
    
    @IBAction func saveWorldMapButton(_ sender: Any) {
        if( sceneView.session.currentFrame?.worldMappingStatus == .mapped || sceneView.session.currentFrame?.worldMappingStatus == .extending) {
            sceneView.session.getCurrentWorldMap { (worldMap, error) in
            let latitude: CLLocationDegrees = self.getCurrentCoord()?.latitude ?? 0
            let longitude: CLLocationDegrees = self.getCurrentCoord()?.longitude ?? 0
            var worldMapString: String?
            do {
                let snapshotAnchor = SnapshotAnchor(capturing: self.sceneView)
                worldMap?.anchors.append(snapshotAnchor!)
            
                // FIXME lots of unsafe nils here
                let data = try NSKeyedArchiver.archivedData(withRootObject: worldMap as Any, requiringSecureCoding: true)
                worldMapString = data.base64EncodedString()
                let lighthouseToSave = Lighthouse(longitude: longitude as Double, latitude: latitude as Double, worldMap: worldMapString!)
                self.networkObject.sendDataToServer(_mapObject:lighthouseToSave.toMap())

                } catch {
                    // FIXME handle this
                }
            }
        }

    }
    

    func resetTrackingConfiguration(with worldMap: ARWorldMap? = nil) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        if let worldMap = worldMap {
            configuration.initialWorldMap = worldMap
            print("Found saved world map.")
        } else {
            print("Move camera around to map your surrounding space.")
        }
        
        sceneView.session.run(configuration, options: options)
    }
    
    func unarchive(worldMapData data: Data) -> ARWorldMap? {
        guard let unarchievedObject = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data),
            let worldMap = unarchievedObject else { return nil }
        return worldMap
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
        func toMap() -> NSDictionary {
            let mapObject: NSDictionary = [
                "latitude" : self.latitude,
                "longitude" : self.longitude,
                "worldMap" : worldMap
            ]
            return mapObject
        }
        
        // Converts fetched JSON from the server into a SavedLightHouse instance
//        static func fromJson() -> SavedLighthouse {
//            // TODO
//        }
    }
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerValue = pickerData[row]
    }
}
