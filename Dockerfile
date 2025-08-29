# 1) Build stage: add providers, enable build-time options, then build
FROM quay.io/keycloak/keycloak:26.3.3 AS builder

# (optional) enable health/metrics at BUILD time
ENV KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true

# Add your custom provider JAR BEFORE the build
COPY --chown=keycloak:keycloak keycloak-otp-config-spi-1.0-SNAPSHOT-keycloak.jar /opt/keycloak/providers/

# Normalize provider timestamps so Keycloak doesn't rebuild on every start
RUN touch -m --date=@1743465600 /opt/keycloak/providers/* && \
    /opt/keycloak/bin/kc.sh build

# 2) Runtime stage: copy the built distro and just start optimized
FROM quay.io/keycloak/keycloak:26.3.3
COPY --from=builder /opt/keycloak/ /opt/keycloak/

# Provide admin on first boot via env at runtime (recommended)
# e.g. -e KC_BOOTSTRAP_ADMIN_USERNAME=admin -e KC_BOOTSTRAP_ADMIN_PASSWORD=change_me

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start","--optimized"]