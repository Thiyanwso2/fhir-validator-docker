# This line tells Docker to base an image on a pre-built image with Alpine Linux. You can use other images from OpenJDK
# registry. Alpine Linux benefit is that the image is pretty small. We also select JRE-only image since we don't need
# to compile code on the image, only run precompiled classes.

# If for some reason you wish to use the full JDK, the following line can be used
FROM adoptopenjdk/openjdk11:alpine

RUN apk add --update wget

ARG PROJECT_VERSION=1.0.38-SNAPSHOT
RUN echo "Project version set to -> ${PROJECT_VERSION}"

ENV APPLICATION_USER ktor
ARG UID=10001
# ARG GID=1000

# RUN groupadd -g $GID -o $UNAME
# RUN useradd -m -u $UID -o -s /bin/bash $APPLICATION_USER
RUN adduser -D -g '' --uid $UID $APPLICATION_USER

RUN mkdir /app
RUN chown -R $APPLICATION_USER /app

USER $APPLICATION_USER

# These lines download and copy the packaged application into the Docker image and sets the working directory to where it was copied.
RUN wget https://github.com/Thiyanwso2/org.hl7.fhir.validator-wrapper/releases/download/v1.0.0/validator-wrapper-jvm-1.0.38-SNAPSHOT.jar -P  /app \
    && cp /app/validator-wrapper-jvm-${PROJECT_VERSION}.jar /app/validator-wrapper.jar

WORKDIR /app

# Environment vars here
ENV ENVIRONMENT prod

EXPOSE 3500

# The last line instructs Docker to run java with G10s GC,  assigns 79% of the system's available memory, and indicates the packaged application.
CMD ["java", "-server", "-XX:+UnlockExperimentalVMOptions", "-XX:InitialRAMPercentage=79", "-XX:MinRAMPercentage=79", "-XX:MaxRAMPercentage=79", "-XX:+UseG1GC", "-XX:MaxGCPauseMillis=100", "-XX:+UseStringDeduplication", "-XX:+CrashOnOutOfMemoryError", "-jar", "validator-wrapper.jar", "-startServer"]
