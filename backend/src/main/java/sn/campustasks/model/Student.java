package sn.campustasks.model;
import jakarta.persistence.*;
@Entity @Table(name="students")
public class Student {
@Id @GeneratedValue(strategy=GenerationType.IDENTITY) public Long id;
@Column(nullable=false,length=100) public String name;
@Column(nullable=false,unique=true,length=254) public String email;
@Column(nullable=false,length=100) public String passwordHash;
}
