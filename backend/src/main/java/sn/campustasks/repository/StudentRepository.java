package sn.campustasks.repository;
import sn.campustasks.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;
public interface StudentRepository extends JpaRepository<Student,Long> { java.util.Optional<Student> findByEmail(String email); }
