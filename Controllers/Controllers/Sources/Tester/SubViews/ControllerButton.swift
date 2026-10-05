//
//  ControllerButton.swift
//  Controllers
//
//  Created by 강동영 on 5/26/25.
//


import SwiftUI

struct ControllerButton: View {
    private var systemName: String
    private let size: CGFloat
    var isPressed: Bool
    
    init(systemName: String, size: CGFloat = 80, isPressed: Bool = false) {
        self.systemName = systemName
        self.size = size
        self.isPressed = isPressed
    }
    
    var body: some View {
        Image(systemName: systemName)
            .controllerIconStyle(size: size, isPressed: isPressed)
    }
}

extension Image {
    func controllerIconStyle(size: CGFloat = 80, isPressed: Bool = false) -> some View {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size)
            .foregroundColor(isPressed ? .blue : .primary)
            .scaleEffect(isPressed ? 1.2 : 1.0)
            .animation(.spring(response: 0.2), value: isPressed)
    }
}
