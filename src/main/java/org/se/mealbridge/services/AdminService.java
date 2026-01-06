package org.se.mealbridge.services;

import org.modelmapper.ModelMapper;
import org.se.mealbridge.dto.AdminDto;
import org.se.mealbridge.dto.VolunteerDto;
import org.se.mealbridge.entity.AdminEntity;
import org.se.mealbridge.entity.DonationStatus;
import org.se.mealbridge.entity.VolunteerEntity;
import org.se.mealbridge.repository.AdminRepository;
import org.se.mealbridge.repository.DonationRepository;
import org.se.mealbridge.repository.RestaurantRepository;
import org.se.mealbridge.repository.VolunteerRepository;
import org.springframework.beans.factory.annotation.Autowired;
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

    public AdminDto registerAdminMem(AdminDto adminDto) {

        AdminEntity adminEntity = modelMapper.map(adminDto, AdminEntity.class);
        AdminEntity savedEntity = adminRepository.save(adminEntity);

        return  modelMapper.map(savedEntity, AdminDto.class);
    }

    public boolean approveVolunteers(Long volunteerId){

        VolunteerEntity volunteer = volunteerRepository.findById(volunteerId).orElse(null);
        if(volunteer != null && !(volunteer.isVerified())){
            volunteer.setVerified(true);
            volunteerRepository.save(volunteer);
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


}
