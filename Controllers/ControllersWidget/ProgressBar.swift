//
//  ProgressBar.swift
//  Controllers
//
//  Created by dongyeongkang on 2023/06/28.
//

import SwiftUI

/// 배터리 잔량 링. 위젯은 애니메이션·onAppear 가 돌지 않으므로 값만 그린다.
struct ProgressBar: View {
    let progress: Float
    var lineWidth: CGFloat = 11.0
    var color: Color = .green

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(color)

            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(color)
                .rotationEffect(Angle(degrees: 270.0))
        }
    }
}
