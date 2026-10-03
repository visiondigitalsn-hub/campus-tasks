package sn.campustasks.model;
import jakarta.persistence.*;
@Entity @Table(name="subjects")
public class Subject {
@Id @GeneratedValue(strategy=GenerationType.IDENTITY) public Long id;
@ManyToOne(optional=false,fetch=FetchType.LAZY) @JoinColumn(name="owner_id") public Student owner;
@Column(nullable=false,length=100) public String name;
@Column(nullable=false,length=2000) public String description;
}
