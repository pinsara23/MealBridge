package org.se.mealbridge.dto;

public record ResetPasswordRequest(String token, String newPassword) {
}
