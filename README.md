# it-nt-router

## todo

在运行时通过环境变量或挂载卷的方式提供配置和 Schema: 更高级的方式是在 Docker 镜像中不包含具体的 router.yaml 和 Schema 文件，而是在 Lambda 函数运行时，通过环境变量或者挂载 AWS EFS (Elastic File System) 卷的方式来提供配置和 Schema。 这种方式更灵活，可以方便地在不重新构建镜像的情况下更新配置和 Schema。

push to register

```
docker tag graphql-router-lambda:latest 319653899185.dkr.ecr.us-east-1.amazonaws.com/it-t/graphql-router-lambda:latest
```

push to register

```
docker push 319653899185.dkr.ecr.us-east-1.amazonaws.com/it-t/graphql-router-lambda:latest
```
