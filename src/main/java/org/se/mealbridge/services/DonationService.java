package org.se.mealbridge.services;

import org.modelmapper.ModelMapper;
import org.se.mealbridge.dto.DonationsDto;
import org.se.mealbridge.entity.DonationEntity;
import org.se.mealbridge.entity.DonationStatus;
import org.se.mealbridge.entity.RestaurantEntity;
import org.se.mealbridge.entity.VolunteerEntity;
import org.se.mealbridge.repository.DonationRepository;
import org.se.mealbridge.repository.RestaurantRepository;
import org.se.mealbridge.repository.VolunteerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;


import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class DonationService {

    @Autowired
    private DonationRepository donationRepository;

    @Autowired
    private RestaurantRepository restaurantRepository;

    @Autowired
    private ModelMapper modelMapper;

    @Autowired
    private VolunteerRepository volunteerRepository;

    private DonationsDto convertToDto(DonationEntity donationEntity) {
        DonationsDto donationsDto = modelMapper.map(donationEntity, DonationsDto.class);
        donationsDto.setRestaurantId(donationEntity.getDonor().getId());
        donationsDto.setRestaurantName(donationEntity.getDonor().getBusinessName());
        return donationsDto;
    }

    //post a new donation
    public DonationsDto createDonation(DonationsDto donationsDto) {

        DonationEntity entity = modelMapper.map(donationsDto, DonationEntity.class);

        //get restaurant details
        RestaurantEntity restaurant = restaurantRepository.findById(donationsDto.getRestaurantId())
                .orElseThrow(() -> new RuntimeException("Restaurant not found"));

        entity.setDonor(restaurant);
        entity.setStatus(DonationStatus.AVAILABLE);
        entity.setPostedAt(LocalDateTime.now());

        entity.setMustPickupBy(LocalDateTime.now().plusHours(donationsDto.getHoursValid()));

        //generate random UUID for QR code
        entity.setPickupToken(UUID.randomUUID().toString());

        DonationEntity savedDonation = donationRepository.save(entity);

        return convertToDto(savedDonation);
    }

    //find all active donations
    public List<DonationsDto> getAllAvailableDonations(){
        List<DonationEntity> donations = donationRepository.findByStatus(DonationStatus.AVAILABLE);
        return donations.stream().map(this::convertToDto).toList();
    }

    //find donations by restaurant id
    public List<DonationsDto> getAllDonationsByRestaurantId(Long restaurantId){

        List<DonationEntity> donations = donationRepository.findByDonorId(restaurantId);
        return donations.stream().map(this::convertToDto).toList();
    }

    //logic for claim donation
    public String claimDonation(Long donationId, Long volunteerId){

        DonationEntity donation =  donationRepository.findById(donationId).orElseThrow(() -> new RuntimeException("Donation not found"));

        VolunteerEntity volunteer = volunteerRepository.findById(volunteerId).orElseThrow(() -> new RuntimeException("Volunteer not found"));

        if (donation.getStatus() != DonationStatus.AVAILABLE) {
            throw new RuntimeException("Sorry this donation was claimed by someone else");
        }

        //logic 1 volunteer cant accept donation from 1 restaurant in near days this should implement


        donation.setAssignedVolunteer(volunteer);
        donation.setStatus(DonationStatus.CLAIMED);
        donation.setClaimedAt(LocalDateTime.now());

        //Token - this is use for create qr code
        String token = donation.getPickupToken();

        donationRepository.save(donation);
        return token;

    }




}
