package org.se.mealbridge.services;

import org.se.mealbridge.dto.MonthlyStatsDto;
import org.se.mealbridge.entity.DonationEntity;
import org.se.mealbridge.entity.DonationStatus;
import org.se.mealbridge.repository.DonationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AnalyticalService {

    @Autowired
    private DonationRepository donationRepository;

    public List<MonthlyStatsDto> getMonthlyStatsDistributedDonations(Long restaurentId){

        List<DonationEntity> donationHistory = donationRepository.findByDonorIdAndStatusIn(
                restaurentId, List.of(DonationStatus.DISTRIBUTED, DonationStatus.PICKED_UP));

        Map<String, Double> statsMap = donationHistory.stream()
                .collect(Collectors.groupingBy(
                        d -> d.getPostedAt().getMonth().toString(), //group by month
                        Collectors.summingDouble(DonationEntity::getQuantityKg) //summing weight
                ));

        List<MonthlyStatsDto> monthlyStats =  new ArrayList<>();
        for (Map.Entry<String, Double> entry : statsMap.entrySet()) {
            monthlyStats.add(new MonthlyStatsDto(entry.getKey(), entry.getValue()));
        }

        return monthlyStats;
    }

    public List<MonthlyStatsDto> getMonthlyStatsExpiredDonations(Long restaurentId){

        List<DonationEntity> donationHistory = donationRepository.findByDonorIdAndStatusIn(
                restaurentId, List.of(DonationStatus.EXPIRED));

        Map<String, Double> statsMap = donationHistory.stream()
                .collect(Collectors.groupingBy(
                        d -> d.getPostedAt().getMonth().toString(), //group by month
                        Collectors.summingDouble(DonationEntity::getQuantityKg) //summing weight
                ));

        List<MonthlyStatsDto> monthlyStats =  new ArrayList<>();
        for (Map.Entry<String, Double> entry : statsMap.entrySet()) {
            monthlyStats.add(new MonthlyStatsDto(entry.getKey(), entry.getValue()));
        }

        return monthlyStats;
    }
}
