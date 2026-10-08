# 6주차 실습 기록

## 내 이미지 주소
- `ghcr.io/zaqmlp523/guestbook:v2`

## 친구 이미지 실행 결과
!(friend_capture.png)

## Dockerfile = 이미지 빌드 방법을 코드로 정의하는 레시피
## WORKDIR = 작업 디렉터리 설정
## COPY = 내 파일을 이미지 안으로 복사할 때 사용

## RUN = 실행할 명령
## COPY . . = 나머지 코드도 이미지 안으로
## ENV = 환경 변수 설정

## EXPOSE 포트 번호 (문서화)
## CMD = 컨테이너 시작 시 실행할 명령

CACHED [2/6] WORKDIR /app

CACHED [3/6] COPY requirements.txt .
CACHED [4/6] RUN pip install --no-cache-dir -r requirements.txt
[5/6] COPY . .
[6/6] RUN useradd -m appuser
