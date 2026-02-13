package org.se.mealbridge.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class VolunteerDto {

    private Long id;

    private String presidentFullName;

    @NotBlank(message = "Organization name is required")
    private String organizationName;

    @Email(message = "Email should be valid")
    @NotBlank(message = "Email is required")
    private String email;

    @NotBlank(message = "Phone number is required")
    private String phoneNumber;

    @NotBlank(message = "Password is required")
    private String password;


    private String message = "Your organization is currently not verified our admin staff will contact you nearly";
}
