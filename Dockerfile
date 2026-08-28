# Builder stage
FROM gradle:8-jdk as builder
WORKDIR /work
# Copy project; assume repo has Gradle build (gradlew or build.gradle(.kts))
COPY . /work
# Use Gradle wrapper if present, else default gradle
RUN if [ -f "./gradlew" ]; then ./gradlew --no-daemon clean build -x test; else gradle --no-daemon clean build -x test; fi

# Runtime stage
FROM eclipse-temurin:25-jre
WORKDIR /app
# Copy built jar (adjust path if project produces a different artifact)
# Try common Gradle output path
COPY --from=builder /work/build/libs/*.jar /app/proxy.jar
EXPOSE 25566
ENV TARGET_HOST=mc-server
ENV TARGET_PORT=25565
ENTRYPOINT ["java","-jar","/app/proxy.jar"]
