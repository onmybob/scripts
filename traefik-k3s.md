## k3s开启treafik

#### 添加环境变量
```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
```

#### 创建文件，覆盖默认的配置

```bash
cat /var/lib/rancher/k3s/server/manifests/traefik-config.yaml

apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    dashboard:
      enabled: true
      domain: "访问traefik的域名"
    globalArguments:
    - "--log.level=INFO"
    - "--providers.kubernetescrd.allowCrossNamespace=true"

```

#### 修改并查看进入点
```bash
kubectl patch ingressroute -n kube-system traefik-dashboard --type=merge -p '{"spec":{"entryPoints":["web"]}}'
kubectl edit ingressroute/traefik-dashboard -oyaml -n kube-system
```

#### 创建一个IngressRoute

```bash
cat traefik-dashboard.yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: web-rate-limit
spec:
  rateLimit:
    average: 100
    burst: 50
---
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
spec:
  entryPoints:
    - web
  routes:
    - match: Host(`访问的域名`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
      middlewares:
        - name: web-rate-limit

kubectl apply -f traefik-dashboard.yaml

http://访问的域名/dashboard

```
#### 增加授权

##### 生成用户名密码
```bash
apt install -y apache2-utils
htpasswd -n admin

admin:$apr1$1OPqJwjN$eW2moftmMx.QcHE6ugvet0

echo 'admin:$apr1$1OPqJwjN$eW2moftmMx.QcHE6ugvet0' | base64 

YWRtaW46JGFwcjEkMU9QcUp3ak4kZVcybW9mdG1NeC5RY0hFNnVndmV0MAo=

```

##### 增加
```bash
cat traefik-dashboard-auth.yaml


apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: traefik-auth
  namespace: kube-system
spec:
  basicAuth:
    secret: authsecret
---
apiVersion: v1
kind: Secret
metadata:
  name: authsecret
  namespace: kube-system
data:
  users: |1
   YWRtaW46JGFwcjEka0NRODcwMkQkWmV0N2Y4Vk0uLk1HWUlMUi5GcDZxMAo=

---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: redirect-https
  namespace: kube-system
spec:
  redirectScheme:
    scheme: https
    permanent: true
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: web-rate-limit
  namespace: kube-system
spec:
  rateLimit:
    average: 100
    burst: 50


cat traefik-dashboard.yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: dashboard
  namespace: kube-system
spec:
  entryPoints:
    - web
    - websecure
  routes:
    - match: Host(`访问的域名`) || (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
      kind: Rule
      services:
        - name: api@internal
          kind: TraefikService
      middlewares:
        - name: traefik-auth
          namespace: kube-system
        - name: redirect-https
          namespace: kube-system
```


