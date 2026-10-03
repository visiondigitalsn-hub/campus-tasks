package sn.campustasks.repository;
import sn.campustasks.model.Task;
import org.springframework.data.jpa.repository.JpaRepository;
public interface TaskRepository extends JpaRepository<Task,Long> { java.util.List<Task> findByOwnerIdOrderByDueDateAscIdAsc(Long owner);
java.util.Optional<Task> findByIdAndOwnerId(Long id, Long owner);
boolean existsBySubjectId(Long subject); }
