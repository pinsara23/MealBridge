package org.se.mealbridge.controller;

import org.se.mealbridge.dto.DonationsDto;
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

    // /api/analytic/graph/distributed/{id}
    @GetMapping("/graph/distributed/{id}")
    public List<MonthlyStatsDto> getMonthlyDistributedComparison(@PathVariable Long id){
        return analyticalService.getMonthlyStatsDistributedDonations(id);
    }

    // /api/analytic/expired/{id}
    @GetMapping("/graph/expired/{id}")
    public List<MonthlyStatsDto> getMonthlyExpiredComparison(@PathVariable Long id){
        return analyticalService.getMonthlyStatsExpiredDonations(id);
    }

    // /api/analytic/donations/month/restaurant/{id}
    @GetMapping("/donations/month/restaurant/{id}")
    public List<DonationsDto> getGaveDonationsByRestaurantsByMonth(@PathVariable Long id){
        return analyticalService.getThisMonthGaveDonationsByRestaurantId(id);
    }

    // /api/analytic/donations/count/month/restaurant/{id}
    @GetMapping("/donations/count/month/restaurant/{id}")
    public int countGaveDonationsByRestaurantsByMonth(@PathVariable Long id){
        return analyticalService.countOfThisMonthGaveDonationsByRestaurantId(id);
    }

    // /api/analytic/donations/count/total/restaurant/{id}
    @GetMapping("/donations/count/total/restaurant/{id}")
    public int getCountOfTotalDonationsByRestaurantId(@PathVariable Long id){
        return analyticalService.getCountOfTotalDonationsByRestaurantId(id);
    }

    // /api/analytic/donations/count/aval/restaurant/{id}
    @GetMapping("/donations/count/aval/restaurant/{id}")
    public int getCountOfAvailableDonationsByRestaurantId(@PathVariable Long id){
        return analyticalService.getCountOfAvailableDonationsByRestaurantId(id);
    }
}
