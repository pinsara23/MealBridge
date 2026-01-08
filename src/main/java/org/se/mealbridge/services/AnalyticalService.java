package org.se.mealbridge.services;

import org.modelmapper.ModelMapper;
import org.se.mealbridge.dto.DonationsDto;
import org.se.mealbridge.dto.MonthlyStatsDto;
import org.se.mealbridge.entity.DonationEntity;
import org.se.mealbridge.entity.DonationStatus;
import org.se.mealbridge.repository.DonationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AnalyticalService {

    @Autowired
    private DonationRepository donationRepository;
    @Autowired
    private ModelMapper modelMapper;

    private DonationsDto convertToDto(DonationEntity donationEntity) {
        DonationsDto donationsDto = modelMapper.map(donationEntity, DonationsDto.class);
        donationsDto.setRestaurantId(donationEntity.getDonor().getId());
        donationsDto.setRestaurantName(donationEntity.getDonor().getBusinessName());
        return donationsDto;
    }

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

    public List<DonationsDto> getThisMonthGaveDonationsByRestaurantId(Long restaurantId){

        LocalDateTime startOfMonth = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfMonth = startOfMonth.plusMonths(1).minusNanos(1);

        List<DonationEntity> donations = donationRepository.findByDonorIdAndStatusAndPostedAtBetween(
                restaurantId,
                DonationStatus.PICKED_UP,
                startOfMonth,
                endOfMonth
        );

        return donations.stream().map(this::convertToDto).toList();
    }

    public int countOfThisMonthGaveDonationsByRestaurantId(Long restaurantId){

        LocalDateTime startOfMonth = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfMonth = startOfMonth.plusMonths(1).minusNanos(1);

        Integer count = donationRepository.countByDonorIdAndStatusAndPostedAtBetween(
                restaurantId,
                DonationStatus.PICKED_UP,
                startOfMonth,
                endOfMonth
        );

        return count != null ? count : 0;
    }

    public int getCountOfTotalDonationsByRestaurantId(Long restaurantId){
        Integer count = donationRepository.countByDonorId(restaurantId);
        return count != null ? count : 0;
    }

    public int getCountOfAvailableDonationsByRestaurantId(Long restaurantId){
        Integer count = donationRepository.countByDonorIdAndStatusIn(restaurantId, List.of(DonationStatus.AVAILABLE, DonationStatus.CLAIMED));
        return count != null ? count : 0;
    }
}
