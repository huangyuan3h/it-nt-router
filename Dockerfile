FROM public.ecr.aws/lambda/provided:al2

COPY router /opt/router 
COPY router.yaml /opt/router.yaml

RUN chmod +x /opt/router

ENTRYPOINT ["/opt/router", "--config", "/opt/router.yaml"]