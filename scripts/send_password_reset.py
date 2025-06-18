#!/usr/bin/env python3

from keycloak import KeycloakAdmin
import argparse


def parse_args():
    parser = argparse.ArgumentParser(description="Bulk Keycloak password reset email sender")
    parser.add_argument("--server-url", required=True, help="Keycloak server URL, e.g. http://localhost:8080/")
    parser.add_argument("--realm", required=True, help="Target realm name")
    parser.add_argument("--admin-user", required=True, help="Keycloak admin username")
    parser.add_argument("--admin-password", required=True, help="Keycloak admin password")
    parser.add_argument("--client-id", default="admin-cli", help="Admin client ID (default: admin-cli)")
    parser.add_argument("--lifespan", type=int, default=86400, help="Reset link lifespan in seconds (default: 86400 = 24h)")
    parser.add_argument("--max-users", type=int, default=1000, help="Max number of users to fetch (default: 1000)")
    parser.add_argument("--insecure", action="store_true", help="Disable SSL verification (for self-signed certs)")

    return parser.parse_args()


def main():
    args = parse_args()

    try:
        keycloak_admin = KeycloakAdmin(
            server_url=args.server_url,
            username=args.admin_user,
            password=args.admin_password,
            realm_name="qgis",  # Admin usually logs in to master
            client_id=args.client_id,
            verify=not args.insecure
        )
    except Exception as e:
        print(f"❌ Failed to connect to Keycloak: {e}")
        return

    keycloak_admin.realm_name = args.realm

    try:
        users = keycloak_admin.get_users({"max": args.max_users})
    except Exception as e:
        print(f"❌ Failed to retrieve users: {e}")
        return
    sent = 0
    for user in users:
        username = user.get("username")
        email = user.get("email")
        user_id = user.get("id")

        if not email:
            print(f"⚠️ Skipping {username}: no email")
            continue

        try:
            # Filter users that don't have any credentials
            credentials = keycloak_admin.get_credentials(user_id)
            if not credentials:
                keycloak_admin.send_update_account(
                    user_id=user_id,
                    payload=["UPDATE_PASSWORD"]
                )
                print(f"✅ Reset email sent to {username} ({email})")
                sent += 1
            else:
                print(f"⏭️ Skipping {username}: already has credentials")
            sent += 1
        except Exception as e:
            print(f"❌ Failed for {username}: {e}")

    print(f"\n🎉 Done. Sent password reset emails to {sent} users.")


if __name__ == "__main__":
    main()