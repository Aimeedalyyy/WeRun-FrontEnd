//
//  WrapLayout.swift
//  WeRun
//
//  Created by Aimee Daly on 17/03/2026.
//


import SwiftUI

struct WrapLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? .infinity

        var width: CGFloat = 0
        var height: CGFloat = 0

        var currentRowWidth: CGFloat = 0
        var currentRowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentRowWidth + size.width > maxWidth {
                // Move to next line
                width = max(width, currentRowWidth)
                height += currentRowHeight + spacing

                currentRowWidth = size.width
                currentRowHeight = size.height
            } else {
                currentRowWidth += size.width + spacing
                currentRowHeight = max(currentRowHeight, size.height)
            }
        }

        width = max(width, currentRowWidth)
        height += currentRowHeight

        return CGSize(width: width, height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY

        var currentRowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > bounds.maxX {
                // Wrap to next line
                x = bounds.minX
                y += currentRowHeight + spacing
                currentRowHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: ProposedViewSize(size)
            )

            x += size.width + spacing
            currentRowHeight = max(currentRowHeight, size.height)
        }
    }
}
