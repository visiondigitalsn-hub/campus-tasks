package sn.campustasks.model;
import jakarta.persistence.*;
@Entity @Table(name="auth_tokens")
public class AuthToken {
@Id @GeneratedValue(strategy=GenerationType.IDENTITY) public Long id;
@ManyToOne(optional=false,fetch=FetchType.LAZY) @JoinColumn(name="owner_id") public Student owner;
@Column(nullable=false,unique=true,length=64) public String tokenHash;
@Column(nullable=false) public java.time.Instant expiresAt;
}
