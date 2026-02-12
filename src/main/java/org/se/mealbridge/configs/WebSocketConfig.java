package org.se.mealbridge.configs;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // Configuration for STOMP endpoints goes here
        // 1. url flutter will connect
        registry.addEndpoint("/ws")
                .setAllowedOriginPatterns("*")
                .withSockJS(); // enable fallback options

    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {

        // 2. the broker message sent to paths starting with /topic
        registry.enableSimpleBroker("/topic");

        // 3. messages sent from client to server with /app prefix
        registry.setApplicationDestinationPrefixes("/app");
    }
}
