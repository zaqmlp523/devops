# week07 - docker + compose + nginx + healthcheck

# .env를 Git에 올리지 않는 이유
# .evn에는 REDIS_PASSWORD 같은 비밀번호가 들어있기 떄문에 git에 올리면 누구에게나 노출될 수 있다. 그렇기 때문에 변수 이름만 적은 .env.example을 대신 올린다.

## Docker Compose 멀티 컨테이너 구성 및 감시 스크립트
compose.yaml : 여러 개의 컨테이너 서비스, 네트워크, 볼륨, 환경 변수 파일 연동 방법 정리
watch-web.sh : 컨테이너 개수가 항상 3개로 유지 되도록 자동 감지 및 복구
작동원리 : docker compose ps 로 개수 확인 후 3개 미만 시 docker compose up -d --scale web=3 실행

## 장,단점 및 한계
장점 : 무거운 오케스트레이션 툴 없이도 현재 배운 Compose와 셸 스크립트만으로 가볍고 직관적인 자동 복구 구현 가능
단점 및 한계 : 5초 주기의 폴링 방식으로 인한 실시간성 지연, 셸 세션이 종료되면 스크립트도 멈추는 안정성 한계
