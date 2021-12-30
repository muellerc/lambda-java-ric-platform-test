FROM amazonlinux:2 AS packer

# Add the Amazon Corretto repository
RUN rpm --import https://yum.corretto.aws/corretto.key
RUN curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo

# Update the packages and install Amazon Corretto 17, Maven and Zip
RUN yum -y update \
    && yum install -y java-17-amazon-corretto-jmods maven zip


# Add the aws-lambda-java-runtime-interface-client-2.1.0.jar manually to the local Maven repo,
# as it is not available at Maven central.
COPY aws-lambda-java-runtime-interface-client-2.1.0.jar .
COPY aws-lambda-java-runtime-interface-client-2.1.0.pom .
RUN mvn install:install-file \
    -Dfile=aws-lambda-java-runtime-interface-client-2.1.0.jar \
    -DpomFile=aws-lambda-java-runtime-interface-client-2.1.0.pom


# Copy the software folder to the image and build the function
COPY software software
WORKDIR /software/example-function
RUN mvn clean package


# Package everything together into a custom runtime archive
WORKDIR /

RUN jlink --add-modules ALL-MODULE-PATH --verbose --compress 2 --strip-java-debug-attributes --no-header-files --no-man-pages --output /jre-17

COPY bootstrap .
RUN chmod 755 bootstrap
RUN cp /software/example-function/target/function.jar function.jar
RUN zip -r runtime.zip \
    bootstrap \
    function.jar \
    /jre-17