//
//  LoginRegisterView.swift
//  WeRun
//
//  Created by Aimee Daly on 15/01/2026.
//

import Foundation
import SwiftUI


struct LoginRegisterView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showCreateAccount = false

    var body: some View {
            ScrollView {
                VStack(spacing: 28) {

                    // MARK: Header
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome back")
                            .font(.title.bold())
                            .foregroundColor(.accentPurple)

                        Text("Log in to continue tracking your performance.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // MARK: Login Form
                    VStack(spacing: 16) {
                        TextField("Username", text: $viewModel.username)
                            .padding()
                            .background(Color.backgroundGrey.opacity(0.2))
                            .cornerRadius(12)
                            .autocapitalization(.none)

                        SecureField("Password", text: $viewModel.password)
                            .padding()
                            .background(Color.backgroundGrey.opacity(0.2))
                            .cornerRadius(12)
                    }

                    // MARK: Loading / Error
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    }

                    if let error = viewModel.error {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.top, 8)
                    }

                    // MARK: Login Button
                    Button {
                        Task {
                            await viewModel.authenticate()
                        }
                    } label: {
                        Text("Log In")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentPurple)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .fontWeight(.semibold)
                    }
                    .disabled(viewModel.isLoading || viewModel.username.isEmpty || viewModel.password.isEmpty)

                    // MARK: Create Account Navigation
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.secondary)
                      NavigationLink(destination: CreateAccountView(viewModel: viewModel)) {
                            Text("Create an account")
                                .foregroundColor(.accentPurple)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding(.top, 8)

                    Spacer(minLength: 20)

                    // MARK: NavigationLink to HomeView
                    NavigationLink(
                        destination: HomeView(),
                        isActive: $viewModel.isLoggedIn,
                        label: { EmptyView() }
                    )
                }
                .padding(24)
            }
    }
}

#Preview {
  LoginRegisterView()
}
