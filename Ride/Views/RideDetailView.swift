//
//  RideDetailView.swift
//  Ride
//
//  Created by Rohan  Gupta on 24/05/22.
//

import SwiftUI

struct RideDetailView: View {
    
    var ride: Ride
    var user: User
    let formatter: DateFormatter
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.93).edgesIgnoringSafeArea(.all)
                .background(BackgroundClearView())
            VStack {
                Image("Map")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width*0.9, height: 260)
                    .shadow(color: .black.opacity(0.2), radius: 10)
                    .padding(.bottom)
                
                Rectangle()
                    .frame(width: UIScreen.main.bounds.width*0.9, height: 260)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.2), radius: 10)
                    .padding(.top)
                    .overlay {
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Ride ID")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(ride.id)")
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("Origin Station")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(ride.origin_station_code)")
                                }
                            }
                            Divider()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Date")
                                        .font(.caption)
                                        .foregroundColor(.gray)
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
                                VStack(alignment: .trailing) {
                                    Text("Distance")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(abs(user.station_code - (ride.station_path.min() ?? 0))) KM")
                                }
                            }
                            Divider()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("State")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(ride.state)")
                                }
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text("City")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(ride.city)")
                                }
                            }
                            Divider()
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Station Path")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(ride.station_path.map { String($0) }.joined(separator: ", "))")
                                }
                                Spacer()
                            }
                        }
                        .padding()
                    }
            }
        }
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        RideDetailView()
//    }
//}
