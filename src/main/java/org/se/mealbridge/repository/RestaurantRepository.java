package org.se.mealbridge.repository;

import org.se.mealbridge.entity.RestaurantEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RestaurantRepository extends JpaRepository<RestaurantEntity,Long> {

    @Query(value = "SELECT * FROM restaurant_details r " +
            "WHERE ST_DistanceSphere(r.location, ST_MakePoint(:longitude, :latitude)) <= :radiusInMeters",
            nativeQuery = true)
    List<RestaurantEntity> findRestaurantsWithinDistance(
            @Param("longitude") double longitude,
            @Param("latitude") double latitude,
            @Param("radiusInMeters") double radiusInMeters
    );

    // --- OPTION 2: Finding by Email (for Login) ---
    RestaurantEntity findByEmail(String email);
}
