FROM eclipse-temurin:21-jdk-alpine AS build

# Última versão estável em repo1.maven.org (verificada em jul/2026 via maven-metadata.xml)
ARG H2_VERSION=2.4.240
ARG H2_SHA256=29b70e427cc1c40cdc376283adbb0cc62853073797bb5fe5761f81fe73d57ce0

RUN wget -qO /opt/h2.jar "https://repo1.maven.org/maven2/com/h2database/h2/${H2_VERSION}/h2-${H2_VERSION}.jar" \
 && echo "${H2_SHA256}  /opt/h2.jar" | sha256sum -c -

# -webAdminPassword só pode ser usada via API Java, o H2 recusa essa flag na linha de comando
# (org.h2.tools.Server -help / verifyArgs lança "Unsupported option" para chamadas via CLI).
# Por isso compilamos um launcher que sobe os servidores programaticamente.
COPY src/launcher/Launcher.java /opt/src/launcher/Launcher.java
RUN javac -cp /opt/h2.jar -d /opt/classes /opt/src/launcher/Launcher.java

FROM eclipse-temurin:21-jre-alpine

COPY --from=build /opt/h2.jar /opt/h2.jar
COPY --from=build /opt/classes /opt/classes

VOLUME /data
EXPOSE 8082 9092

ENTRYPOINT ["java", "-cp", "/opt/h2.jar:/opt/classes", "launcher.Launcher"]
