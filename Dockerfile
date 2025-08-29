# 1) Build stage
FROM quay.io/keycloak/keycloak:24.0.4 AS builder

ENV KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true

# copy your provider(s)
COPY --chown=keycloak:keycloak keycloak-otp-config-spi-1.0-SNAPSHOT-keycloak.jar /opt/keycloak/providers/

# Normalize timestamps (portable) and build with the same options you'll use at runtime
RUN set -eux; \
    if find /opt/keycloak/providers -type f >/dev/null 2>&1; then \
        # Use -t YYYYMMDDhhmm.SS (UTC) instead of GNU --date
        find /opt/keycloak/providers -type f -exec touch -m -t 202501010000.00 {} +; \
    fi; \
    /opt/keycloak/bin/kc.sh build \
      --db=mariadb \
      --http-relative-path=/auth \
      --http-management-relative-path=/management \
      --health-enabled=true \
      --metrics-enabled=true

# 2) Runtime stage
FROM quay.io/keycloak/keycloak:24.0.4
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Keep build-time toggles consistent to avoid "changes detected" messages
ENV KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start","--optimized"]
