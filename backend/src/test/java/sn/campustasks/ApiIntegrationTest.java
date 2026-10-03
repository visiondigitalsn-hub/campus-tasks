package sn.campustasks;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;
import sn.campustasks.repository.*;
import sn.campustasks.service.AuthService;
import tools.jackson.databind.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;
import static org.junit.jupiter.api.Assertions.*;
@SpringBootTest @AutoConfigureMockMvc
class ApiIntegrationTest {
 @Autowired MockMvc mvc;
 @Autowired StudentRepository students;
 @Autowired AuthTokenRepository tokens;
 private final ObjectMapper json=new ObjectMapper();
 private int counter;
 private String register() throws Exception {
  String email="student"+java.util.UUID.randomUUID()+"@campus.sn";
  String response=mvc.perform(post("/api/v1/auth/register").contentType("application/json").content("{\"name\":\"Awa\",\"email\":\""+email+"\",\"password\":\"Campus123!\"}")) .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
  assertNotEquals("Campus123!",students.findByEmail(email).orElseThrow().passwordHash);
  return json.readTree(response).get("token").asText();
 }
 private long subject(String token) throws Exception {
  String response=mvc.perform(post("/api/v1/subjects").header("Authorization","Bearer "+token).contentType("application/json").content("{\"name\":\"Java\",\"description\":\"Cours\"}")) .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
  return json.readTree(response).get("id").asLong();
 }
 private String task(long subject,String date,String status) {
  return "{\"title\":\"Projet\",\"description\":\"Travail\",\"subjectId\":"+subject+",\"dueDate\":\""+date+"\",\"priority\":\"HIGH\",\"status\":\""+status+"\"}";
 }
 @Test void isolationAndRules() throws Exception {
  String a=register(),b=register();long sid=subject(a);
  String response=mvc.perform(post("/api/v1/tasks").header("Authorization","Bearer "+a).contentType("application/json").content(task(sid,"2020-01-01","TODO"))).andExpect(status().isCreated()).andExpect(jsonPath("$.createdAt").exists()).andReturn().getResponse().getContentAsString();
  long tid=json.readTree(response).get("id").asLong();
  mvc.perform(get("/api/v1/tasks").header("Authorization","Bearer "+b)).andExpect(status().isOk()).andExpect(content().json("[]"));
  mvc.perform(put("/api/v1/tasks/"+tid).header("Authorization","Bearer "+b).contentType("application/json").content(task(sid,"2027-01-01","DONE"))).andExpect(status().isNotFound());
  mvc.perform(delete("/api/v1/tasks/"+tid).header("Authorization","Bearer "+b)).andExpect(status().isNotFound());
  mvc.perform(post("/api/v1/tasks").header("Authorization","Bearer "+b).contentType("application/json").content(task(sid,"2027-01-01","TODO"))).andExpect(status().isNotFound());
  mvc.perform(put("/api/v1/subjects/"+sid).header("Authorization","Bearer "+b).contentType("application/json").content("{\"name\":\"Vol\",\"description\":\"\"}")).andExpect(status().isNotFound());
  mvc.perform(delete("/api/v1/subjects/"+sid).header("Authorization","Bearer "+b)).andExpect(status().isNotFound());
  mvc.perform(get("/api/v1/tasks?subjectId="+sid).header("Authorization","Bearer "+b)).andExpect(status().isNotFound());
  mvc.perform(delete("/api/v1/subjects/"+sid).header("Authorization","Bearer "+a)).andExpect(status().isConflict());
  mvc.perform(get("/api/v1/dashboard").header("Authorization","Bearer "+a)).andExpect(status().isOk()).andExpect(jsonPath("$.overdue").value(1)).andExpect(jsonPath("$.todo").value(1)).andExpect(jsonPath("$.late[0].subjectName").value("Java")).andExpect(jsonPath("$.late[0].subjectId").value(sid));
  mvc.perform(put("/api/v1/tasks/"+tid).header("Authorization","Bearer "+a).contentType("application/json").content(task(sid,"2020-01-01","DONE"))).andExpect(status().isOk());
  mvc.perform(get("/api/v1/dashboard").header("Authorization","Bearer "+a)).andExpect(jsonPath("$.overdue").value(0)).andExpect(jsonPath("$.done").value(1));
  mvc.perform(delete("/api/v1/tasks/"+tid).header("Authorization","Bearer "+a)).andExpect(status().isNoContent());
  mvc.perform(delete("/api/v1/subjects/"+sid).header("Authorization","Bearer "+a)).andExpect(status().isNoContent());
 }
 @Test void validationAuthenticationAndRevocation() throws Exception {
  mvc.perform(get("/api/v1/tasks")).andExpect(status().isUnauthorized());
  mvc.perform(post("/api/v1/auth/register").contentType("application/json").content("{\"name\":\"\",\"email\":\"bad\",\"password\":\"1\"}")).andExpect(status().isBadRequest()).andExpect(jsonPath("$.message").exists());
  String a=register();
  mvc.perform(post("/api/v1/subjects").header("Authorization","Bearer "+a).contentType("application/json").content("{\"name\":\" \" ,\"description\":\"\"}")).andExpect(status().isBadRequest());
  mvc.perform(get("/api/v1/tasks?status=INVALID").header("Authorization","Bearer "+a)).andExpect(status().isBadRequest());
  mvc.perform(post("/api/v1/auth/logout").header("Authorization","Bearer "+a)).andExpect(status().isNoContent());
  mvc.perform(get("/api/v1/subjects").header("Authorization","Bearer "+a)).andExpect(status().isUnauthorized());
  assertTrue(tokens.findByTokenHash(AuthService.hash(a)).isEmpty());
 }
 @Test void reconnectFilterAndSorting() throws Exception {
  String email="reconnect"+java.util.UUID.randomUUID()+"@campus.sn";
  String credentials="{\"email\":\""+email+"\",\"password\":\"Campus123!\"}";
  String raw=mvc.perform(post("/api/v1/auth/register").contentType("application/json").content("{\"name\":\"Awa\",\"email\":\""+email+"\",\"password\":\"Campus123!\"}")).andExpect(status().isCreated()).andReturn().getResponse().getContentAsString();
  String token=json.readTree(raw).get("token").asText();long sid=subject(token);
  mvc.perform(post("/api/v1/tasks").header("Authorization","Bearer "+token).contentType("application/json").content(task(sid,"2028-01-01","TODO"))).andExpect(status().isCreated());
  mvc.perform(post("/api/v1/tasks").header("Authorization","Bearer "+token).contentType("application/json").content(task(sid,"2027-01-01","IN_PROGRESS"))).andExpect(status().isCreated());
  mvc.perform(post("/api/v1/auth/logout").header("Authorization","Bearer "+token)).andExpect(status().isNoContent());
  raw=mvc.perform(post("/api/v1/auth/login").contentType("application/json").content(credentials)).andExpect(status().isOk()).andReturn().getResponse().getContentAsString();token=json.readTree(raw).get("token").asText();
  mvc.perform(get("/api/v1/tasks").header("Authorization","Bearer "+token)).andExpect(jsonPath("$[0].dueDate").value("2027-01-01")).andExpect(jsonPath("$[0].subjectName").value("Java")).andExpect(jsonPath("$[0].subjectId").value(sid));
  mvc.perform(get("/api/v1/tasks?subjectId="+sid+"&status=TODO&sort=desc").header("Authorization","Bearer "+token)).andExpect(jsonPath("$.length()").value(1)).andExpect(jsonPath("$[0].status").value("TODO"));
  mvc.perform(post("/api/v1/auth/login").contentType("application/json").content(credentials.replace("Campus123!","Wrong123!"))).andExpect(status().isUnauthorized());
 }
}
