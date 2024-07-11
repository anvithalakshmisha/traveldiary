//
//  HomeView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 12/04/24.
//

// HomeView.swift
// TravelDiary

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var userAuth: UserAuth
    @FetchRequest(
        entity: Moment.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Moment.timestamp, ascending: false)],
        predicate: NSPredicate(format: "timestamp >= %@", Calendar.current.date(byAdding: .day, value: -7, to: Date())! as NSDate)
    ) var recentMoments: FetchedResults<Moment>
    
    var body: some View {
        NavigationView {
            VStack {
                if recentMoments.isEmpty {
                    // Show message when there are no recent moments
                    Text("No recent moments. Start one by adding your trips and memories!")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List {
                        ForEach(recentMoments, id: \.self) { moment in
                            // Here we use the existing MomentRow view to display each recent moment.
                            if moment.trip?.user == userAuth.currentUser {
                                MomentRow(moment: moment)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recents")
        }
    }
}
