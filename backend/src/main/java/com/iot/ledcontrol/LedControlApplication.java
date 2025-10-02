package com.iot.ledcontrol;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class LedControlApplication {

    public static void main(String[] args) {
        SpringApplication.run(LedControlApplication.class, args);
        System.out.println("\n==============================================");
        System.out.println("IoT LED Control Backend Started Successfully!");
        System.out.println("API: http://localhost:8080/api");
        System.out.println("==============================================\n");
    }
}
