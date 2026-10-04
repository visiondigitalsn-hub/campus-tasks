package sn.campustasks.config;

import java.net.URI;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;

/** Convert Render's private Postgres URI to JDBC before datasource binding. */
public class RenderDatabaseEnvironment implements EnvironmentPostProcessor {
 @Override public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
  String raw = environment.getProperty("RENDER_DATABASE_URL");
  if (raw == null || raw.isBlank()) return;
  try {
   URI uri = URI.create(raw);
   if (!("postgresql".equals(uri.getScheme()) || "postgres".equals(uri.getScheme())) || uri.getHost() == null || uri.getRawUserInfo() == null || uri.getRawPath() == null || uri.getRawPath().length() < 2) throw new IllegalArgumentException();
   String[] credentials = uri.getRawUserInfo().split(":", 2);
   if (credentials.length != 2) throw new IllegalArgumentException();
   String host = uri.getHost();
   if (host.contains(":") && !host.startsWith("[")) host = "[" + host + "]";
   String jdbc = "jdbc:postgresql://" + host + ":" + (uri.getPort() < 0 ? 5432 : uri.getPort()) + uri.getRawPath();
   if (uri.getRawQuery() != null) jdbc += "?" + uri.getRawQuery();
   environment.getPropertySources().addFirst(new MapPropertySource("renderPostgres", Map.of(
    "spring.datasource.url", jdbc,
    "spring.datasource.username", decode(credentials[0]),
    "spring.datasource.password", decode(credentials[1]))));
  } catch (IllegalArgumentException exception) {
   throw new IllegalArgumentException("RENDER_DATABASE_URL must be a valid PostgreSQL connection URI.");
  }
 }
 private static String decode(String value) { return URLDecoder.decode(value.replace("+", "%2B"), StandardCharsets.UTF_8); }
}
