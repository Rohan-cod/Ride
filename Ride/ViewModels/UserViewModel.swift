//
//  UserViewModel.swift
//  Ride
//
//  Created by Rohan  Gupta on 23/05/22.
//

import Foundation
import SwiftUI
import Alamofire
import SwiftyJSON

class UserViewModel: ObservableObject {
    
    @Published var user: User = User(station_code: 0, name: "", profile_key: "")
    
    @Published var isLoading: Bool = false
    
    let url: URL = URL(string: "https://assessment.api.vweb.app/user")!
    
    func fetchUser() {
        withAnimation {
            isLoading = true
        }
        let request = AF.request(url)
        request.responseData { (responseData) in
            if((responseData.data) != nil) {
                let swiftyJsonVar = JSON(responseData.data!)

                let station_code = swiftyJsonVar["station_code"].intValue
                let name = swiftyJsonVar["name"].stringValue
                let profile_key = swiftyJsonVar["profile_key"].stringValue
                
                self.user = User(station_code: station_code, name: name, profile_key: profile_key)
            }
        }
        withAnimation {
            isLoading = false
        }
    }
}
