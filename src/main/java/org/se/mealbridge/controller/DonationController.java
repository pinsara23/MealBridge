package org.se.mealbridge.controller;

import org.se.mealbridge.dto.DonationsDto;
import org.se.mealbridge.repository.DonationRepository;
import org.se.mealbridge.services.DonationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

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
    public List<DonationsDto> getFeed(){
        return donationService.getAllAvailableDonations();
    }

    // /api/donations/feed
    @GetMapping("/feed/restaurent/{id}")
    public List<DonationsDto> getFeedByRestaurantId(@PathVariable Long id){
        return donationService.getAllDonationsByRestaurantId(id);
    }

    @GetMapping("/feed/volunteer/{id}")
    public List<DonationsDto> getFeedByVolunteerId(@PathVariable Long id){
        return donationService.getAllDonationsByVolunteerId(id);
    }

    // /api/donations/{donation id}/claim?vId=id  vId = volunteerid
    @PutMapping("/{donationId}/claim")
    public String claimDonation(
            @PathVariable Long donationId,
            @RequestParam Long vId){

        return donationService.claimDonation(donationId, vId);
    }

    // /api/donations/verify-pickup?token=token
    @PutMapping("/verify-pickup")
    public boolean verifyPickup(@RequestParam String token){

        return donationService.verifyPickup(token);
    }

    // /api/donations/distribute
    @PostMapping ("/distribute")
    public boolean submitProof(
            @RequestParam("token") String token,
            @RequestParam("photo") MultipartFile photo
            ){
        System.out.println("Photo saved successfully");
        return donationService.submitDistributionProof(token, photo);
    }

}
