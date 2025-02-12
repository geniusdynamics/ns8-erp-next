#!/bin/bash

#
# Copyright (C) 2022 Nethesis S.r.l.
# SPDX-License-Identifier: GPL-3.0-or-later
#

set -e
source database.env
source backup_paths.env
# Check if the service is running
is_service_active() {
	local service_name=$1
	systemctl --user -q is-active "$service_name"
}

# Check if erpnext.service is running and also backend.service
if ! is_service_active "erpnext.service" && ! is_service_active "backend.service"; then
	echo "Both erpnext.service and backend.service are inactive. Waiting for backend.service to become active..."

	# Wait for backend.service to become active
	while ! is_service_active "backend.service"; do
		sleep 5 # Check every 5 seconds
	done
	echo "backend.service is now active."
fi

# After both service are active, restore backup
echo "Restoring backup..."

SITE="frontend"
BACKUP_FILE="backup_paths.env"
restore_back_up() {
	local site=$1

	# Print the current working directory
	echo "Current working directory: $(pwd)"
	ls -la

	# Check if the backup_paths.txt file exists
	if [[ ! -f "${BASE_DIR}${BACKUP_FILE}" ]]; then
		echo "Error: ${BASE_DIR}${BACKUP_FILE} not found"
		exit 1
	fi
	# Load the backup paths fom file
	source "$BACKUP_FILE"

	# Run the restore command from bench
	podman exec backend bench --site "$site" restore "$DB_PATH" \
		--db-root-password="$MARIADB_ROOT_PASSWORD" \
		--with-public-files="$PUBLIC_ARCHIVE" \
		--with-private-files="$PRIVATE_ARCHIVE"
}
restore_back_up "$SITE"
