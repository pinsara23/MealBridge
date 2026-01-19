package org.se.mealbridge.repository;

import org.se.mealbridge.entity.VolunteerEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface VolunteerRepository extends JpaRepository<VolunteerEntity, Long> {

    Optional<VolunteerEntity> findByEmail(String email);

    List<VolunteerEntity> findByIsVerified(boolean status);

    @Query("SELECT v.creditScore FROM VolunteerEntity v WHERE v.id = :id")
    Double findCreditScoreById(@Param("id") Long id);
}
