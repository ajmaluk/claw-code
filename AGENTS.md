# Agent Commands and Workflows

## Verification Commands

To ensure code correctness after changes, run the following commands in the `rust/` directory:

- `cargo fmt` - Format the Rust code
- `cargo clippy --workspace --all-targets -- -D warnings` - Lint the code with warnings as errors
- `cargo test --workspace` - Run the test suite

Note: These commands require Rust to be installed. For zero-dependency usage, users should use the pre-built binaries via the installer scripts.