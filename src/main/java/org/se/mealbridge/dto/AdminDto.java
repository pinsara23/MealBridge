package org.se.mealbridge.dto;

import lombok.Data;

@Data
public class AdminDto {

    private Long id;

    private String userName;
    private String password;
    private String role = "staff";
}
