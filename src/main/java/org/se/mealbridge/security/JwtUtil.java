package org.se.mealbridge.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.function.Function;

@Component
public class JwtUtil {

    private static final Key SECRET_KEY = Keys.secretKeyFor(SignatureAlgorithm.HS256);

    private final long DURATION = 1000 * 60 * 60 * 10 ; //10 hours

    public String generateToken(String userName, String role) {

        return Jwts.builder()
                .setSubject(userName)
                .claim("role", role)
                .setIssuedAt(new Date())
                .signWith(SECRET_KEY)
                .setExpiration(new java.util.Date(System.currentTimeMillis() + DURATION))
                .compact();
    }

//    public String extractUsername(String token) {
//
//        Claims claims = Jwts.parserBuilder()
//                .setSigningKey(SECRET_KEY)
//                .build()
//                .parseClaimsJws(token)
//                .getBody();
//
//        return claims.getSubject();
//    }

    public boolean validateToken(String token, UserDetails userDetails) {
        final String username = extractUsername(token);
        // Token is valid if:
        // A) The username matches the UserDetails passed in
        // B) The token is NOT expired
        return (username.equals(userDetails.getUsername()) && ! isTokenExpired(token));
    }

    private boolean isTokenExpired(String token) {
        return extractExpiration(token).before(new Date());
    }

    private Date extractExpiration(String token) {
        return extractClaim(token, Claims::getExpiration);
    }

    // 5. Generic Claim Extractor (Helper)
    public <T> T extractClaim(String token, Function<Claims, T> claimsResolver) {
        final Claims claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    // 6. Extract All Claims (The parser)
    private Claims extractAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(SECRET_KEY) // Must match the key used in generateToken
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    public String extractUsername(String token) {
        return extractClaim(token, Claims::getSubject);
    }
}
