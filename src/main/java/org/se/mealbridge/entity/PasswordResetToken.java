package org.se.mealbridge.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
public class PasswordResetToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String token;

    private LocalDateTime expiryDate;

    @OneToOne(targetEntity = RestaurantEntity.class, fetch = FetchType.EAGER)
    @JoinColumn(nullable = false, name = "restaurant_id")
    private RestaurantEntity restaurant;

    public PasswordResetToken(String token, RestaurantEntity restaurantEntity) {

        this.token = token;
        this.restaurant = restaurantEntity;
        this.expiryDate = LocalDateTime.now().plusMinutes(15); // Token valid for 15 minutes
    }

    public boolean isExpired() {
        return LocalDateTime.now().isAfter(this.expiryDate);
    }
}
