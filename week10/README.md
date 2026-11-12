# Week10: Deployment and Service

- 환경: minikube (단일 노드), Deployment `guestbook`, Service `guestbook` (NodePort 80:30080)
- 이미지: `ghcr.io/zaqmlp523/guestbook:v1`, `ghcr.io/zaqmlp523/guestbook:v2`

## 1. replicas를 5로 확장

```
$ kubectl scale deployment guestbook --replicas=5
deployment.apps/guestbook scaled

$ kubectl get pods -o wide
NAME                        READY   STATUS    RESTARTS      AGE     IP           NODE       NOMINATED NODE   READINESS GATES
guestbook-969fc557d-fbw94   1/1     Running   1 (30m ago)   6d22h   10.244.0.4   minikube   <none>           <none>
guestbook-969fc557d-px2s5   1/1     Running   0             8s      10.244.0.8   minikube   <none>           <none>
guestbook-969fc557d-r8lgw   1/1     Running   0             8s      10.244.0.6   minikube   <none>           <none>
guestbook-969fc557d-sbrqm   1/1     Running   0             8s      10.244.0.7   minikube   <none>           <none>
guestbook-969fc557d-vwvqd   1/1     Running   1 (30m ago)   6d22h   10.244.0.3   minikube   <none>           <none>
```

기존 Pod 2개(AGE 6d22h)에 더해 8초 전에 만들어진 Pod 3개가 추가되어 총 5개가 Running 상태이다.
(이 시점에는 v2 ReplicaSet `969fc557d`가 활성 상태였다. 아래 트러블슈팅 참고.)

## 2. 서비스를 통과한 요청에서 서로 다른 Pod hostname 확인

```
$ kubectl get svc guestbook
NAME        TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)        AGE
guestbook   NodePort   10.96.61.205   <none>        80:30080/TCP   6d22h

$ for i in $(seq 1 15); do minikube ssh "curl -s $(minikube ip):30080" | grep -i -o "guestbook-[a-z0-9-]*"; done | sort | uniq -c
      6 guestbook-dbf8b9c99-6r8hv
      3 guestbook-dbf8b9c99-grtqm
      4 guestbook-dbf8b9c99-l2wxb
      2 guestbook-dbf8b9c99-np7zl
```

같은 Service 주소(NodePort 30080)로 15번 요청했을 때 서로 다른 4개의 Pod hostname이 응답했다.
Service가 요청을 여러 Pod로 분산(로드밸런싱)하는 것을 확인했다.
(15번 요청 중 `guestbook-dbf8b9c99-wrs7n`은 선택되지 않았는데, 분산이 무작위라서 요청 수가 적을 때 생기는 편차로 보인다.)

## 3. Pod 하나를 강제 삭제 -> 자동 복구 확인

```
$ kubectl delete $(kubectl get pods -o name | head -1) --grace-period=0 --force
Warning: Immediate deletion does not wait for confirmation that the running resource has been terminated. The resource may continue to run on the cluster indefinitely.
pod "guestbook-dbf8b9c99-6r8hv" force deleted from default namespace

$ kubectl get pods
NAME                        READY   STATUS              RESTARTS   AGE
guestbook-dbf8b9c99-grtqm   1/1     Running             0          11m
guestbook-dbf8b9c99-jvkdf   0/1     ContainerCreating   0          0s
guestbook-dbf8b9c99-l2wxb   1/1     Running             0          11m
guestbook-dbf8b9c99-np7zl   1/1     Running             0          2m45s
guestbook-dbf8b9c99-wrs7n   1/1     Running             0          11m
```

`6r8hv`를 삭제하자마자 새 Pod `jvkdf`가 `ContainerCreating`(AGE 0s)으로 생성되었다.
ReplicaSet이 desired 상태(replicas=5)를 유지하기 위해 삭제된 Pod를 자동으로 다시 만든다.

## 4. v1 -> v2 롤링 업데이트 후 rollout history

