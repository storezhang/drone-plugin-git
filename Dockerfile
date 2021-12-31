FROM storezhang/alpine AS builder


# 标签修改程序版本
ENV FAST_GITHUB_VERSION 2.1.2


RUN apk add unzip
RUN wget https://download.fastgit.org/dotnetcore/FastGithub/releases/download/${FAST_GITHUB_VERSION}/fastgithub_linux-x64.zip --output-document /fastgithub_linux-x64.zip
RUN unzip fastgithub_linux-x64.zip
RUN mv /fastgithub_linux-x64 /opt/fastgithub
RUN chmod +x /opt/fastgithub/fastgithub



# 打包真正的镜像
FROM storezhang/alpine


MAINTAINER storezhang "storezhang@gmail.com"
LABEL architecture="AMD64/x86_64" version="latest" build="2021-12-31"
LABEL Description="Drone持续集成Git插件，增加标签功能以及Github加速功能。同时支持推拉模式"


# 复制文件
COPY --from=builder /opt/fastgithub /opt/fastgithub
COPY docker /
COPY git /bin


RUN set -ex \
    \
    \
    \
    && apk update \
    \
    # 安装FastGithub依赖库 \
    && apk --no-cache add libgcc libstdc++ gcompat icu \
    \
    # 安装Git工具
    && apk --no-cache add git openssh-client \
    \
    \
    \
    # 增加执行权限
    && chmod +x /bin/git \
    # 增加执行权限，防止出现因为无执行权限导致在Docker内部无法运行的问题
    && chmod +x /etc/s6/fastgithub/* \
    \
    \
    \
    && rm -rf /var/cache/apk/*



# 执行命令
ENTRYPOINT /bin/git


# 配置环境变量
ENV GOPROXY https://goproxy.io,direct
