package org.se.mealbridge.security;

import org.se.mealbridge.entity.AdminEntity;
import org.se.mealbridge.entity.RestaurantEntity;
import org.se.mealbridge.entity.VolunteerEntity;
import org.se.mealbridge.repository.AdminRepository;
import org.se.mealbridge.repository.RestaurantRepository;
import org.se.mealbridge.repository.VolunteerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class CustomUserDetailsService implements UserDetailsService {

    @Autowired
    private RestaurantRepository restaurantRepository;
    @Autowired
    private VolunteerRepository volunteerRepository;
    @Autowired
    private AdminRepository adminRepository;


    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {

        //1.CHECK IN RESTAURANT
        Optional<RestaurantEntity> restaurant = restaurantRepository.findByEmail(email);
        if (restaurant.isPresent()){
            return User.builder()
                    .username(restaurant.get().getEmail())
                    .password(restaurant.get().getPassword())
                    .roles("RESTAURANT")
                    .build();
        }

        //2.CHECK IN VOLUNTEERS
        Optional<VolunteerEntity> volunteer = volunteerRepository.findByEmail(email);
        if (volunteer.isPresent()){
            return User.builder()
                    .username(volunteer.get().getEmail())
                    .password(volunteer.get().getPassword())
                    .roles("VOLUNTEER")
                    .build();
        }

        //3. check in admin
        Optional<AdminEntity> admin = adminRepository.findByUserName(email);
        if (admin.isPresent()){
            return User.builder()
                    .username(admin.get().getUserName())
                    .password(admin.get().getPassword())
                    .roles("ADMIN")
                    .build();
        }

        throw new UsernameNotFoundException("User not found with email: " + email);

    }
}
