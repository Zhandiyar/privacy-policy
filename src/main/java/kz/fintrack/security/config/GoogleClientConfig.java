package kz.fintrack.security.config;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Getter
@Setter
@Configuration
@ConfigurationProperties(prefix = "google.client")
public class GoogleClientConfig {
    private String webClientId;
    private String androidClientId;
    private String iosClientId;
} 