# Build stage
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /workspace

# Copy pom first for better layer caching
COPY pom.xml ./

# Pre-fetch dependencies
RUN mvn -q -DskipTests dependency:go-offline

# Copy sources and build
COPY src ./src
RUN mvn -q -DskipTests package

# Runtime stage
FROM eclipse-temurin:21-jre
WORKDIR /app

# Create non-root user (Debian-based image)
RUN groupadd -g 1001 appuser && useradd -r -u 1001 -g appuser appuser

# --- FIX START ---
# Create the uploads directory and give ownership to appuser
RUN mkdir -p /app/uploads && chown -R appuser:appuser /app/uploads
# --- FIX END ---

USER appuser

COPY --from=build /workspace/target/*.jar /app/app.jar

EXPOSE 8080

ENV JAVA_OPTS=""

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar /app/app.jar"]