docker run -e JAVA_HOME=/usr
-v type=cache,src=<volume-name>,dst=<container-path>
-it --entrypoint /bin/bash hadoop-build
