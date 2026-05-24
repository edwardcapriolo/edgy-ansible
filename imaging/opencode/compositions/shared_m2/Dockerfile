FROM ecapriolo/trusted-opencode-devel:0.0.1

ARG dusername
ARG duid
USER root
RUN apk add --no-cache gcompat libstdc++
RUN addgroup -S ${dusername} && adduser -S -G ${dusername} -h /home/${dusername} -D ${dusername} -u ${duid}
USER ${dusername}
WORKDIR /home/${dusername}
