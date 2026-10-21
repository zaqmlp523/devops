#!/bin/bash
cd "$(dirname "$0")" || exit 1

echo "=== Web=3 유지 감시 스크립트 시작 (종료: Ctrl+C) ==="
while true; do
    # 현재 실행 중인 web 서비스 컨테이너 개수 확인
    RUNNING_COUNT=$(docker compose ps --services --filter "status=running" | grep -c "web")

    if [ "$RUNNING_COUNT" -lt 3 ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 경고: 실행 중인 web 컨테이너가 3개 미만($RUNNING_COUNT개)입니다. 복구를 시도합니다."
        docker compose up -d --scale web=3
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] 정상: web 컨테이너가 3개 유지 중입니다."
    fi

    sleep 5
done
