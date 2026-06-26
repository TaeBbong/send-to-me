#!/bin/bash
# Composite raw 1320x2868 simulator screenshots into App Store / Play frames:
# rounded device + soft shadow on a cohesive brand-blue gradient with a
# benefit-focused 2-line Korean caption. Output stays exactly 1320x2868.
set -euo pipefail

FONT="/System/Library/Fonts/AppleSDGothicNeo.ttc"
W=1320; H=2868
DEV_W=980                 # device width on canvas
CAP1_Y=150               # caption line 1 baseline offset from top
CAP2_Y=290               # caption line 2
DEV_Y=560                # device top offset from top (under caption)
TMP=$(mktemp -d)

frame() {
  local raw="$1" out="$2" line1="$3" line2="$4" top="$5" bot="$6" txt="$7"
  # 1) round the screenshot corners
  magick -size ${W}x${H} xc:black -fill white \
    -draw "roundrectangle 0,0,$((W-1)),$((H-1)),70,70" "$TMP/mask.png"
  magick "$raw" "$TMP/mask.png" -alpha off -compose CopyOpacity -composite "$TMP/rounded.png"
  # 2) scale to device width
  magick "$TMP/rounded.png" -resize ${DEV_W}x "$TMP/dev.png"
  # 3) soft drop shadow
  magick "$TMP/dev.png" \( +clone -background black -shadow 50x35+0+26 \) \
    +swap -background none -layers merge +repage "$TMP/devsh.png"
  # 4) gradient background
  magick -size ${W}x${H} gradient:"$top"-"$bot" "$TMP/bg.png"
  # 5) caption (faux-bold via thin stroke) + device
  magick "$TMP/bg.png" \
    -font "$FONT" -fill "$txt" -stroke "$txt" -strokewidth 1.2 \
    -pointsize 92 -gravity North -annotate +0+${CAP1_Y} "$line1" \
    -pointsize 92 -gravity North -annotate +0+${CAP2_Y} "$line2" \
    -stroke none \
    "$TMP/devsh.png" -gravity North -geometry +0+${DEV_Y} -composite \
    -alpha remove -alpha off "$out"
  echo "  ✓ $(basename "$out")"
}

BLUE_T="#2D67E8"; BLUE_B="#5F93FF"   # cohesive brand blue (light screens)
DARK_T="#15161A"; DARK_B="#2B2F3D"   # dark screen
WHITE="#FFFFFF"

mkdir -p ios
echo "Framing iOS 6.9\" (1320x2868)…"
frame raw/01_chat.png        ios/01_capture.png   "생각나면 톡 던지세요"   "저장은 즉시, 정리는 AI가" "$BLUE_T" "$BLUE_B" "$WHITE"
frame raw/02_rooms.png       ios/02_classify.png  "쌓인 메모, AI가 자동 분류" "카테고리가 채팅방처럼 한눈에" "$BLUE_T" "$BLUE_B" "$WHITE"
frame raw/03_detail_todo.png ios/03_checklist.png "할 일은 체크리스트로"     "완료까지 한 화면에서 관리" "$BLUE_T" "$BLUE_B" "$WHITE"
frame raw/04_detail_ref.png  ios/04_cards.png     "링크와 자료는 요약 카드로" "다시 찾기 쉽게 보관" "$BLUE_T" "$BLUE_B" "$WHITE"
frame raw/06_chat_dark.png   ios/05_dark.png      "라이트도 다크도"         "눈이 편한 다크 모드" "$DARK_T" "$DARK_B" "$WHITE"
frame raw/05_settings.png    ios/06_settings.png  "분류 방식도 내 마음대로"   "AI 동작을 세밀하게 설정" "$BLUE_T" "$BLUE_B" "$WHITE"

rm -rf "$TMP"
echo "Done."
