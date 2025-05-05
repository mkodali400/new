FROM openjdk:17
LABEL maintainer = "Mahesh <kodalimahesh@outlook.com>"
LABEL version = "1"
CMD mkdir -p /opt/eureka
WORKDIR /opt/eureka
COPY /target/i27-eureka-0.0.1-SNAPSHOT.jar /opt/eureka/
CMD chmod -R 777 /opt/eureka
CMD ["java", "-jar", "i27-eureka-0.0.1-SNAPSHOT.jar"]
EXPOSE 8761