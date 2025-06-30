package kz.fintrack.security.dto;

import lombok.Data;

@Data
public class GoogleSignInRequest {
    private String idToken;
    private String platform;
} 