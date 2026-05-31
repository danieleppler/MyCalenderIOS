//
//  UIView+SemanticContent.swift
//  MyCalender
//

import UIKit

extension UIView {
    /// Recursively sets `semanticContentAttribute = .unspecified` on this view and
    /// all of its descendants, so the subtree follows the device's UI language
    /// direction instead of any global `.forceLeftToRight` override applied via
    /// `UIView.appearance()`.
    func applyLocaleAwareDirection() {
        semanticContentAttribute = .unspecified
        subviews.forEach { $0.applyLocaleAwareDirection() }
    }
}
