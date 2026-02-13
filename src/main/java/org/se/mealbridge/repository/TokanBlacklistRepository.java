package org.se.mealbridge.repository;

import org.se.mealbridge.entity.BlacklistedToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.Optional;

public interface TokanBlacklistRepository extends JpaRepository<BlacklistedToken, Long> {

    Optional<BlacklistedToken> findByToken(String token);
    boolean existsByToken(String token);
    void deleteByExpiryDateBefore(LocalDateTime expiryDate);
}
