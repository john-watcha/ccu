//
//  ClaudeAPIService.swift
//  ccu
//
//  Created by codian on 11/5/25.
//

import Foundation

/// 사용량 정보
struct UsageInfo {
    let inputTokens: Int
    let outputTokens: Int
    let totalCost: Double
    let todayCost: Double
    let cacheCreationTokens: Int
    let cacheReadTokens: Int
    let totalTokens: Int
}

/// 에러
enum APIError: LocalizedError {
    case commandFailed(String)
    case invalidResponse
    case decodingError(Error)

    var errorDescription: String? {
        switch self {
        case .commandFailed(let message):
            return "명령어 실행 실패: \(message)"
        case .invalidResponse:
            return "잘못된 응답입니다"
        case .decodingError(let error):
            return "데이터 파싱 에러: \(error.localizedDescription)"
        }
    }
}

/// Claude Code 사용량을 조회하는 서비스
class ClaudeAPIService {
    /// npx 경로를 찾음
    private func findNpxPath() -> String? {
        let possiblePaths = [
            "/opt/homebrew/bin/npx",
            "/usr/local/bin/npx",
            "/usr/bin/npx",
            NSHomeDirectory() + "/.nvm/versions/node/latest/bin/npx"
        ]

        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }

        return nil
    }

    /// 사용량 정보를 조회함
    func fetchUsage() async throws -> UsageInfo {
        return try await withCheckedThrowingContinuation { continuation in
            guard let npxPath = findNpxPath() else {
                continuation.resume(throwing: APIError.commandFailed("npx를 찾을 수 없습니다. Node.js가 설치되어 있는지 확인하세요."))
                return
            }

            let process = Process()
            process.executableURL = URL(fileURLWithPath: npxPath)
            process.arguments = ["ccusage@latest", "--json"]

            // 환경 변수 설정
            var environment = ProcessInfo.processInfo.environment
            environment["PATH"] = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
            process.environment = environment

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            do {
                try process.run()

                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()

                if process.terminationStatus != 0 {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    continuation.resume(throwing: APIError.commandFailed(errorMessage))
                    return
                }

                // JSON 파싱
                let decoder = JSONDecoder()

                do {
                    let response = try decoder.decode(CCUsageResponse.self, from: data)

                    // 오늘 날짜의 비용 찾기
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let todayString = dateFormatter.string(from: Date())

                    let todayCost = response.daily.first { $0.date == todayString }?.totalCost ?? 0.0

                    let usageInfo = UsageInfo(
                        inputTokens: response.totals.inputTokens,
                        outputTokens: response.totals.outputTokens,
                        totalCost: response.totals.totalCost,
                        todayCost: todayCost,
                        cacheCreationTokens: response.totals.cacheCreationTokens,
                        cacheReadTokens: response.totals.cacheReadTokens,
                        totalTokens: response.totals.totalTokens
                    )

                    continuation.resume(returning: usageInfo)
                } catch {
                    continuation.resume(throwing: APIError.decodingError(error))
                }
            } catch {
                continuation.resume(throwing: APIError.commandFailed(error.localizedDescription))
            }
        }
    }
}

/// ccusage 명령어의 응답 구조체
struct CCUsageResponse: Codable {
    let daily: [DailyUsage]
    let totals: Totals

    struct DailyUsage: Codable {
        let date: String
        let totalCost: Double
    }

    struct Totals: Codable {
        let inputTokens: Int
        let outputTokens: Int
        let cacheCreationTokens: Int
        let cacheReadTokens: Int
        let totalCost: Double
        let totalTokens: Int
    }
}
