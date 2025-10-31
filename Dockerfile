# ----------------------------------------------------------------------
# STAGE 1: BUILD PHASE (Builds ALL modules once)
# ----------------------------------------------------------------------
FROM maven:3.8.3-openjdk-17 AS build
WORKDIR /app
COPY . /app
# This one command builds the JARs for ALL submodules: auth-service, employee-service, ride-service, etc.
RUN mvn clean install -DskipTests

# ----------------------------------------------------------------------
# STAGE 2: PACKAGE/RUN PHASE (Creates unique image based on ARG)
# ----------------------------------------------------------------------
# ➡️ Declare the argument that RENDER will set to select the module
ARG MODULE_NAME

# Use a minimal JRE image for a small, secure final container
FROM eclipse-temurin:17-jre-alpine

# The copy path now uses the dynamic MODULE_NAME argument.
# 🚨 This is the CORRECT path for a multi-module Maven project.
COPY --from=build /app/${MODULE_NAME}/target/${MODULE_NAME}-1.0-SNAPSHOT.jar app.jar

ENV PORT 8080
EXPOSE 8080

# The command to execute the application
ENTRYPOINT ["java", "-jar", "/app.jar"]