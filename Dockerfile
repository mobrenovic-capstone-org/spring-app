FROM gradle:8.13-jdk17-focal AS build

RUN mkdir /project
# COPY . /project
# WORKDIR /project
# RUN gradle clean build -x test
COPY /build/libs/spring-petclinic-3.4.0.jar /project/java-application.jar
COPY jmx_prometheus_javaagent-1.2.0.jar /project/jmx_prometheus_javaagent-1.2.0.jar
COPY config.yaml /project/config.yaml

FROM eclipse-temurin:17.0.14_7-jre-ubi9-minimal
EXPOSE 8000
EXPOSE 8080
RUN mkdir /application
COPY --from=build /project/java-application.jar /application/java-application.jar
COPY --from=build /project/jmx_prometheus_javaagent-1.2.0.jar /application/jmx_prometheus_javaagent-1.2.0.jar
COPY --from=build /project/config.yaml /application/config.yaml

WORKDIR /application
CMD [ "java", "-javaagent:jmx_prometheus_javaagent-1.2.0.jar=8000:config.yaml", "-jar", "java-application.jar"]
