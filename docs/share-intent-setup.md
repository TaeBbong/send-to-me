# 외부 공유 받기 (Share Intent) + 클립보드 붙여넣기 설정

다른 앱의 "공유" 시트에서 텍스트/URL을 받아 **즉시 메모로 저장하고 자동 분류**까지 돌리는 기능과,
앱 진입 시 **클립보드 붙여넣기 제안 칩**을 띄우는 기능을 추가했습니다.

패키지: [`share_handler`](https://pub.dev/packages/share_handler)

---

## 1. 코드/설정에서 이미 끝난 것 (추가 작업 불필요)

| 영역 | 파일 | 내용 |
|---|---|---|
| 의존성 | `pubspec.yaml` | `share_handler` 추가 |
| 수신 서비스 | `lib/features/sharing/shared_intent_service.dart` | share_handler 래핑 + 텍스트 추출 |
| 수신 리스너 | `lib/features/sharing/share_intent_listener.dart` | 공유 수신 → `MemoActions.send()` → `/chat` 이동 |
| 앱 연결 | `lib/app/app.dart` | `MaterialApp.router`에 리스너 부착 |
| 클립보드 | `lib/features/memo_chat/widgets/chat_input_bar.dart` | 포그라운드 진입 시 붙여넣기 칩 |
| Android | `android/app/src/main/AndroidManifest.xml` | `SEND`/`SEND_MULTIPLE` intent-filter, `launchMode=singleTask`, 권한 |
| iOS | `ios/Runner/Info.plist` | URL scheme `ShareMedia-...`, `AppGroupId` |
| iOS | `ios/Podfile` | `ShareExtension` 타겟용 pod |
| iOS | `ios/Runner/SceneDelegate.swift` | scene → app delegate URL 브릿지 |

> **공유 = 분류 자동 실행**: 수신된 텍스트는 채팅 입력과 동일한 `MemoActions.send()` 경로를 타므로,
> 즉시 저장 + 백그라운드 LLM 분류가 자동으로 돕니다. 사용자가 전송 버튼을 누를 필요 없습니다.

**Android는 이걸로 끝입니다.** `flutter run`으로 바로 테스트하세요.

---

## 2. iOS: Share Extension 타겟 생성 (수동, Xcode에서)

iOS만 Xcode에서 타겟을 직접 추가해야 합니다. 아래 **App Group ID로 통일**하세요:

```
group.com.taebbong.sendtome
```

### 2-1. 타겟 추가
1. `open ios/Runner.xcworkspace` 로 Xcode 열기
2. **File → New → Target… → Share Extension** 선택
3. Product Name = `ShareExtension` (이 이름 그대로 — Podfile/번들 ID 규칙이 여기에 맞춰져 있음)
4. Language = Swift, "Activate scheme?" 뜨면 **Cancel** (활성화 안 함)
5. 생성되면 `ShareExtension` 폴더에 `ShareViewController.swift`, `Info.plist`, `MainInterface.storyboard`가 생김

### 2-2. App Group 추가 (두 타겟 모두)
**Runner**, **ShareExtension** 각각에 대해:
1. 타겟 선택 → **Signing & Capabilities → + Capability → App Groups**
2. `group.com.taebbong.sendtome` 추가 (양쪽 동일하게)

> 실기기/TestFlight 배포 시에는 Apple Developer 계정에 동일한 App Group을 등록해야 합니다.
> 시뮬레이터 개발 중에는 위 값 그대로 동작합니다.

### 2-3. `ShareViewController.swift` 교체
Xcode가 만든 내용을 전부 지우고 아래로 교체:

```swift
import share_handler_ios_models

class ShareViewController: ShareHandlerIosViewController {}
```

### 2-4. ShareExtension `Info.plist` 교체
`ShareExtension/Info.plist`의 `<dict>` 안을 아래로 맞춥니다 (핵심: `AppGroupId` + `NSExtension`):

```xml
<key>AppGroupId</key>
<string>group.com.taebbong.sendtome</string>
<key>CFBundleVersion</key>
<string>$(FLUTTER_BUILD_NUMBER)</string>
<key>NSExtension</key>
<dict>
    <key>NSExtensionAttributes</key>
    <dict>
        <key>NSExtensionActivationRule</key>
        <string>SUBQUERY (
            extensionItems,
            $extensionItem,
            SUBQUERY (
                $extensionItem.attachments,
                $attachment,
                (
                    ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.url"
                    || ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.text"
                    || ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.image"
                    || ANY $attachment.registeredTypeIdentifiers UTI-CONFORMS-TO "public.file-url"
                )
            ).@count > 0
        ).@count > 0</string>
        <key>PHSupportedMediaTypes</key>
        <array>
            <string>Image</string>
        </array>
    </dict>
    <key>NSExtensionMainStoryboard</key>
    <string>MainInterface</string>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.share-services</string>
</dict>
```

### 2-5. pod 설치
```bash
cd ios && pod install
```
`Podfile`에는 이미 `ShareExtension` 타겟 블록이 추가돼 있습니다 (Runner와 통합되려면
`use_frameworks!`가 양쪽에 모두 있어야 하므로 ShareExtension 블록에도 포함돼 있음).

---

## 3. 테스트

**Android**
1. `flutter run`
2. 크롬/유튜브 등에서 링크 공유 → "Awesome Memo" 선택
3. 앱이 열리고 `/chat`에 메모가 즉시 쌓이며 분류가 돌아야 함

**iOS** (위 2번 완료 후)
1. `flutter run`
2. Safari에서 페이지 공유 → "Awesome Memo" 선택
3. 동일하게 동작 확인. **앱을 완전히 종료한 상태(cold start)** 와 **백그라운드 상태(warm)** 둘 다 테스트할 것.

**클립보드 (공통)**: 다른 앱에서 텍스트 복사 → Awesome Memo로 돌아오면 입력창 위에 "📋 붙여넣기: …" 칩 표시 → 탭하면 입력창에 채워짐.

---

## 3-1. 타겟 추가 후 겪은 실제 빌드 이슈 (해결됨)

Xcode 16.3에서 ShareExtension 타겟을 추가하니 두 가지 문제가 났고, 아래처럼 고쳤습니다. (재발 시 참고)

1. **`pod install` 실패: `Unable to find compatibility version string for object version 70`**
   - 원인: 타겟 추가 때 Xcode가 `Runner.xcodeproj`의 `objectVersion`을 70으로 올렸는데, 설치된 `xcodeproj` 1.27.0(최신)이 70을 모름(이 gem은 77/63/60/56만 인식). gem 업데이트로는 해결 불가.
   - 해결: `ios/Runner.xcodeproj/project.pbxproj`의 `objectVersion = 70;` → `objectVersion = 77;` (동기화 그룹을 쓰므로 낮추면 안 되고, gem이 아는 Xcode 16 포맷값인 77로).

2. **빌드 실패: `Cycle inside Runner` (ShareExtension.appex 복사 ↔ Embed Pods Frameworks/Thin Binary 순환)**
   - 원인: Xcode가 추가한 `Embed Foundation Extensions`(appex 복사) 단계가 Runner의 **맨 마지막**에 놓여 `Thin Binary`/AppIntents 메타데이터와 순환.
   - 해결: Runner → Build Phases에서 **`Embed Foundation Extensions`를 `Thin Binary` 앞으로** 이동. (`project.pbxproj`의 `buildPhases` 배열에서 순서 변경)

> 검증: `flutter build ios --debug --simulator` 또는
> `xcodebuild -workspace ios/Runner.xcworkspace -scheme Runner -sdk iphonesimulator build CODE_SIGNING_ALLOWED=NO` → **BUILD SUCCEEDED** 확인 완료.

## 4. 알려진 리스크 / 주의

- **신형 SceneDelegate 템플릿**: 이 프로젝트는 Flutter의 새 `FlutterSceneDelegate`를 쓰는데,
  share_handler(iOS)는 구형 `application:open:` 방식이라 `SceneDelegate.swift`에 URL 브릿지를 넣어 연결했습니다.
  **iOS 공유, 특히 cold start가 동작하지 않으면 이 브릿지부터 확인**하세요.
- **이미지/파일 공유**: 메모는 텍스트 전용이라 현재는 공유된 **텍스트/URL만** 메모로 저장합니다.
  이미지-only 공유는 무시됩니다(추후 첨부 저장 구현 시 `SharedIntentService.extractText` 확장).
- **iOS 클립보드 배너**: 붙여넣기 칩은 미리보기를 보여주려 클립보드를 읽으므로 iOS의
  "○○에서 붙여넣기" 안내가 뜰 수 있습니다. 입력창이 비었을 때 + 내용이 있을 때(`hasStrings`)만 읽도록 빈도를 줄여 두었습니다.
