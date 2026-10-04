package sn.campustasks;
import org.junit.jupiter.api.Test;
import org.springframework.mock.env.MockEnvironment;
import sn.campustasks.config.RenderDatabaseEnvironment;
import static org.junit.jupiter.api.Assertions.*;

class RenderDatabaseEnvironmentTest {
 @Test void convertsRenderUriWithoutLosingEncodedCredentials() {
  MockEnvironment env = new MockEnvironment().withProperty("RENDER_DATABASE_URL", "postgresql://student:p%40ss+word@internal-db:5432/campustasks?sslmode=require");
  new RenderDatabaseEnvironment().postProcessEnvironment(env, null);
  assertEquals("jdbc:postgresql://internal-db:5432/campustasks?sslmode=require", env.getProperty("spring.datasource.url"));
  assertEquals("student", env.getProperty("spring.datasource.username"));
  assertEquals("p@ss+word", env.getProperty("spring.datasource.password"));
 }
 @Test void leavesLocalConfigurationAloneAndDoesNotLeakInvalidUri() {
  MockEnvironment env = new MockEnvironment().withProperty("spring.datasource.url", "jdbc:postgresql://localhost/test");
  new RenderDatabaseEnvironment().postProcessEnvironment(env, null);
  assertEquals("jdbc:postgresql://localhost/test", env.getProperty("spring.datasource.url"));
  env.setProperty("RENDER_DATABASE_URL", "postgresql://secret-value@wrong");
  IllegalArgumentException error = assertThrows(IllegalArgumentException.class, () -> new RenderDatabaseEnvironment().postProcessEnvironment(env, null));
  assertFalse(error.getMessage().contains("secret-value"));
 }
}
