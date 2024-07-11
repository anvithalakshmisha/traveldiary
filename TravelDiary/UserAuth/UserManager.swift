//
//  UserManager.swift
//  TravelDiary
//
//  Created by Anvitha Lakshmisha on 4/23/24.
//

import Foundation
import CoreData
import UIKit
import CoreLocation

// ObservableObject allows SwiftUI views to react to changes in this class.
class UserAuth: ObservableObject {
    // Published properties will trigger UI updates when changed.
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?

    private var context: NSManagedObjectContext
    
    // Initialize with a Managed Object Context.
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // Log in using username and password.
    func login(username: String, password: String, completion: @escaping (Bool, String) -> Void) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)

        do {
            let results = try context.fetch(fetchRequest)
            if let user = results.first, user.password == password {
                DispatchQueue.main.async {
                    self.currentUser = user
                    self.isLoggedIn = true
                    completion(true, "")
                }
            } else {
                completion(false, "Incorrect username or password.")
            }
        } catch {
            completion(false, "There was an error logging you in.")
        }
    }

    // Log out the current user.
    func logout() {
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isLoggedIn = false
        }
    }
    
    // Sign up a new user with the given credentials.
    func signUp(username: String, password: String, email: String, fullname: String, completion: @escaping (Bool, String) -> Void) {
        // First, check if a user with the same username or email already exists.
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@ OR email == %@", username, email)

        do {
            let existingUsers = try context.fetch(request)
            if !existingUsers.isEmpty {
                completion(false, "A user with the same username or email already exists.")
                return
            }
            
            // If no existing user, proceed with creating the new user.
            let newUser = User(context: context)
            newUser.username = username
            newUser.password = password // Note: In a real app, hash the password before storing it!
            newUser.email = email
            newUser.fullname = fullname
            
            try context.save()
            
            DispatchQueue.main.async {
                self.currentUser = newUser
                self.isLoggedIn = true
                completion(true, "")
            }
        } catch {
            completion(false, "There was a problem saving your data.")
        }
    }
}

extension UserAuth {
    // Function to fetch the stats for the current user.
    func fetchUserStats(completion: @escaping (UserStats) -> Void) {
        guard let user = self.currentUser else {
            completion(UserStats(trips: 0, moments: 0, photos: 0, totalMiles: 0.0))
            return
        }
        
        context.perform {
            let tripsFetchRequest: NSFetchRequest<Trip> = Trip.fetchRequest()
            tripsFetchRequest.predicate = NSPredicate(format: "user == %@", user)
            
            let momentsFetchRequest: NSFetchRequest<Moment> = Moment.fetchRequest()
            momentsFetchRequest.predicate = NSPredicate(format: "trip.user == %@", user)
            
            do {
                let trips = try self.context.fetch(tripsFetchRequest)
                let moments = try self.context.fetch(momentsFetchRequest)
                
                let photos = moments.compactMap { $0.imagesArray }.flatMap { $0 }.count
                
                let totalMiles = self.totalMilesTravelled(trips: trips)
                
                DispatchQueue.main.async {
                    completion(UserStats(trips: trips.count, moments: moments.count, photos: photos, totalMiles: totalMiles))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(UserStats(trips: 0, moments: 0, photos: 0, totalMiles: 0.0))
                }
            }
        }
    }
    
    private func totalMilesTravelled(trips: [Trip]) -> Double {
        var totalMiles = 0.0
        for index in 0..<trips.count {
            if let distance = self.distanceBetweenTrips(trips, from: index) {
                totalMiles += distance
            }
        }
        return totalMiles
    }
    
    private func distanceBetweenTrips(_ trips: [Trip], from index: Int) -> Double? {
        guard index >= 0 && index < trips.count - 1 else {
            return nil
        }
        let startLocation = CLLocation(latitude: trips[index].latitude, longitude: trips[index].longitude)
        let endLocation = CLLocation(latitude: trips[index + 1].latitude, longitude: trips[index + 1].longitude)
        return startLocation.distance(from: endLocation) / 1609.34 // Convert meters to miles
    }
}


extension UserAuth {
    // Save the profile image to the current user
    func saveProfileImage(_ image: UIImage) {
        guard let currentUser = currentUser, let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        currentUser.profileImageData = imageData
        do {
            try context.save()
            // Explicitly notify that the currentUser has changed.
            self.objectWillChange.send()
        } catch {
            print("Failed to save profile image: \(error)")
        }
    }
    
    // You can use this method to update other user information too.
    func saveUserDetails(fullName: String, profileImage: UIImage?) {
        guard let currentUser = self.currentUser else { return }
        
        currentUser.fullname = fullName
        if let profileImage = profileImage, let imageData = profileImage.jpegData(compressionQuality: 0.5) {
            currentUser.profileImageData = imageData
        }
        
        do {
            self.objectWillChange.send()
            try context.save()
        } catch {
            print("Failed to save user details: \(error)")
        }
    }

}


// UserStats structure to hold the stats.
struct UserStats {
    var trips: Int
    var moments: Int
    var photos: Int
    var totalMiles: Double
}
