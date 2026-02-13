package org.se.mealbridge.controller;

import jakarta.validation.Valid;
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
    public RestaurantDTO registerRestaurent(@Valid @RequestBody RestaurantDTO restaurantDTO) {
        return restaurantService.registerRestaurent(restaurantDTO);
    }

    // /api/restaurants/update/{restaurantId}
    @PutMapping("/update/{restaurantId}")
    public RestaurantDTO updateDetails(@RequestBody RestaurantDTO restaurantDTO, @PathVariable Long restaurantId) {
        return restaurantService.updateRestaurentdetails(restaurantDTO, restaurantId);
    }

     // /api/restaurants/update/password/{restaurantId}?opass=oldpassword&npass=newpassword
    @PostMapping("/update/password/{restaurantId}")
    public boolean changePassword(@RequestParam String opass, @RequestParam String npass, @PathVariable Long restaurantId) {
        return restaurantService.changePassword(restaurantId, opass, npass);
    }

    @GetMapping("/nearby")
    public List<RestaurantDTO> getNearby(
            @RequestParam double latitude,
            @RequestParam double longitude,
            @RequestParam(defaultValue = "5000") double radius
    ){
        return restaurantService.findNearbyRestaurants(latitude, longitude, radius);
    }

    // /api/restaurants/details/{id}
    @GetMapping("/details/{id}")
    public RestaurantDTO seeDetails(@PathVariable Long id){
        return restaurantService.findRestaurantById(id);
    }

    // /api/restaurants/location/{id}
    @GetMapping("/location/{id}")
    public RestaurantDTO seeLocation(@PathVariable Long id){
        return restaurantService.getRestaurentLocationById(id);
    }
}
