//
//  tabbarHelper.swift
//  WeRun
//
//  Created by Aimee Daly on 25/11/2025.
//

import SwiftUI


extension View {
    func tabViewStyle(
        backgroundColor: Color,
        itemColor: Color,
        badgeColor: Color,
        selectedItemColor: Color
    ) -> some View {
        onAppear {
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.iconColor = itemColor.uiColor
            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor: itemColor.uiColor as Any,
            ]

            itemAppearance.normal.badgeBackgroundColor = badgeColor.uiColor
            itemAppearance.selected.badgeBackgroundColor = badgeColor.uiColor

            itemAppearance.selected.iconColor = selectedItemColor.uiColor
            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: selectedItemColor.uiColor as Any,
            ]

            let appearance = UITabBarAppearance()
            appearance.backgroundColor = backgroundColor.uiColor

            appearance.stackedLayoutAppearance = itemAppearance
            appearance.inlineLayoutAppearance = itemAppearance
            appearance.compactInlineLayoutAppearance = itemAppearance

            UITabBar.appearance().standardAppearance = appearance

            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

extension Color {
    var uiColor: UIColor? {
        UIColor(self)
    }
}
