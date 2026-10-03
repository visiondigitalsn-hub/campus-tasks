FROM maven:3.9.11-eclipse-temurin-21 AS build
WORKDIR /build
COPY pom.xml .
RUN mvn -B dependency:go-offline
COPY src src
RUN mvn -B package -DskipTests
FROM eclipse-temurin:21-jre-alpine
RUN addgroup -S campus && adduser -S campus -G campus
WORKDIR /app
COPY --from=build --chown=campus:campus /build/target/*.jar app.jar
USER campus
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
