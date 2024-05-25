FROM quay.io/fedora/httpd-24:20240515 AS upstream
FROM ghcr.io/radiorabe/ubi9-minimal:0.6.6 AS build

ENV APP_ROOT=/opt/app-root

ENV HTTPD_VERSION=2.4

RUN    mkdir -p /mnt/rootfs \
    && microdnf install -y \
       --releasever 9 \
       --installroot /mnt/rootfs \
       --nodocs \
       --noplugins \
       --config /etc/dnf/dnf.conf \
       --setopt install_weak_deps=0 \
       --setopt cachedir=/var/cache/dnf \
       --setopt reposdir=/etc/yum.repos.d \
       --setopt varsdir=/etc/yum.repos.d \
         coreutils-single \
         findutils \
         glibc-minimal-langpack \
         hostname \
         httpd-core \
         mod_ldap \
         mod_security \
         mod_session \
         mod_ssl \
         sscg \
         nss_wrapper-libs \
    && cp \
       /etc/pki/ca-trust/source/anchors/rabe-ca.crt \
       /mnt/rootfs/etc/pki/ca-trust/source/anchors/ \
    && update-ca-trust \
    && chmod a-s \
       /mnt/rootfs/usr/bin/* \
       /mnt/rootfs/usr/sbin/* \
       /mnt/rootfs/usr/libexec/*/* \
    && rm -rf \
       /mnt/rootfs/var/cache/* \
       /mnt/rootfs/var/log/dnf* \
       /mnt/rootfs/var/log/yum.*

FROM scratch as app

ENV PLATFORM=el9 \
    SUMMARY="Apache HTTPD Image for RaBe" \
    APP_ROOT=/opt/app-root \
    HOME=/opt/app-root/src \
    STI_SCRIPTS_PATH=/usr/libexec/s2i \
    STI_SCRIPTS_URL=image:///usr/libexec/s2i \
    HTTPD_VERSION=2.4 \
    HTTPD_CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/httpd/ \
    HTTPD_APP_ROOT=/opt/app-root \
    HTTPD_CONFIGURATION_PATH=/opt/app-root/etc/httpd.d \
    HTTPD_MAIN_CONF_PATH=/etc/httpd/conf \
    HTTPD_MAIN_CONF_MODULES_D_PATH=/etc/httpd/conf.modules.d \
    HTTPD_MAIN_CONF_D_PATH=/etc/httpd/conf.d \
    HTTPD_TLS_CERT_PATH=/etc/httpd/tls \
    HTTPD_VAR_RUN=/var/run/httpd \
    HTTPD_DATA_PATH=/var/www \
    HTTPD_DATA_ORIG_PATH=/var/www \
    HTTPD_LOG_PATH=/var/log/httpd

COPY --from=build /mnt/rootfs/ /
COPY --from=upstream ${STI_SCRIPTS_PATH} ${STI_SCRIPTS_PATH}
COPY --from=upstream ${HTTPD_CONTAINER_SCRIPTS_PATH} ${HTTPD_CONTAINER_SCRIPTS_PATH}
COPY --from=upstream ${APP_ROOT} ${APP_ROOT}
COPY --from=upstream /usr/bin/run-httpd /usr/bin/run-httpd
COPY --from=upstream /usr/libexec/httpd-prepare /usr/libexec/httpd-prepare

RUN    useradd -u 1001 -r -g 0 -d ${HOME} -c "Default Application User" default \
    && chown -R 1001:0 /etc/httpd/conf/ \
    && /usr/libexec/httpd-prepare

WORKDIR /opt/app-root/src

USER 1001

STOPSIGNAL SIGQUIT

CMD ["/usr/bin/run-httpd"]
