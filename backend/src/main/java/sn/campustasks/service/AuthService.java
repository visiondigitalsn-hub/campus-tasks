package sn.campustasks.service;
import sn.campustasks.model.*;
import sn.campustasks.repository.*;
import sn.campustasks.dto.Dto.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import java.time.*;
import java.security.*;
import java.nio.charset.StandardCharsets;
import java.util.*;
@Service @Transactional
public class AuthService {
 private final StudentRepository students; private final AuthTokenRepository tokens; private final PasswordEncoder encoder; private final long hours;
 public AuthService(StudentRepository s,AuthTokenRepository t,PasswordEncoder e,@Value("${campus.token-hours}") long h) { students=s;tokens=t;encoder=e;hours=h; }
 public Session register(Register input) {
  String email=input.email().strip().toLowerCase(Locale.ROOT);
  if(students.findByEmail(email).isPresent()) throw new BusinessException(HttpStatus.CONFLICT,"Cette adresse e-mail est déjà utilisée.");
  checkPassword(input.password());
  Student s=new Student();s.name=input.name().strip();s.email=email;s.passwordHash=encoder.encode(input.password());students.saveAndFlush(s);
  return issue(s);
 }
 public Session login(Login input) {
  Student s=students.findByEmail(input.email().strip().toLowerCase(Locale.ROOT)).orElseThrow(()->new BusinessException(HttpStatus.UNAUTHORIZED,"E-mail ou mot de passe incorrect."));
  checkPassword(input.password());
  if(!encoder.matches(input.password(),s.passwordHash)) throw new BusinessException(HttpStatus.UNAUTHORIZED,"E-mail ou mot de passe incorrect.");
  return issue(s);
 }
 private void checkPassword(String password) { if(password.getBytes(StandardCharsets.UTF_8).length>72) throw new BusinessException(HttpStatus.BAD_REQUEST,"Le mot de passe dépasse 72 octets UTF-8."); }
 private Session issue(Student s) {
  byte[] random=new byte[32];new SecureRandom().nextBytes(random);
  String raw=Base64.getUrlEncoder().withoutPadding().encodeToString(random);
  AuthToken t=new AuthToken();t.owner=s;t.tokenHash=hash(raw);t.expiresAt=Instant.now().plus(Duration.ofHours(hours));tokens.save(t);
  return new Session(raw,t.expiresAt,s.name);
 }
 @Transactional(readOnly=true) public Optional<Long> authenticate(String raw) {
  return tokens.findByTokenHash(hash(raw)).filter(t->t.expiresAt.isAfter(Instant.now())).map(t->t.owner.id);
 }
 public void logout(String raw) { tokens.findByTokenHash(hash(raw)).ifPresent(tokens::delete); }
 public static String hash(String raw) {
  try { return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(raw.getBytes(StandardCharsets.UTF_8))); }
  catch(NoSuchAlgorithmException e) { throw new IllegalStateException(e); }
 }
}
