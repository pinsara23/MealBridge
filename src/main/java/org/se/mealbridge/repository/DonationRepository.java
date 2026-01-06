package org.se.mealbridge.repository;

import org.se.mealbridge.entity.DonationEntity;
import org.se.mealbridge.entity.DonationStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;

public interface DonationRepository extends JpaRepository<DonationEntity, Long> {

    //find by active status
    List<DonationEntity> findByStatus(DonationStatus status);

    //Find by restaurant id
    List<DonationEntity> findByDonorId(Long restaurantId);

    //find all donation  where Status is available and mustpickedup time is before now
    List<DonationEntity> findByStatusAndMustPickupByBefore(DonationStatus status, LocalDateTime now);
}
