//
//  MainTabView.swift
//  Controllers
//
//  Created by 강동영 on 2023/08/23.
//

import UIKit
import SwiftUI

struct MainTabView: View {
    @State private var selection: TabType = MainTabView.initialTab

    var body: some View {
        TabView(selection: $selection) {
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
    /// 앱을 켰을 때 보이는 탭. DEBUG 에서는 스크린샷용 실행 인자(`-ACTab`)로 바꿀 수 있다.
    private static var initialTab: TabType {
        #if DEBUG
        switch ScreenshotFixture.initialTab {
        case "tester": return .tester
        case "setting": return .setting
        default: break
        }
        #endif
        return .controlelr
    }

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
