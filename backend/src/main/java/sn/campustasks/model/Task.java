package sn.campustasks.model;
import jakarta.persistence.*;
@Entity @Table(name="tasks")
public class Task {
@Id @GeneratedValue(strategy=GenerationType.IDENTITY) public Long id;
@ManyToOne(optional=false,fetch=FetchType.LAZY) @JoinColumn(name="owner_id") public Student owner;
@ManyToOne(optional=false,fetch=FetchType.LAZY) @JoinColumn(name="subject_id") public Subject subject;
@Column(nullable=false,length=150) public String title;
@Column(nullable=false,length=4000) public String description;
@Column(nullable=false) public java.time.LocalDate dueDate;
@Enumerated(EnumType.STRING) @Column(nullable=false,length=10) public Priority priority;
@Enumerated(EnumType.STRING) @Column(nullable=false,length=15) public Status status;
@Column(nullable=false) public java.time.Instant createdAt;
public enum Priority { LOW, MEDIUM, HIGH }
public enum Status { TODO, IN_PROGRESS, DONE }
}
