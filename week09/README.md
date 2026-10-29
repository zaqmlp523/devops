# DevOps 쿠버네티스 실습

## 클러스터 설치 및 노드 확인

## pod 자가 치유 (Deployment) 확인
Deployment를 통해 delete하더라도 쿠버네티스가 자동으로 
새로운 pod를 생성해 개수를 유지하는 것을 kubectl get pods -w
로 확인

## 선언형
쿠버네티스가 현재 상태를 계속 관찰하고 비교하여 내가 원하는
목표 상태를 맞춰주는 방식

## 트러블슈팅 및 느낀 점
막혔던것 : 처음 배포 시 ImagePullBackOff 에러 발생
해결방법 : 이미지 태그(v2) 확인 및 ghcr 패키지 권한을 public
으로 설정하여 정상 해결 
