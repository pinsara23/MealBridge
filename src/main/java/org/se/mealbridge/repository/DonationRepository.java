package org.se.mealbridge.repository;

import org.se.mealbridge.entity.DonationEntity;
import org.se.mealbridge.entity.DonationStatus;
import org.se.mealbridge.entity.VolunteerEntity;
import org.springframework.data.domain.Limit;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface DonationRepository extends JpaRepository<DonationEntity, Long> {

    //find by active status
    List<DonationEntity> findByStatus(DonationStatus status);

    //Find by restaurant id
    List<DonationEntity> findByDonorIdAndStatusNotIn(Long restaurantId, List<DonationStatus> donationStatuses);

    List<DonationEntity> findByAssignedVolunteerAndStatusNotIn(VolunteerEntity assignedVolunteer, List<DonationStatus> donationStatuses);

    List<DonationEntity> findByDonorIdAndStatusIn(Long id, List<DonationStatus> donationStatuses);

    //find all donation  where Status is available and must pickedup time is before now
    List<DonationEntity> findByStatusAndMustPickupByBefore(DonationStatus status, LocalDateTime now);

    //find donation by pickup token
    Optional<DonationEntity> findByPickupToken(String pickupToken);

    List<DonationEntity> findByDonorIdAndStatusAndPostedAtBetween(
            Long donorId,
            DonationStatus status,
            LocalDateTime start,
            LocalDateTime end
    );

    Integer countByDonorIdAndStatusAndPostedAtBetween(Long donorId,
                                                      DonationStatus status,
                                                      LocalDateTime postedAtAfter,
                                                      LocalDateTime postedAtBefore);

    Integer countByDonorId(Long donorId);

    Integer countByDonorIdAndStatusIn(Long donorId, List<DonationStatus> statuses);

//    @Query("SELECT new org.se.mealbridge.dto.MonthlyStatsDto(FUNCTION('TO_CHAR', d.postedAt, 'Month'), SUM(d.quantityKg)) " +
//            "FROM DonationEntity d WHERE d.donor.id = :restaurantId " +
//            "GROUP BY FUNCTION('TO_CHAR', d.postedAt, 'Month')")
//    List<MonthlyStatsDto> getMonthlyStats(@Param("restaurantId") Long restaurantId);
}
