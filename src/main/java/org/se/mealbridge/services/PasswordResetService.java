package org.se.mealbridge.services;

import lombok.RequiredArgsConstructor;
import org.se.mealbridge.entity.PasswordResetToken;
import org.se.mealbridge.entity.RestaurantEntity;
import org.se.mealbridge.repository.PasswordResetTokenRepository;
import org.se.mealbridge.repository.RestaurantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class PasswordResetService {

    @Autowired
    private RestaurantRepository restaurantRepository;
    @Autowired
    private PasswordResetTokenRepository passwordResetTokenRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;

    private JavaMailSender mailSender;

    //step 1 handle forgot password request
    public void initiatePassword(String email){

        RestaurantEntity restaurant = restaurantRepository.findByEmail(email)
                .orElseThrow(()-> new RuntimeException("No restaurant found with email: "+email));

        String token = UUID.randomUUID().toString();

        //save token to DB
        PasswordResetToken passwordResetToken = new PasswordResetToken(token, restaurant);
        passwordResetTokenRepository.save(passwordResetToken);

        //send email
        sendResetEmail(email,token);
    }

    //step 2 handle the reset password action
    public void resetPassword(String token, String newPassword){
        PasswordResetToken passwordResetToken = passwordResetTokenRepository.findByToken(token)
                .orElseThrow(()-> new RuntimeException("Invalid or expired token"));

        RestaurantEntity restaurant = passwordResetToken.getRestaurant();
        restaurant.setPassword(passwordEncoder.encode(newPassword));
        restaurantRepository.save(restaurant);

        //cleanup token after use
        passwordResetTokenRepository.deleteByToken(token);
    }

    private void sendResetEmail(String to, String token){

        SimpleMailMessage mailMessage = new SimpleMailMessage();
        mailMessage.setTo(to);
        mailMessage.setSubject("Password reset request");
        mailMessage.setText("To reset your password, click the link below:\n" +
                "http://localhost:8080/api/auth/reset-password?token="+token);

        mailSender.send(mailMessage);
    }
}
