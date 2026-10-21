
## curl 확인 결과

### localhost:8091
```
<h1>nginx1<h1>
```

### localhost:8092
```
<h1>nginx2<h1>
```

### localhost:8093
```
<h1>nginx3<h1>
```

## 이미지와 컨테이너의 차이
이미지 : 애플리케이션 실행에 필요한 파일과 설정이 포함된 읽기 전용 템플릿
컨테이너 : 이미지를 실행하여 격리된 환경에서 동작시키는 인스턴스

## 주요 도커 명령어 실습 기록
dorker run : 컨테이너 생성 및 실행 
docker ps : 실행 중인 컨테이너 목록 확인
docker logs : 컨테이너 로그 출력 
docker exec : 실행 중인 컨테이너 내부 접속

