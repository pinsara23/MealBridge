package org.se.mealbridge.controller;

import org.se.mealbridge.dto.AdminDto;
import org.se.mealbridge.dto.VolunteerDto;
import org.se.mealbridge.services.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private AdminService adminService;

    // /api/admin/register
    @PostMapping("/register")
    public AdminDto registerAdmin(@RequestBody AdminDto adminDto){
        return adminService.registerAdminMem(adminDto);
    }

    @GetMapping("/volunteers/pending")
    public List<VolunteerDto> getUnaprovedVolunteers(){
        return adminService.getUnverifiedVolunteers();
    }

    @PutMapping("/volunteer/{id}/approve")
    public boolean approveVolunteer(@PathVariable Long volunteerId){
        return adminService.approveVolunteers(volunteerId);
    }

    //change this to List wen connect to frontend
    // /api/admin/stats
    @GetMapping("/stats")
    public Map<String , Long> getStats(){
        return Map.of(
                "Total volunteers: ",adminService.getTotalVolunteers(),
                "Total Restaurents",adminService.getTotalRestaurantsRegistered(),
                "Total completed donations",adminService.getTotalCompletedDonations()
        );
    }

}
