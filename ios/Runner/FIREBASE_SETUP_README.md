# Firebase Crashlytics iOS 설정 가이드

이 프로젝트는 환경별(Debug/Release) Firebase 설정을 사용합니다.

## 폴더 구조

```
Runner/
  Firebase/
    Debug/
      GoogleService-Info.plist  (개발 환경용)
    Release/
      GoogleService-Info.plist  (프로덕션 환경용)
```

## Xcode에서 수동 설정 필요 사항

### 1. Target Membership 해제

각 GoogleService-Info.plist 파일의 Target Membership을 해제해야 합니다:

1. Xcode에서 프로젝트 열기
2. `Runner/Firebase/Debug/GoogleService-Info.plist` 선택
3. File Inspector (오른쪽 패널)에서 Target Membership 체크 해제
4. `Runner/Firebase/Release/GoogleService-Info.plist`도 동일하게 Target Membership 체크 해제

### 2. Enable App Sandbox 확인

1. Project > Targets > Runner 선택
2. Build Settings > Signing 검색
3. "Enable App Sandbox" 설정을 `No`로 변경 (기본값은 `Yes`일 수 있음)

### 3. Run Script Phase 위치 확인

Build Phases에서 다음 순서를 확인:
1. [CP] Check Pods Manifest.lock
2. Run Script (Flutter)
3. Sources
4. Frameworks
5. **Setup Firebase Environment GoogleService-Info.plist** ← 이 스크립트가 Resources 앞에 있어야 함
6. Resources
7. Embed Frameworks
8. Thin Binary
9. [CP] Embed Pods Frameworks
10. [CP] Copy Pods Resources
11. ShellScript (Firebase Crashlytics)

## 참고

- Run Script Phase가 이미 `project.pbxproj`에 추가되어 있습니다.
- Debug 빌드 시 `Firebase/Debug/GoogleService-Info.plist`가 사용됩니다.
- Release 빌드 시 `Firebase/Release/GoogleService-Info.plist`가 사용됩니다.
- 각 환경의 plist 파일은 Firebase Console에서 다운로드한 파일로 교체할 수 있습니다.

