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
    
    func getDataFromServer(completionHandler:@escaping (Array<Any>?, Error?) -> Void) {
        let manager = AFHTTPSessionManager()
        manager.get(serverURL, parameters: nil, progress: nil, success: { (URLSessionDataTask, responseObject) in
            print("success")
            var lightHouseArray = Array<Any>()
            if let array = responseObject as? Array<Dictionary<String, Any>> {
                for item in array {
                    let lightHouse = Lighthouse(longitude: item["longitude"] as! Double, latitude: item["latitude"] as!Double, worldMap: item["worldMap"] as! String)
                    lightHouseArray.append(lightHouse)
                }
                print(lightHouseArray)
                completionHandler(lightHouseArray, nil)
            }

        }) { (URLSessionDataTask, Error) in
            print("failure")
        }
    }

}

