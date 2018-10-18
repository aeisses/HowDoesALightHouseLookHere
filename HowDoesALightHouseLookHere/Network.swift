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

//    func sendJSONDataToServer(_mapJson:NSObject, _serverUrl:NSURL) {
    func sendJSONDataToServer (){
        let manager = AFHTTPSessionManager()
        let URLString = " https://lighthousehack.herokuapp.com/api/worldmap"
        let mapData = ["latitude":12.1234, "longitude":21.12345, "workdMap":"abcdefg"] as [String : Any]
        let jsonData = try? JSONSerialization.data(withJSONObject: mapData, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        NSLog(jsonString!)
        manager.post(URLString, parameters: <#T##Any?#>, progress: <#T##((Progress) -> Void)?##((Progress) -> Void)?##(Progress) -> Void#>, success: <#T##((URLSessionDataTask, Any?) -> Void)?##((URLSessionDataTask, Any?) -> Void)?##(URLSessionDataTask, Any?) -> Void#>, failure: <#T##((URLSessionDataTask?, Error) -> Void)?##((URLSessionDataTask?, Error) -> Void)?##(URLSessionDataTask?, Error) -> Void#>)


    }

  
}
