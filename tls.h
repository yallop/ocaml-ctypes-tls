#ifndef TLS_H
#define TLS_H

#include <stdint.h>
#include <stddef.h>

struct tls;
struct tls_config;

int
tls_init(void);

const char *
tls_error(struct tls *ctx);

struct tls_config *
tls_config_new(void);

void
tls_config_free(struct tls_config *config);

int
tls_config_set_ca_file(struct tls_config *config, const char *ca_file);

int
tls_config_set_ca_path(struct tls_config *config, const char *ca_path);

int
tls_config_set_cert_file(struct tls_config *config, const char *cert_file);

int
tls_config_set_cert_mem(struct tls_config *config, const uint8_t *cert, size_t len);

int
tls_config_set_ciphers(struct tls_config *config, const char *ciphers);

int
tls_config_set_ecdhcurve(struct tls_config *config, const char *name);

int
tls_config_set_key_file(struct tls_config *config, const char *key_file);

int
tls_config_set_key_mem(struct tls_config *config, const uint8_t *key, size_t len);

int
tls_config_set_protocols(struct tls_config *config, uint32_t protocols);

int
tls_config_set_verify_depth(struct tls_config *config, int verify_depth);

void
tls_config_clear_keys(struct tls_config *config);

void
tls_config_insecure_noverifyhost(struct tls_config *config);

void
tls_config_insecure_noverifycert(struct tls_config *config);

void
tls_config_verify(struct tls_config *config);

struct tls *
tls_client(void);

struct tls *
tls_server(void);

int
tls_configure(struct tls *ctx, struct tls_config *config);

void
tls_reset(struct tls *ctx);

int
tls_close(struct tls *ctx);

void
tls_free(struct tls *ctx);

int
tls_connect(struct tls *ctx, const char *host, const char *port);

int
tls_connect_socket(struct tls *ctx, int s, const char *hostname);

int
tls_read(struct tls *ctx, void *buf, size_t buflen, size_t *outlen);

int
tls_write(struct tls *ctx, const void *buf, size_t buflen);

#endif /* TLS_H */
