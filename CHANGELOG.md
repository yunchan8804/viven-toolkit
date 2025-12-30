# Changelog

All notable changes to this project will be documented in this file.

## [1.3.0] - 2024-12-30

### Added
- **Rules 문서 분리**: 코딩 규칙을 모듈화된 파일로 분리
  - `rules/lua-style.md` - Lua 코딩 스타일 가이드
  - `rules/network-patterns.md` - Host/Client, RPC, 동기화 패턴
  - `rules/common-errors.md` - 자주 발생하는 오류와 해결책

- **새 템플릿 추가**:
  - `multiplayer-template.lua` - Host/Client RPC 전체 구조
  - `ui-panel-template.lua` - UI 패널 (Show/Hide/Refresh 패턴)
  - `sync-data-template.lua` - 동기화 테이블 (isDirty/캐시 패턴)

- **새 스니펫 추가**:
  - `xr-control.lua` - XR/VR 컨트롤러, 진동 제어
  - `room-control.lua` - Room 정보, 플레이어 관리, 프로퍼티

- **사용 가이드**: `USAGE.md` 추가 - 상세 사용법, 시나리오 예제, 팁

- **자동 생성 폴더**: `generated/` - DocFX 기반 API 참조 자동 생성

- **동기화 스크립트**: `scripts/sync-docfx-api.py` - DocFX YML → toolkit 동기화

- **새 슬래시 커맨드**:
  - `/viven:multiplayer` - Host/Client 템플릿 생성
  - `/viven:ui-panel` - UI 패널 템플릿 생성
  - `/viven:sync-data` - 동기화 테이블 템플릿 생성

### Changed
- **CLAUDE.md 리팩토링**: 1200줄 → 250줄로 간소화, 파일 참조 방식 도입
- **README.md 업데이트**: Quick Start 개선, 파일 구조 업데이트

### API Changes
- **Deprecated**: `UI.SetUIMode()`, `Player.Mine.PlayEmote()`
- **New APIs**: `Player.Mine.AddMoveInput()`, `Room.LeaveRoom()`, `XR.StartControllerVibration()` 등

## [1.2.1] - 2024-12-xx

### Added
- 네트워크 멀티플레이어 시스템 문서
- RPC, Room 속성 가이드
- Host-Client 아키텍처 패턴

## [1.0.0] - 2024-xx-xx

### Added
- 초기 릴리즈
- CLAUDE.md 메인 가이드
- 기본 Lua 스니펫
- 슬래시 커맨드 지원
