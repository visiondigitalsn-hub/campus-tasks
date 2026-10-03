package sn.campustasks.service;
import sn.campustasks.dto.Dto.*;
import sn.campustasks.model.*;
import sn.campustasks.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.http.HttpStatus;
import java.time.*;
import java.util.*;
@Service @Transactional
public class PlannerService {
 private final SubjectRepository subjects;private final TaskRepository tasks;private final StudentRepository students;
 public PlannerService(SubjectRepository s,TaskRepository t,StudentRepository u) { subjects=s;tasks=t;students=u; }
 private BusinessException missing() { return new BusinessException(HttpStatus.NOT_FOUND,"Élément introuvable."); }
 private Subject subject(Long owner,Long id) { return subjects.findByIdAndOwnerId(id,owner).orElseThrow(this::missing); }
 private Task task(Long owner,Long id) { return tasks.findByIdAndOwnerId(id,owner).orElseThrow(this::missing); }
 @Transactional(readOnly=true) public List<SubjectView> subjects(Long owner) { return subjects.findByOwnerIdOrderByNameAsc(owner).stream().map(SubjectView::of).toList(); }
 public SubjectView saveSubject(Long owner,Long id,SubjectInput input) {
  Subject s=id==null?new Subject():subject(owner,id);s.owner=students.getReferenceById(owner);s.name=input.name().strip();s.description=input.description().strip();return SubjectView.of(subjects.save(s));
 }
 public void deleteSubject(Long owner,Long id) {
  Subject s=subject(owner,id);
  if(tasks.existsBySubjectId(id)) throw new BusinessException(HttpStatus.CONFLICT,"Supprimez les tâches de cette matière avant de la supprimer.");
  subjects.delete(s);
 }
 @Transactional(readOnly=true) public List<TaskView> tasks(Long owner,Long subjectId,Task.Status status,boolean descending) {
  if(subjectId!=null) subject(owner,subjectId);
  List<TaskView> result=new ArrayList<>(tasks.findByOwnerIdOrderByDueDateAscIdAsc(owner).stream().filter(t->subjectId==null||t.subject.id.equals(subjectId)).filter(t->status==null||t.status==status).map(TaskView::of).toList());
  if(descending) Collections.reverse(result);return result;
 }
 public TaskView saveTask(Long owner,Long id,TaskInput input) {
  Task t=id==null?new Task():task(owner,id);
  t.subject=subject(owner,input.subjectId());t.owner=students.getReferenceById(owner);
  t.title=input.title().strip();t.description=input.description().strip();t.dueDate=input.dueDate();t.priority=input.priority();t.status=input.status();
  if(id==null) t.createdAt=Instant.now();return TaskView.of(tasks.save(t));
 }
 public void deleteTask(Long owner,Long id) { tasks.delete(task(owner,id)); }
 @Transactional(readOnly=true) public Dashboard dashboard(Long owner) {
  List<TaskView> all=tasks(owner,null,null,false);LocalDate today=LocalDate.now(ZoneOffset.UTC);
  List<TaskView> late=all.stream().filter(t->t.status()!=Task.Status.DONE&&t.dueDate().isBefore(today)).toList();
  List<TaskView> upcoming=all.stream().filter(t->t.status()!=Task.Status.DONE&&!t.dueDate().isBefore(today)).limit(5).toList();
  return new Dashboard(all.stream().filter(t->t.status()==Task.Status.TODO).count(),all.stream().filter(t->t.status()==Task.Status.IN_PROGRESS).count(),all.stream().filter(t->t.status()==Task.Status.DONE).count(),late.size(),upcoming,late);
 }
}
