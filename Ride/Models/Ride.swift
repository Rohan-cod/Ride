//
//  Ride.swift
//  Ride
//
//  Created by Rohan  Gupta on 23/05/22.
//

import Foundation

struct Ride: Identifiable {
    var id: Int
    var origin_station_code: Int
    var station_path: Array<Int>
    var destination_station_code: Int
    var date: Int
    var map_url: String
    var state: String
    var city: String
}
