package org.se.mealbridge.services;

import org.locationtech.jts.geom.Coordinate;
import org.locationtech.jts.geom.GeometryFactory;
import org.locationtech.jts.geom.Point;
import org.modelmapper.ModelMapper;
import org.se.mealbridge.dto.RestaurantDTO;
import org.se.mealbridge.entity.RestaurantEntity;
import org.se.mealbridge.repository.RestaurantRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class RestaurentService {

    @Autowired
    private RestaurantRepository restaurantRepository;

    @Autowired
    private ModelMapper modelMapper;

    private final GeometryFactory geometryFactory = new GeometryFactory();

    //1.Register a restaurant
    public RestaurantEntity registerRestaurent(RestaurantDTO restaurantDTO) {

        RestaurantEntity restaurantEntity = modelMapper.map(restaurantDTO, RestaurantEntity.class);

        //geometry mapping
        Point point  = geometryFactory.createPoint(new Coordinate(restaurantDTO.getLongitude(), restaurantDTO.getLatitude()));
        point.setSRID(4326);
        restaurantEntity.setLocation(point);

        return restaurantRepository.save(restaurantEntity);
    }

    //2.Find nearby restaurent
    public List<RestaurantEntity> findNearbyRestaurants(double latitude, double longitude, double radiusInMeters) {
        return restaurantRepository.findRestaurantsWithinDistance(longitude, latitude, radiusInMeters);
    }

}
