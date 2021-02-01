ARG DEX_IMAGE
FROM ${DEX_IMAGE} as DEX

FROM registry.access.redhat.com/ubi8/ubi-minimal:8.1
# Dex connectors, such as GitHub and Google logins require root certificates.
# Proper installations should manage those certificates, but it's a bad user
# experience when this doesn't work out of the box.
#
# OpenSSL is required so wget can query HTTPS endpoints for health checking.
RUN microdnf update -y && \
    microdnf install -y openssl

RUN rpm -Uvh https://www.rpmfind.net/linux/openmandriva/cooker/repository/x86_64/main/release/cross-x86_64-openmandriva-linux-musl-musl-1.2.1-1-omv4002.x86_64.rpm

USER 1001:1001
COPY --from=DEX /usr/local/bin/dex /usr/local/bin/dex

COPY LICENSE /licenses/

LABEL release="${DEX_IMAGE}" \
    name="dex" \
    vendor="dexidp" \
    version="${DEX_IMAGE}" \
    summary="dex identity provider" \
    description="dex identity provider"

# Import frontend assets and set the correct CWD directory so the assets
# are in the default path.
COPY --from=DEX /web /web
WORKDIR /

ENTRYPOINT ["dex"]

CMD ["version"]
