package org.se.mealbridge.controller;

import org.se.mealbridge.dto.MonthlyStatsDto;
import org.se.mealbridge.services.AnalyticalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/analytic")
public class AnalyticalController {

    @Autowired
    private AnalyticalService analyticalService;

    // /api/analytic/graph/{id}
    @GetMapping("/graph/distributed/{id}")
    public List<MonthlyStatsDto> getMonthlyDistributedComparison(@PathVariable Long id){
        return analyticalService.getMonthlyStatsDistributedDonations(id);
    }

    @GetMapping("/graph/expired/{id}")
    public List<MonthlyStatsDto> getMonthlyExpiredComparison(@PathVariable Long id){
        return analyticalService.getMonthlyStatsExpiredDonations(id);
    }
}
