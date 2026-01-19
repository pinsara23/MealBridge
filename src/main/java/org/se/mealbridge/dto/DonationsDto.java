package org.se.mealbridge.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class DonationsDto {

    private Long id;
    private String foodDescription;
    private double quantityKg;
    private String imageUrl;

    //Input
    private int hoursValid;

    //exact time
    private LocalDateTime mustPickupBy;
    private String status;

    //Linking
    private Long restaurantId;
    private String restaurantName;

    private String pickupToken;

}
