# Auto Generated Dockerfile

FROM ballerina/ballerina-runtime:0.990.3
LABEL maintainer="dev@ballerina.io"

COPY ocr-service.balx /home/ballerina 

EXPOSE  8080
CMD ballerina run --config ${CONFIG_FILE} ocr-service.balx
