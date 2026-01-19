package org.se.mealbridge.controller;

import org.se.mealbridge.dto.AdminDto;
import org.se.mealbridge.dto.RestaurantDTO;
import org.se.mealbridge.dto.VolunteerDto;
import org.se.mealbridge.services.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private AdminService adminService;

    // /api/admin/register *
    @PostMapping("/register")
    public AdminDto registerAdmin(@RequestBody AdminDto adminDto){
        return adminService.registerAdminMem(adminDto);
    }

    // /api/admin/update-password/{id}/new?password=password *
    @PostMapping("/update-password/{id}/new")
    public boolean updatePassword(@PathVariable long id, @RequestParam String password){
        return adminService.changePassword(id, password);
    }

    // /api/admin/volunteer/{id}/approve
    @PreAuthorize("hasRole('ADMIN')")
    @PutMapping("/volunteer/{id}/approve")
    public boolean approveVolunteer(@PathVariable Long id){
        return adminService.approveVolunteers(id);
    }


    // /api/admin/stats/tot-restaurants *
    @GetMapping("/stats/tot-restaurants")
    public long getStatsRestaurants(){
        return adminService.getTotalRestaurantsRegistered();
    }

    // /api/admin/stats/tot-volunteers *
    @GetMapping("/stats/tot-volunteers")
    public long getStatsVolunteers(){
        return adminService.getTotalVolunteers();
    }

    // /api/admin/stats/tot-donations/completed *
    @GetMapping("/stats/tot-donations/completed")
    public long getStatsDonationsCompleted(){
        return adminService.getTotalCompletedDonations();
    }

    // /api/admin/stats/tot-donations/available *
    @GetMapping("/stats/tot-donations/available")
    public long getStatsDonationsAvailable(){
        return adminService.getTotalAvailableDonations();
    }

    // /api/admin/stats/tot-donations *
    @GetMapping("/stats/tot-donations")
    public long getStatsDonations(){
        return adminService.getTotalPostedDonations();
    }

    // /api/admin/stats/tot-quantity *
    @GetMapping("/stats/tot-quantity")
    public Double getTotalQuantity(){
        return adminService.totalFoodDonatedInKg();
    }

    // /api/admin/stats/users/count *
    @GetMapping("/stats/users/count")
    public Long getTotalUsers(){
        return adminService.getTotalVolunteers() + adminService.getTotalRestaurantsRegistered();
    }

    // /api/admin/stats/restaurants *
    @GetMapping("/stats/restaurants")
    public List<RestaurantDTO> getAllRestaurants(){
        return adminService.getAllRestaurants();
    }

    // /api/admin/stats/volunteers *
    @GetMapping("/stats/volunteers")
    public List<VolunteerDto> getAllVolunteers(){
        return adminService.getAllVolunteers();
    }

    // /api/admin/stats/volunteers/unapproved *
    @GetMapping("/stats/volunteers/unapproved")
    public List<VolunteerDto> getAllUnapprovedVolunteers(){
        return adminService.getUnverifiedVolunteers();
    }

    // /api/admin/get/admin/{id} *
    @GetMapping("/get/admin/{id}")
    public AdminDto getAdminById(@PathVariable Long id){
        return adminService.getAdminById(id);
    }

    // /api/admin/get/admin/all *
    @GetMapping("/get/admin/all")
    public List<AdminDto> getAllAdmins(){
        return adminService.getAllAdmins();
    }



}
