package com.example.geekeradmin.config;

import com.example.geekeradmin.filter.JwtAuthenticationFilter;
import com.example.geekeradmin.service.RoleService;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.Arrays;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .cors(cors -> cors.configurationSource(corsConfigurationSource()))
            .csrf(csrf -> csrf.disable())
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                // 公开接口：无需登录
                .requestMatchers("/geeker/login").permitAll()
                .requestMatchers("/geeker/public/**").permitAll()
                .requestMatchers("/geeker/file/img/**").permitAll()
                .requestMatchers("/uploads/**").permitAll()
                // 全体登录用户可用（需先于对应模块的 admin 规则声明，否则会被前缀拦截）
                .requestMatchers("/geeker/menu/list").authenticated()
                .requestMatchers("/geeker/user/info").authenticated()
                .requestMatchers(HttpMethod.GET, "/geeker/dict/data/type/**").authenticated()
                // 系统管理模块：仅超级管理员（admin）可访问
                .requestMatchers("/geeker/user/**").hasRole(RoleService.ROLE_ADMIN)
                .requestMatchers("/geeker/role/**").hasRole(RoleService.ROLE_ADMIN)
                .requestMatchers("/geeker/menu/**").hasRole(RoleService.ROLE_ADMIN)
                .requestMatchers("/geeker/department/**").hasRole(RoleService.ROLE_ADMIN)
                .requestMatchers("/geeker/dict/**").hasRole(RoleService.ROLE_ADMIN)
                .requestMatchers("/geeker/job/**").hasRole(RoleService.ROLE_ADMIN)
                .requestMatchers("/geeker/log/**").hasRole(RoleService.ROLE_ADMIN)
                // 其余业务接口（devAssets / novel / file 上传等）：登录即可
                .anyRequest().authenticated()
            )
            .exceptionHandling(ex -> ex
                .authenticationEntryPoint((request, response, authException) -> {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write("{\"code\":401,\"msg\":\"登录已过期，请重新登录\",\"data\":null}");
                })
                .accessDeniedHandler((request, response, accessDeniedException) -> {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.setContentType(MediaType.APPLICATION_JSON_VALUE);
                    response.setCharacterEncoding("UTF-8");
                    response.getWriter().write("{\"code\":403,\"msg\":\"无权限访问该资源\",\"data\":null}");
                })
            )
            .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(Arrays.asList("*"));
        config.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(Arrays.asList("*"));
        config.setAllowCredentials(false);
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}
