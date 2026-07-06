package launcher;

import org.h2.tools.Server;
import org.h2.server.web.WebServer;

public class Launcher {
    public static void main(String[] args) throws Exception {
        String adminPassword = System.getenv("H2_ADMIN_PASSWORD");
        if (adminPassword == null || adminPassword.isEmpty()) {
            throw new IllegalStateException("Defina H2_ADMIN_PASSWORD no .env (mínimo 12 caracteres)");
        }
        String adminPasswordHash = WebServer.encodeAdminPassword(adminPassword);

        Server.createWebServer(
                "-web", "-webAllowOthers", "-webPort", "8082",
                "-webAdminPassword", adminPasswordHash,
                "-baseDir", "/data", "-ifNotExists"
        ).start();

        Server.createTcpServer(
                "-tcp", "-tcpAllowOthers", "-tcpPort", "9092",
                "-baseDir", "/data", "-ifNotExists"
        ).start();

        Thread.currentThread().join();
    }
}
