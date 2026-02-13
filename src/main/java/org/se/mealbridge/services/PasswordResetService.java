package org.se.mealbridge.services;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.se.mealbridge.entity.AdminEntity;
import org.se.mealbridge.entity.PasswordResetToken;
import org.se.mealbridge.entity.RestaurantEntity;
import org.se.mealbridge.entity.VolunteerEntity;
import org.se.mealbridge.repository.AdminRepository;
import org.se.mealbridge.repository.PasswordResetTokenRepository;
import org.se.mealbridge.repository.RestaurantRepository;
import org.se.mealbridge.repository.VolunteerRepository;
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


    private final JavaMailSender mailSender;
    @Autowired
    private VolunteerRepository volunteerRepository;
    @Autowired
    private AdminRepository adminRepository;

    //step 1 handle forgot password request
    public void initiatePassword(String email){

        String userType = null;

        if (restaurantRepository.findByEmail(email).isPresent()){
            userType = "RESTAURANT";
        } else if (volunteerRepository.findByEmail(email).isPresent()) {
            userType = "VOLUNTEER";
        } else if (adminRepository.findByUserName(email).isPresent()) {
            userType = "ADMIN";
        }

        if (userType == null){
            return;
        }

        String token = UUID.randomUUID().toString();

        //save token to DB
        PasswordResetToken passwordResetToken = new PasswordResetToken(token, userType, email);
        passwordResetTokenRepository.save(passwordResetToken);

        //send email
        sendResetEmail(email,token);
    }

    //step 2 handle the reset password action
    @Transactional
    public void resetPassword(String token, String newPassword){

        PasswordResetToken passwordResetToken = passwordResetTokenRepository.findByToken(token)
                .orElseThrow(()-> new RuntimeException("Invalid or expired token"));

        String userType = passwordResetToken.getUserType();
        String email = passwordResetToken.getEmail();

        switch (userType){
            case "RESTAURANT":
                RestaurantEntity restaurant = restaurantRepository.findByEmail(email)
                        .orElseThrow(()-> new RuntimeException("User not found"));
                restaurant.setPassword(passwordEncoder.encode(newPassword));
                restaurantRepository.save(restaurant);
                break;

            case "VOLUNTEER":
                VolunteerEntity vonteer = volunteerRepository.findByEmail(email)
                        .orElseThrow(()-> new RuntimeException("User not found"));
                vonteer.setPassword(passwordEncoder.encode(newPassword));
                volunteerRepository.save(vonteer);
                break;

            case "ADMIN":
                AdminEntity admin = adminRepository.findByUserName(email)
                        .orElseThrow(()-> new RuntimeException("User not found"));
                admin.setPassword(passwordEncoder.encode(newPassword));
                adminRepository.save(admin);
                break;
        }

        //cleanup token after use
        passwordResetTokenRepository.deleteByToken(token);
    }

    private void sendResetEmail(String to, String token){

        SimpleMailMessage mailMessage = new SimpleMailMessage();
        mailMessage.setTo(to);
        mailMessage.setSubject("Password reset request");
        mailMessage.setText("To reset your password, click the link below:\n" +
                "https://pinsara23.github.io/MealBridge/?token="+token);

        mailSender.send(mailMessage);
    }
}
