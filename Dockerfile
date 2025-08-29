# 1) Build stage
FROM quay.io/keycloak/keycloak:24.0.4 AS builder

ENV KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true

COPY --chown=keycloak:keycloak keycloak-otp-config-spi-1.0-SNAPSHOT-keycloak.jar /opt/keycloak/providers/

# Normalize timestamps and build with the same options you’ll use at runtime
RUN touch -m --date=@1743465600 /opt/keycloak/providers/* && \
    /opt/keycloak/bin/kc.sh build \
      --db=mariadb \
      --http-relative-path=/auth \
      --http-management-relative-path=/auth \
      --health-enabled=true \
      --metrics-enabled=true

# 2) Runtime stage
FROM quay.io/keycloak/keycloak:24.0.4
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Keep these envs the same as the build (prevents “changes detected”)
ENV KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start","--optimized"]