//
//  ContentView.swift
//  Ride
//
//  Created by Rohan  Gupta on 23/05/22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var rideViewModel = RideViewModel()
    @ObservedObject var userViewModel = UserViewModel()
    var formatter = DateFormatter()
    
    @State private var selectedFilter: String = "Nearest"
    
    @State private var selectedCity: String?
    @State private var selectedState: String?
    
    @State private var showDetail: Bool = false
    
    @State private var selectedRide: Ride?
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    HStack {
                        ForEach(["Nearest", "Upcoming", "Past"], id: \.self) { filter in
                            VStack(alignment: .leading, spacing: 0) {
                                HStack {
                                    Text(filter)
                                    if filter == "Upcoming" {
                                        Text("(\(rideViewModel.getUpcomingRidesCount(stationCode: userViewModel.user.station_code)))")
                                    }
                                    if filter == "Past" {
                                        Text("(\(rideViewModel.getPastRidesCount(stationCode: userViewModel.user.station_code)))")
                                    }
                                }
                                .foregroundColor(selectedFilter==filter ? .black : .gray)
                                if selectedFilter==filter {
                                    Rectangle()
                                        .frame(width: 40, height: 2)
                                        .foregroundColor(.blue)
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    selectedFilter = filter
                                }
                            }
                        }
                        Spacer()
                        Menu {
                            Menu {
                                Button {
                                    withAnimation {
                                        self.selectedState = nil
                                    }
                                } label: {
                                    HStack {
                                        Text("All")
                                        Spacer()
                                        if selectedState == nil {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                ForEach(rideViewModel.states.sorted(by: { $0 < $1 }), id: \.self) { state in
                                    Button {
                                        withAnimation {
                                            self.selectedState = state
                                        }
                                    } label: {
                                        HStack {
                                            Text(state)
                                            Spacer()
                                            if selectedState == state {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Text("State")
                            }
                            Menu {
                                Button {
                                    withAnimation {
                                        self.selectedCity = nil
                                    }
                                } label: {
                                    HStack {
                                        Text("All")
                                        Spacer()
                                        if selectedCity == nil {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                                ForEach(rideViewModel.cities.sorted(by: { $0 < $1 }), id: \.self) { city in
                                    Button {
                                        withAnimation {
                                            self.selectedCity = city
                                        }
                                    } label: {
                                        HStack {
                                            Text(city)
                                            Spacer()
                                            if selectedCity == city {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Text("City")
                            }
                            Button {
                                withAnimation {
                                    self.selectedCity = nil
                                    self.selectedState = nil
                                }
                            } label: {
                                Text("Clear")
                            }
                            
                        } label: {
                            HStack {
                                Image(systemName: "text.alignleft")
                                Text("Filter")
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                    }
                    .padding(.leading)
                    ScrollView {
                        ForEach(rideViewModel.getRides(filter: selectedFilter, stationCode: userViewModel.user.station_code, state: selectedState, city: selectedCity)) { ride in
                            Image("Map")
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width*0.9, height: 260)
                                .overlay(alignment: .bottom) {
                                    Rectangle()
                                        .frame(width: UIScreen.main.bounds.width*0.9, height: 40)
                                        .foregroundColor(Color(white: 0.94))
                                        .cornerRadius(14, corners: [.bottomLeft, .bottomRight])
                                        .overlay(alignment: .center) {
                                            HStack {
                                                Spacer()
                                                Text("#")
                                                    .foregroundColor(.blue)
                                                Text("\(ride.id)")
                                                    .padding(.trailing)
                                                Spacer()
                                                HStack {
                                                    Image(systemName: "calendar")
                                                        .foregroundColor(.blue)
                                                    let date = Date(timeIntervalSince1970: TimeInterval(ride.date))
                                                    let dateString = formatter.string(from: date)
                                                    if let spaceIndex = dateString.firstIndex(of: " ") {
                                                        if let dateInt = Int(dateString[dateString.startIndex..<spaceIndex]) {
                                                            if let dateOrdinal = dateInt.ordinal {
                                                                let dateMonth = String(dateString[spaceIndex..<dateString.endIndex])
                                                                Text("\(dateOrdinal)\(dateMonth)")
                                                            }
                                                        }
                                                    }
                                                }
                                                Spacer()
                                            }
                                        }
                                        .overlay(alignment: .topLeading) {
                                            HStack {
                                                Spacer()
                                                Rectangle()
                                                    .cornerRadius(5)
                                                    .foregroundColor(.blue)
                                                    .overlay(alignment: .center) {
                                                        Text("\(abs(userViewModel.user.station_code - (ride.station_path.min() ?? 0))) KM")
                                                            .font(.callout)
                                                            .fontWeight(.bold)
                                                            .foregroundColor(.white)
                                                    }
                                                    .frame(width: 75, height: 23)
                                                    .padding(.top, -35)
                                                    .padding(.trailing)
                                            }
                                        }
                                }
                                .onTapGesture {
                                    self.selectedRide = ride
                                    if self.selectedRide != nil {
                                        showDetail = true
                                    }
                                }
                        }
                    }
                    .sheet(isPresented: $showDetail) {
                        if let safeSelectedRide = self.selectedRide {
                            RideDetailView(ride: safeSelectedRide, user: userViewModel.user, formatter: formatter)
                        } else {
                            Text("No Ride")
                        }
                    }
                }
                .opacity((rideViewModel.isLoading || userViewModel.isLoading) ? 0.5 : 1)
                
                if (rideViewModel.isLoading || userViewModel.isLoading) {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .onAppear {
                formatter.dateFormat = "d MMM"
                
                rideViewModel.fetchRides()
                userViewModel.fetchUser()
            }
            .navigationTitle(Text("Edvora"))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Image(systemName: "person")
                }
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

