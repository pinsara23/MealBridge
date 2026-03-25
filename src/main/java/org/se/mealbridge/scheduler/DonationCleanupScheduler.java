package org.se.mealbridge.scheduler;

import jakarta.transaction.Transactional;
import org.se.mealbridge.entity.DonationEntity;
import org.se.mealbridge.entity.DonationStatus;
import org.se.mealbridge.entity.VolunteerEntity;
import org.se.mealbridge.repository.DonationRepository;
import org.se.mealbridge.repository.TokanBlacklistRepository;
import org.se.mealbridge.repository.VolunteerRepository;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@Component
public class DonationCleanupScheduler {

    private final DonationRepository donationRepository;
    private final VolunteerRepository volunteerRepository;
    private final TokanBlacklistRepository tokanBlacklistRepository;

    public DonationCleanupScheduler(DonationRepository donationRepository, VolunteerRepository volunteerRepository, TokanBlacklistRepository tokanBlacklistRepository) {
        this.donationRepository = donationRepository;
        this.volunteerRepository = volunteerRepository;
        this.tokanBlacklistRepository = tokanBlacklistRepository;
    }

    @Transactional
    @Scheduled(fixedRate = 60000) //run this every 1min 60000 ms
    public void markExpiredDonations(){

        LocalDateTime now  = LocalDateTime.now();

        //donation is still active but now time is after must picked up time
        List<DonationEntity> expiredDonations = donationRepository.findByStatusAndMustPickupByBefore(DonationStatus.AVAILABLE, now);

        if (!expiredDonations.isEmpty()){

            for (DonationEntity donation : expiredDonations){
                donation.setStatus(DonationStatus.EXPIRED);
            }

            donationRepository.saveAll(expiredDonations);
        }

        //donation is claimed but expired before volunteer comes to the shop volunteer gives 1hr grace time period
        LocalDateTime graceTime  = LocalDateTime.now().minusHours(1);

        List<DonationEntity> expiredDonationsButClaimed = donationRepository.findByStatusAndMustPickupByBefore(DonationStatus.CLAIMED, graceTime);
        if (!expiredDonationsButClaimed.isEmpty()){
            for (DonationEntity donation : expiredDonationsButClaimed){
                donation.setStatus(DonationStatus.EXPIRED);
            }

            donationRepository.saveAll(expiredDonationsButClaimed);
        }

        List<DonationEntity> expiredDonationsButPickedUp = donationRepository.findByStatusAndMustPickupByBefore(DonationStatus.PICKED_UP, graceTime);
        if (!expiredDonationsButPickedUp.isEmpty()){
            for (DonationEntity donation : expiredDonationsButPickedUp){
                donation.setStatus(DonationStatus.EXPIRED);

                VolunteerEntity volunteer = donation.getAssignedVolunteer();
                if (volunteer != null){
                    volunteer.setCreditScore(volunteer.getCreditScore() -5);

                }

            }

            donationRepository.saveAll(expiredDonationsButPickedUp);
        }
    }

    @Transactional
    @Scheduled(fixedRate = 3600000) // run every hour
    public void deleteBlackListedTokens(){

        tokanBlacklistRepository.deleteByExpiryDateBefore(LocalDateTime.now());

    }

}
