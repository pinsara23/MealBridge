package org.se.mealbridge.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DayStats {

    private int dayIndex;
    private double totalWeight;
}
