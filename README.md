# springboot-cert
Requirement - Your springboot microservice has integration with another service which is outside of your domain, in this situation java will throw an SSL Handshake error like this,

`Root exception is javax.net.ssl.SSLHandshakeException: sun.security.validator.ValidatorException: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target`

Solution - There are multiple ways to resolve this problem, I am going to explain a simple method which usually works. Now Java doesn't look into your system location `/etc/ssl/*` or `/etc/pki/*` for the certs. So `update-ca-certificates` may not the right approach for your java based application. By default java look for certificates at `${JAVA_HOME}/jre/lib/security`.

Below bash code snippet can be used to automate the task of fetching and importing the needed certificate.

```
DOWNLOAD_URLS="spring.io graph.microsoft.com login.microsoftonline.com" # You can have multiple urls here seperated by space
for URL in $(echo ${DOWNLOAD_URLS})
  do
      echo "Fetching certificate from $URL"
      echo -n | openssl s_client -connect ${URL}:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${JAVA_HOME}/jre/lib/security/${URL}.cert
      ${JAVA_HOME}/bin/keytool -import -noprompt  -storepass changeit -alias ${URL} -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${JAVA_HOME}/jre/lib/security/${URL}.cert
  done
```

Now you are good to start/run your java app. 

If you are on docker, you may consider building a docker image 

`#Dockerfile `
```
FROM openjdk:8-jdk-alpine
VOLUME /tmp
ARG JAR_FILE
COPY ${JAR_FILE} app.jar
ENV DOWNLOAD_URLS="spring.io"
RUN apk add --no-cache openssl \
    && wget -O - https://raw.githubusercontent.com/govindkailas/springboot-cert/master/add_certs_keytools.sh | sh

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-jar","/app.jar"] ```

