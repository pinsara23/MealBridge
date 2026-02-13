package org.se.mealbridge.controller;

import org.se.mealbridge.dto.ForgotPasswordRequest;
import org.se.mealbridge.dto.LoginRequest;
import org.se.mealbridge.dto.LoginResponse;
import org.se.mealbridge.dto.ResetPasswordRequest;
import org.se.mealbridge.entity.AdminEntity;
import org.se.mealbridge.entity.RestaurantEntity;
import org.se.mealbridge.entity.VolunteerEntity;
import org.se.mealbridge.repository.AdminRepository;
import org.se.mealbridge.repository.RestaurantRepository;
import org.se.mealbridge.repository.VolunteerRepository;
import org.se.mealbridge.security.JwtUtil;
import org.se.mealbridge.services.PasswordResetService;
import org.se.mealbridge.services.TokenBlacklistService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;
    @Autowired
    private RestaurantRepository restaurantRepository;
    @Autowired
    private VolunteerRepository volunteerRepository;
    @Autowired
    private AdminRepository adminRepository;
    @Autowired
    private JwtUtil jwtUtil;
    @Autowired
    private PasswordResetService passwordResetService;
    @Autowired
    private TokenBlacklistService tokenBlacklistService;

    // /api/auth/login
    @PostMapping("/login")
    public LoginResponse login(@RequestBody LoginRequest request){

        //authenticate password
        Authentication auth = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(),request.getPassword())
        );

        //extract role
        String role = auth.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .findFirst()
                .orElse("USER");

        Long userId = null;
        String name = "";

        if (role.equals("ROLE_RESTAURANT")){
            Optional<RestaurantEntity> res = restaurantRepository.findByEmail(request.getEmail());
            if (res.isPresent()){
                userId = res.get().getId();
                name = res.get().getBusinessName();
            }
        } else if (role.equals("ROLE_VOLUNTEER")) {
            Optional<VolunteerEntity> vol = volunteerRepository.findByEmail(request.getEmail());
            if (vol.isPresent()){
                userId = vol.get().getId();
                name = vol.get().getOrganizationName();
            }
        } else if (role.equals("ROLE_ADMIN")) {
            Optional<AdminEntity> ad = adminRepository.findByUserName(request.getEmail());
            if (ad.isPresent()){
                userId = ad.get().getId();
                name = ad.get().getUserName();
            }
        }

        //generate token
        String token = jwtUtil.generateToken(request.getEmail(), role);

        //return
        //        Map<String,Object> response = new HashMap<>();
//        response.put("token",token);
//        response.put("role",role);
//        response.put("userId",userId);
//        response.put("name",name);

        return new LoginResponse(token,name,role,userId);
    }

    // /api/auth/forgot-password
    @PostMapping("/forgot-password")
    public ResponseEntity<String> forgotPassword(@RequestBody ForgotPasswordRequest forgotPasswordRequest){

        passwordResetService.initiatePassword(forgotPasswordRequest.email());
        return ResponseEntity.ok("Password reset email send");
    }

    // /api/auth/reset-password
    @PostMapping("/reset-password")
    public ResponseEntity<String> resetPassword(@RequestBody ResetPasswordRequest resetRequest){

        passwordResetService.resetPassword(resetRequest.token(), resetRequest.newPassword());
        return ResponseEntity.ok("Password reset successful");
    }

    // /api/auth/logout
    @PostMapping("/logout")
    public ResponseEntity<String> logout(@RequestHeader("Authorization") String token){

        if (token != null && token.startsWith("Bearer ")){

            String jwt = token.substring(7);
            tokenBlacklistService.blacklistToken(jwt);
            return ResponseEntity.ok("Logout successful.");
        }

        return ResponseEntity.badRequest().body("Invalid token.");
    }
}
