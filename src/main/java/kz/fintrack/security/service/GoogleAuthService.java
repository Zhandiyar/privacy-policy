package kz.fintrack.security.service;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import kz.fintrack.security.config.GoogleClientConfig;
import kz.fintrack.security.dto.GoogleSignInRequest;
import kz.fintrack.security.exception.AuthenticationException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Collections;

@Slf4j
@Service
@RequiredArgsConstructor
public class GoogleAuthService {
    private final GoogleClientConfig googleClientConfig;

    public GoogleIdToken.Payload verifyGoogleToken(GoogleSignInRequest request) {
        String clientId = getClientId(request.getPlatform());
        log.info("Верификация Google токена для платформы: {}, используя clientId: {}", request.getPlatform(), clientId);

        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(new NetHttpTransport(), new GsonFactory())
                    .setAudience(Collections.singletonList(clientId))
                    .build();

            GoogleIdToken idToken = verifier.verify(request.getIdToken());
            if (idToken == null) {
                log.error("Недействительный ID токен");
                throw new AuthenticationException("Недействительный ID токен");
            }

            GoogleIdToken.Payload payload = idToken.getPayload();
            log.info("Google токен успешно верифицирован для пользователя: {}", payload.getEmail());
            return payload;

        } catch (GeneralSecurityException | IOException e) {
            log.error("Ошибка при верификации Google токена", e);
            throw new AuthenticationException("Ошибка при верификации Google токена");
        }
    }

    private String getClientId(String platform) {
        return switch (platform.toUpperCase()) {
            case "ANDROID" -> googleClientConfig.getAndroidClientId();
            case "IOS" -> googleClientConfig.getIosClientId();
            default -> googleClientConfig.getWebClientId();
        };
    }
} 