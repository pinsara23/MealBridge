package org.se.mealbridge.services;

import org.modelmapper.ModelMapper;
import org.se.mealbridge.dto.AdminDto;
import org.se.mealbridge.dto.RestaurantDTO;
import org.se.mealbridge.dto.VolunteerDto;
import org.se.mealbridge.entity.AdminEntity;
import org.se.mealbridge.entity.DonationStatus;
import org.se.mealbridge.entity.RestaurantEntity;
import org.se.mealbridge.entity.VolunteerEntity;
import org.se.mealbridge.repository.AdminRepository;
import org.se.mealbridge.repository.DonationRepository;
import org.se.mealbridge.repository.RestaurantRepository;
import org.se.mealbridge.repository.VolunteerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AdminService {

    @Autowired
    private ModelMapper modelMapper;

    @Autowired
    private AdminRepository adminRepository;
    @Autowired
    private VolunteerRepository volunteerRepository;
    @Autowired
    private RestaurantRepository restaurantRepository;

    @Autowired
    private DonationRepository donationRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private WebSocketService webSocketService;

    public AdminDto registerAdminMem(AdminDto adminDto) {

        AdminEntity adminEntity = modelMapper.map(adminDto, AdminEntity.class);
        adminEntity.setPassword(passwordEncoder.encode(adminDto.getPassword()));

        AdminEntity savedEntity = adminRepository.save(adminEntity);
        savedEntity.setPassword(null);

        return  modelMapper.map(savedEntity, AdminDto.class);
    }

    public boolean changePassword(Long id, String password) {

        AdminEntity adminEntity = adminRepository.findById(id).orElseThrow(() -> new RuntimeException("Admin not found"));

        adminEntity.setPassword(passwordEncoder.encode(password));

        AdminEntity savedEntity = adminRepository.save(adminEntity);
        if (savedEntity != null) {
            return true;
        } else {
            return false;
        }
    }

    public boolean approveVolunteers(Long volunteerId){

        VolunteerEntity volunteer = volunteerRepository.findById(volunteerId).orElse(null);
        if(volunteer != null && !(volunteer.isVerified())){
            volunteer.setVerified(true);
            volunteerRepository.save(volunteer);

            webSocketService.notifVolunteer(volunteerId, "Your volunteer group has been approved by the admin. You can now access all features of the platform.");

        }else {
            return false;
        }
        return true;
    }

    public List<VolunteerDto> getUnverifiedVolunteers(){
        List<VolunteerEntity> volunteers = volunteerRepository.findByIsVerified(false);

        return volunteers.stream().map(volunteerEntity -> {

            VolunteerDto volunteerDto = modelMapper.map(volunteerEntity, VolunteerDto.class);
            volunteerDto.setPassword(null);
            return volunteerDto;
        }).toList();

    }

    //Dashboard stats
    public Long getTotalVolunteers(){
        return volunteerRepository.count();
    }

    public Long getTotalRestaurantsRegistered(){
        return restaurantRepository.count();
    }

    public Long getTotalCompletedDonations(){
        return (long) donationRepository.findByStatus(DonationStatus.DISTRIBUTED).size();
    }

    public Long getTotalAvailableDonations(){
        return (long) donationRepository.findByStatus(DonationStatus.AVAILABLE).size();
    }

    public Long getTotalPostedDonations(){
        return (long) donationRepository.count();
    }

    public Double totalFoodDonatedInKg() {
        Double totalKg = donationRepository.getTotalQuantity();
        return totalKg != null ? totalKg : 0.0;
    }

    public List<VolunteerDto> getAllVolunteers(){
        List<VolunteerEntity> volunteers = volunteerRepository.findAll();

        return volunteers.stream().map(volunteerEntity -> {

            VolunteerDto volunteerDto = modelMapper.map(volunteerEntity, VolunteerDto.class);
            volunteerDto.setPassword(null);
            return volunteerDto;
        }).toList();
    }

    public List<RestaurantDTO> getAllRestaurants(){

        List<RestaurantEntity> restaurants = restaurantRepository.findAll();

        return restaurants.stream().map(restaurantEntity -> {
             RestaurantDTO restaurantDto = modelMapper.map(restaurantEntity, RestaurantDTO.class);

             if (restaurantEntity.getLocation() != null) {
                 restaurantDto.setLongitude(restaurantEntity.getLocation().getX());
                 restaurantDto.setLatitude(restaurantEntity.getLocation().getY());
             }

             restaurantDto.setPassword(null);

             return restaurantDto;

        }).toList();

    }

    public AdminDto getAdminById(Long id){

        AdminEntity adminEntity = adminRepository.findById(id).orElseThrow(() -> new RuntimeException("Admin not found"));
        AdminDto adminDto = modelMapper.map(adminEntity, AdminDto.class);
        adminDto.setPassword(null);
        return adminDto;
    }

    public List<AdminDto> getAllAdmins(){
        List<AdminEntity> adminEntities = adminRepository.findAll();
        return adminEntities.stream().map(adminEntity -> {
            AdminDto adminDto = modelMapper.map(adminEntity, AdminDto.class);
            adminDto.setPassword(null);
            return adminDto;
        }).toList();
    }


}
