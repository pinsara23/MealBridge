package org.se.mealbridge.services;

import jakarta.transaction.Transactional;
import org.modelmapper.ModelMapper;
import org.se.mealbridge.dto.DonationsDto;
import org.se.mealbridge.dto.VolunteerDto;
import org.se.mealbridge.entity.DonationEntity;
import org.se.mealbridge.entity.DonationStatus;
import org.se.mealbridge.entity.RestaurantEntity;
import org.se.mealbridge.entity.VolunteerEntity;
import org.se.mealbridge.repository.DonationRepository;
import org.se.mealbridge.repository.RestaurantRepository;
import org.se.mealbridge.repository.VolunteerRepository;
import org.se.mealbridge.util.FileStorageutil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;


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

    @Autowired
    private FileStorageutil fileStorageutil;

    @Autowired
    private WebSocketService webSocketService;

    private DonationsDto convertToDto(DonationEntity donationEntity) {
        DonationsDto donationsDto = modelMapper.map(donationEntity, DonationsDto.class);
        donationsDto.setRestaurantId(donationEntity.getDonor().getId());
        donationsDto.setRestaurantName(donationEntity.getDonor().getBusinessName());
        int hour = donationEntity.getMustPickupBy().minusHours(LocalDateTime.now().getHour()).getHour();
        donationsDto.setHoursValid(Math.max(hour, 0));
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

        webSocketService.notifyAllVolunteers("NEW_FOOD_AVAILABLE");
        webSocketService.notifyRestaurant(savedDonation.getDonor().getId(), "DONATION_POSTED");

        return convertToDto(savedDonation);
    }

    //find all active donations
    public List<DonationsDto> getAllAvailableDonations(){
        List<DonationEntity> donations = donationRepository.findByStatus(DonationStatus.AVAILABLE);
        return donations.stream().map(this::convertToDto).toList();
    }

    //find donations by restaurant id - these are not picked up currently in restaurant side
    public List<DonationsDto> getAllDonationsByRestaurantId(Long restaurantId){

        List<DonationEntity> donations = donationRepository.findByDonorIdAndStatusNotIn(restaurantId,
                List.of(DonationStatus.DISTRIBUTED, DonationStatus.EXPIRED, DonationStatus.PICKED_UP)
        );
        return donations.stream().map(this::convertToDto).toList();
    }

    //find active Donations by volunteer id
    public List<DonationsDto> getAllDonationsByVolunteerId(Long volunteerId){

        VolunteerEntity volunteer = volunteerRepository.findById(volunteerId)
                .orElseThrow(() -> new RuntimeException("Volunteer not found"));
        List<DonationEntity> donations = donationRepository.findByAssignedVolunteerAndStatusNotIn(volunteer, List.of(DonationStatus.DISTRIBUTED, DonationStatus.EXPIRED));

        return donations.stream().map(this::convertToDto).toList();
    }

    public List<DonationsDto> getAllFinishedDonationsByVolunteerId(Long volunteerId){

        VolunteerEntity volunteer = volunteerRepository.findById(volunteerId)
                .orElseThrow(() -> new RuntimeException("Volunteer not found"));
        List<DonationEntity> donations = donationRepository.findByAssignedVolunteerAndStatusNotIn(volunteer, List.of(DonationStatus.CLAIMED, DonationStatus.PICKED_UP, DonationStatus.AVAILABLE));

        return donations.stream().map(this::convertToDto).toList();
    }

    //logic for claim donation
    public String claimDonation(Long donationId, Long volunteerId){

        DonationEntity donation =  donationRepository.findById(donationId).orElseThrow(() -> new RuntimeException("Donation not found"));

        VolunteerEntity volunteer = volunteerRepository.findById(volunteerId).orElseThrow(() -> new RuntimeException("Volunteer not found"));

        if (donation.getStatus() != DonationStatus.AVAILABLE) {
            return "error1";
        }

        //logic 1 volunteer cant accept donation from 1 restaurant in near days this should implement
        if (!(volunteer.isVerified())){
            return "error2";
        }

        donation.setAssignedVolunteer(volunteer);
        donation.setStatus(DonationStatus.CLAIMED);
        donation.setClaimedAt(LocalDateTime.now());

        //Token - this is use for create qr code
        String token = donation.getPickupToken();

        donationRepository.save(donation);

        webSocketService.notifyRestaurant(donation.getDonor().getId(), "DONATION_CLAIMED");
        webSocketService.notifyDonationUpdate(donationId, donation.getFoodDescription()+" CLAIMED");

        return token;

    }

    // pickup a donation
    public boolean verifyPickup(String token, Long restaurantId){

        DonationEntity donation = donationRepository.findByPickupToken(token)
                .orElseThrow(() -> new RuntimeException("Donation not found"));

        if (donation.getStatus() != DonationStatus.CLAIMED) {
            return  false;
        }

        if (donation.getStatus() == DonationStatus.EXPIRED) {
            return  false;
        }

        if (donation.getDonor().getId() == restaurantId) {

            donation.setStatus(DonationStatus.PICKED_UP);
            donationRepository.save(donation);

            webSocketService.notifyRestaurant(donation.getDonor().getId(), "DONATION_PICKED");
            webSocketService.notifyDonationUpdate(donation.getId(), "DONATION_PICKED");
            webSocketService.notifVolunteer(donation.getAssignedVolunteer().getId(), "DONATION_PICKED");

            return true;

        }else  {
            return  false;
        }


    }

    //Distribute Donations
    @Transactional
    public boolean submitDistributionProof(String token, MultipartFile photo){

        DonationEntity donation = donationRepository.findByPickupToken(token).orElseThrow(() -> new RuntimeException("Donation not found"));

        if (donation.getStatus() != DonationStatus.PICKED_UP) {
            System.out.println("You have to pickup donation first");
            return false;
        }

        String photoFileName = fileStorageutil.saveFile(photo);
        donation.setImageUrl(photoFileName);

        donation.setStatus(DonationStatus.DISTRIBUTED);
        VolunteerEntity volunteer = donation.getAssignedVolunteer();

        if (volunteer != null){
            volunteer.setCreditScore(volunteer.getCreditScore() + 10);
            volunteerRepository.save(volunteer);
        }

        donationRepository.save(donation);

        webSocketService.notifyRestaurant(donation.getDonor().getId(), "DONATION_DISTRIBUTED");
        webSocketService.notifyDonationUpdate(donation.getId(), "DONATION_DISTRIBUTED");
        webSocketService.notifVolunteer(donation.getAssignedVolunteer().getId(), "DONATION_DISTRIBUTED");

        return true;
    }

    //Distribute Donations without photo
    @Transactional
    public boolean confirmDistribution(String token){

        DonationEntity donation = donationRepository.findByPickupToken(token).orElseThrow(() -> new RuntimeException("Donation not found"));

        if (donation.getStatus() != DonationStatus.PICKED_UP) {
            System.out.println("You have to pickup donation first");
            return false;
        }

        donation.setStatus(DonationStatus.DISTRIBUTED);
        VolunteerEntity volunteer = donation.getAssignedVolunteer();

        if (volunteer != null){
            volunteer.setCreditScore(volunteer.getCreditScore() + 10);
            volunteerRepository.save(volunteer);
        }

        donationRepository.save(donation);

        webSocketService.notifyRestaurant(donation.getDonor().getId(), "DONATION_DISTRIBUTED");
        webSocketService.notifyDonationUpdate(donation.getId(), "DONATION_DISTRIBUTED");
        webSocketService.notifVolunteer(donation.getAssignedVolunteer().getId(), "DONATION_DISTRIBUTED");

        return true;
    }

    // these donations are already picked up or expired or distributed
    public List<DonationsDto> getDonationHistoryByRestaurentId(Long restaurantId){

        List<DonationEntity> donationHistory = donationRepository.findByDonorIdAndStatusNotIn(restaurantId,
                List.of(DonationStatus.AVAILABLE, DonationStatus.CLAIMED)
        );
        return donationHistory.stream().map(this::convertToDto).toList();
    }

    public VolunteerDto getVolunteerDetailsByDonationId(Long donationId){

        DonationEntity donation = donationRepository.findById(donationId)
                .orElseThrow(() -> new RuntimeException("Donation not found"));

        VolunteerEntity volunteer = donation.getAssignedVolunteer();

        if (volunteer == null){
            return null;
        }

        VolunteerDto volunteerDto = modelMapper.map(volunteer, VolunteerDto.class);
        volunteerDto.setPassword(null);
        volunteerDto.setMessage(null);
        return volunteerDto;
    }



}
