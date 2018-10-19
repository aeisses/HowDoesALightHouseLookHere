//
//  LightHouse.swift
//  HowDoesALightHouseLookHere
//
//  Created by Amisha Goyal on 10/19/18.
//  Copyright © 2018 Aaron Eisses. All rights reserved.
//

import Foundation

class Lighthouse : NSObject {
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