```
$ kubectl set image deployment/guestbook '*=ghcr.io/zaqmlp523/guestbook:v2'
deployment.apps/guestbook image updated

$ kubectl annotate deployment/guestbook kubernetes.io/change-cause="week10: v1 to v2 rolling update" --overwrite
deployment.apps/guestbook annotated

$ kubectl rollout status deployment/guestbook
Waiting for deployment "guestbook" rollout to finish: 3 out of 5 new replicas have been updated...
Waiting for deployment "guestbook" rollout to finish: 3 out of 5 new replicas have been updated...
Waiting for deployment "guestbook" rollout to finish: 3 out of 5 new replicas have been updated...
Waiting for deployment "guestbook" rollout to finish: 3 out of 5 new replicas have been updated...
Waiting for deployment "guestbook" rollout to finish: 4 out of 5 new replicas have been updated...
Waiting for deployment "guestbook" rollout to finish: 4 out of 5 new replicas have been updated...
Waiting for deployment "guestbook" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "guestbook" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "guestbook" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "guestbook" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "guestbook" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "guestbook" rollout to finish: 4 of 5 updated replicas are available...
deployment "guestbook" successfully rolled out

$ kubectl rollout history deployment/guestbook
deployment.apps/guestbook
REVISION  CHANGE-CAUSE
1         v2: 제목 변경
8         <none>
9         week10: v1 to v2 rolling update
```

새 Pod가 단계적으로 늘어나고 기존 Pod가 하나씩 종료되면서 중단 없이 v2로 교체되었다.
history의 revision 9가 이번 v1 -> v2 업데이트이다. (revision 1, 8은 이전 실습에서 남은 기록)

## 5. 롤백

```
$ kubectl rollout undo deployment/guestbook
deployment.apps/guestbook rolled back

$ kubectl rollout status deployment/guestbook
Waiting for deployment "guestbook" rollout to finish: 3 out of 5 new replicas have been updated...
Waiting for deployment "guestbook" rollout to finish: 3 out of 5 new replicas have been updated...
Waiting for deployment "guestbook" rollout to finish: 3 out of 5 new replicas have been updated...
Waiting for deployment "guestbook" rollout to finish: 4 out of 5 new replicas have been updated...
Waiting for deployment "guestbook" rollout to finish: 4 out of 5 new replicas have been updated...
Waiting for deployment "guestbook" rollout to finish: 4 out of 5 new replicas have been updated...
Waiting for deployment "guestbook" rollout to finish: 2 old replicas are pending termination...
Waiting for deployment "guestbook" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "guestbook" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "guestbook" rollout to finish: 1 old replicas are pending termination...
Waiting for deployment "guestbook" rollout to finish: 4 of 5 updated replicas are available...
deployment "guestbook" successfully rolled out

$ kubectl annotate deployment/guestbook kubernetes.io/change-cause="week10: rollback to v1" --overwrite
deployment.apps/guestbook annotated

$ kubectl rollout history deployment/guestbook
deployment.apps/guestbook
REVISION  CHANGE-CAUSE
1         v2: 제목 변경
9         week10: v1 to v2 rolling update
10        week10: rollback to v1

$ kubectl describe deployment guestbook | grep Image
    Image:         ghcr.io/zaqmlp523/guestbook:v1
```

`rollout undo`로 직전 revision(v1)으로 되돌렸고, 이미지가 `guestbook:v1`로 복구된 것을 확인했다.
롤백도 새 revision(10)으로 기록된다.

## 트러블슈팅: v1 이미지 `ErrImagePull`

- 증상: 롤백 시 새 Pod가 `ImagePullBackOff`. 이벤트 메시지는 `ghcr.io/zaqmlp523/guestbook:v1: not found`.
- 원인: ghcr.io에 `v1` 태그가 없었다. (`docker pull ...:v2`는 성공, `...:v1`만 `not found`)
  v2는 노드에 이미 캐시되어 있어서 문제가 드러나지 않았다.
- 해결: 로컬에 있던 `guestbook:v1` 이미지를 ghcr 이름으로 태그해서 minikube 노드에 직접 넣었다.

```
$ docker tag guestbook:v1 ghcr.io/zaqmlp523/guestbook:v1
$ minikube image load ghcr.io/zaqmlp523/guestbook:v1
```

  Deployment의 `imagePullPolicy`가 `IfNotPresent`라서 노드에 이미지가 있으면 레지스트리에 접근하지 않고 Pod가 시작된다.
- 참고: 롤백이 멈췄던 동안에도 새 Pod가 Ready가 되지 않으면 기존 Pod가 유지되어 서비스는 계속 응답했다. (롤링 업데이트의 안전장치)

## 정리

- Deployment는 ReplicaSet을 통해 Pod 개수(replicas)를 유지한다. Pod를 삭제해도 자동으로 복구된다.
- Service는 같은 label의 여러 Pod로 요청을 분산한다.
- 롤링 업데이트는 새 ReplicaSet을 늘리고 기존 ReplicaSet을 줄이는 방식으로 진행되며, `rollout undo`로 이전 revision으로 되돌릴 수 있다.
