//
//  EditProfileView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 25/04/24.
//

import SwiftUI
import CoreData
import UIKit

import SwiftUI

struct EditProfileView: View {
    @ObservedObject var user: User
    @EnvironmentObject var userAuth: UserAuth
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext // Inject the context
    @State private var inputImage: UIImage?
    @State private var fullName: String
    @State private var showingImagePicker = false // To show the image picker
    
    init(user: User) {
        _fullName = State(initialValue: user.fullname ?? "")
        self.user = user
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Picture")) {
                    ProfileImageView(inputImage: $inputImage)
                    Button("Select Image") {
                        showingImagePicker = true
                    }
                }

                Section(header: Text("Full Name")) {
                    TextField("Full Name", text: $fullName)
                }

                Button("Save Changes") {
                    saveChanges()
                }
            }
            .navigationBarTitle("Edit Profile", displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage, sourceType: .photoLibrary)
            }
        }
    }

    func saveChanges() {
        if let inputImage = inputImage {
            userAuth.saveProfileImage(inputImage)
        }
        userAuth.saveUserDetails(fullName: fullName, profileImage: inputImage)
        presentationMode.wrappedValue.dismiss()
    }
}

struct ProfileImageView: View {
    @Binding var inputImage: UIImage?
    
    var body: some View {
        if let inputImage = inputImage {
            Image(uiImage: inputImage)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
        } else {
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
        }
    }
}

//#Preview {
//    EditProfileView()
//}
