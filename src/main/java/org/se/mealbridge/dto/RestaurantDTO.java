package org.se.mealbridge.dto;

import lombok.Data;

import java.time.LocalTime;

@Data
public class RestaurantDTO {

    private Long id;
    private String businessName;
    private String email;
    private String phoneNumber;
    private String password;

    private LocalTime openTime;
    private LocalTime closeTime;

    private double latitude;
    private double longitude;


}
