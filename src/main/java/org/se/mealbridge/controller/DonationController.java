package org.se.mealbridge.controller;

import org.se.mealbridge.dto.DonationsDto;
import org.se.mealbridge.repository.DonationRepository;
import org.se.mealbridge.services.DonationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/donations")
public class DonationController {

    @Autowired
    private DonationService donationService;

    ///api/donations
    @PostMapping
    public DonationsDto postDonation(@RequestBody DonationsDto dto) {

        return donationService.createDonation(dto);
    }

    // /api/donations/feed
    @GetMapping("/feed")
    public List<DonationsDto> fetFeed(){
        return donationService.getAllAvailableDonations();
    }

    // /api/donations/feed
    @GetMapping("/feed/{id}")
    public List<DonationsDto> fetFeedByRestaurantId(@PathVariable Long id){
        return donationService.getAllDonationsByRestaurantId(id);
    }

    // /api/donations/{donation id}/claim?vId=id
    @PutMapping("/{donationId}/claim")
    public String claimDonation(
            @PathVariable Long donationId,
            @RequestParam Long vId){

        return donationService.claimDonation(donationId, vId);
    }

}
