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

    // /api/volunteer/update/{id}
    @PutMapping("/update/{id}")
    public VolunteerDto updateVolunteer(@RequestBody VolunteerDto volunteerDto, @PathVariable Long id){
        return volunteerService.updateVolunteer(volunteerDto,id);
    }

    // /api/volunteer/details/{id}
    @GetMapping("/details/{id}")
    public VolunteerDto getVolunteer(@PathVariable Long id){
        return volunteerService.getVolunteer(id);
    }








}
