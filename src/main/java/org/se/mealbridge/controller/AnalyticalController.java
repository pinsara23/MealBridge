package org.se.mealbridge.controller;

import org.se.mealbridge.dto.DayStats;
import org.se.mealbridge.dto.DonationsDto;
import org.se.mealbridge.dto.MonthlyStatsDto;
import org.se.mealbridge.services.AnalyticalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/analytic")
@CrossOrigin(origins = "*")
public class AnalyticalController {

    @Autowired
    private AnalyticalService analyticalService;

    // /api/analytic/graph/distributed/{id}
    @GetMapping("/graph/distributed/{id}")
    public List<MonthlyStatsDto> getMonthlyDistributedComparison(@PathVariable Long id){
        return analyticalService.getMonthlyStatsDistributedDonations(id);
    }

    // /api/analytic/graph/expired/{id}
    @GetMapping("/graph/expired/{id}")
    public List<MonthlyStatsDto> getMonthlyExpiredComparison(@PathVariable Long id){
        return analyticalService.getMonthlyStatsExpiredDonations(id);
    }

    // /api/analytic/graph/all/{id}
    @GetMapping("/graph/all/{id}")
    public List<MonthlyStatsDto> getMonthlyComparison(@PathVariable Long id){
        return analyticalService.getMonthlyStatsAllDonations(id);
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

    // /api/analytic/donations/count/aval/volunteer/{id}
    @GetMapping("/donations/count/aval/volunteer/{id}")
    public int getCountOfAvailableDonationsByVolunteerId(@PathVariable Long id){
        return analyticalService.getCountOfAvailableDonationsByVolunteerId(id);
    }

    // /api/analytic/donations/count/finish/volunteer/{id}
    @GetMapping("/donations/count/finish/volunteer/{id}")
    public int getCountOfFinishedDonationsByVolunteerId(@PathVariable Long id){
        return analyticalService.getCountOfFinishedDonationsByVolunteerId(id);
    }

    // /api/analytic/donations/count/total/volunteer/{id}
    @GetMapping("/donations/count/total/volunteer/{id}")
    public int getCountOfTotalDonationsByVolunteerId(@PathVariable Long id){
        return analyticalService.getCountOfTotalDonationsByVolunteerId(id);
    }

    // /api/analytic/donations/count/month/volunteer/{id}
    @GetMapping("/donations/count/month/volunteer/{id}")
    public int countGaveDonationsByVolunteersByMonth(@PathVariable Long id){
        return analyticalService.countOfThisMonthGaveDonationsByVolunteerId(id);
    }

    // /api/analytic/creditor/volunteer/{id}
    @GetMapping("/creditor/volunteer/{id}")
    public Double getCreditScoreByVolunteerId(@PathVariable Long id){
        return analyticalService.getCreditScoreByVolunteerId(id);
    }

    // /api/analytic/predict/{restaurantId}
    @GetMapping("/predict/{restaurantId}")
    public Double getValuesForMlModel(@PathVariable Long restaurantId){
        return analyticalService.predictNextDayWastage(restaurantId);
    }

}
