package sn.campustasks.controller;
import sn.campustasks.dto.Dto;
import sn.campustasks.service.BusinessException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.http.*;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.dao.DataIntegrityViolationException;
import java.util.stream.Collectors;
@RestControllerAdvice
public class Errors {
 @ExceptionHandler(BusinessException.class) ResponseEntity<Dto.Error> business(BusinessException e) { return ResponseEntity.status(e.status).body(new Dto.Error(e.getMessage())); }
 @ExceptionHandler(MethodArgumentNotValidException.class) ResponseEntity<Dto.Error> validation(MethodArgumentNotValidException e) {
  String message=e.getBindingResult().getFieldErrors().stream().map(f->f.getField()+" : "+f.getDefaultMessage()).collect(Collectors.joining(" ; "));
  return ResponseEntity.badRequest().body(new Dto.Error("Saisie invalide. "+message));
 }
 @ExceptionHandler({HttpMessageNotReadableException.class,MethodArgumentTypeMismatchException.class}) ResponseEntity<Dto.Error> format(Exception e) { return ResponseEntity.badRequest().body(new Dto.Error("Format invalide : vérifiez les champs, la date et les valeurs proposées.")); }
 @ExceptionHandler(DataIntegrityViolationException.class) ResponseEntity<Dto.Error> conflict(Exception e) { return ResponseEntity.status(409).body(new Dto.Error("Conflit de données : cet élément existe déjà ou est encore utilisé.")); }
}
