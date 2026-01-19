package org.se.mealbridge.repository;

import org.se.mealbridge.entity.DonationEntity;
import org.se.mealbridge.entity.DonationStatus;
import org.se.mealbridge.entity.VolunteerEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
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

    Integer countByDonorIdAndPostedAtBetween(Long donorId,
                                             LocalDateTime postedAtAfter,
                                             LocalDateTime postedAtBefore);

    Integer countByDonorId(Long donorId);

    Integer countByDonorIdAndStatusIn(Long donorId, List<DonationStatus> statuses);

    Integer countByAssignedVolunteerIdAndStatusIn(Long id, List<DonationStatus> statuses);

    Integer countByAssignedVolunteerId(Long id);

    Integer countByAssignedVolunteerIdAndPostedAtBetween(Long volunteerId,
                                             LocalDateTime postedAtAfter,
                                             LocalDateTime postedAtBefore);

    List<DonationEntity> findTop50ByDonorId(Long donorId);

    List<DonationEntity> findByDonorId(Long donorId);

    @Query("SELECT SUM(d.quantityKg) FROM DonationEntity d")
    Double getTotalQuantity();

//    @Query("SELECT new org.se.mealbridge.dto.MonthlyStatsDto(FUNCTION('TO_CHAR', d.postedAt, 'Month'), SUM(d.quantityKg)) " +
//            "FROM DonationEntity d WHERE d.donor.id = :restaurantId " +
//            "GROUP BY FUNCTION('TO_CHAR', d.postedAt, 'Month')")
//    List<MonthlyStatsDto> getMonthlyStats(@Param("restaurantId") Long restaurantId);
}
