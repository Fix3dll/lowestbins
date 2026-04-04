FROM rustlang/rust:nightly AS builder
WORKDIR /usr/src/lowestbins

RUN apt-get update && apt-get install -y --no-install-recommends pkg-config curl && rm -rf /var/lib/apt/lists/*

COPY Cargo.toml Cargo.lock ./
COPY src ./src
COPY generated ./generated
COPY benches ./benches
COPY build.rs update_display_names.rs README.md ./

ENV RUSTFLAGS="--cfg reqwest_unstable"
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 runner && \
    useradd --uid 1000 --home-dir /data --create-home --gid runner runner

USER runner
VOLUME /data
WORKDIR /data

EXPOSE 8080/tcp
COPY --from=builder /usr/src/lowestbins/target/release/lowestbins .
CMD ["./lowestbins"]
