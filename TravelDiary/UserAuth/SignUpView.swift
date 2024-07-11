//
//  SignUpView.swift
//  TravelDiary
//
//  Created by Bhavesh Raja on 11/04/24.
//

import SwiftUI
import CoreData

struct SignUpView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var fullname: String = "" // Add state for fullname
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var alertMessage: String = ""
    @State private var showingAlert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("CREATE YOUR ACCOUNT")
                    .font(.title2)
                    .fontWeight(.bold)

                TextField("Full Name", text: $fullname)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                TextField("Username", text: $username)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                Button("Sign Up") {
                    signUp()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(hue: 0.709, saturation: 1.0, brightness: 1.0))
                .foregroundColor(.white)
                .cornerRadius(10)

            }
            .padding()
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Sign Up"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    private func signUp() {
        // Validate that the passwords match
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match."
            showingAlert = true
            return
        }
        
        // Validate that none of the fields are empty
        guard !fullname.isEmpty, !username.isEmpty, !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields."
            showingAlert = true
            return
        }

        // Check if a user with the same username or email already exists
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@ OR email == %@", username, email)
        
        do {
            let existingUsers = try viewContext.fetch(request)
            if !existingUsers.isEmpty {
                // If there are existing users, show an alert and do not proceed with creating a new user
                alertMessage = "A user with the same username or email already exists."
                showingAlert = true
                return
            } else {
                // If no existing user, proceed with creating the new user
                let newUser = User(context: viewContext)
                newUser.fullname = fullname
                newUser.username = username
                newUser.email = email
                newUser.password = password

                // No need to set 'id', as it's automatically managed by CoreData for new entities
                
                try viewContext.save()
                alertMessage = "You have signed up successfully."
                showingAlert = true
                // Implement any post sign-up logic here, such as navigating to the login screen
            }
        } catch {
            alertMessage = "There was an error checking for existing users."
            showingAlert = true
        }
    }
}

#Preview {
    SignUpView()
}
