//
//  ConnectionGuideView.swift
//  Controllers
//
//  컨트롤러가 연결되지 않았을 때 페어링 방법을 안내한다.
//  블루투스 설정으로 바로 보내는 공개 API가 없어 설정 이동 버튼은 두지 않는다.
//

import SwiftUI

struct ConnectionGuideView: View {
    let onRefresh: () -> Void
    @ScaledMetric private var badgeSize: CGFloat = 28

    private let steps: [(symbol: String, key: String)] = [
        ("hand.tap.fill", "Connect Guide Step 1"),
        ("gearshape.fill", "Connect Guide Step 2"),
        ("battery.100.bolt", "Connect Guide Step 3"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.accentColor)
                        .accessibilityHidden(true)
                    Text("Connect Guide Title".localized)
                        .font(.title2.bold())
                    Text("Connect Guide Subtitle".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .multilineTextAlignment(.center)

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(steps.indices, id: \.self) { index in
                        HStack(alignment: .top, spacing: 12) {
                            Text("\(index + 1)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: badgeSize, height: badgeSize)
                                .background(Circle().fill(Color.accentColor))
                            Image(systemName: steps[index].symbol)
                                .font(.title3)
                                .foregroundColor(.accentColor)
                                .frame(width: badgeSize)
                                .accessibilityHidden(true)
                            Text(steps[index].key.localized)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))

                HStack(spacing: 8) {
                    ProgressView()
                    Text("Connect Guide Waiting".localized)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)

                Text("Connect Guide Support Note".localized)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button(action: onRefresh) {
                    Label("Refresh".localized, systemImage: "arrow.clockwise")
                        .font(.footnote)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 32)
            .frame(maxWidth: 500)
            .frame(maxWidth: .infinity)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    ConnectionGuideView(onRefresh: {})
}
