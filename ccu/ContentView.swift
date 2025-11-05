//
//  ContentView.swift
//  ccu
//
//  Created by codian on 11/5/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: UsageViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Image(systemName: "cloud.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("Claude Code 사용량")
                    .font(.headline)
                Spacer()
            }

            Divider()

            if let errorMessage = viewModel.errorMessage {
                // 에러 표시
                VStack(alignment: .leading, spacing: 8) {
                    Label("에러 발생", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.subheadline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                // 사용량 정보 표시
                VStack(alignment: .leading, spacing: 12) {
                    UsageRow(label: "입력 토큰", value: formatNumber(viewModel.inputTokens), icon: "arrow.down.circle.fill", color: .green)
                    UsageRow(label: "출력 토큰", value: formatNumber(viewModel.outputTokens), icon: "arrow.up.circle.fill", color: .blue)
                    UsageRow(label: "캐시 생성", value: formatNumber(viewModel.cacheCreationTokens), icon: "square.and.arrow.down.fill", color: .orange)
                    UsageRow(label: "캐시 읽기", value: formatNumber(viewModel.cacheReadTokens), icon: "square.and.arrow.up.fill", color: .cyan)

                    Divider()

                    UsageRow(label: "총 토큰", value: formatNumber(viewModel.totalTokens), icon: "sum", color: .purple)
                    UsageRow(label: "오늘 비용", value: String(format: "$%.2f", viewModel.todayCost), icon: "calendar.circle.fill", color: .orange)
                    UsageRow(label: "총 비용", value: String(format: "$%.2f", viewModel.totalCost), icon: "dollarsign.circle.fill", color: .red)

                    if let lastUpdated = viewModel.lastUpdated {
                        Text("마지막 업데이트: \(formatDate(lastUpdated))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            // 버튼
            HStack {
                Button {
                    Task {
                        await viewModel.fetchUsage()
                    }
                } label: {
                    Label("새로고침", systemImage: "arrow.clockwise")
                        .font(.caption)
                }
                .disabled(viewModel.isLoading)

                Spacer()
            }
        }
        .padding()
        .frame(width: 320)
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

struct UsageRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline.monospacedDigit())
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(UsageViewModel())
}
