package org.se.mealbridge.controller;

import org.se.mealbridge.dto.RestaurantDTO;
import org.se.mealbridge.entity.RestaurantEntity;
import org.se.mealbridge.services.RestaurantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/restaurants")
public class RestaurantController {

    @Autowired
    private RestaurantService restaurantService;

    @PostMapping("/register")
    public RestaurantDTO registerRestaurent(@RequestBody RestaurantDTO restaurantDTO) {
        return restaurantService.registerRestaurent(restaurantDTO);
    }

    @GetMapping("/nearby")
    public List<RestaurantDTO> getNearby(
            @RequestParam double latitude,
            @RequestParam double longitude,
            @RequestParam(defaultValue = "5000") double radius
    ){
        return restaurantService.findNearbyRestaurants(latitude, longitude, radius);
    }
}
