package de.diakonie.onlineberatung.authenticator;

import static java.util.Objects.isNull;

import java.util.Objects;
import javax.ws.rs.ForbiddenException;
import javax.ws.rs.NotAuthorizedException;
import org.keycloak.models.KeycloakSession;
import org.keycloak.models.RoleModel;
import org.keycloak.services.managers.AppAuthManager.BearerTokenAuthenticator;

public class BearerTokenSessionAuthenticator implements SessionAuthenticator {

  private static final String ROLE_REQUIRED = "technical";

  @Override
  public void authenticate(KeycloakSession session) {
    var auth = new BearerTokenAuthenticator(session).authenticate();
    if (auth == null) {
      throw new NotAuthorizedException("Bearer");
    } else if (isNull(auth.getUser()) || auth.getUser().getRoleMappingsStream()
        .map(RoleModel::getName)
        .noneMatch(name -> Objects.equals(name, ROLE_REQUIRED))) {

      throw new ForbiddenException("Does not have required role");
    }
  }
}
