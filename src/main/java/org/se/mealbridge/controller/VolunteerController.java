package org.se.mealbridge.controller;

import org.se.mealbridge.dto.VolunteerDto;
import org.se.mealbridge.services.VolunteerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/volunteer")
public class VolunteerController {

    @Autowired
    private VolunteerService volunteerService;

    // /api/volunteer/register
    @PostMapping("/register")
    public VolunteerDto registerVolunteer(@RequestBody VolunteerDto volunteerDto) {
        return volunteerService.saveVolunteer(volunteerDto);
    }

    // /api/volunteer/register
    @GetMapping("/unapproved")
    public List<VolunteerDto> getUnApprovedVolunteers(){
        return volunteerService.getNotVerifiedVolunteers();
    }




}
