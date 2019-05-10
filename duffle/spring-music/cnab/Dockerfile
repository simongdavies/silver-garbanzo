FROM debian:stretch

ENV HELM_LATEST_VERSION="v2.12.3"

# install helm, kubectl, azure-cli
RUN apt-get update -y \
    && apt-get install curl apt-transport-https lsb-release gnupg -y \
    && curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null \
    && AZ_REPO=$(lsb_release -cs) && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update && apt-get install azure-cli \
    && apt-get update && apt-get install -y apt-transport-https \
    && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y kubectl \
    && curl -LO https://git.io/get_helm.sh \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh

COPY app/ /cnab/app/
COPY Dockerfile cnab/Dockerfile

CMD [ "/cnab/app/run" ]
