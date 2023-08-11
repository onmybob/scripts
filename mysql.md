## 容器内访问外部mysql

```bash
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
spec:
  ports:
  - port: 3306
---
apiVersion: v1
kind: Endpoints
metadata:
  name: mysql-service
subsets:
  - addresses:
      - ip: "10.0.12.6"
    ports:
      - port: 3306
```
