#6주차 실습 기록

## 내 이미지 주소
- `ghcr.io/zaqmlp523/guestbook:v2`

## Dockerfile 주요 명령어
FROM : 기반이 될 베이스 이미지 지정
WORKDIR : 작업 디렉토리 설정
COPY : 소스코드나 파일을 컨테이너 내부로 복사
RUN : 이미지 빌드 과정에서 실행할 명령어
CMD / ENTRYPOINT : 컨테이너가 시작될 떄 시본으로 실행할 명령어

## 레이어 캐시 원리
Layer Cache : 명령어 단위로 레이어가 캐싱되어 빌드 속도가 빨라짐

## GHCR 푸시 과정
개인 토큰을 이용한 로그인 방법
이미지 태깅 및 원격 저장소 업로드
