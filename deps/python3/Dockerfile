# Stage FINAL
ARG VERSION="3.8-alpine"
ARG VERSION_NUM="3.8"
FROM python:$VERSION as final

LABEL maintainer="alessandro.carrega@cnit.it"
LABEL description="Python version $VERSION_NUM on Alpine Linux with gcc support"
LABEL version=$VERSION

RUN apk add --no-cache --virtual .build-deps gcc musl-dev linux-headers
