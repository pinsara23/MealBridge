package org.se.mealbridge.entity;

import jakarta.persistence.*;
import lombok.*;
import org.locationtech.jts.geom.Point;


import java.time.LocalTime;

@Entity
@Table(name = "restaurant_details")
@Getter @Setter @ToString
@NoArgsConstructor
@AllArgsConstructor
public class RestaurantEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String businessName;
    private String email;
    private String phoneNumber;
    private String password;
    private LocalTime openTime;
    private LocalTime closeTime;

    //this field for measure carbon footprint
    private double socialCreditScore = 0.0;

    // --- GEOLOCATION FIELD ---
    // SRID 4326 is the standard for GPS (Latitude/Longitude) on Earth
    @Column(columnDefinition = "geometry(Point, 4326)")
    private Point location;

    // Helper method to update location easily from Lat/Lon doubles
    // (This is helpful when receiving JSON from Frontend)
    /* Note: In your Service layer, you will use GeometryFactory to create the Point
       before setting it here.
    */

}
