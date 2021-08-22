package com.jiawa.wiki.controller;

import com.jiawa.wiki.domain.Test;
import com.jiawa.wiki.service.TestService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
public class TestController {
    @Autowired
    private TestService testService;
    @Value("${test.hello:HELLO}")
    private String hello;
    @GetMapping("/hello")
    public String hello(){
        return "Hello World" + hello;
    }

    @PostMapping("/hello/post")
    public String helloPost(String name){
        return "hello world" + name;
    }
    @GetMapping("/test/list")
    public List<Test> list(){
        return testService.list();
    }
}
