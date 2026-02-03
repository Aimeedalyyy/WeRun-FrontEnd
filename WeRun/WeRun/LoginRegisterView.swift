//
//  LoginRegisterView.swift
//  WeRun
//
//  Created by Aimee Daly on 15/01/2026.
//

import Foundation
import SwiftUI

// MARK: - SwiftUI View
struct LoginRegisterView: View {
    @StateObject private var viewModel = AuthViewModel()

    var body: some View {
            VStack(spacing: 20) {
                // Toggle between Login/Register
                Picker("Mode", selection: $viewModel.mode) {
                    Text("Login").tag(AuthViewModel.AuthMode.login)
                    Text("Register").tag(AuthViewModel.AuthMode.register)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // Username
                TextField("Username", text: $viewModel.username)
                    .textFieldStyle(.roundedBorder)
                    .autocapitalization(.none)

                // Email only visible for registration
                if viewModel.mode == .register {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }

                // Password
                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)

                // Error message
                if let error = viewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }

                // Button
                Button(action: {
                    Task {
                        await viewModel.authenticate()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text(viewModel.mode == .login ? "Login" : "Register")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(viewModel.isLoading || viewModel.username.isEmpty || viewModel.password.isEmpty)

                Spacer()
                
                // NavigationLink to HomeView after successful login/register
                NavigationLink(
                    destination: HomeView(),
                    isActive: $viewModel.isLoggedIn,
                    label: { EmptyView() }
                )
            }
            .padding()
            .navigationTitle(viewModel.mode == .login ? "Login" : "Register")
        
    }
}
