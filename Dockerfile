# Use the exact Keycloak version you want
FROM quay.io/keycloak/keycloak:24.0.3 as builder

# Copy your provider JARs
COPY --chown=keycloak:keycloak keycloak-otp-config-spi-1.0-SNAPSHOT-keycloak.jar /opt/keycloak/providers/

# Run the server build once at image build time
RUN /opt/keycloak/bin/kc.sh build --db=mariadb --health-enabled=true --metrics-enabled=true

# Runtime image
FROM quay.io/keycloak/keycloak:24.0.3
COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start","--optimized"]
