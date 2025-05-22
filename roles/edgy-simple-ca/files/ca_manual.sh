openssl genrsa -des3 -out myCA.key -passout pass:itssecret 2048
openssl req -x509 -new -nodes -passin pass:itssecret -key myCA.key -sha256 -days 1825 -out myCA.pem -subj "/C=US/ST=New York/L=New York/O=arizone cert/OU=arizona unit/CN=teknek.io"
openssl x509 -outform der -in myCA.pem -out myCA.crt
keytool -import -alias myCA -file myCA.crt -keystore myTruststore.jks -deststoretype jks -storepass itssecret -noprompt

openssl ecparam -name prime256v1 -genkey -noout -out fedora.key
openssl req -new -sha256 -key fedora.key -out fedora.csr -subj "/C=US/ST=New York/L=New York/O=arizone cert/OU=arizona unit/CN=fedora"
openssl x509 -req -in fedora.csr -CA myCA.crt -CAkey myCA.key -passin pass:itssecret -CAcreateserial -out fedora.crt -days 1000 -sha256
openssl pkcs12 -export -in fedora.crt -inkey fedora.key -out fedora.p12 -passout pass:ssshhh
keytool -importkeystore -srckeystore fedora.p12 -srcstoretype PKCS12 -destkeystore fedora.jks -deststoretype JKS -storepass ssshhh
keytool -importkeystore -srckeystore fedora.p12 -srcstoretype PKCS12 -destkeystore fedora.jks -deststoretype JKS -deststorepass ssshhh -srcstorepass ssshhh

