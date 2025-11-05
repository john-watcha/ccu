//
//  UsageViewModel.swift
//  ccu
//
//  Created by codian on 11/5/25.
//

import SwiftUI
import Combine

/// Claude Code 사용량 정보를 관리하는 ViewModel
class UsageViewModel: ObservableObject {
    @Published var displayText: String = "..."
    @Published var inputTokens: Int = 0
    @Published var outputTokens: Int = 0
    @Published var cacheCreationTokens: Int = 0
    @Published var cacheReadTokens: Int = 0
    @Published var totalTokens: Int = 0
    @Published var totalCost: Double = 0.0
    @Published var todayCost: Double = 0.0
    @Published var lastUpdated: Date?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let apiService = ClaudeAPIService()
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    init() {
        // 앱 시작 시 즉시 사용량 조회
        Task {
            await fetchUsage()
        }

        // 5분마다 자동 업데이트
        startAutoUpdate()
    }

    deinit {
        timer?.invalidate()
    }

    /// 사용량 정보를 가져옴
    @MainActor
    func fetchUsage() async {
        isLoading = true
        errorMessage = nil

        do {
            let usage = try await apiService.fetchUsage()
            inputTokens = usage.inputTokens
            outputTokens = usage.outputTokens
            cacheCreationTokens = usage.cacheCreationTokens
            cacheReadTokens = usage.cacheReadTokens
            totalTokens = usage.totalTokens
            totalCost = usage.totalCost
            todayCost = usage.todayCost
            lastUpdated = Date()

            updateDisplayText()
        } catch {
            errorMessage = error.localizedDescription
            displayText = "Error"
        }

        isLoading = false
    }

    /// 메뉴바에 표시할 텍스트 업데이트
    private func updateDisplayText() {
        displayText = String(format: "$%.2f", todayCost)
    }

    /// 자동 업데이트 시작
    private func startAutoUpdate() {
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            Task {
                await self?.fetchUsage()
            }
        }
    }
}
