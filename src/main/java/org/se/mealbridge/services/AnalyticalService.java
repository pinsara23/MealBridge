package org.se.mealbridge.services;

import org.modelmapper.ModelMapper;
import org.se.mealbridge.dto.DayStats;
import org.se.mealbridge.dto.DonationsDto;
import org.se.mealbridge.dto.MonthlyStatsDto;
import org.se.mealbridge.entity.DonationEntity;
import org.se.mealbridge.entity.DonationStatus;
import org.se.mealbridge.repository.DonationRepository;
import org.se.mealbridge.repository.VolunteerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class AnalyticalService {

    @Autowired
    private DonationRepository donationRepository;
    @Autowired
    private ModelMapper modelMapper;
    @Autowired
    private VolunteerRepository volunteerRepository;

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

    public List<MonthlyStatsDto> getMonthlyStatsAllDonations(Long restaurentId){

        List<DonationEntity> donationHistory = donationRepository.findByDonorId(restaurentId);

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

        Integer count = donationRepository.countByDonorIdAndPostedAtBetween(
                restaurantId,
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

    public int getCountOfAvailableDonationsByVolunteerId(Long volunteerId){
        Integer count = donationRepository.countByAssignedVolunteerIdAndStatusIn(volunteerId, List.of(DonationStatus.PICKED_UP, DonationStatus.CLAIMED));
        return count != null ? count : 0;
    }

    public int getCountOfFinishedDonationsByVolunteerId(Long volunteerId){
        Integer count = donationRepository.countByAssignedVolunteerIdAndStatusIn(volunteerId, List.of(DonationStatus.DISTRIBUTED));
        return count != null ? count : 0;
    }

    public int getCountOfTotalDonationsByVolunteerId(Long volunteerId){
        Integer count = donationRepository.countByAssignedVolunteerId(volunteerId);
        return count != null ? count : 0;
    }

    public int countOfThisMonthGaveDonationsByVolunteerId(Long volunteerId){

        LocalDateTime startOfMonth = LocalDateTime.now().withDayOfMonth(1).withHour(0).withMinute(0).withSecond(0).withNano(0);
        LocalDateTime endOfMonth = startOfMonth.plusMonths(1).minusNanos(1);

        Integer count = donationRepository.countByAssignedVolunteerIdAndPostedAtBetween(
                volunteerId,
                startOfMonth,
                endOfMonth
        );

        return count != null ? count : 0;
    }

    public Double getCreditScoreByVolunteerId(Long volunteerId){
        return volunteerRepository.findCreditScoreById(volunteerId);
    }

    // this send data for ml model to predict next day wastage
    public List<DayStats> getDayStatsForMlModel(Long restaurantId){

        List<DonationEntity> history = donationRepository.findTop50ByDonorId(restaurantId);

        return history.stream()
               .map(donationEntity -> {
                   int javaDate = donationEntity.getPostedAt().getDayOfWeek().getValue();
                   int pyDate = javaDate-1;

                   return new DayStats(pyDate, donationEntity.getQuantityKg());
               }).collect(Collectors.toList());


    }

    public double predictNextDayWastage(Long restaurantId){

        List<DayStats> dayStats = getDayStatsForMlModel(restaurantId);

        final String mlUrl = "http://localhost:5000/predict";
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<List<DayStats>> requestEntity = new HttpEntity<>(dayStats,headers);

        try{
            ResponseEntity<Map> response = restTemplate.postForEntity(mlUrl, requestEntity, Map.class);

            if (response.getBody() != null && response.getBody().containsKey("predictedQuantity")){
                return Double.parseDouble(response.getBody().get("predictedQuantity").toString());
            }
        }catch (Exception e){
            System.out.println("ML service error: " + e.getMessage());
        }

        return 0.0;
    }


}
