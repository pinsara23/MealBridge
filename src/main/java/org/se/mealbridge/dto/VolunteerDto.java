package org.se.mealbridge.dto;

import lombok.Data;

@Data
public class VolunteerDto {

    private Long id;

    private String presidentFullName;
    private String organizationName;
    private String email;
    private String phoneNumber;
    private String password;


    private String message = "Your organization is currently not verified our admin staff will contact you nearly";
}
