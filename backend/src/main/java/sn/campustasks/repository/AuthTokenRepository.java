package sn.campustasks.repository;
import sn.campustasks.model.AuthToken;
import org.springframework.data.jpa.repository.JpaRepository;
public interface AuthTokenRepository extends JpaRepository<AuthToken,Long> { @org.springframework.data.jpa.repository.EntityGraph(attributePaths="owner")
java.util.Optional<AuthToken> findByTokenHash(String hash); }
