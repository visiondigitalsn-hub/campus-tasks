package sn.campustasks.controller;
import sn.campustasks.dto.Dto.*;
import sn.campustasks.model.Task;
import sn.campustasks.service.*;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.http.HttpStatus;
import java.util.*;
@RestController @RequestMapping("/api/v1")
public class ApiController {
 private final AuthService auth;private final PlannerService planner;
 public ApiController(AuthService a,PlannerService p) { auth=a;planner=p; }
 private Long owner(Authentication a) { return (Long)a.getPrincipal(); }
 @GetMapping("/health") public Map<String,String> health() { return Map.of("status","UP","version","1.0.0"); }
 @PostMapping("/auth/register") @ResponseStatus(HttpStatus.CREATED) public Session register(@Valid @RequestBody Register in) { return auth.register(in); }
 @PostMapping("/auth/login") public Session login(@Valid @RequestBody Login in) { return auth.login(in); }
 @PostMapping("/auth/logout") @ResponseStatus(HttpStatus.NO_CONTENT) public void logout(@RequestHeader("Authorization") String header) { auth.logout(header.substring(7)); }
 @GetMapping("/subjects") public List<SubjectView> subjects(Authentication a) { return planner.subjects(owner(a)); }
 @PostMapping("/subjects") @ResponseStatus(HttpStatus.CREATED) public SubjectView addSubject(Authentication a,@Valid @RequestBody SubjectInput in) { return planner.saveSubject(owner(a),null,in); }
 @PutMapping("/subjects/{id}") public SubjectView editSubject(Authentication a,@PathVariable Long id,@Valid @RequestBody SubjectInput in) { return planner.saveSubject(owner(a),id,in); }
 @DeleteMapping("/subjects/{id}") @ResponseStatus(HttpStatus.NO_CONTENT) public void deleteSubject(Authentication a,@PathVariable Long id) { planner.deleteSubject(owner(a),id); }
 @GetMapping("/tasks") public List<TaskView> tasks(Authentication a,@RequestParam(required=false) Long subjectId,@RequestParam(required=false) Task.Status status,@RequestParam(defaultValue="asc") String sort) {
  if(!Set.of("asc","desc").contains(sort)) throw new BusinessException(HttpStatus.BAD_REQUEST,"Le tri doit être asc ou desc.");
  return planner.tasks(owner(a),subjectId,status,sort.equals("desc"));
 }
 @PostMapping("/tasks") @ResponseStatus(HttpStatus.CREATED) public TaskView addTask(Authentication a,@Valid @RequestBody TaskInput in) { return planner.saveTask(owner(a),null,in); }
 @PutMapping("/tasks/{id}") public TaskView editTask(Authentication a,@PathVariable Long id,@Valid @RequestBody TaskInput in) { return planner.saveTask(owner(a),id,in); }
 @DeleteMapping("/tasks/{id}") @ResponseStatus(HttpStatus.NO_CONTENT) public void deleteTask(Authentication a,@PathVariable Long id) { planner.deleteTask(owner(a),id); }
 @GetMapping("/dashboard") public Dashboard dashboard(Authentication a) { return planner.dashboard(owner(a)); }
}
