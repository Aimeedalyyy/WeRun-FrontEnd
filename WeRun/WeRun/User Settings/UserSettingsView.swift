//
//  UserSettingsView.swift
//  WeRun
//
//  Created by Aimee Daly on 29/01/2026.
//

import SwiftUI

struct UserSettingsView: View {
    @EnvironmentObject var authState: AppAuthState

    var body: some View {
        Button(role: .destructive) {
            authState.logout()
        } label: {
            Label("Log Out", systemImage: "arrow.backward.circle")
        }
    }
}

#Preview {
    UserSettingsView()
}
