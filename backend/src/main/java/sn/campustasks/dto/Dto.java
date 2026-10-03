package sn.campustasks.dto;
import jakarta.validation.constraints.*;
import sn.campustasks.model.*;
import java.time.*;
import java.util.List;
public class Dto {
 public record Register(@NotBlank @Size(max=100) String name, @NotBlank @Email @Size(max=254) String email, @NotBlank @Size(min=8,max=72) String password) {}
 public record Login(@NotBlank @Email @Size(max=254) String email, @NotBlank @Size(max=72) String password) {}
 public record Session(String token, Instant expiresAt, String name) {}
 public record SubjectInput(@NotBlank @Size(max=100) String name, @NotNull @Size(max=2000) String description) {}
 public record SubjectView(Long id,String name,String description) {
  public static SubjectView of(Subject s) { return new SubjectView(s.id,s.name,s.description); }
 }
 public record TaskInput(@NotBlank @Size(max=150) String title, @NotNull @Size(max=4000) String description, @NotNull Long subjectId, @NotNull LocalDate dueDate, @NotNull Task.Priority priority, @NotNull Task.Status status) {}
 public record TaskView(Long id,String title,String description,Long subjectId,String subjectName,LocalDate dueDate,Task.Priority priority,Task.Status status,Instant createdAt) {
  public static TaskView of(Task t) { return new TaskView(t.id,t.title,t.description,t.subject.id,t.subject.name,t.dueDate,t.priority,t.status,t.createdAt); }
 }
 public record Dashboard(long todo,long inProgress,long done,long overdue,List<TaskView> upcoming,List<TaskView> late) {}
 public record Error(String message) {}
}
