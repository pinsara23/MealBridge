package org.se.mealbridge.services;

import org.modelmapper.ModelMapper;
import org.se.mealbridge.dto.VolunteerDto;
import org.se.mealbridge.entity.VolunteerEntity;
import org.se.mealbridge.repository.VolunteerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class VolunteerService {

    @Autowired
    private VolunteerRepository volunteerRepository;
    @Autowired
    private ModelMapper modelMapper;

    //save volunteer group
    public VolunteerDto saveVolunteer(VolunteerDto volunteerDto) {

        VolunteerEntity enity = modelMapper.map(volunteerDto, VolunteerEntity.class);

        VolunteerEntity savedVolunteerEntity = volunteerRepository.save(enity);
        return modelMapper.map(savedVolunteerEntity, VolunteerDto.class);
    }

    //verify an volunteer
    public boolean verifyVolunteer(Long volunteerId) {

        VolunteerEntity entity =  volunteerRepository.findById(volunteerId).orElse(null);
        if (entity == null){
            return false;
        }

        entity.setVerified(true);
        volunteerRepository.save(entity);
        return true;
    }

    //list of not verified volunteers
    public List<VolunteerDto> getNotVerifiedVolunteers() {

        List<VolunteerEntity> volunteerEntities = volunteerRepository.findByIsVerified(false);
        return volunteerEntities.stream().map(volunteerEntity -> {

            VolunteerDto dto = modelMapper.map(volunteerEntity, VolunteerDto.class);
            dto.setPassword(null);
            return dto;

        }).toList();
    }
}
