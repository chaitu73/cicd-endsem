# Stage 1: build with Maven + JDK 21
FROM maven:3.9.5-eclipse-temurin-21 AS build
WORKDIR /app

# Copy only what's needed for dependency resolution first (speeds up rebuilds)
COPY pom.xml .
RUN mvn -B -f pom.xml dependency:go-offline

# Copy source and build
COPY src ./src
RUN mvn -B -f pom.xml clean package -DskipTests

# Stage 2: runtime with JRE 21
FROM eclipse-temurin:21-jre
WORKDIR /app

# Copy the jar from build stage (adjust path to your artifact)
COPY --from=build /app/target/*.jar /app/app.jar

# If your app expects environment vars or specific port, adapt here:
EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
