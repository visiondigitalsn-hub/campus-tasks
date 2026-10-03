package sn.campustasks.security;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import sn.campustasks.service.AuthService;
import java.io.IOException;
import java.util.List;
public class TokenFilter extends OncePerRequestFilter {
 private final AuthService auth;
 public TokenFilter(AuthService auth) { this.auth=auth; }
 @Override protected void doFilterInternal(HttpServletRequest request,HttpServletResponse response,FilterChain chain) throws ServletException,IOException {
  String header=request.getHeader("Authorization");
  if(header!=null&&header.startsWith("Bearer ")) auth.authenticate(header.substring(7)).ifPresent(id->SecurityContextHolder.getContext().setAuthentication(new UsernamePasswordAuthenticationToken(id,null,List.of())));
  chain.doFilter(request,response);
 }
}
