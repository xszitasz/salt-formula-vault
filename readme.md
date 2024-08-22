# Vault Agent Setup Documentation

## `vaultAgent.sls`

This SaltStack state file configures and manages the Vault agent. It performs the following tasks:

1. **Handle ZIP File**:
   - Extracts the Vault binary from a ZIP file to `/usr/local/bin`.
   - Skips verification and sets permissions for the extracted files.

2. **Ensure Directory**:
   - Creates the directory `/etc/vault.d` with the specified permissions (user: root, group: root, mode: 600).

3. **Copy Config File**:
   - Manages the Vault configuration file `config.hcl` located in `/etc/vault.d`, ensuring it is copied from the Salt state source.

4. **Copy Service File**:
   - Manages the systemd service file `vault-agent.service`, ensuring it is copied to `/etc/systemd/system` with the correct permissions.

5. **Reload Systemd**:
   - Executes `systemctl daemon-reload` to reload systemd and apply the new service configuration.

6. **Copy Template File**:
   - Manages the Jinja template file `spring-boot-token.ctmpl`, copying it to `/etc/vault.d` and applying the Jinja template context.

7. **Create and Move PID File**:
   - Creates a temporary PID file in `/tmp` and then moves it to `/etc/vault.d`.

8. **Manage Role and Secret IDs**:
   - Manages files for `role_id` and `secret_id` in `/etc/vault.d`, ensuring they are created with the correct contents and permissions.

9. **Manage Vault Agent Service**:
   - Stops the Vault agent service if it is running and starts it again, ensuring it is enabled and correctly configured to watch the relevant files.

## `vault-agent.service`

A systemd service file that configures the Vault agent service:

- **Description**: Vault Agent to serve Tokens
- **Service**:
  - **User**: root
  - **WorkingDirectory**: /etc/vault.d
  - **ExecStart**: /usr/local/bin/vault agent -config=/etc/vault.d/config.hcl
  - **Restart**: always
- **Install**:
  - **WantedBy**: multi-user.target

## `spring-boot-token.ctmpl`

A Jinja template used to generate a Spring Boot token:

- Uses the `secret` function to create a token for the Spring Boot role.
- The token is stored in a variable named `VAULT_TOKEN`.

## `map.jinja`

A Jinja file used to set variables based on Salt grains and pillars:

- **Purpose**: Configures dynamic values based on the environment and Salt data.
- **Site Variable**: Determines the value of `suffix` based on the Salt grain `site`:
  - If `site` is `'psm'`, `suffix` is set to an empty string.
  - If `site` is `'test'`, `suffix` is set to `'test'`.
  - For other sites, `suffix` remains an empty string.
- **Variables**:
  - `suffix`: A suffix used in token creation.
  - `role_id`: Retrieved from the Salt pillar `vault:role_id`.
  - `secret_id`: Retrieved from the Salt pillar `vault:secret_id`.

## `config.hcl`

Vault configuration file that specifies:

- **PID File**: Location of the PID file.
- **Vault Settings**:
  - **Address**: URL for the Vault server.
  - **TLS Settings**: Skips TLS verification.
  - **Retry Settings**: Number of retry attempts.
- **Auto Auth**:
  - **Method**: AppRole authentication with configuration files for `role_id` and `secret_id`.
- **Sink**:
  - **File Path**: Path where the agent token is stored.
- **Template**:
  - **Source**: Path to the template file.
  - **Destination**: Path where the rendered template is saved.

## `init.sls`

This file is currently empty.
