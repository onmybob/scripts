# k3s配置一个ssl站点

#### 配置站点SSL证书 ,文件名必须是tls.crt和tls.key
```bash
kubectl create secret generic bobjoy-cert --from-file=/root/ssl/www.bobjoy.com/tls.crt  --from-file=/root/ssl/www.bobjoy.com/tls.key
```

#### 配置文件
```bash
cat hello.yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: hello-node
  name: hello-node
spec:
  replicas: 3
  selector:
    matchLabels:
      app: hello-node
  template:
    metadata:
      labels:
        app: hello-node
    spec:
      containers:
      - image: registry.cn-shenzhen.aliyuncs.com/onmybob/hello-node:1.0.4
        imagePullPolicy: Always
        name: hello-node
      imagePullSecrets:
      - name: aliyun

---

apiVersion: v1
kind: Service
metadata:
  name: hello-service
spec:
  selector:
    app: hello-node
  ports:
  - protocol: TCP
    port: 8081
    targetPort: 8080

---

apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
  name: hello-node
spec:
  entryPoints:
    - web
    - websecure
  tls:
     secretName: bobjoy-cert
  routes:
    - match: Host(`www.bobjoy.com`)
      kind: Rule
      services:
        - name: hello-service
          port: 8081
      middlewares:
        - name: redirect-https
          namespace: kube-system
```
          
