//
//  InfoView.swift
//  Controllers
//
//  Created by 강동영 on 5/22/25.
//

import SwiftUI

struct InfoView: View {
    let isPresented: (() -> Void)
    let appName: String = Bundle.main.displayName
    let appVersion: String = Bundle.main.versionString
    
    init(isPresented: @escaping () -> Void) {
        self.isPresented = isPresented
    }
    
    var body: some View {
        VStack {
            Spacer().frame(height: 100)
            
            Image(.appLogo)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
            
            Text(Bundle.main.displayName.localized)
                .font(.system(size: 25, weight: .bold))
                .multilineTextAlignment(.center)
            Spacer().frame(height: 6)
            Text("v\(appVersion.localized)")
                .font(.system(size: 20, weight: .bold))
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button {
                isPresented()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.black)
            }
            .padding(.bottom, 80)

        }
    }
}

@available(iOS 17.0, *)
#Preview {
    InfoView(isPresented: {})
}

