package org.se.mealbridge.repository;

import org.se.mealbridge.entity.AdminEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AdminRepository extends JpaRepository<AdminEntity,Long> {

    Optional<AdminEntity> findByUserName(String userName);
    Optional<AdminEntity> findByRole(String Role);
}
