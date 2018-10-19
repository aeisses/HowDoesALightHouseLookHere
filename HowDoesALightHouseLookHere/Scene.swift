//
//  Scene.swift
//  ARKitSprite
//
//  Created by Amisha Goyal on 10/18/18.
//  Copyright © 2018 Amisha Goyal. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    var offSet : Float = 0
    var virtualObjectAnchor: ARAnchor?

    override func didMove(to view: SKView) {
        // Setup your scene here
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        
        if let touch = touches.first {
             position = touch.location(in: view)
            guard let hitTestResult = sceneView
                .hitTest(touch.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
                .first
                else { return }
        
            // Create anchor using the camera's current position
//            if let currentFrame = sceneView.session.currentFrame {
                
                // Create a transform with a translation of 0.2 meters in front of the camera
    //            var translation = matrix_identity_float4x4
    //            translation.columns.3.z = -offSet-1.0
    //            let transform = simd_mul(currentFrame.camera.transform, translation)
                
                if let existingAnchor = virtualObjectAnchor {
                    sceneView.session.remove(anchor: existingAnchor)
                }
                
                // Add a new anchor to the session
                virtualObjectAnchor = ARAnchor(name: "virtualObject", transform: hitTestResult.worldTransform)
                sceneView.session.add(anchor: virtualObjectAnchor!)
//            }
        }
    }
}
