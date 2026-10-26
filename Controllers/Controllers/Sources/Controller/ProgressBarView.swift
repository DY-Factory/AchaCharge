//
//  ProgressBarView.swift
//  Controllers
//
//  Created by 강동영 on 5/10/25.
//

import SwiftUI

struct ProgressBarView: View {
    @Binding var progress: Float
    @State var isAnimating: Bool = false
    var lineWidth: CGFloat = 11.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(Color.green)
            
            Circle()
                .trim(from: 0.0, to: CGFloat(self.progress))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.green)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear(duration: 2.0), value: isAnimating)
        }
        .onAppear {
            isAnimating = true
        }
    }
}