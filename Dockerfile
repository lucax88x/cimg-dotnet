FROM cimg/base:2020.10-18.04
LABEL maintainer="Luca Trazzi <lucax88x@gmail.com>"

USER root

RUN apt-get update

# DOTNET dependencies
RUN apt-get install -y --no-install-recommends \
        libc6 \
        libgcc1 \
        libgssapi-krb5-2 \
        libicu60 \
        libssl1.1 \
        libstdc++6 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

# NODE dependencies
RUN apt-get install -y gnupg

ENV \
    # DOTNET_SDK_VERSION=3.1.403 \
    # DOTNET_SDK_SHA=0a0319ee8e9042bf04b6e83211c2d6e44e40e604bff0a133ba0d246d08bff76ebd88918ab5e10e6f7f0d2b504ddeb65c0108c6539bc4fbc4f09e4af3937e88ea
    DOTNET_SDK_VERSION=5.0.100-rc.2.20479.15 \
    DOTNET_SDK_SHA=e705043cdec53827695567eed021c76b100d77416f10cc18d4f5d02950f85bf9ccd7e2c22643f00a883e11b253fb8aa098e4dce008008a0796f913496f97e362

# https://nodejs.org/dist/$NODE_VERSION/SHASUMS256.txt.asc
ENV \
    NODE_VERSION=14.14.0 \
    NODE_DOWNLOAD_SHA=438cc26853b17f4aad79fb441f6dbcc1128aff9ffcd0c132ae044259f96ff6a8

ENV NODE_DOWNLOAD_URL https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.gz

ENV YARN_VERSION 1.22.10

ENV \
    # Unset ASPNETCORE_URLS from aspnet base image
    ASPNETCORE_URLS= \
    DOTNET_RUNNING_IN_CONTAINER=true \
    # Disable the invariant mode (set in base image)
    # DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=false \
    # Enable correct mode for dotnet watch (only mode supported in a container)
    DOTNET_USE_POLLING_FILE_WATCHER=true \
    # Skip extraction of XML docs - generally not useful within an image/container - helps performance
    NUGET_XMLDOC_MODE=skip


# Install .NET Core SDK
RUN curl -SL --output dotnet.tar.gz https://dotnetcli.azureedge.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-sdk-$DOTNET_SDK_VERSION-linux-x64.tar.gz \
    && echo "$DOTNET_SDK_SHA dotnet.tar.gz" | sha512sum -c - \
    && mkdir -p /usr/share/dotnet \
    && tar -ozxf dotnet.tar.gz -C /usr/share/dotnet \
    && rm dotnet.tar.gz \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Install Node
RUN curl -SL "$NODE_DOWNLOAD_URL" --output nodejs.tar.gz && \
    echo "$NODE_DOWNLOAD_SHA nodejs.tar.gz" | sha256sum -c - && \
    tar -xzf "nodejs.tar.gz" -C /usr/local --strip-components=1 && \
    rm nodejs.tar.gz && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs

# Install Yarn
RUN curl -L -o yarn.tar.gz "https://yarnpkg.com/downloads/${YARN_VERSION}/yarn-v${YARN_VERSION}.tar.gz" && \
    sudo tar -xzf yarn.tar.gz -C /opt/ && \
    rm yarn.tar.gz && \
    sudo ln -s /opt/yarn-v${YARN_VERSION}/bin/yarn /usr/local/bin/yarn && \
    sudo ln -s /opt/yarn-v${YARN_VERSION}/bin/yarnpkg /usr/local/bin/yarnpkg

USER circleci

RUN dotnet --version
RUN node --version
RUN yarn --version


