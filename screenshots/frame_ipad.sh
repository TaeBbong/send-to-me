#!/bin/bash
# iPad sibling of frame.sh: composite raw 2064x2752 iPad Pro 13" simulator
# screenshots into the same brand-blue gradient + 2-line Korean caption frame.
# Output stays exactly 2064x2752 (App Store "iPad 13-inch Display" slot).
set -euo pipefail

FONT="/System/Library/Fonts/AppleSDGothicNeo.ttc"
W=2064; H=2752
DEV_W=1480                # device width on canvas (~72%)
RADIUS=110                # corner radius on the raw (before scaling)
CAP1_Y=210               # caption line 1 baseline offset from top
CAP2_Y=400               # caption line 2
DEV_Y=660                # device top offset from top (under caption)
PT=118                   # caption point size
TMP=$(mktemp -d)

frame() {
  local raw="$1" out="$2" line1="$3" line2="$4" top="$5" bot="$6" txt="$7"
  # 1) round the screenshot corners
  magick -size ${W}x${H} xc:black -fill white \
    -draw "roundrectangle 0,0,$((W-1)),$((H-1)),${RADIUS},${RADIUS}" "$TMP/mask.png"
  magick "$raw" "$TMP/mask.png" -alpha off -compose CopyOpacity -composite "$TMP/rounded.png"
  # 2) scale to device width
  magick "$TMP/rounded.png" -resize ${DEV_W}x "$TMP/dev.png"
  # 3) soft drop shadow
  magick "$TMP/dev.png" \( +clone -background black -shadow 50x40+0+30 \) \
    +swap -background none -layers merge +repage "$TMP/devsh.png"
  # 4) gradient background
  magick -size ${W}x${H} gradient:"$top"-"$bot" "$TMP/bg.png"
  # 5) caption (faux-bold via thin stroke) + device
  magick "$TMP/bg.png" \
    -font "$FONT" -fill "$txt" -stroke "$txt" -strokewidth 1.4 \
    -pointsize ${PT} -gravity North -annotate +0+${CAP1_Y} "$line1" \
    -pointsize ${PT} -gravity North -annotate +0+${CAP2_Y} "$line2" \
    -stroke none \
    "$TMP/devsh.png" -gravity North -geometry +0+${DEV_Y} -composite \
    -alpha remove -alpha off "$out"
  echo "  ✓ $(basename "$out")"
}

BLUE_T="#2D67E8"; BLUE_B="#5F93FF"   # cohesive brand blue (light screens)
DARK_T="#15161A"; DARK_B="#2B2F3D"   # dark screen
WHITE="#FFFFFF"

mkdir -p ios/13
echo "Framing iPad 13\" (2064x2752)…"
frame raw_ipad/01_chat.png        ios/13/01_capture.png   "생각나면 톡 던지세요"   "저장은 즉시, 정리는 AI가" "$BLUE_T" "$BLUE_B" "$WHITE"
frame raw_ipad/02_rooms.png       ios/13/02_classify.png  "쌓인 메모, AI가 자동 분류" "카테고리가 채팅방처럼 한눈에" "$BLUE_T" "$BLUE_B" "$WHITE"
frame raw_ipad/03_detail_todo.png ios/13/03_checklist.png "할 일은 체크리스트로"     "완료까지 한 화면에서 관리" "$BLUE_T" "$BLUE_B" "$WHITE"
frame raw_ipad/04_detail_ref.png  ios/13/04_cards.png     "링크와 자료는 요약 카드로" "다시 찾기 쉽게 보관" "$BLUE_T" "$BLUE_B" "$WHITE"
frame raw_ipad/06_chat_dark.png   ios/13/05_dark.png      "라이트도 다크도"         "눈이 편한 다크 모드" "$DARK_T" "$DARK_B" "$WHITE"
frame raw_ipad/05_settings.png    ios/13/06_settings.png  "분류 방식도 내 마음대로"   "AI 동작을 세밀하게 설정" "$BLUE_T" "$BLUE_B" "$WHITE"

rm -rf "$TMP"
echo "Done."
