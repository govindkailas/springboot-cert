# we expect jave home to be set, in most of the cases it will be there by default
# Please set the env variable DOWNLOAD_URLS, eg: DOWNLOAD_URLS="spring.io" You can also have multiple urls added to DOWNLOAD_URLS seperated by space
# eg: DOWNLOAD_URLS="spring.io graph.microsoft.com login.microsoftonline.com" - in this case all the urls will be considered for fetching the certificate
# Note - Dont give https or any port number
for URL in $(echo ${DOWNLOAD_URLS})
    do
		echo "Fetching certificate from $URL"
		echo -n | openssl s_client -connect ${URL}:443 | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${JAVA_HOME}/jre/lib/security/${URL}.cert
		${JAVA_HOME}/bin/keytool -import -noprompt  -storepass changeit -alias ${URL} -keystore ${JAVA_HOME}/jre/lib/security/cacerts -file ${JAVA_HOME}/jre/lib/security/${URL}.cert
done
