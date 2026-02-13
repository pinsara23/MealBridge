package org.se.mealbridge.services;

import org.se.mealbridge.entity.BlacklistedToken;
import org.se.mealbridge.repository.TokanBlacklistRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class TokenBlacklistService {

    @Autowired
    private TokanBlacklistRepository tokanBlacklistRepository;

    public void blacklistToken(String token){

        BlacklistedToken blacklistedToken = new BlacklistedToken();
        blacklistedToken.setToken(token);

        blacklistedToken.setExpiryDate(LocalDateTime.now().plusHours(24));
        tokanBlacklistRepository.save(blacklistedToken);

    }

    public boolean isBlackListed(String token){
        return tokanBlacklistRepository.existsByToken(token);
    }
}
