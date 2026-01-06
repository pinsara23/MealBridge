package org.se.mealbridge.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "volunteer_details")
@Data
@AllArgsConstructor
@NoArgsConstructor
public class VolunteerEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String presidentFullName;
    private String organizationName;
    private String email;
    private String phoneNumber;
    private String password;
    private double creditScore = 0.0;

    private boolean isVerified = false;
}
