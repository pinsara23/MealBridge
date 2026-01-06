package org.se.mealbridge.repository;

import org.se.mealbridge.entity.VolunteerEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface VolunteerRepository extends JpaRepository<VolunteerEntity, Long> {

    VolunteerEntity findByEmail(String email);

    List<VolunteerEntity> findByIsVerified(boolean status);
}
