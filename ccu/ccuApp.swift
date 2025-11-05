//
//  ccuApp.swift
//  ccu
//
//  Created by codian on 11/5/25.
//

import SwiftUI

@main
struct ccuApp: App {
    @StateObject private var usageViewModel = UsageViewModel()

    var body: some Scene {
        MenuBarExtra {
            ContentView()
                .environmentObject(usageViewModel)

            Divider()

            Button("종료") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
            .padding(.bottom, 8)
        } label: {
            HStack(spacing: 4) {
                Image("MenuBarIcon")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFit()
                    .frame(width: 16, height: 16, alignment: .center)
                Text(usageViewModel.displayText)
                    .font(.system(size: 12, design: .monospaced))
            }
        }
        .menuBarExtraStyle(.window)
    }
}
