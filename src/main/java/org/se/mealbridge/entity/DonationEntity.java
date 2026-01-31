package org.se.mealbridge.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "donations")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DonationEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String foodDescription;

    private double quantityKg;

    private String imageUrl;

    //Timing
    private LocalDateTime postedAt;
    private LocalDateTime mustPickupBy;
    private LocalDateTime claimedAt;


    //For QR code
    private String pickupToken;

    //State
    @Enumerated(EnumType.STRING)
    private DonationStatus status;

    //Relationships
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "restaurant_details_id", nullable = false)
    private RestaurantEntity donor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "volunteer_details_id")
    private VolunteerEntity assignedVolunteer;

}
