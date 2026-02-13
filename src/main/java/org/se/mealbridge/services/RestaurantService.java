package org.se.mealbridge.services;

import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.modelmapper.ModelMapper;
import org.se.mealbridge.dto.RestaurantDTO;
import org.se.mealbridge.entity.RestaurantEntity;
import org.se.mealbridge.repository.RestaurantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.List;

@Service
public class RestaurantService {

    @Autowired
    private RestaurantRepository restaurantRepository;

    @Autowired
    private ModelMapper modelMapper;

    private final GeometryFactory geometryFactory = new GeometryFactory();
    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private WebSocketService webSocketService;

    //1.Register a restaurant
    public RestaurantDTO registerRestaurent(RestaurantDTO restaurantDTO) {

        RestaurantEntity restaurantEntity = modelMapper.map(restaurantDTO, RestaurantEntity.class);

        restaurantEntity.setPassword(passwordEncoder.encode(restaurantDTO.getPassword()));

        //geometry mapping
        Point point  = geometryFactory.createPoint(new Coordinate(restaurantDTO.getLongitude(), restaurantDTO.getLatitude()));
        point.setSRID(4326);
        restaurantEntity.setLocation(point);

        RestaurantEntity entity =  restaurantRepository.save(restaurantEntity);

        RestaurantDTO dto =  modelMapper.map(entity, RestaurantDTO.class);
        dto.setLongitude(entity.getLocation().getX());
        dto.setLatitude(entity.getLocation().getY());
        dto.setPassword(null);

        webSocketService.notifyAdmin("New restaurant registered: " + dto.getBusinessName());
        return dto;
    }

    public RestaurantDTO updateRestaurentdetails(RestaurantDTO restaurantDTO, Long restaurantId) {

        RestaurantEntity existingRestaurant = restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new RuntimeException("Restaurant not found"));

        if (restaurantDTO.getBusinessName() != null) existingRestaurant.setBusinessName(restaurantDTO.getBusinessName());
        if (restaurantDTO.getPhoneNumber() != null) existingRestaurant.setPhoneNumber(restaurantDTO.getPhoneNumber());
        if (restaurantDTO.getEmail() != null) existingRestaurant.setEmail(restaurantDTO.getEmail());
        if (restaurantDTO.getOpenTime() != null) existingRestaurant.setOpenTime(restaurantDTO.getOpenTime());
        if (restaurantDTO.getCloseTime() != null) existingRestaurant.setCloseTime(restaurantDTO.getCloseTime());

        RestaurantEntity updatedRestaurant = restaurantRepository.save(existingRestaurant);

        RestaurantDTO dto =  modelMapper.map(updatedRestaurant, RestaurantDTO.class);
        if (dto != null){
            dto.setLongitude(updatedRestaurant.getLocation().getX());
            dto.setLatitude(updatedRestaurant.getLocation().getY());
            dto.setPassword(null);
        }

        return dto;

    }

    public boolean changePassword(Long restaurantId, String oldPassword, String newPassword) {

        RestaurantEntity existingRestaurant = restaurantRepository.findById(restaurantId)
                .orElseThrow(() -> new RuntimeException("Restaurant not found"));

        String currentPasswordHash = existingRestaurant.getPassword();

        if (!passwordEncoder.matches(oldPassword, currentPasswordHash)) {
            return false;
        }
        existingRestaurant.setPassword(passwordEncoder.encode(newPassword));

        RestaurantEntity updatedRestaurant = restaurantRepository.save(existingRestaurant);

        return true;

    }

    //2.Find nearby restaurent
    public List<RestaurantDTO> findNearbyRestaurants(double latitude, double longitude, double radiusInMeters) {
        List<RestaurantEntity> restaurantEntities =  restaurantRepository.findRestaurantsWithinDistance(longitude, latitude, radiusInMeters);

        return restaurantEntities.stream().map(restaurantEntity -> {
            RestaurantDTO restaurantDTO = modelMapper.map(restaurantEntity, RestaurantDTO.class);

            //Mannual map coordinates
            if (restaurantEntity.getLocation() != null) {
                restaurantDTO.setLatitude(restaurantEntity.getLocation().getY());
                restaurantDTO.setLongitude(restaurantEntity.getLocation().getX());
            }
            restaurantDTO.setPassword(null);

            return restaurantDTO;

        }).toList();
    }

    public RestaurantDTO findRestaurantById(@PathVariable Long id){
        RestaurantEntity entity = restaurantRepository.findById(id).orElse(null);
        RestaurantDTO dto =  modelMapper.map(entity, RestaurantDTO.class);

        if (entity.getLocation() != null) {
            dto.setLatitude(entity.getLocation().getY());
            dto.setLongitude(entity.getLocation().getX());
        }
        dto.setPassword(null);

        return dto;
    }

    public RestaurantDTO getRestaurentLocationById(Long id) {
        RestaurantEntity entity = restaurantRepository.findById(id).orElse(null);
        RestaurantDTO dto =  modelMapper.map(entity, RestaurantDTO.class);

        if (entity.getLocation() != null) {
            dto.setLatitude(entity.getLocation().getY());
            dto.setLongitude(entity.getLocation().getX());
        }
        dto.setPassword(null);
        dto.setId(null);
        dto.setEmail(null);


        return dto;
    }

}
