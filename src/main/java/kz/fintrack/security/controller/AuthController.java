package kz.fintrack.security.controller;

import kz.fintrack.security.config.GoogleClientConfig;
import kz.fintrack.security.dto.GoogleSignInRequest;
import kz.fintrack.security.service.GoogleAuthService;
import kz.fintrack.security.service.JwtService;
import kz.fintrack.user.entity.User;
import kz.fintrack.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UserService userService;
    private final JwtService jwtService;
    private final GoogleAuthService googleAuthService;
    private final GoogleClientConfig googleClientConfig;

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String password = request.get("password");

        User user = userService.authenticate(username, password);
        String token = jwtService.generateToken(user);

        return ResponseEntity.ok(Map.of(
            "success", true,
            "data", token,
            "message", "Успешная авторизация"
        ));
    }

    @PostMapping("/register")
    public ResponseEntity<Map<String, Object>> register(@RequestBody Map<String, String> request) {
        String username = request.get("username");
        String email = request.get("email");
        String password = request.get("password");

        User user = userService.register(username, email, password);
        String token = jwtService.generateToken(user);

        return ResponseEntity.ok(Map.of(
            "success", true,
            "data", token,
            "message", "Успешная регистрация"
        ));
    }

    @PostMapping("/google-signin")
    public ResponseEntity<Map<String, Object>> googleSignIn(@RequestBody GoogleSignInRequest request) {
        String idToken = request.getIdToken();
        String platform = request.getPlatform();

        String clientId = switch (platform.toLowerCase()) {
            case "ios" -> googleClientConfig.getIosClientId();
            case "android" -> googleClientConfig.getAndroidClientId();
            default -> googleClientConfig.getWebClientId();
        };

        User user = googleAuthService.verifyGoogleToken(idToken, clientId);
        String token = jwtService.generateToken(user);

        return ResponseEntity.ok(Map.of(
            "success", true,
            "data", token,
            "message", "Успешная авторизация через Google"
        ));
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<Map<String, Object>> forgotPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        userService.sendPasswordResetEmail(email);

        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Инструкции по сбросу пароля отправлены на ваш email"
        ));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<Map<String, Object>> resetPassword(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        String newPassword = request.get("newPassword");

        userService.resetPassword(token, newPassword);

        return ResponseEntity.ok(Map.of(
            "success", true,
            "message", "Пароль успешно изменен"
        ));
    }
} 