ARG BASE_IMAGE=ecapriolo/trusted-opencode:0.0.3-cloudops
FROM ${BASE_IMAGE}

ARG dusername
ARG duid
ARG dgid

USER root
RUN apk add --no-cache gcompat libc6-compat libstdc++ \
 && if getent group "${dgid}" >/dev/null; then dgroup="$(getent group "${dgid}" | cut -d: -f1)"; else addgroup -S -g "${dgid}" "${dusername}" && dgroup="${dusername}"; fi \
 && adduser -S -G "$dgroup" -h "/home/${dusername}" -D -u "${duid}" "${dusername}" \
 && echo "${dusername}:100000:65536" >> /etc/subuid \
 && echo "${dusername}:100000:65536" >> /etc/subgid

USER ${dusername}
WORKDIR /home/${dusername}
