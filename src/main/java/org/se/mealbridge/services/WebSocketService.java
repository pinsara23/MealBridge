package org.se.mealbridge.services;

import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

@Service
public class WebSocketService {

    private final SimpMessagingTemplate simpMessagingTemplate;

    public WebSocketService(SimpMessagingTemplate simpMessagingTemplate) {
        this.simpMessagingTemplate = simpMessagingTemplate;
    }

    public void notifyAllVolunteers(String message){

        //send message to all volunteers
        simpMessagingTemplate.convertAndSend("/topic/volunteers",message);
    }

    public void notifVolunteer(Long volunteerId, String message){

        String topic = "/topic/volunteer/" + volunteerId;
        simpMessagingTemplate.convertAndSend(topic,message);
    }

    public void notifyDonationUpdate(Long donationId, String status){

        String topic = "/topic/donation/" + donationId;
        simpMessagingTemplate.convertAndSend(topic, status);
    }

    //to notify relevant restaurant
    public void notifyRestaurant(Long restaurantId, String message) {

        String topic = "/topic/restaurant/" + restaurantId;
        simpMessagingTemplate.convertAndSend(topic, message);
    }

    public void notifyAdmin(String message) {
        String topic = "/topic/admins";
        simpMessagingTemplate.convertAndSend(topic, message);
    }
}
