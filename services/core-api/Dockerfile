# ---- Build stage ----
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -B -q dependency:go-offline
COPY src ./src
RUN mvn -B -q package -DskipTests

# ---- Runtime stage: small JRE image, non-root user ----
FROM eclipse-temurin:21-jre
WORKDIR /app
RUN useradd --system --uid 1001 skinvidhi
COPY --from=build /app/target/core-api-*.jar app.jar
USER skinvidhi
EXPOSE 8080
ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75", "-jar", "app.jar"]
