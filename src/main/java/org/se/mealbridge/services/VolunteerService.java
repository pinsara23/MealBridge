package org.se.mealbridge.services;

import org.modelmapper.ModelMapper;
import org.se.mealbridge.dto.VolunteerDto;
import org.se.mealbridge.entity.VolunteerEntity;
import org.se.mealbridge.repository.VolunteerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class VolunteerService {

    @Autowired
    private VolunteerRepository volunteerRepository;
    @Autowired
    private ModelMapper modelMapper;
    @Autowired
    private PasswordEncoder passwordEncoder;

    //save volunteer group
    public VolunteerDto saveVolunteer(VolunteerDto volunteerDto) {

        VolunteerEntity enity = modelMapper.map(volunteerDto, VolunteerEntity.class);
        enity.setPassword(passwordEncoder.encode(volunteerDto.getPassword()));

        VolunteerEntity savedVolunteerEntity = volunteerRepository.save(enity);
        return modelMapper.map(savedVolunteerEntity, VolunteerDto.class);
    }

    //update volunteer details
    public VolunteerDto updateVolunteer(VolunteerDto volunteerDto, Long volunteerId) {

        VolunteerEntity existingVolunteer = volunteerRepository.findById(volunteerId)
                .orElseThrow(() -> new RuntimeException("Volunteer not found"));

        if (volunteerDto.getOrganizationName() != null) existingVolunteer.setOrganizationName(volunteerDto.getOrganizationName());
        if (volunteerDto.getPresidentFullName() != null) existingVolunteer.setPresidentFullName(volunteerDto.getPresidentFullName());
        if (volunteerDto.getPhoneNumber() != null) existingVolunteer.setPhoneNumber(volunteerDto.getPhoneNumber());
        if (volunteerDto.getEmail() != null) existingVolunteer.setEmail(volunteerDto.getEmail());


        VolunteerEntity updatedVolunteer = volunteerRepository.save(existingVolunteer);

        return modelMapper.map(updatedVolunteer, VolunteerDto.class);

    }

    public boolean changePassword(Long id, String oldPassword, String newPassword) {

        VolunteerEntity volunteer = volunteerRepository.findById(id).orElseThrow(() -> new RuntimeException("Volunteer not found"));

        String hashedOldPassword = passwordEncoder.encode(oldPassword);
        if (!(passwordEncoder.matches(oldPassword, hashedOldPassword))){
            return false;
        }

        volunteer.setPassword(passwordEncoder.encode(newPassword));
        volunteerRepository.save(volunteer);
        return true;
    }

    public VolunteerDto getVolunteer(Long id){
        VolunteerEntity en = volunteerRepository.findById(id).orElseThrow(() -> new RuntimeException("Volunteer not found"));
        return modelMapper.map(en, VolunteerDto.class);
    }
}
