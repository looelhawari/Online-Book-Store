package com.example.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        // Protect user pages
        registry.addInterceptor(new AuthInterceptor())
                .addPathPatterns("/catalog", "/cart", "/cart/**",
                                 "/checkout", "/payment", "/order-confirmation",
                                 "/my-orders");

        // Protect admin pages (everything under /admin except /admin/login)
        registry.addInterceptor(new AdminInterceptor())
                .addPathPatterns("/admin/**")
                .excludePathPatterns("/admin/login");
    }
}
