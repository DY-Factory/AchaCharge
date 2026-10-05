//
//  MainTabView.swift
//  Controllers
//
//  Created by 강동영 on 2023/08/23.
//

import UIKit
import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ForEach(TabType.allCases, id: \.self) { type in
                tabView(for: type)
                    .tag(type)
                    .tabItem {
                        Label(type.title, systemImage: type.selectedImage)
                    }
            }
        }
    }
    
    @ViewBuilder
    private func tabView(for type: TabType) -> some View {
        switch type {
        case .controlelr:
            ControllerView()
        
        case .tester:
            TesterView()
            
        case .setting:
            SettingViewRepresentable()
        }
    }
}

extension MainTabView {
    enum TabType: CaseIterable {
        case controlelr
        case tester
        case setting
        
        var title: String {
            switch self {
            case .controlelr:
                return "Controller".localized
            
            case .tester:
                return "Tester".localized
            
            case .setting:
                return "Setting".localized
            }
        }
        
        var deSelectedImage: String {
            switch self {
            case .controlelr:
                return "gamecontroller"
            
                
            case .tester:
                return "formfitting.gamecontroller"
                
            case .setting:
                return "gearshape"
            }
        }
        
        var selectedImage: String {
            switch self {
            case .controlelr:
                return "gamecontroller.fill"
            
            case .tester:
                return "formfitting.gamecontroller.fill"
                
            case .setting:
                return "gearshape.fill"
            }
        }
    }
}

#Preview {
    MainTabView()
}
