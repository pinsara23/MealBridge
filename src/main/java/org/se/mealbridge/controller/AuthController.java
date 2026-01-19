package org.se.mealbridge.controller;

import org.se.mealbridge.dto.LoginRequest;
import org.se.mealbridge.entity.AdminEntity;
import org.se.mealbridge.entity.RestaurantEntity;
import org.se.mealbridge.entity.VolunteerEntity;
import org.se.mealbridge.repository.AdminRepository;
import org.se.mealbridge.repository.RestaurantRepository;
import org.se.mealbridge.repository.VolunteerRepository;
import org.se.mealbridge.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
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

    // /api/auth/login
    @PostMapping("/login")
    public Map<String,Object> login(@RequestBody LoginRequest request){

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
        Map<String,Object> response = new HashMap<>();
        response.put("token",token);
        response.put("role",role);
        response.put("userId",userId);
        response.put("name",name);

        return response;
    }
}
