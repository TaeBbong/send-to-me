# 앱 식별자 (Bundle ID / Package / Display Name)

앱의 bundle id·package·표시 이름과, 이를 바꿀 때 따라오는 작업을 정리합니다.

## 현재 값

| 항목 | 값 |
|---|---|
| iOS bundle id (본앱) | `com.taebbong.sendtome` |
| iOS bundle id (테스트) | `com.taebbong.sendtome.RunnerTests` |
| iOS bundle id (공유 익스텐션) | `com.taebbong.sendtome.ShareExtension` |
| Android `applicationId` / `namespace` | `com.taebbong.sendtome` |
| App Group (iOS, 공유 익스텐션 ↔ 본앱) | `group.com.taebbong.sendtome` |
| 표시 이름 (영어) | `Send to Me` |
| 표시 이름 (한글) | `나에게 보내기` |

> `macos / web / linux / windows` 타겟은 아직 `com.example.*`입니다. 데스크톱/웹은 배포 대상이 아니라 의도적으로 두었습니다. **배포하게 되면 같이 바꾸고 아래 절차를 다시 타야 합니다.**

> 바꾸지 않는 것: `pubspec.yaml`의 `name`(Dart 패키지명 — 전체 `package:awesome_memo/...` import에 영향), drift DB 이름 `awesome_memo`(기존 로컬 데이터 보존).

## 표시 이름 현지화 위치

- **Android**: `AndroidManifest.xml`의 `android:label="@string/app_name"` → `res/values/strings.xml`(영어), `res/values-ko/strings.xml`(한글)
- **iOS**: `Runner/en.lproj/InfoPlist.strings`, `Runner/ko.lproj/InfoPlist.strings`의 `CFBundleDisplayName`. Xcode 프로젝트에 `InfoPlist.strings` variant group + `knownRegions`에 `ko` 등록 필요.

## ⚠️ 식별자를 바꾸거나 타겟을 추가하면 반드시

`rename` 패키지(`rename setBundleId` / `setAppName`)는 **문자열 치환만** 합니다. 다음은 도구가 처리하지 못하므로 직접 확인해야 합니다.

1. **iOS 접미사 타겟 복구** — `rename`이 `.RunnerTests` / `.ShareExtension`까지 본앱 id로 뭉갭니다. 공유 익스텐션은 반드시 본앱의 **자식 id**(`...sendtome.ShareExtension`)여야 동작합니다.
2. **App Group 일치** — Runner/ShareExtension의 `*.entitlements`·`Info.plist` 4곳 + Apple Developer 계정의 App Group 등록. 안 맞으면 공유 익스텐션 ↔ 본앱 데이터 전달이 깨져 **공유 기능 자체가 동작하지 않습니다.**
3. **Android 패키지 이동** — `namespace` 변경 시 `MainActivity.kt`를 새 패키지 폴더로 옮기고 `package` 선언도 수정.
4. **Firebase 재설정 (가장 중요)** — bundle id / applicationId는 Firebase에 등록된 키입니다. 로컬만 바꾸면 `firebase_ai` 호출이 인증 실패합니다.
   - Firebase 콘솔에서 새 bundle id로 iOS/Android 앱을 추가한 뒤,
   - **반드시 `flutterfire configure`를 다시 실행**합니다. 이 한 번으로 `lib/firebase_options.dart` + `ios/Runner/GoogleService-Info.plist` + `android/app/google-services.json`이 새 식별자에 맞게 재생성됩니다.
   ```bash
   flutterfire configure
   ```
5. **클린 리빌드**:
   ```bash
   flutter clean && (cd ios && pod install)
   ```
