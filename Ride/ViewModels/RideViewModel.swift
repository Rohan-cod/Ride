//
//  RideViewModel.swift
//  Ride
//
//  Created by Rohan  Gupta on 23/05/22.
//

import Foundation
import SwiftUI
import Alamofire
import SwiftyJSON

class RideViewModel: ObservableObject {
    
    @Published var rides: [Ride] = [Ride]()
    @Published var states: [String] = [String]()
    @Published var cities: [String] = [String]()
    
    @Published var isLoading: Bool = false
    
    let url: URL = URL(string: "https://assessment.api.vweb.app/rides")!
    
    func fetchRides() {
        withAnimation {
            isLoading = true
        }
        let request = AF.request(url)
        request.responseData { (responseData) in
            if((responseData.data) != nil) {
                let swiftyJsonVar = JSON(responseData.data!)
                

                if let rides = swiftyJsonVar.array {
                    for data in rides {
                        let rideDataJson = JSON(data)
                        let id = rideDataJson["id"].intValue
                        let origin_station_code = rideDataJson["origin_station_code"].intValue
                        
                        var station_path = [Int]()
                        if let station_path_array = rideDataJson["station_path"].array {
                            for dat in station_path_array {
                                let stationPathDataJson = JSON(dat)
                                let station_path_value = stationPathDataJson.intValue
                                station_path.append(station_path_value)
                            }
                        }
                        
                        let destination_station_code = rideDataJson["destination_station_code"].intValue
                        let date = rideDataJson["date"].intValue
                        let map_url = rideDataJson["map_url"].stringValue
                        let state = rideDataJson["state"].stringValue
                        let city = rideDataJson["city"].stringValue
                        
                        let ride = Ride(id: id, origin_station_code: origin_station_code, station_path: station_path, destination_station_code: destination_station_code, date: date, map_url: map_url, state: state, city: city)
                        self.rides.append(ride)
                        if !self.states.contains(state) {
                            self.states.append(state)
                        }
                        if !self.cities.contains(city) {
                            self.cities.append(city)
                        }
                    }
                }
            }
        }
        withAnimation {
            isLoading = false
        }
    }
    
    func getRides(filter: String, stationCode: Int, state: String?, city: String?) -> [Ride] {
        if filter == "Nearest" {
            return getNearestRides(stationCode: stationCode, state: state, city: city)
        } else if filter == "Upcoming" {
            return getUpcomingRides(stationCode: stationCode, state: state, city: city)
        } else if filter == "Past" {
            return getPastRides(stationCode: stationCode, state: state, city: city)
        }
        return getNearestRides(stationCode: stationCode, state: state, city: city)
    }
    
    func getNearestRides(stationCode: Int, state: String?, city: String?) -> [Ride] {
        var ridesSorted = self.rides.sorted(by: {
            (abs(stationCode - ($0.station_path.min() ?? 0))) < (abs(stationCode - ($1.station_path.min() ?? 0)))
        })
        
        ridesSorted = ridesSorted.filter { Ride in
            var boolean = true
        
            if state != nil {
                boolean = boolean && Ride.state == state
            }
            if city != nil {
                boolean = boolean && Ride.city == city
            }
            
            return boolean
        }
                
        return ridesSorted

    }
    
    func getUpcomingRides(stationCode: Int, state: String?, city: String?) -> [Ride] {
        var filteredRides = self.rides.filter { Ride in
            var boolean = Ride.date > Int(Date.now.timeIntervalSince1970)
        
            if state != nil {
                boolean = boolean && Ride.state == state
            }
            if city != nil {
                boolean = boolean && Ride.city == city
            }
            
            return boolean
        }
        
        filteredRides = filteredRides.sorted(by: {
            (abs(stationCode - ($0.station_path.min() ?? 0))) < (abs(stationCode - ($1.station_path.min() ?? 0)))
        })
                
        return filteredRides
    }
    
    func getPastRides(stationCode: Int, state: String?, city: String?) -> [Ride] {
        var filteredRides = self.rides.filter { Ride in
            var boolean = Ride.date < Int(Date.now.timeIntervalSince1970)
        
            if state != nil {
                boolean = boolean && Ride.state == state
            }
            if city != nil {
                boolean = boolean && Ride.city == city
            }
            
            return boolean
        }
        
        filteredRides = filteredRides.sorted(by: {
            (abs(stationCode - ($0.station_path.min() ?? 0))) < (abs(stationCode - ($1.station_path.min() ?? 0)))
        })
        return filteredRides
    }
    
    func getUpcomingRidesCount(stationCode: Int) -> String {
        String(getUpcomingRides(stationCode: stationCode, state: nil, city: nil).count)
    }
    
    func getPastRidesCount(stationCode: Int) -> String {
        String(getPastRides(stationCode: stationCode, state: nil, city: nil).count)
    }
}
