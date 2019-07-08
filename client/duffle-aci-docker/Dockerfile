FROM alpine:latest

ENV ORAS_VERSION=0.5.0
ENV ORAS_REPO=deislabs/oras
ENV ORAS_DOWNLOAD_DIR=/tmp
ENV TOOLHOME="/usr/local/bin"

ENV DUFFLE_VERSION=aciidriver
ENV DUFFLE_REPO=simongdavies/duffle

ENV DUFFLE_ACI_DRIVER_VERSION=v.0.0.1
ENV DUFFLE_ACI_DRIVER_REPO=simongdavies/duffle-aci-driver

ENV AZCOPY_URL=https://aka.ms/downloadazcopy-v10-linux
ENV AZCOPY_DOWNLOAD_DIR=/tmp
ENV AZCOPY_DIR=azcopy_linux_amd64_10.2.1

RUN apk add --update bash py-pip jq curl coreutils  && rm -rf /var/cache/apk/*
RUN apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python-dev make  
RUN pip --no-cache-dir install -U pip
RUN pip --no-cache-dir install azure-cli
RUN apk del --purge build
RUN apk add libc6-compat

RUN curl https://github.com/${ORAS_REPO}/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz -fLo "./${ORAS_DOWNLOAD_DIR}/oras_${ORAS_VERSION}_linux_amd64.tar.gz"
RUN tar -zxf "./${ORAS_DOWNLOAD_DIR}/oras_0.5.0_linux_amd64.tar.gz" -C .
RUN mv ./oras "${TOOLHOME}/oras"
RUN chmod +x "${TOOLHOME}/oras"

# Install duffle 

RUN curl "https://github.com/${DUFFLE_REPO}/releases/download/${DUFFLE_VERSION}/duffle-linux-amd64" -fLo "${TOOLHOME}/duffle"
RUN chmod +x "${TOOLHOME}/duffle"

# Install duffle aci driver

RUN curl "https://github.com/${DUFFLE_ACI_DRIVER_REPO}/releases/download/${DUFFLE_ACI_DRIVER_VERSION}/duffle-aci-driver-linux-amd64" -fLo "${TOOLHOME}/duffle-aci-driver"
RUN chmod +x "${TOOLHOME}/duffle-aci-driver"

# Install azcopy

RUN curl ${AZCOPY_URL} -fLo "./${AZCOPY_DOWNLOAD_DIR}/azcopy.tar.gz"
RUN tar -zxf ./${AZCOPY_DOWNLOAD_DIR}/azcopy.tar.gz -C .
RUN mv ./${AZCOPY_DIR}/azcopy "${TOOLHOME}/azcopy"
RUN chmod +x "${TOOLHOME}/azcopy"

COPY run-duffle.sh .
RUN chmod 755 run-duffle.sh

CMD ["/bin/bash","-c","./run-duffle.sh"]