#!/bin/bash
# Google Play phone frames at 1080x1920 (9:16, within Play's 2:1 limit) +
# 1024x500 feature graphic. Same brand-blue look as the iOS set.
set -euo pipefail

FONT="/System/Library/Fonts/AppleSDGothicNeo.ttc"
W=1080; H=1920
DEV_W=560
CAP1_Y=120; CAP2_Y=210; DEV_Y=380
TMP=$(mktemp -d)

# rounding mask sized to the native Android capture (1080x2400)
magick -size 1080x2400 xc:black -fill white \
  -draw "roundrectangle 0,0,1079,2399,56,56" "$TMP/mask.png"

frame() {
  local raw="$1" out="$2" line1="$3" line2="$4" top="$5" bot="$6" txt="$7"
  magick "$raw" "$TMP/mask.png" -alpha off -compose CopyOpacity -composite "$TMP/rounded.png"
  magick "$TMP/rounded.png" -resize ${DEV_W}x "$TMP/dev.png"
  magick "$TMP/dev.png" \( +clone -background black -shadow 50x22+0+16 \) \
    +swap -background none -layers merge +repage "$TMP/devsh.png"
  magick -size ${W}x${H} gradient:"$top"-"$bot" "$TMP/bg.png"
  magick "$TMP/bg.png" \
    -font "$FONT" -fill "$txt" -stroke "$txt" -strokewidth 0.8 \
    -pointsize 58 -gravity North -annotate +0+${CAP1_Y} "$line1" \
    -pointsize 58 -gravity North -annotate +0+${CAP2_Y} "$line2" \
    -stroke none \
    "$TMP/devsh.png" -gravity North -geometry +0+${DEV_Y} -composite \
    -alpha remove -alpha off "$out"
  echo "  ✓ $(basename "$out")"
}

BLUE_T="#2D67E8"; BLUE_B="#5F93FF"
DARK_T="#15161A"; DARK_B="#2B2F3D"
WHITE="#FFFFFF"

mkdir -p android/phone
echo "Framing Android phone (1080x1920)…"
frame raw_android/01_chat.png        android/phone/01_capture.png   "생각나면 톡 던지세요"   "저장은 즉시, 정리는 AI가" "$BLUE_T" "$BLUE_B" "$WHITE"
frame raw_android/02_rooms.png       android/phone/02_classify.png  "쌓인 메모, AI가 자동 분류" "카테고리가 채팅방처럼 한눈에" "$BLUE_T" "$BLUE_B" "$WHITE"
frame raw_android/03_detail_todo.png android/phone/03_checklist.png "할 일은 체크리스트로"     "완료까지 한 화면에서 관리" "$BLUE_T" "$BLUE_B" "$WHITE"
frame raw_android/04_detail_ref.png  android/phone/04_cards.png     "링크와 자료는 요약 카드로" "다시 찾기 쉽게 보관" "$BLUE_T" "$BLUE_B" "$WHITE"
frame raw_android/06_chat_dark.png   android/phone/05_dark.png      "라이트도 다크도"         "눈이 편한 다크 모드" "$DARK_T" "$DARK_B" "$WHITE"
frame raw_android/05_settings.png    android/phone/06_settings.png  "분류 방식도 내 마음대로"   "AI 동작을 세밀하게 설정" "$BLUE_T" "$BLUE_B" "$WHITE"

# ---- Feature graphic 1024x500 ----
echo "Building feature graphic (1024x500)…"
FW=1024; FH=500
magick -size ${FW}x${FH} gradient:"$BLUE_T"-"$BLUE_B" "$TMP/fbg.png"
# small device peek on the right
magick raw_android/01_chat.png "$TMP/mask.png" -alpha off -compose CopyOpacity -composite "$TMP/frounded.png"
magick "$TMP/frounded.png" -resize 250x "$TMP/fdev.png"
magick "$TMP/fdev.png" \( +clone -background black -shadow 60x18+0+10 \) \
  +swap -background none -layers merge +repage "$TMP/fdevsh.png"
# app icon (foreground) at left
ICON="../assets/icon/app_icon_foreground.png"
magick "$TMP/fbg.png" \
  \( "$ICON" -resize 150x150 \) -gravity West -geometry +70+0 -composite \
  -font "$FONT" -fill "$WHITE" -stroke "$WHITE" -strokewidth 0.8 \
  -gravity West -pointsize 72 -annotate +250-40 "나에게 보내기" \
  -stroke none -fill "#E6EEFF" -pointsize 34 -annotate +252+55 "생각나면 톡, 정리는 AI가" \
  "$TMP/fdevsh.png" -gravity East -geometry +60+0 -composite \
  -alpha remove -alpha off android/feature_graphic.png
echo "  ✓ feature_graphic.png"

rm -rf "$TMP"
echo "Done."
