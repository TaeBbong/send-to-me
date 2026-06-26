# App Store / Play screenshots

Real-app screenshots framed with benefit captions. Each platform is captured on
its **own** OS so the status bar matches store requirements:

- **iOS** — iPhone 16 Pro Max simulator, clean status bar via `simctl status_bar`.
- **Android** — `Medium_Phone_API_36` emulator, clean status bar via SysUI demo
  mode. (Do **not** reuse iOS captures on Play — an iOS status bar / Dynamic
  Island in a Play listing fails review.)

Both use the dev build's seeded sample data.

## Output

| Path | Size | Store slot |
|------|------|-----------|
| `ios/6.9/` | 1320×2868 | **App Store — required** (6.9″, iPhone 16 Pro Max) |
| `ios/6.5/` | 1242×2688 | App Store — 6.5″ fallback |
| `android/phone/` | 1080×1920 | **Google Play** phone (9:16, within Play's 2:1 limit) |
| `android/feature_graphic.png` | 1024×500 | Google Play feature graphic |
| `raw/` | 1320×2868 | unframed iOS source captures |
| `raw_android/` | 1080×2400 | unframed Android source captures |

> Apple's 1320×2868 (2.17:1) exceeds Google Play's 2:1 aspect limit, so the
> Play set is rendered separately at 9:16 — don't reuse the iOS files there.

## Gallery order (captions are benefit-focused, max 2 lines)

1. **01_capture** — 생각나면 톡 던지세요 / 저장은 즉시, 정리는 AI가  *(hero — chat-style capture)*
2. **02_classify** — 쌓인 메모, AI가 자동 분류 / 카테고리가 채팅방처럼 한눈에  *(differentiator)*
3. **03_checklist** — 할 일은 체크리스트로 / 완료까지 한 화면에서 관리  *(per-kind generative UI)*
4. **04_cards** — 링크와 자료는 요약 카드로 / 다시 찾기 쉽게 보관
5. **05_dark** — 라이트도 다크도 / 눈이 편한 다크 모드
6. **06_settings** — 분류 방식도 내 마음대로 / AI 동작을 세밀하게 설정

The first 3 are what most users see before scrolling. App name in store
metadata: **나에게 보내기** (Send to Me).

## Regenerate

Raw captures live in `raw/`. To re-frame after editing captions/colors:

```bash
cd screenshots
bash frame.sh           # iOS 6.9″  → ios/6.9/
bash frame_android.sh   # Play phone + feature graphic
# iOS 6.5″ is a resize of 6.9″:
for f in ios/6.9/*.png; do magick "$f" -resize 1242x2688! "ios/6.5/$(basename "$f")"; done
```

To re-capture from the app, run it via the screenshot driver entrypoint
(`lib/main_driver.dart`, which enables `flutter_driver`) and drive it with the
Dart MCP `flutter_driver` tool. Set a clean status bar first:

```bash
# iOS
xcrun simctl status_bar booted override --time "9:41" \
  --batteryState charged --batteryLevel 100 --wifiBars 3 --cellularBars 4

# Android (SysUI demo mode → capture with `adb exec-out screencap -p`)
adb shell settings put global sysui_demo_allowed 1
adb shell am broadcast -a com.android.systemui.demo -e command enter
adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0941
adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 100 -e plugged false
adb shell am broadcast -a com.android.systemui.demo -e command network -e mobile hide -e wifi show -e level 4 -e fully true
adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false
# ...capture screens..., then: adb shell am broadcast -a com.android.systemui.demo -e command exit
```

`lib/main_driver.dart` + the `flutter_driver` dev-dependency exist **only** for
screenshot capture — safe to delete if you don't plan to re-capture.
