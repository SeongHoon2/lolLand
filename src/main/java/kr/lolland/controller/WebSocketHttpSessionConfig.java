package kr.lolland.controller;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.ChannelRegistration;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

import javax.servlet.http.HttpSession;
import java.util.Map;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.Message;

@Configuration
public class WebSocketHttpSessionConfig implements WebSocketMessageBrokerConfigurer {
    @Override
    public void configureClientInboundChannel(ChannelRegistration registration) {
        registration.interceptors(new ChannelInterceptor() {
            @Override
            public Message<?> preSend(Message<?> message, org.springframework.messaging.MessageChannel channel) {
                StompHeaderAccessor accessor = StompHeaderAccessor.wrap(message);
                Map<String,Object> attrs = accessor.getSessionAttributes();
                if (attrs != null && !attrs.containsKey("HTTP.SESSION")) {
                    Object httpSession = accessor.getHeader("simpHttpSession");
                    if (httpSession instanceof HttpSession) attrs.put("HTTP.SESSION", httpSession);
                }
                return message;
            }
        });
    }
}
