//
//  AuthenticationService.swift
//  RadioApp
//
//  Created by Мария Нестерова on 03.08.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift

struct AuthDataResultModel {
    let uid: String
    let email: String?
    let name: String?

    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.name = user.displayName
    }
}

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    private init() {
        UserDefaults.standard.removeObject(forKey: "credentials")
    }

    func getAuthenticatedUser(completion: @escaping (User?) -> Void) {
        let _ = auth.addStateDidChangeListener { auth, user in
            completion(user)
        }
    }
    
    func getCurrentUser() -> User? {
        auth.currentUser
    }

    func createUser(name: String, email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResults = try await auth.createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResults.user)
    }

    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await auth.signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func signInWithGoogleAccount() async -> Bool {
        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene, let window = await windowScene.windows.first, let rootViewController = await window.rootViewController else {
            print("There is no root viewController")
            return false
        }
        do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken else {
                throw URLError(.badServerResponse)
            }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            let result = try await auth.signIn(with: credential)
            let firebaseUser = result.user
            print("User \(firebaseUser.uid) successfully signed in with email: \(firebaseUser.email ?? "Unknown")")
            return true
        }
        catch {
            print(error.localizedDescription)
            return false
        }
    }

    func signOut() throws {
        try auth.signOut()
    }

    func resetPassword(with email: String) async throws {
        try await auth.sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(newPassword: String) async throws -> Bool {
        let user = auth.currentUser
        
        do {
            try await user?.updatePassword(to: newPassword)
            return true
        }
        catch {
            return false
        }
    }
    
    func updateEmail(newEmail: String) async throws {
        try await auth.currentUser?.sendEmailVerification(beforeUpdatingEmail: newEmail)
        try await auth.currentUser?.reload()
    }
    
    func updateUsername(name: String) {
        let currentUser = auth.currentUser
        if currentUser?.displayName == nil {
            currentUser?.displayName = " "
        }
        let changeRequest = auth.currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = name
        changeRequest?.commitChanges() { [weak self] error in
            if let error {
                print(error.localizedDescription)
            } else {
                self?.auth.currentUser?.reload()
            }
        }
    }
    
}
