package org.se.mealbridge.dto;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class MonthlyStatsDto {

    private String month;
    private double totalWeight;
}
