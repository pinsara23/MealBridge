package org.se.mealbridge.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "admin_details")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AdminEntity {

    @Id
    @GeneratedValue(strategy =  GenerationType.IDENTITY)
    private Long id;

    private String userName;
    private String password;
    private String role = "staff";
}
