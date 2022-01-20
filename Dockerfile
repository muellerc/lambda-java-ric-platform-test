FROM amazonlinux:2 AS packer

# Add the Amazon Corretto repository
RUN rpm --import https://yum.corretto.aws/corretto.key
RUN curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo

# Update the packages and install Amazon Corretto 17, Maven and Zip
RUN yum -y update \
    && yum install -y java-17-amazon-corretto-jmods maven zip


# Copy the software folder to the image and build the function
COPY software software
WORKDIR /software/example-function
RUN mvn clean package


WORKDIR /

# Create a Java 17 JRE which contains all modules
RUN jlink --add-modules ALL-MODULE-PATH \
    --verbose \
    --compress 2 \
    --strip-java-debug-attributes \
    --no-header-files \
    --no-man-pages \
    --output /jre-17

# Use Javas Application Class Data Sharing feature to precompile JDK and our function.jar file
# it creates the file /jre-17/lib/server/classes.jsa
RUN /jre-17/bin/java -Xshare:dump \
    -Xbootclasspath/a:/software/example-function/target/function.jar \
    -version

# Package everything together into a custom runtime archive
COPY bootstrap .
RUN chmod 755 bootstrap
RUN cp /software/example-function/target/function.jar function.jar
RUN zip -r runtime.zip \
    bootstrap \
    function.jar \
    /jre-17
