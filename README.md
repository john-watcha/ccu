# CCU (Claude Code Usage)

macOS 메뉴바에 Claude Code의 사용량을 표시하는 앱입니다.

## 주요 기능

- 메뉴바에 실시간 토큰 사용량 표시
- 입력/출력 토큰 개별 조회
- 캐시 생성/읽기 토큰 조회
- 총 비용 계산
- 5분마다 자동 업데이트
- `npx ccusage@latest --json` 명령어 활용

## 사전 요구사항

- macOS 14.0 이상
- Node.js 및 npx 설치
- Claude Code 사용 환경 (API 키가 환경에 설정되어 있어야 함)

## 설정 방법

### 1. Xcode 프로젝트 설정

1. Xcode에서 `ccu.xcodeproj` 열기
2. 프로젝트 네비게이터에서 프로젝트 선택
3. "Signing & Capabilities" 탭으로 이동
4. "Code Signing" 섹션에서 팀 선택
5. `ccu.entitlements` 파일이 프로젝트에 자동으로 추가되었는지 확인

## 빌드 및 실행

### Xcode에서 실행

```bash
open ccu.xcodeproj
```

Xcode에서 ⌘+R을 눌러 실행

### 커맨드라인에서 빌드

```bash
xcodebuild -project ccu.xcodeproj -scheme ccu -configuration Release build
```

빌드된 앱 위치:
```
~/Library/Developer/Xcode/DerivedData/ccu-*/Build/Products/Release/ccu.app
```

## 사용법

1. 앱 실행 시 메뉴바 오른쪽에 클라우드 아이콘(☁️)과 토큰 사용량이 표시됩니다
2. 아이콘 클릭 시 상세 정보 패널이 열립니다:
   - 입력 토큰 수
   - 출력 토큰 수
   - 캐시 생성 토큰 수
   - 캐시 읽기 토큰 수
   - 총 토큰 수
   - 총 비용
   - 마지막 업데이트 시간
3. "새로고침" 버튼을 클릭하여 수동으로 업데이트 가능
4. "종료" 버튼으로 앱 종료

## 기술 스택

- Swift
- SwiftUI
- Process (커맨드라인 실행)
- npx ccusage (Claude Code 사용량 조회)

## 프로젝트 구조

```
ccu/
├── ccuApp.swift              # 앱 진입점 및 메뉴바 설정
├── ContentView.swift         # 메인 UI
├── UsageViewModel.swift      # 사용량 데이터 관리
├── ClaudeAPIService.swift    # 커맨드라인 실행 로직
├── ccu.entitlements         # 앱 권한 설정
└── Assets.xcassets/         # 앱 리소스
```

## 주의사항

- Node.js와 npx가 시스템에 설치되어 있어야 합니다
- Claude Code API 키가 환경에 설정되어 있어야 합니다
- 네트워크 연결이 필요합니다 (npx 패키지 다운로드)
- macOS 14.0 이상에서 동작합니다

## 비용 계산

`ccusage` 패키지가 자동으로 모델별 비용을 계산하여 제공합니다. 여러 모델의 사용량을 종합하여 총 비용을 표시합니다.

## 라이선스

MIT License
