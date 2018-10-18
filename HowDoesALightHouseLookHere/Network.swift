//
//  Network.swift
//  HowDoesALightHouseLookHere
//
//  Created by Amisha Goyal on 10/18/18.
//  Copyright © 2018 Aaron Eisses. All rights reserved.
//

import Foundation
import AFNetworking

class Network: NSObject {
    let serverURL = "https://lighthousehack.herokuapp.com/api/worldmap"

    func sendDataToServer(_mapObject:NSDictionary) {
        let manager = AFHTTPSessionManager()
        manager.post(serverURL,
                     parameters: _mapObject, progress: nil,
                     success: { (URLSessionDataTask, Any) in
                        print("success")
        },
                     failure: { (URLSessionDataTask, Error) in
                        print("failure" + Error.localizedDescription)

        })
    }

  
}
