package org.se.mealbridge.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.LocalTime;

@Data
public class RestaurantDTO {

    private Long id;

    @NotBlank(message = "Business name is required")
    private String businessName;

    @Email(message = "Email should be valid")
    @NotBlank(message = "Email is required")
    private String email;

    @NotBlank(message = "Phone number is required")
    private String phoneNumber;

    @NotBlank(message = "Password is required")
    private String password;

    private LocalTime openTime;
    private LocalTime closeTime;

    private double latitude;
    private double longitude;


}
