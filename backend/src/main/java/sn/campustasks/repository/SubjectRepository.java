package sn.campustasks.repository;
import sn.campustasks.model.Subject;
import org.springframework.data.jpa.repository.JpaRepository;
public interface SubjectRepository extends JpaRepository<Subject,Long> { java.util.List<Subject> findByOwnerIdOrderByNameAsc(Long owner);
java.util.Optional<Subject> findByIdAndOwnerId(Long id, Long owner); }
